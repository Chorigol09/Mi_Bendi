USE DBVENTAS_WEB
GO

-- Ver el código del SP actual
PRINT 'Código del SP usp_ObtenerFacturas:'
PRINT '===================================='
GO

SELECT ROUTINE_DEFINITION 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_NAME = 'usp_ObtenerFacturas'
GO

PRINT ''
PRINT 'Ejecutando el SP:'
PRINT '===================================='
GO

EXEC usp_ObtenerFacturas
GO
