USE DBVENTAS_WEB
GO

-- =============================================
-- Script: FIX - Agregar generación automática de Remitos y Facturas
-- Descripción: Modifica usp_RegistrarCompra para generar remitos y facturas automáticamente
-- =============================================

PRINT '╔════════════════════════════════════════════════╗'
PRINT '║   FIX: GENERACIÓN AUTOMÁTICA DE REMITOS        ║'
PRINT '║        Y FACTURAS AL CREAR ORDEN DE COMPRA     ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

-- ============================================================
-- MODIFICAR SP usp_RegistrarCompra PARA GENERAR AUTOMÁTICAMENTE
-- ============================================================
PRINT '1. Modificando SP usp_RegistrarCompra...'
GO

CREATE OR ALTER PROCEDURE usp_RegistrarCompra
@Detalle XML,
@Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    
    BEGIN TRY
        BEGIN TRANSACTION

        DECLARE @compra TABLE(
            idusuario INT,
            idproveedor INT,
            idtienda INT,
            totalcosto DECIMAL(18,2)
        )
        
        DECLARE @detallecompra TABLE(
            idcompra INT,
            idproducto INT,
            cantidad INT,
            preciounidadcompra DECIMAL(18,2),
            preciounidadventa DECIMAL(18,2),
            totalcosto DECIMAL(18,2)
        )

        -- Extraer datos del XML
        INSERT INTO @compra(idusuario, idproveedor, idtienda, totalcosto)
        SELECT 
            IdUsuario = Node.Data.value('(IdUsuario)[1]','int'),
            IdProveedor = Node.Data.value('(IdProveedor)[1]','int'),
            IdTienda = Node.Data.value('(IdTienda)[1]','int'),
            TotalCosto = Node.Data.value('(TotalCosto)[1]','decimal(18,2)')
        FROM @Detalle.nodes('/DETALLE/COMPRA') Node(Data)
     
        INSERT INTO @detallecompra(idcompra, idproducto, cantidad, preciounidadcompra, preciounidadventa, totalcosto)
        SELECT 
            IdCompra = Node.Data.value('(IdCompra)[1]','int'),
            IdProducto = Node.Data.value('(IdProducto)[1]','int'),
            Cantidad = Node.Data.value('(Cantidad)[1]','int'),
            PrecioUnidadCompra = Node.Data.value('(PrecioUnidadCompra)[1]','decimal(18,2)'),
            PrecioUnidadVenta = Node.Data.value('(PrecioUnidadVenta)[1]','decimal(18,2)'),
            TotalCosto = Node.Data.value('(TotalCosto)[1]','decimal(18,2)')
        FROM @Detalle.nodes('/DETALLE/DETALLE_COMPRA/DETALLE') Node(Data)

        -- 1. Insertar en ORDEN_COMPRA
        DECLARE @IdCompra INT = 0
        DECLARE @IdProveedor INT
        DECLARE @TotalCosto DECIMAL(18,2)
        
        INSERT INTO ORDEN_COMPRA(IdUsuario, IdProveedor, IdTienda, TotalCosto, Estado)
        SELECT idusuario, idproveedor, idtienda, totalcosto, 'Abierta' FROM @compra
        
        SET @IdCompra = SCOPE_IDENTITY()
        
        -- Obtener IdProveedor y TotalCosto
        SELECT @IdProveedor = idproveedor, @TotalCosto = totalcosto FROM @compra

        -- Actualizar idcompra en detalle
        UPDATE @detallecompra SET idcompra = @IdCompra
        
        -- 2. Insertar detalle en DETALLE_ORDEN_COMPRA
        INSERT INTO DETALLE_ORDEN_COMPRA(IdOrdenCompra, IdProducto, Cantidad, PrecioUnitarioCompra, PrecioUnitarioVenta, TotalCosto)
        SELECT idcompra, idproducto, cantidad, preciounidadcompra, preciounidadventa, totalcosto FROM @detallecompra

        -- ============================================================
        -- 3. GENERAR REMITO AUTOMÁTICAMENTE
        -- ============================================================
        DECLARE @NumeroRemito VARCHAR(50)
        DECLARE @IdRemito INT
        
        -- Generar número de remito: REM-YYYYMMDD-IdOrdenCompra
        SET @NumeroRemito = 'REM-' + CONVERT(VARCHAR(8), GETDATE(), 112) + '-' + CAST(@IdCompra AS VARCHAR(10))
        
        -- Insertar Remito
        INSERT INTO REMITO(IdOrdenCompra, IdProveedor, NumeroRemito, Estado, Observaciones, FechaRegistro, Activo)
        VALUES(@IdCompra, @IdProveedor, @NumeroRemito, 'En Espera', 'Generado automáticamente', GETDATE(), 1)
        
        SET @IdRemito = SCOPE_IDENTITY()
        
        -- Copiar detalle de orden de compra a detalle de remito
        INSERT INTO DETALLE_REMITO(IdRemito, IdProducto, Cantidad)
        SELECT @IdRemito, idproducto, cantidad
        FROM @detallecompra
        
        -- ============================================================
        -- 4. GENERAR FACTURA AUTOMÁTICAMENTE
        -- ============================================================
        DECLARE @NumeroFactura VARCHAR(50)
        DECLARE @IdFactura INT
        
        -- Generar número de factura: FACT-YYYYMMDD-IdOrdenCompra
        SET @NumeroFactura = 'FACT-' + CONVERT(VARCHAR(8), GETDATE(), 112) + '-' + CAST(@IdCompra AS VARCHAR(10))
        
        -- Insertar Factura
        INSERT INTO FACTURA(IdOrdenCompra, IdProveedor, NumeroFactura, Total, Estado, Observaciones, FechaEmision, Activo)
        VALUES(@IdCompra, @IdProveedor, @NumeroFactura, @TotalCosto, 'Pendiente', 'Generada automáticamente', GETDATE(), 1)
        
        SET @IdFactura = SCOPE_IDENTITY()
        
        -- Copiar detalle de orden de compra a detalle de factura
        INSERT INTO DETALLE_FACTURA(IdFactura, IdProducto, PrecioUnitario, Cantidad, SubTotal)
        SELECT @IdFactura, idproducto, preciounidadcompra, cantidad, totalcosto
        FROM @detallecompra

        -- NO ACTUALIZAR STOCK AQUÍ - Solo registrar la orden
        -- El stock se actualiza manualmente desde Reportes > Productos por Tienda
        
        COMMIT TRANSACTION
        SET @Resultado = 1
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        SET @Resultado = 0
        
        -- Para debug
        PRINT 'Error: ' + ERROR_MESSAGE()
    END CATCH
