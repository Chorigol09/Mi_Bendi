USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'PRUEBA DE STORED PROCEDURES'
PRINT '========================================='
PRINT ''

-- Obtener un proveedor con facturas pendientes
DECLARE @IdProveedor INT = (
    SELECT TOP 1 IdProveedor 
    FROM FACTURA 
    WHERE Estado = 'Pendiente'
    GROUP BY IdProveedor
    ORDER BY COUNT(*) DESC
)

IF @IdProveedor IS NULL
BEGIN
    PRINT 'ERROR: No hay facturas pendientes'
    PRINT 'Ejecuta el script: 031_INSERTAR_FACTURAS_PRUEBA.sql'
    RETURN
END

DECLARE @NombreProveedor VARCHAR(100) = (SELECT RazonSocial FROM PROVEEDOR WHERE IdProveedor = @IdProveedor)

PRINT 'Proveedor seleccionado: ' + @NombreProveedor + ' (ID: ' + CAST(@IdProveedor AS VARCHAR) + ')'
PRINT ''

-- PRUEBA 1: Obtener facturas pendientes
PRINT '--- PRUEBA 1: SP_OBTENER_FACTURAS_PENDIENTES ---'
EXEC SP_OBTENER_FACTURAS_PENDIENTES @IdProveedor
GO

PRINT ''
PRINT '========================================='
PRINT 'PRUEBA COMPLETADA'
PRINT '========================================='
PRINT ''
PRINT 'Si ves facturas arriba, el SP funciona correctamente'
PRINT 'Ahora puedes probar en la aplicacion'
PRINT ''
