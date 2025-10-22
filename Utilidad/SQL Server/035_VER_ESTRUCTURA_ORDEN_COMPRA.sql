USE DBVENTAS_WEB
GO

PRINT '=========================================='
PRINT 'ESTRUCTURA DE LA TABLA ORDEN_COMPRA'
PRINT '=========================================='
PRINT ''

SELECT 
    COLUMN_NAME as NombreColumna,
    DATA_TYPE as TipoDato,
    CHARACTER_MAXIMUM_LENGTH as Longitud,
    IS_NULLABLE as AceptaNULL
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ORDEN_COMPRA'
ORDER BY ORDINAL_POSITION

PRINT ''
PRINT '=========================================='
PRINT 'PRIMERAS 5 FILAS DE ORDEN_COMPRA'
PRINT '=========================================='
PRINT ''

-- Seleccionar todas las columnas de las primeras 5 filas
SELECT TOP 5 *
FROM ORDEN_COMPRA
ORDER BY 1 DESC

GO