END
GO

PRINT '   ✓ SP usp_RegistrarCompra actualizado con generación automática'
PRINT ''

-- ============================================================
-- CREAR/ACTUALIZAR SPs AUXILIARES
-- ============================================================
PRINT '2. Creando SPs auxiliares...'
GO

-- SP para obtener remitos con datos completos
CREATE OR ALTER PROCEDURE usp_ObtenerRemitos
AS
BEGIN
    SELECT 
        r.IdRemito,
        r.IdOrdenCompra,
        r.IdProveedor,
        p.RazonSocial,
        r.NumeroRemito,
        r.Estado,
        r.Observaciones,
        r.FechaRegistro,
        r.FechaRecepcion,
        r.Activo,
        -- Fecha de la orden de compra
        CONVERT(VARCHAR(10), oc.FechaRegistro, 103) AS FechaOrdenCompra,
        -- Cantidad total de productos
        ISNULL((
            SELECT SUM(dr.Cantidad)
            FROM DETALLE_REMITO dr
            WHERE dr.IdRemito = r.IdRemito
        ), 0) AS CantidadProductos,
        -- Lista de productos
        STUFF((
            SELECT ', ' + pr.Nombre + ' (' + CAST(dr.Cantidad AS VARCHAR(10)) + ')'
            FROM DETALLE_REMITO dr
            INNER JOIN PRODUCTO pr ON dr.IdProducto = pr.IdProducto
            WHERE dr.IdRemito = r.IdRemito
            FOR XML PATH('')
        ), 1, 2, '') AS Productos
    FROM REMITO r
    INNER JOIN PROVEEDOR p ON r.IdProveedor = p.IdProveedor
    INNER JOIN ORDEN_COMPRA oc ON r.IdOrdenCompra = oc.IdCompra
    WHERE r.Activo = 1
    ORDER BY r.FechaRegistro DESC
END
GO

