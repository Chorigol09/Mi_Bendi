USE DBVENTAS_WEB
GO

-- =============================================
-- Script: CORRECCIÓN FINAL DE TODOS LOS PROBLEMAS
-- =============================================

PRINT '========================================'
PRINT '   CORRIGIENDO TODOS LOS PROBLEMAS'
PRINT '========================================'
PRINT ''

-- ============================================
-- PROBLEMA 1: Stored Procedure de Compra usa COMPRA en lugar de ORDEN_COMPRA
-- ============================================

PRINT '1. Corrigiendo stored procedure usp_RegistrarCompra...'
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

        -- Insertar en ORDEN_COMPRA (NO en COMPRA)
        DECLARE @IdCompra INT = 0
        
        INSERT INTO ORDEN_COMPRA(IdUsuario, IdProveedor, IdTienda, TotalCosto, Estado)
        SELECT idusuario, idproveedor, idtienda, totalcosto, 'Abierta' FROM @compra
        
        SET @IdCompra = SCOPE_IDENTITY()

        -- Actualizar idcompra en detalle
        UPDATE @detallecompra SET idcompra = @IdCompra
        
        -- Insertar detalle en DETALLE_ORDEN_COMPRA (NO en DETALLE_COMPRA)
        INSERT INTO DETALLE_ORDEN_COMPRA(IdOrdenCompra, IdProducto, Cantidad, PrecioUnitarioCompra, PrecioUnitarioVenta, TotalCosto)
        SELECT idcompra, idproducto, cantidad, preciounidadcompra, preciounidadventa, totalcosto FROM @detallecompra

        -- NO ACTUALIZAR STOCK AQUÍ - Solo registrar la orden
        -- El stock se actualiza manualmente desde Reportes > Productos por Tienda
        
        COMMIT TRANSACTION
        SET @Resultado = 1
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        SET @Resultado = 0
    END CATCH
END
GO

PRINT '   ✓ usp_RegistrarCompra corregido (usa ORDEN_COMPRA)'
PRINT ''

-- ============================================
-- PROBLEMA 2: Stored Procedure de Reporte no trae PrecioVenta
-- ============================================

PRINT '2. Corrigiendo stored procedure usp_ObtenerReporteProductos...'
GO

CREATE OR ALTER PROCEDURE usp_ObtenerReporteProductos
@idtienda INT,
@codigoproducto VARCHAR(100)
AS
BEGIN
    SELECT 
        t.RUC AS RucTienda,
        t.Nombre AS NombreTienda,
        t.Direccion AS DireccionTienda,
        p.Codigo AS CodigoProducto,
        p.Nombre AS NombreProducto,
        p.Descripcion AS DescripcionProducto,
        pt.Stock AS StockenTienda,
        pt.PrecioUnidadCompra,
        pt.PrecioUnidadVenta,
        ISNULL(p.PrecioVenta, 0) AS PrecioVenta,  -- ← AGREGAR ESTO
        p.IdProducto,
        t.IdTienda
    FROM PRODUCTO_TIENDA pt
    INNER JOIN PRODUCTO p ON pt.IdProducto = p.IdProducto
    INNER JOIN TIENDA t ON pt.IdTienda = t.IdTienda
    WHERE 
        (@idtienda = 0 OR pt.IdTienda = @idtienda)
        AND (@codigoproducto = '' OR p.Codigo LIKE '%' + @codigoproducto + '%')
        AND pt.Activo = 1
        AND p.Activo = 1
    ORDER BY t.Nombre, p.Nombre
END
GO

PRINT '   ✓ usp_ObtenerReporteProductos corregido (incluye PrecioVenta)'
PRINT ''

-- ============================================
-- PROBLEMA 3: Stored Procedure ActualizarStock
-- ============================================

PRINT '3. Creando stored procedure usp_ActualizarStock...'
GO

CREATE OR ALTER PROCEDURE usp_ActualizarStock
    @IdProducto INT,
    @IdTienda INT,
    @NuevoStock INT,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    
    BEGIN TRY
        UPDATE PRODUCTO_TIENDA 
        SET Stock = @NuevoStock
        WHERE IdProducto = @IdProducto 
          AND IdTienda = @IdTienda
        
        IF @@ROWCOUNT > 0
            SET @Resultado = 1
    END TRY
    BEGIN CATCH
        SET @Resultado = 0
    END CATCH
