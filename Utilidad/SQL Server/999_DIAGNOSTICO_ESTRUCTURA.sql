-- =============================================
-- Script: Diagnóstico de estructura de tablas
-- Descripción: Ver columnas reales de FACTURA y PROVEEDOR
-- =============================================

USE DBVENTAS_WEB
GO

PRINT ''
PRINT '========================================='
PRINT 'COLUMNAS DE LA TABLA FACTURA'
PRINT '========================================='
SELECT 
    COLUMN_NAME AS 'Nombre Columna',
    DATA_TYPE AS 'Tipo de Dato',
    CHARACTER_MAXIMUM_LENGTH AS 'Longitud'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FACTURA'
ORDER BY ORDINAL_POSITION

PRINT ''
PRINT '========================================='
PRINT 'COLUMNAS DE LA TABLA PROVEEDOR'
PRINT '========================================='
SELECT 
    COLUMN_NAME AS 'Nombre Columna',
    DATA_TYPE AS 'Tipo de Dato',
    CHARACTER_MAXIMUM_LENGTH AS 'Longitud'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PROVEEDOR'
ORDER BY ORDINAL_POSITION

PRINT ''
PRINT '========================================='
PRINT 'COLUMNAS DE LA TABLA DETALLE_FACTURA'
PRINT '========================================='
SELECT 
    COLUMN_NAME AS 'Nombre Columna',
    DATA_TYPE AS 'Tipo de Dato',
    CHARACTER_MAXIMUM_LENGTH AS 'Longitud'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DETALLE_FACTURA'
ORDER BY ORDINAL_POSITION