-- SP para obtener facturas con datos completos
CREATE OR ALTER PROCEDURE usp_ObtenerFacturas
AS
BEGIN
    SELECT 
        f.IdFactura,
        f.IdOrdenCompra,
        f.IdProveedor,
        p.RazonSocial,
        f.NumeroFactura,
        f.Total,
        f.Estado,
        f.Observaciones,
        f.FechaEmision,
        f.FechaPago,
        f.Activo,
        -- Fecha de la orden de compra
        CONVERT(VARCHAR(10), oc.FechaRegistro, 103) AS FechaOrdenCompra,
        -- Cantidad total de productos
        ISNULL((
            SELECT SUM(df.Cantidad)
            FROM DETALLE_FACTURA df
            WHERE df.IdFactura = f.IdFactura
        ), 0) AS CantidadProductos,
        -- Lista de productos
        STUFF((
            SELECT ', ' + pr.Nombre + ' (' + CAST(df.Cantidad AS VARCHAR(10)) + ')'
            FROM DETALLE_FACTURA df
            INNER JOIN PRODUCTO pr ON df.IdProducto = pr.IdProducto
            WHERE df.IdFactura = f.IdFactura
            FOR XML PATH('')
        ), 1, 2, '') AS Productos
    FROM FACTURA f
    INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
    INNER JOIN ORDEN_COMPRA oc ON f.IdOrdenCompra = oc.IdCompra
    WHERE f.Activo = 1
    ORDER BY f.FechaEmision DESC
END
GO

-- SP para actualizar estado de remito
CREATE OR ALTER PROCEDURE usp_ActualizarEstadoRemito(
    @IdRemito INT,
    @Estado VARCHAR(20),
    @Resultado BIT OUTPUT
)
AS
BEGIN
    BEGIN TRY
        UPDATE REMITO
        SET Estado = @Estado,
            FechaRecepcion = CASE WHEN @Estado = 'Recibido' THEN GETDATE() ELSE FechaRecepcion END
        WHERE IdRemito = @IdRemito
        
        SET @Resultado = 1
    END TRY
    BEGIN CATCH
        SET @Resultado = 0
    END CATCH
END
GO

-- SP para actualizar estado de factura
CREATE OR ALTER PROCEDURE usp_ActualizarEstadoFactura(
    @IdFactura INT,
    @Estado VARCHAR(20),
    @Resultado BIT OUTPUT
)
AS
BEGIN
    BEGIN TRY
        UPDATE FACTURA
        SET Estado = @Estado,
            FechaPago = CASE WHEN @Estado = 'Pagado' THEN GETDATE() ELSE FechaPago END
        WHERE IdFactura = @IdFactura
        
        SET @Resultado = 1
    END TRY
    BEGIN CATCH
        SET @Resultado = 0
    END CATCH
END
GO

PRINT '   ✓ SPs auxiliares creados'
PRINT ''

-- ============================================================
-- GENERAR REMITOS Y FACTURAS PARA ÓRDENES EXISTENTES
-- ============================================================
PRINT '3. Generando Remitos y Facturas para órdenes existentes (sin remito/factura)...'
GO

-- Generar remitos para órdenes sin remito
INSERT INTO REMITO(IdOrdenCompra, IdProveedor, NumeroRemito, Estado, Observaciones, FechaRegistro, Activo)
SELECT 
    oc.IdCompra,
    oc.IdProveedor,
    'REM-' + CONVERT(VARCHAR(8), oc.FechaRegistro, 112) + '-' + CAST(oc.IdCompra AS VARCHAR(10)),
    'En Espera',
    'Generado automáticamente (recuperación)',
    oc.FechaRegistro,
    1
FROM ORDEN_COMPRA oc
WHERE NOT EXISTS (SELECT 1 FROM REMITO r WHERE r.IdOrdenCompra = oc.IdCompra)
AND oc.Activo = 1

DECLARE @RemitosGenerados INT = @@ROWCOUNT

-- Copiar detalles para nuevos remitos
INSERT INTO DETALLE_REMITO(IdRemito, IdProducto, Cantidad)
SELECT 
    r.IdRemito,
    doc.IdProducto,
    doc.Cantidad
