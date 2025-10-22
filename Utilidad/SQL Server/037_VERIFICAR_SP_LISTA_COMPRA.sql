USE DBVENTAS_WEB
GO

PRINT '=========================================='
PRINT 'VERIFICAR SP usp_ObtenerListaCompra'
PRINT '=========================================='
PRINT ''

-- Mostrar parámetros
PRINT 'Parámetros del SP:'
SELECT 
    pm.name AS Parametro,
    TYPE_NAME(pm.user_type_id) AS Tipo
FROM sys.procedures p
INNER JOIN sys.parameters pm ON p.object_id = pm.object_id
WHERE p.name = 'usp_ObtenerListaCompra'
ORDER BY pm.parameter_id

PRINT ''
PRINT 'Ejecutando el SP con parámetros...'
PRINT ''

-- Ejecutar el SP con parámetros
EXEC usp_ObtenerListaCompra 
    @FechaInicio = '2024-01-01',
    @FechaFin = '2025-12-31',
    @IdProveedor = 0,
    @IdTienda = 0

PRINT ''
PRINT '=========================================='
PRINT 'FIN'
PRINT '=========================================='
GO
