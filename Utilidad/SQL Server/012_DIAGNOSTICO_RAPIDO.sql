USE DBVENTAS_WEB
GO

-- =============================================
-- DIAGNÓSTICO RÁPIDO DE PROBLEMAS
-- =============================================

PRINT '╔════════════════════════════════════════╗'
PRINT '║     DIAGNÓSTICO RÁPIDO DEL SISTEMA     ║'
PRINT '╚════════════════════════════════════════╝'
PRINT ''

-- Problema 1: ¿Puede registrar orden de compra?
PRINT '❓ PROBLEMA 1: No puede registrar Orden de Compra'
PRINT '------------------------------------------------'

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ORDEN_COMPRA')
    PRINT '✓ Tabla ORDEN_COMPRA existe'
ELSE
BEGIN
    PRINT '❌ Tabla ORDEN_COMPRA NO existe'
    PRINT '   SOLUCIÓN: Ejecutar 000_EJECUTAR_TODO.sql'
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_RegistrarCompra')
BEGIN
    DECLARE @SP NVARCHAR(MAX)
    SELECT @SP = OBJECT_DEFINITION(OBJECT_ID('usp_RegistrarCompra'))
    
    IF @SP LIKE '%ORDEN_COMPRA%'
        PRINT '✓ SP usa ORDEN_COMPRA (correcto)'
    ELSE
    BEGIN
        PRINT '❌ SP usa COMPRA (incorrecto)'
        PRINT '   SOLUCIÓN: Ejecutar 010_CORREGIR_TODO_FINAL.sql'
    END
    
    IF @SP LIKE '%Estado%'
        PRINT '✓ SP maneja campo Estado'
    ELSE
    BEGIN
        PRINT '❌ SP NO maneja campo Estado'
        PRINT '   SOLUCIÓN: Ejecutar 010_CORREGIR_TODO_FINAL.sql'
    END
END
ELSE
BEGIN
    PRINT '❌ SP usp_RegistrarCompra NO existe'
    PRINT '   SOLUCIÓN: Ejecutar 009_STORED_PROCEDURES_COMPLETO.sql'
END
PRINT ''

-- Problema 2 y 3: ¿Puede entrar a Remitos/Facturas?
PRINT '❓ PROBLEMA 2 y 3: Error 404 en Remitos y Facturas'
PRINT '----------------------------------------------------'

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'REMITO')
    PRINT '✓ Tabla REMITO existe'
ELSE
BEGIN
    PRINT '❌ Tabla REMITO NO existe'
    PRINT '   SOLUCIÓN: Ejecutar 000_EJECUTAR_TODO.sql'
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'FACTURA')
    PRINT '✓ Tabla FACTURA existe'
ELSE
BEGIN
    PRINT '❌ Tabla FACTURA NO existe'
    PRINT '   SOLUCIÓN: Ejecutar 000_EJECUTAR_TODO.sql'
END

IF EXISTS (SELECT * FROM SUBMENU WHERE Nombre = 'Remitos')
    PRINT '✓ Menú Remitos existe en BD'
ELSE
BEGIN
    PRINT '❌ Menú Remitos NO existe'
    PRINT '   SOLUCIÓN: Ejecutar 000_EJECUTAR_TODO.sql'
END

IF EXISTS (SELECT * FROM SUBMENU WHERE Nombre = 'Facturas')
    PRINT '✓ Menú Facturas existe en BD'
ELSE
BEGIN
    PRINT '❌ Menú Facturas NO existe'
    PRINT '   SOLUCIÓN: Ejecutar 000_EJECUTAR_TODO.sql'
END

PRINT '⚠️  Si los menús existen pero sigue dando 404:'
PRINT '   PROBLEMA: El proyecto NO está compilado'
PRINT '   SOLUCIÓN: Ejecutar RECOMPILAR_Y_EJECUTAR.bat'
PRINT '            O en Visual Studio: Build > Rebuild Solution'
PRINT ''

