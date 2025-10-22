USE DBVENTAS_WEB
GO

PRINT '=========================================='
PRINT 'VERIFICAR STORED PROCEDURE DE COMPRAS'
PRINT '=========================================='
PRINT ''

-- Verificar si existe
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerCompras')
BEGIN
    PRINT '✓ El SP usp_ObtenerCompras EXISTE'
    PRINT ''
    
    -- Mostrar parámetros
    PRINT 'Parámetros del SP:'
    SELECT 
        pm.name AS Parametro,
        TYPE_NAME(pm.user_type_id) AS Tipo
    FROM sys.procedures p
    INNER JOIN sys.parameters pm ON p.object_id = pm.object_id
    WHERE p.name = 'usp_ObtenerCompras'
    ORDER BY pm.parameter_id
    
    PRINT ''
    PRINT 'Probando el SP con fechas amplias...'
    PRINT ''
    
    -- Ejecutar el SP
    EXEC usp_ObtenerCompras 
        @fechainicio = '2024-01-01',
        @fechafin = '2025-12-31',
        @idproveedor = 0,
        @idtienda = 0
END
ELSE
BEGIN
    PRINT '✗ El SP usp_ObtenerCompras NO EXISTE'
    PRINT ''
    PRINT 'Buscando SPs relacionados con compras...'
    PRINT ''
    
    SELECT 
        name AS NombreSP,
        create_date AS FechaCreacion
    FROM sys.procedures
    WHERE name LIKE '%compra%'
    ORDER BY name
END

PRINT ''
PRINT '=========================================='
PRINT 'FIN DE LA VERIFICACIÓN'
PRINT '=========================================='
GO
