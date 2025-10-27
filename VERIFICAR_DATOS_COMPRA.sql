USE DBVENTAS_WEB
GO

PRINT '==== VERIFICACIÓN RÁPIDA DE DATOS ===='
PRINT ''

-- Contar órdenes
DECLARE @TotalOrdenes INT
SELECT @TotalOrdenes = COUNT(*) FROM ORDEN_COMPRA
PRINT 'Total de órdenes de compra: ' + CAST(@TotalOrdenes AS VARCHAR(10))
PRINT ''

-- Ver las últimas órdenes
IF @TotalOrdenes > 0
BEGIN
    PRINT 'Últimas 5 órdenes:'
    SELECT TOP 5 
        IdCompra,
        FechaRegistro,
        TotalCosto,
        IdProveedor,
        IdTienda
    FROM ORDEN_COMPRA 
    ORDER BY FechaRegistro DESC
END
ELSE
BEGIN
    PRINT 'NO HAY ÓRDENES DE COMPRA EN LA BASE DE DATOS'
END

PRINT ''
PRINT '==== VERIFICAR STORED PROCEDURE ===='

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerListaCompra')
BEGIN
    PRINT '✓ SP usp_ObtenerListaCompra existe'
    PRINT ''
    PRINT 'Probando el SP...'
    PRINT ''
    
    EXEC usp_ObtenerListaCompra 
        @FechaInicio = '2020-01-01',
        @FechaFin = '2030-12-31',
        @IdProveedor = 0,
        @IdTienda = 0
END
ELSE
BEGIN
    PRINT '✗ SP usp_ObtenerListaCompra NO EXISTE'
    PRINT 'Ejecutar: 015_MEJORAR_CONSULTA_COMPRAS.sql'
END
GO