-- Problema 4: ¿Se guarda el precio de venta?
PRINT '❓ PROBLEMA 4: Precio de venta vuelve a 0'
PRINT '-----------------------------------------'

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PRODUCTO' AND COLUMN_NAME = 'PrecioVenta')
BEGIN
    PRINT '✓ Campo PrecioVenta existe en PRODUCTO'
    
    -- Test de UPDATE
    DECLARE @TestId INT, @TestPrecio DECIMAL(18,2)
    SELECT TOP 1 @TestId = IdProducto FROM PRODUCTO
    
    UPDATE PRODUCTO SET PrecioVenta = 99999 WHERE IdProducto = @TestId
    SELECT @TestPrecio = PrecioVenta FROM PRODUCTO WHERE IdProducto = @TestId
    
    IF @TestPrecio = 99999
    BEGIN
        PRINT '✓ UPDATE de PrecioVenta funciona'
        UPDATE PRODUCTO SET PrecioVenta = 0 WHERE IdProducto = @TestId
    END
    ELSE
    BEGIN
        PRINT '❌ UPDATE de PrecioVenta NO funciona'
        PRINT '   PROBLEMA: Permisos o trigger bloqueando'
    END
END
ELSE
BEGIN
    PRINT '❌ Campo PrecioVenta NO existe'
    PRINT '   SOLUCIÓN: Ejecutar 010_CORREGIR_TODO_FINAL.sql'
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_ObtenerReporteProductos')
BEGIN
    DECLARE @SP2 NVARCHAR(MAX)
    SELECT @SP2 = OBJECT_DEFINITION(OBJECT_ID('usp_ObtenerReporteProductos'))
    
    IF @SP2 LIKE '%PrecioVenta%'
        PRINT '✓ SP trae campo PrecioVenta'
    ELSE
    BEGIN
        PRINT '❌ SP NO trae campo PrecioVenta'
        PRINT '   SOLUCIÓN: Ejecutar 010_CORREGIR_TODO_FINAL.sql'
    END
END
ELSE
BEGIN
    PRINT '❌ SP usp_ObtenerReporteProductos NO existe'
    PRINT '   SOLUCIÓN: Ejecutar 009_STORED_PROCEDURES_COMPLETO.sql'
END
PRINT ''

-- Resumen
PRINT ''
PRINT '╔════════════════════════════════════════╗'
PRINT '║            RESUMEN RÁPIDO              ║'
PRINT '╚════════════════════════════════════════╝'
PRINT ''

DECLARE @Problemas INT = 0

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ORDEN_COMPRA')
    SET @Problemas = @Problemas + 1

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'REMITO')
    SET @Problemas = @Problemas + 1

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'FACTURA')
    SET @Problemas = @Problemas + 1

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PRODUCTO' AND COLUMN_NAME = 'PrecioVenta')
    SET @Problemas = @Problemas + 1

IF @Problemas = 0
BEGIN
    PRINT '✅ BASE DE DATOS: TODO CORRECTO'
    PRINT ''
    PRINT 'Si sigues con problemas:'
    PRINT '  1. Verifica que el proyecto esté COMPILADO'
    PRINT '  2. Ejecuta: RECOMPILAR_Y_EJECUTAR.bat'
    PRINT '  3. O en Visual Studio: Build > Rebuild Solution'
END
ELSE
BEGIN
    PRINT '❌ HAY ' + CAST(@Problemas AS VARCHAR(5)) + ' PROBLEMA(S) EN LA BASE DE DATOS'
    PRINT ''
    PRINT 'SOLUCIÓN:'
    PRINT '  1. Ejecutar: 000_EJECUTAR_TODO.sql'
    PRINT '  2. Ejecutar: 009_STORED_PROCEDURES_COMPLETO.sql'
    PRINT '  3. Ejecutar: 010_CORREGIR_TODO_FINAL.sql'
    PRINT '  4. Ejecutar: 007_SEED_DATOS_PRUEBA_COMPLETO.sql'
    PRINT '  5. Ejecutar: RECOMPILAR_Y_EJECUTAR.bat'
END

PRINT ''
PRINT '════════════════════════════════════════'
GO
