USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'ESTRUCTURA DE TABLA PERMISOS'
PRINT '========================================='
PRINT ''

-- Ver estructura de PERMISOS
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PERMISOS'
ORDER BY ORDINAL_POSITION
GO

PRINT ''
PRINT '--- DATOS DE EJEMPLO DE PERMISOS ---'
SELECT TOP 10 * FROM PERMISOS
GO

PRINT ''
PRINT '--- RELACIONES DE PERMISOS ---'
SELECT 
    fk.name AS ForeignKey,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS ReferencedColumn
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc 
    ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'PERMISOS'
GO

PRINT ''
PRINT '========================================='
PRINT 'Copia el resultado completo'
PRINT '========================================='
