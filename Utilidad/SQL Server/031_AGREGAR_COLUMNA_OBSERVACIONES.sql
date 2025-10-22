USE DBVENTAS_WEB
GO

PRINT '=========================================='
PRINT 'VERIFICAR Y AGREGAR COLUMNA OBSERVACIONES'
PRINT '=========================================='
PRINT ''

-- Verificar si la columna existe
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'FACTURA' AND COLUMN_NAME = 'Observaciones'
)
BEGIN
    PRINT 'La columna Observaciones NO existe. Agregándola...'
    
    ALTER TABLE FACTURA 
    ADD Observaciones VARCHAR(500) NULL
    
    PRINT '✓ Columna Observaciones agregada exitosamente'
END
ELSE
BEGIN
    PRINT '✓ La columna Observaciones ya existe'
END

PRINT ''
PRINT 'Verificando estructura actual de FACTURA:'
PRINT ''

SELECT 
    COLUMN_NAME as Columna,
    DATA_TYPE as Tipo,
    CHARACTER_MAXIMUM_LENGTH as Longitud,
    IS_NULLABLE as Acepta_NULL
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FACTURA'
ORDER BY ORDINAL_POSITION

PRINT ''
PRINT '=========================================='
PRINT 'COMPLETADO'
PRINT '=========================================='
GO
