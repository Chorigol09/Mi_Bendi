USE DBVENTAS_WEB
GO

-- =============================================
-- Script: Generar Remitos y Facturas Automáticamente
-- Descripción: Modificar SP de registro de compras y actualizar SPs de consulta
-- =============================================

PRINT '╔════════════════════════════════════════════════╗'
PRINT '║  CONFIGURAR GENERACIÓN AUTOMÁTICA DE REMITOS  ║'
PRINT '║           Y FACTURAS EN ORDEN DE COMPRA        ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

-- ============================================================
-- 1. ACTUALIZAR SP DE REGISTRAR ORDEN DE COMPRA
-- ============================================================
PRINT '1. Actualizando SP usp_RegistrarOrdenCompra...'
PRINT '   - Agregar generación automática de Remito'
PRINT '   - Agregar generación automática de Factura'
GO

CREATE OR ALTER PROCEDURE usp_RegistrarOrdenCompra(
    @IdProveedor INT,
    @IdTienda INT,
    @TotalCosto DECIMAL(18,2),
    @DetalleOrdenCompra NVARCHAR(MAX),
    @Resultado BIT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
)
AS
BEGIN
    BEGIN TRY
        DECLARE @IdOrdenCompra INT = 0
        DECLARE @NumeroRemito VARCHAR(50)
        DECLARE @NumeroFactura VARCHAR(50)
        
        BEGIN TRANSACTION
        
        -- 1. Registrar Orden de Compra
        INSERT INTO ORDEN_COMPRA(IdProveedor, IdTienda, TotalCosto, Estado, FechaRegistro, Activo)
        VALUES(@IdProveedor, @IdTienda, @TotalCosto, 'Abierta', GETDATE(), 1)
        
        SET @IdOrdenCompra = SCOPE_IDENTITY()
        
        -- 2. Registrar Detalle de Orden de Compra
        INSERT INTO DETALLE_ORDEN_COMPRA(IdOrdenCompra, IdProducto, Cantidad, PrecioUnitarioCompra, PrecioUnitarioVenta, TotalCosto)
        SELECT @IdOrdenCompra, IdProducto, Cantidad, PrecioUnidadCompra, PrecioUnidadVenta, TotalCosto FROM OPENJSON(@DetalleOrdenCompra)
        WITH(
            IdProducto INT '$.IdProducto',
            PrecioUnidadCompra DECIMAL(18,2) '$.PrecioUnidadCompra',
            PrecioUnidadVenta DECIMAL(18,2) '$.PrecioUnidadVenta',
            Cantidad INT '$.Cantidad',
            TotalCosto DECIMAL(18,2) '$.TotalCosto'
        )
        
        -- 3. GENERAR REMITO AUTOMÁTICAMENTE
        -- Generar número de remito: REM-YYYYMMDD-IdOrdenCompra
        SET @NumeroRemito = 'REM-' + CONVERT(VARCHAR(8), GETDATE(), 112) + '-' + CAST(@IdOrdenCompra AS VARCHAR(10))
        
        -- Insertar Remito
        INSERT INTO REMITO(IdOrdenCompra, IdProveedor, NumeroRemito, Estado, Observaciones, FechaRegistro, Activo)
        VALUES(@IdOrdenCompra, @IdProveedor, @NumeroRemito, 'En Espera', 'Generado automáticamente', GETDATE(), 1)
        
        DECLARE @IdRemito INT = SCOPE_IDENTITY()
        
        -- Copiar detalle de orden de compra a detalle de remito
        INSERT INTO DETALLE_REMITO(IdRemito, IdProducto, Cantidad)
        SELECT @IdRemito, IdProducto, Cantidad
        FROM DETALLE_ORDEN_COMPRA
        WHERE IdOrdenCompra = @IdOrdenCompra
        
        -- 4. GENERAR FACTURA AUTOMÁTICAMENTE
        -- Generar número de factura: FACT-YYYYMMDD-IdOrdenCompra
        SET @NumeroFactura = 'FACT-' + CONVERT(VARCHAR(8), GETDATE(), 112) + '-' + CAST(@IdOrdenCompra AS VARCHAR(10))
        
        -- Insertar Factura
        INSERT INTO FACTURA(IdOrdenCompra, IdProveedor, NumeroFactura, Total, Estado, Observaciones, FechaEmision, Activo)
        VALUES(@IdOrdenCompra, @IdProveedor, @NumeroFactura, @TotalCosto, 'Pendiente', 'Generada automáticamente', GETDATE(), 1)
        
        DECLARE @IdFactura INT = SCOPE_IDENTITY()
        
        -- Copiar detalle de orden de compra a detalle de factura
        INSERT INTO DETALLE_FACTURA(IdFactura, IdProducto, PrecioUnitario, Cantidad, SubTotal)
        SELECT @IdFactura, IdProducto, PrecioUnitarioCompra, Cantidad, TotalCosto
        FROM DETALLE_ORDEN_COMPRA
        WHERE IdOrdenCompra = @IdOrdenCompra
        
        COMMIT TRANSACTION
        
        SET @Resultado = 1
        SET @Mensaje = 'Orden de Compra registrada correctamente. Remito: ' + @NumeroRemito + ', Factura: ' + @NumeroFactura
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SET @Resultado = 0
        SET @Mensaje = ERROR_MESSAGE()
    END CATCH
