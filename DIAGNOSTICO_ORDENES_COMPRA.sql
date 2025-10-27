USE DBVENTAS_WEB
GO

PRINT '╔════════════════════════════════════════════════╗'
PRINT '║     DIAGNÓSTICO DE ÓRDENES DE COMPRA           ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

-- 1. Verificar si existe el stored procedure
PRINT '1. VERIFICANDO STORED PROCEDURE...'
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerListaCompra')
BEGIN
    PRINT '   ✓ El SP usp_ObtenerListaCompra EXISTE'
END
ELSE
BEGIN
    PRINT '   ✗ El SP usp_ObtenerListaCompra NO EXISTE - ESTE ES EL PROBLEMA!'
    PRINT '   Solución: Ejecutar el script 015_MEJORAR_CONSULTA_COMPRAS.sql'
    GOTO FIN
END

PRINT ''

-- 2. Verificar si hay órdenes de compra en la tabla
PRINT '2. VERIFICANDO DATOS EN LA TABLA...'
DECLARE @CantidadOrdenes INT
SELECT @CantidadOrdenes = COUNT(*) FROM ORDEN_COMPRA

IF @CantidadOrdenes > 0
BEGIN
    PRINT '   ✓ Hay ' + CAST(@CantidadOrdenes AS VARCHAR(10)) + ' órdenes de compra en la base de datos'
    PRINT ''
    
    -- Mostrar las últimas 5 órdenes
    PRINT '   Últimas 5 órdenes de compra:'
    SELECT TOP 5 
        IdCompra,
        FechaRegistro,
        TotalCosto,
        ISNULL(Estado, 'Sin estado') AS Estado
    FROM ORDEN_COMPRA
    ORDER BY FechaRegistro DESC
END
ELSE
BEGIN
    PRINT '   ✗ NO HAY órdenes de compra en la base de datos'
    PRINT '   Solución: Crear algunas órdenes de compra desde la aplicación'
    GOTO FIN
END

PRINT ''

-- 3. Probar el stored procedure
PRINT '3. PROBANDO EL STORED PROCEDURE...'
PRINT '   Ejecutando con parámetros amplios...'
PRINT ''

BEGIN TRY
    EXEC usp_ObtenerListaCompra 
        @FechaInicio = '2020-01-01',
        @FechaFin = '2030-12-31',
        @IdProveedor = 0,
        @IdTienda = 0
    
    PRINT ''
    PRINT '   ✓ El SP ejecuta correctamente'
END TRY
BEGIN CATCH
    PRINT '   ✗ ERROR al ejecutar el SP:'
    PRINT '   ' + ERROR_MESSAGE()
END CATCH

PRINT ''

-- 4. Verificar estructura de la tabla
PRINT '4. VERIFICANDO ESTRUCTURA DE LA TABLA...'
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('ORDEN_COMPRA') AND name = 'Estado')
BEGIN
    PRINT '   ✓ La columna Estado existe'
END
ELSE
BEGIN
    PRINT '   ✗ La columna Estado NO existe'
    PRINT '   Solución: Ejecutar ALTER TABLE para agregar la columna'
END

FIN:
PRINT ''
PRINT '╔════════════════════════════════════════════════╗'
PRINT '║           FIN DEL DIAGNÓSTICO                  ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''
PRINT 'Si todos los checks están ✓, el problema está resuelto'
PRINT 'en el código. Solo necesitas recompilar la aplicación.'
GO
