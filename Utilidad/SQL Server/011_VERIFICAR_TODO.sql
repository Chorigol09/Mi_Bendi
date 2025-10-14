USE DBVENTAS_WEB
GO

-- =============================================
-- Script: VERIFICACIÓN COMPLETA DE TODO
-- =============================================

PRINT '========================================'
PRINT '   VERIFICACIÓN COMPLETA DEL SISTEMA'
PRINT '========================================'
PRINT ''

-- 1. Verificar que existe tabla ORDEN_COMPRA
PRINT '1. Verificando tabla ORDEN_COMPRA...'
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ORDEN_COMPRA')
    PRINT '   ✓ Tabla ORDEN_COMPRA existe'
ELSE
    PRINT '   ❌ ERROR: Tabla ORDEN_COMPRA NO existe'
PRINT ''

-- 2. Verificar campo Estado en ORDEN_COMPRA
PRINT '2. Verificando campo Estado...'
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ORDEN_COMPRA' AND COLUMN_NAME = 'Estado')
    PRINT '   ✓ Campo Estado existe'
ELSE
    PRINT '   ❌ ERROR: Campo Estado NO existe'
PRINT ''

-- 3. Verificar campo PrecioVenta en PRODUCTO
PRINT '3. Verificando campo PrecioVenta en PRODUCTO...'
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PRODUCTO' AND COLUMN_NAME = 'PrecioVenta')
BEGIN
    PRINT '   ✓ Campo PrecioVenta existe'
    
    -- Verificar si hay precios guardados
    DECLARE @CountPrecio INT
    SELECT @CountPrecio = COUNT(*) FROM PRODUCTO WHERE PrecioVenta > 0
    PRINT '   ℹ️  Productos con precio > 0: ' + CAST(@CountPrecio AS VARCHAR(10))
END
ELSE
    PRINT '   ❌ ERROR: Campo PrecioVenta NO existe'
PRINT ''

-- 4. Verificar tablas REMITO y FACTURA
PRINT '4. Verificando tablas REMITO y FACTURA...'
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'REMITO')
    PRINT '   ✓ Tabla REMITO existe'
ELSE
    PRINT '   ❌ ERROR: Tabla REMITO NO existe'

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'FACTURA')
    PRINT '   ✓ Tabla FACTURA existe'
ELSE
    PRINT '   ❌ ERROR: Tabla FACTURA NO existe'
PRINT ''

-- 5. Verificar stored procedures
PRINT '5. Verificando stored procedures...'
DECLARE @spCount INT = 0

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_RegistrarCompra')
BEGIN
    PRINT '   ✓ usp_RegistrarCompra existe'
    SET @spCount = @spCount + 1
END
ELSE
    PRINT '   ❌ ERROR: usp_RegistrarCompra NO existe'

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_ObtenerReporteProductos')
BEGIN
    PRINT '   ✓ usp_ObtenerReporteProductos existe'
    SET @spCount = @spCount + 1
END
ELSE
    PRINT '   ❌ ERROR: usp_ObtenerReporteProductos NO existe'

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_ObtenerRemitos')
BEGIN
    PRINT '   ✓ usp_ObtenerRemitos existe'
    SET @spCount = @spCount + 1
END
ELSE
    PRINT '   ❌ ERROR: usp_ObtenerRemitos NO existe'

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_ObtenerFacturas')
BEGIN
    PRINT '   ✓ usp_ObtenerFacturas existe'
    SET @spCount = @spCount + 1
END
ELSE
    PRINT '   ❌ ERROR: usp_ObtenerFacturas NO existe'

PRINT ''
PRINT '   Total SPs encontrados: ' + CAST(@spCount AS VARCHAR(10)) + '/4'
PRINT ''

-- 6. Verificar menús en SUBMENU
PRINT '6. Verificando menús de Remitos y Facturas...'
IF EXISTS (SELECT * FROM SUBMENU WHERE Nombre = 'Remitos')
    PRINT '   ✓ Menú Remitos existe'
ELSE
    PRINT '   ❌ ERROR: Menú Remitos NO existe'

IF EXISTS (SELECT * FROM SUBMENU WHERE Nombre = 'Facturas')
    PRINT '   ✓ Menú Facturas existe'
ELSE
    PRINT '   ❌ ERROR: Menú Facturas NO existe'
PRINT ''

-- 7. Verificar controladores en SUBMENU
PRINT '7. Verificando nombres de controladores...'
SELECT 
    sm.Nombre AS SubMenu,
    sm.Controlador,
    sm.Vista,
    CASE 
        WHEN sm.Controlador = 'Reportes' THEN '✓'
        WHEN sm.Controlador = 'Remito' THEN '✓'
        WHEN sm.Controlador = 'Factura' THEN '✓'
        ELSE '?'
    END AS Estado