END
GO

PRINT '   ✓ SP usp_RegistrarOrdenCompra actualizado'
PRINT ''

-- ============================================================
-- 2. ACTUALIZAR SP OBTENER REMITOS CON DATOS DE ORDEN
-- ============================================================
PRINT '2. Actualizando SP usp_ObtenerRemitos...'
GO

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

PRINT '   ✓ SP usp_ObtenerRemitos actualizado'
PRINT ''

-- ============================================================
-- 3. ACTUALIZAR SP OBTENER FACTURAS CON DATOS DE ORDEN
-- ============================================================
PRINT '3. Actualizando SP usp_ObtenerFacturas...'
GO

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

PRINT '   ✓ SP usp_ObtenerFacturas actualizado'
PRINT ''

-- ============================================================
-- 4. CREAR SP PARA ACTUALIZAR ESTADO DE REMITO
-- ============================================================
PRINT '4. Creando SP usp_ActualizarEstadoRemito...'
GO

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

PRINT '   ✓ SP usp_ActualizarEstadoRemito creado'
PRINT ''

-- ============================================================
-- 5. CREAR SP PARA ACTUALIZAR ESTADO DE FACTURA
-- ============================================================
PRINT '5. Creando SP usp_ActualizarEstadoFactura...'
GO

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

PRINT '   ✓ SP usp_ActualizarEstadoFactura creado'
PRINT ''

-- ============================================================
-- 6. GENERAR REMITOS Y FACTURAS PARA ÓRDENES EXISTENTES
-- ============================================================
PRINT '6. Generando Remitos y Facturas para órdenes existentes...'
GO

-- Generar remitos para órdenes sin remito
INSERT INTO REMITO(IdOrdenCompra, IdProveedor, NumeroRemito, Estado, Observaciones, FechaRegistro, Activo)
SELECT 
    oc.IdCompra,
    oc.IdProveedor,
    'REM-' + CONVERT(VARCHAR(8), oc.FechaRegistro, 112) + '-' + CAST(oc.IdCompra AS VARCHAR(10)),
    'En Espera',
    'Generado automáticamente',
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
    'Generada automáticamente',
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

PRINT '   ✓ Remitos generados: ' + CAST(@RemitosGenerados AS VARCHAR(10))
PRINT '   ✓ Facturas generadas: ' + CAST(@FacturasGeneradas AS VARCHAR(10))
PRINT ''

-- ============================================================
-- 7. VERIFICACIÓN
-- ============================================================
PRINT '7. Verificación de resultados...'
PRINT ''

DECLARE @TotalRemitos INT, @TotalFacturas INT, @TotalOrdenes INT

SELECT @TotalOrdenes = COUNT(*) FROM ORDEN_COMPRA WHERE Activo = 1
SELECT @TotalRemitos = COUNT(*) FROM REMITO WHERE Activo = 1
SELECT @TotalFacturas = COUNT(*) FROM FACTURA WHERE Activo = 1

PRINT '   Órdenes de Compra activas: ' + CAST(@TotalOrdenes AS VARCHAR(10))
PRINT '   Remitos activos: ' + CAST(@TotalRemitos AS VARCHAR(10))
PRINT '   Facturas activas: ' + CAST(@TotalFacturas AS VARCHAR(10))
PRINT ''

IF @TotalOrdenes = @TotalRemitos AND @TotalOrdenes = @TotalFacturas
BEGIN
    PRINT '   ✓ VERIFICACIÓN EXITOSA: Todas las órdenes tienen remito y factura'
END
ELSE
BEGIN
    PRINT '   ⚠️  ADVERTENCIA: No todas las órdenes tienen remito y factura'
END

PRINT ''
PRINT '╔════════════════════════════════════════════════╗'
PRINT '║        ✅ CONFIGURACIÓN COMPLETADA             ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''
PRINT 'Ahora al registrar una Orden de Compra se generarán automáticamente:'
PRINT '  • Remito (Estado: En Espera)'
PRINT '  • Factura (Estado: Pendiente)'
PRINT ''
GO