END
GO

PRINT '   ✓ usp_ActualizarStock creado'
PRINT ''

-- ============================================
-- PROBLEMA 4: Verificar que tabla PRODUCTO tiene PrecioVenta
-- ============================================

PRINT '4. Verificando campo PrecioVenta en PRODUCTO...'

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PRODUCTO' AND COLUMN_NAME = 'PrecioVenta')
BEGIN
    ALTER TABLE PRODUCTO ADD PrecioVenta DECIMAL(18,2) DEFAULT 0
    PRINT '   ✓ Campo PrecioVenta agregado'
END
ELSE
BEGIN
    PRINT '   ✓ Campo PrecioVenta ya existe'
END
PRINT ''

-- ============================================
-- PROBLEMA 5: Corregir usp_ObtenerDetalleCompra para XML correcto
-- ============================================

PRINT '5. Corrigiendo usp_ObtenerDetalleCompra...'
GO

CREATE OR ALTER PROCEDURE usp_ObtenerDetalleCompra
@IdCompra INT
AS
BEGIN
    SELECT  
        RIGHT('000000' + CONVERT(VARCHAR(MAX), oc.IdCompra), 6) AS Codigo,
        CONVERT(CHAR(10), oc.FechaRegistro, 103) AS FechaCompra,
        CONVERT(DECIMAL(10,2), oc.TotalCosto) AS TotalCosto,
        
        (SELECT p.RUC, p.RazonSocial 
         FROM PROVEEDOR p
         WHERE p.IdProveedor = oc.IdProveedor
         FOR XML PATH (''), TYPE) AS 'DETALLE_PROVEEDOR',
        
        (SELECT t.RUC, t.Nombre, t.Direccion 
         FROM TIENDA t
         WHERE t.IdTienda = oc.IdTienda
         FOR XML PATH (''), TYPE) AS 'DETALLE_TIENDA',
        
        (SELECT 
            CONVERT(INT, doc.Cantidad) AS Cantidad,
            CONCAT(pr.Nombre, ' - ', pr.Descripcion) AS NombreProducto,
            CONVERT(DECIMAL(10,2), doc.PrecioUnitarioCompra) AS PrecioUnitarioCompra,
            CONVERT(DECIMAL(10,2), doc.TotalCosto) AS TotalCosto
         FROM DETALLE_ORDEN_COMPRA doc
         INNER JOIN PRODUCTO pr ON doc.IdProducto = pr.IdProducto
         WHERE doc.IdOrdenCompra = oc.IdCompra
         FOR XML PATH('PRODUCTO'), TYPE) AS 'DETALLE_PRODUCTO'
        
    FROM ORDEN_COMPRA oc
    WHERE oc.IdCompra = @IdCompra
    FOR XML PATH('DETALLE_COMPRA')
END
GO

PRINT '   ✓ usp_ObtenerDetalleCompra corregido'
PRINT ''

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

PRINT ''
PRINT '========================================'
PRINT '   VERIFICANDO CORRECCIONES'
PRINT '========================================'
PRINT ''

-- Verificar stored procedures
SELECT 
    ROUTINE_NAME AS 'Procedimiento Corregido',
    LAST_ALTERED AS 'Última Modificación'
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
  AND ROUTINE_NAME IN (
      'usp_RegistrarCompra',
      'usp_ObtenerReporteProductos',
      'usp_ActualizarStock',
      'usp_ObtenerDetalleCompra'
  )
ORDER BY ROUTINE_NAME

PRINT ''
PRINT '========================================'
PRINT '   ✅ CORRECCIONES COMPLETADAS'
PRINT '========================================'
PRINT ''
PRINT '📝 PROBLEMAS RESUELTOS:'
PRINT '  ✓ 1. Registrar Orden de Compra (usa ORDEN_COMPRA)'
PRINT '  ✓ 2. Reporte trae PrecioVenta correctamente'
PRINT '  ✓ 3. Actualización de Stock funciona'
PRINT '  ✓ 4. Campo PrecioVenta en PRODUCTO'
PRINT '  ✓ 5. Detalle de compra con XML correcto'
PRINT ''
GO