FROM REMITO r
INNER JOIN DETALLE_ORDEN_COMPRA doc ON r.IdOrdenCompra = doc.IdOrdenCompra
WHERE NOT EXISTS (SELECT 1 FROM DETALLE_REMITO dr WHERE dr.IdRemito = r.IdRemito)

-- Generar facturas para órdenes sin factura
INSERT INTO FACTURA(IdOrdenCompra, IdProveedor, NumeroFactura, Total, Estado, Observaciones, FechaEmision, Activo)
SELECT 
    oc.IdCompra,
    oc.IdProveedor,
    'FACT-' + CONVERT(VARCHAR(8), oc.FechaRegistro, 112) + '-' + CAST(oc.IdCompra AS VARCHAR(10)),
    oc.TotalCosto,
    'Pendiente',
    'Generada automáticamente (recuperación)',
    oc.FechaRegistro,
    1
FROM ORDEN_COMPRA oc
WHERE NOT EXISTS (SELECT 1 FROM FACTURA f WHERE f.IdOrdenCompra = oc.IdCompra)
AND oc.Activo = 1

DECLARE @FacturasGeneradas INT = @@ROWCOUNT

-- Copiar detalles para nuevas facturas
INSERT INTO DETALLE_FACTURA(IdFactura, IdProducto, PrecioUnitario, Cantidad, SubTotal)
SELECT 
    f.IdFactura,
    doc.IdProducto,
    doc.PrecioUnitarioCompra,
    doc.Cantidad,
    doc.TotalCosto
FROM FACTURA f
INNER JOIN DETALLE_ORDEN_COMPRA doc ON f.IdOrdenCompra = doc.IdOrdenCompra
WHERE NOT EXISTS (SELECT 1 FROM DETALLE_FACTURA df WHERE df.IdFactura = f.IdFactura)

PRINT '   ✓ Remitos generados para órdenes existentes: ' + CAST(@RemitosGenerados AS VARCHAR(10))
PRINT '   ✓ Facturas generadas para órdenes existentes: ' + CAST(@FacturasGeneradas AS VARCHAR(10))
PRINT ''

-- ============================================================
-- VERIFICACIÓN
-- ============================================================
PRINT '4. Verificación de resultados...'
PRINT ''

DECLARE @TotalRemitos INT, @TotalFacturas INT, @TotalOrdenes INT

SELECT @TotalOrdenes = COUNT(*) FROM ORDEN_COMPRA WHERE Activo = 1
SELECT @TotalRemitos = COUNT(*) FROM REMITO WHERE Activo = 1
SELECT @TotalFacturas = COUNT(*) FROM FACTURA WHERE Activo = 1

PRINT '   📊 Estadísticas:'
PRINT '   ┌─────────────────────────────────────┐'
PRINT '   │ Órdenes de Compra: ' + RIGHT('        ' + CAST(@TotalOrdenes AS VARCHAR(10)), 8) + '   │'
PRINT '   │ Remitos activos:   ' + RIGHT('        ' + CAST(@TotalRemitos AS VARCHAR(10)), 8) + '   │'
PRINT '   │ Facturas activas:  ' + RIGHT('        ' + CAST(@TotalFacturas AS VARCHAR(10)), 8) + '   │'
PRINT '   └─────────────────────────────────────┘'
PRINT ''

IF @TotalOrdenes = @TotalRemitos AND @TotalOrdenes = @TotalFacturas
BEGIN
    PRINT '   ✅ VERIFICACIÓN EXITOSA: Todas las órdenes tienen remito y factura'
END
ELSE
BEGIN
    PRINT '   ⚠️  ADVERTENCIA: Diferencia en cantidades'
    PRINT '      Órdenes sin remito: ' + CAST(@TotalOrdenes - @TotalRemitos AS VARCHAR(10))
    PRINT '      Órdenes sin factura: ' + CAST(@TotalOrdenes - @TotalFacturas AS VARCHAR(10))
END

PRINT ''
PRINT '╔════════════════════════════════════════════════╗'
PRINT '║           ✅ FIX COMPLETADO                    ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''
PRINT '✅ Ahora al crear una Orden de Compra se generarán automáticamente:'
PRINT '   • Remito (Estado: En Espera)'
PRINT '   • Factura (Estado: Pendiente)'
PRINT ''
PRINT '📝 Próximo paso: Reiniciar la aplicación'
PRINT ''
GO
