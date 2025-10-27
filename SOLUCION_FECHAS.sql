USE DBVENTAS_WEB
GO

PRINT '=========================================='
PRINT 'VERIFICAR FECHAS DE ÓRDENES DE COMPRA'
PRINT '=========================================='
PRINT ''

-- Ver las fechas reales de las órdenes
PRINT 'Fechas de las órdenes de compra en la base de datos:'
PRINT ''
SELECT 
    IdCompra,
    CONVERT(DATE, FechaRegistro) AS Fecha,
    CONVERT(VARCHAR(10), FechaRegistro, 103) AS FechaFormateada,
    TotalCosto,
    Estado
FROM ORDEN_COMPRA
ORDER BY FechaRegistro DESC

PRINT ''
PRINT 'Probando el SP con diferentes rangos de fechas...'
PRINT ''

-- Probar con rango amplio
PRINT '1. Probando con fechas del 2025-10-01 al 2025-10-31:'
EXEC usp_ObtenerListaCompra 
    @FechaInicio = '2025-10-01',
    @FechaFin = '2025-10-31',
    @IdProveedor = 0,
    @IdTienda = 0

PRINT ''
PRINT '2. Probando con fechas del 2025-01-01 al 2025-12-31:'
EXEC usp_ObtenerListaCompra 
    @FechaInicio = '2025-01-01',
    @FechaFin = '2025-12-31',
    @IdProveedor = 0,
    @IdTienda = 0

GO