FROM SUBMENU sm
WHERE sm.Nombre IN ('Productos por tienda', 'Ventas', 'Remitos', 'Facturas')
ORDER BY sm.Nombre
PRINT ''

-- 8. Verificar permisos
PRINT '8. Verificando permisos para Administrador (IdRol=1)...'
DECLARE @RemitoPerm INT, @FacturaPerm INT
SELECT @RemitoPerm = COUNT(*) FROM PERMISOS p
INNER JOIN SUBMENU sm ON p.IdSubMenu = sm.IdSubMenu
WHERE p.IdRol = 1 AND sm.Nombre = 'Remitos' AND p.Activo = 1

SELECT @FacturaPerm = COUNT(*) FROM PERMISOS p
INNER JOIN SUBMENU sm ON p.IdSubMenu = sm.IdSubMenu
WHERE p.IdRol = 1 AND sm.Nombre = 'Facturas' AND p.Activo = 1

IF @RemitoPerm > 0
    PRINT '   ✓ Permiso Remitos existe para Admin'
ELSE
    PRINT '   ❌ ERROR: Permiso Remitos NO existe para Admin'

IF @FacturaPerm > 0
    PRINT '   ✓ Permiso Facturas existe para Admin'
ELSE
    PRINT '   ❌ ERROR: Permiso Facturas NO existe para Admin'
PRINT ''

-- 9. Test de INSERT en PRODUCTO.PrecioVenta
PRINT '9. Testeando UPDATE de PrecioVenta...'
BEGIN TRY
    DECLARE @TestIdProducto INT
    SELECT TOP 1 @TestIdProducto = IdProducto FROM PRODUCTO
    
    UPDATE PRODUCTO SET PrecioVenta = 999.99 WHERE IdProducto = @TestIdProducto
    
    DECLARE @TestPrecio DECIMAL(18,2)
    SELECT @TestPrecio = PrecioVenta FROM PRODUCTO WHERE IdProducto = @TestIdProducto
    
    IF @TestPrecio = 999.99
    BEGIN
        PRINT '   ✓ UPDATE funciona correctamente'
        -- Restaurar
        UPDATE PRODUCTO SET PrecioVenta = 0 WHERE IdProducto = @TestIdProducto
    END
    ELSE
        PRINT '   ❌ ERROR: UPDATE no funciona'
END TRY
BEGIN CATCH
    PRINT '   ❌ ERROR: ' + ERROR_MESSAGE()
END CATCH
PRINT ''

-- RESUMEN FINAL
PRINT ''
PRINT '========================================'
PRINT '   RESUMEN DE VERIFICACIÓN'
PRINT '========================================'
PRINT ''

-- Contar datos
DECLARE @CountOC INT, @CountRemito INT, @CountFactura INT, @CountProducto INT
SELECT @CountOC = COUNT(*) FROM ORDEN_COMPRA
SELECT @CountRemito = ISNULL((SELECT COUNT(*) FROM REMITO), 0)
SELECT @CountFactura = ISNULL((SELECT COUNT(*) FROM FACTURA), 0)
SELECT @CountProducto = COUNT(*) FROM PRODUCTO

PRINT 'DATOS EN BASE DE DATOS:'
PRINT '  - Órdenes de Compra: ' + CAST(@CountOC AS VARCHAR(10))
PRINT '  - Remitos: ' + CAST(@CountRemito AS VARCHAR(10))
PRINT '  - Facturas: ' + CAST(@CountFactura AS VARCHAR(10))
PRINT '  - Productos: ' + CAST(@CountProducto AS VARCHAR(10))
PRINT ''

IF @CountOC = 0
    PRINT '⚠️  No hay órdenes de compra. Ejecuta: 007_SEED_DATOS_PRUEBA_COMPLETO.sql'
PRINT ''

-- Verificar si el SP de registrar compra usa ORDEN_COMPRA
PRINT 'VERIFICANDO SP usp_RegistrarCompra:'
DECLARE @SPDefinition NVARCHAR(MAX)
SELECT @SPDefinition = OBJECT_DEFINITION(OBJECT_ID('usp_RegistrarCompra'))

IF @SPDefinition LIKE '%ORDEN_COMPRA%'
    PRINT '  ✓ SP usa tabla ORDEN_COMPRA (correcto)'
ELSE
    PRINT '  ❌ SP usa tabla COMPRA (incorrecto) - Ejecuta: 010_CORREGIR_TODO_FINAL.sql'

IF @SPDefinition LIKE '%Estado%'
    PRINT '  ✓ SP incluye campo Estado (correcto)'
ELSE
    PRINT '  ❌ SP NO incluye campo Estado - Ejecuta: 010_CORREGIR_TODO_FINAL.sql'
PRINT ''

PRINT '========================================'
PRINT '   FIN DE VERIFICACIÓN'
PRINT '========================================'
GO
