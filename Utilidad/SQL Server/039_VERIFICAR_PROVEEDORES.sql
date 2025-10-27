USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'VERIFICACION DE PROVEEDORES'
PRINT '========================================='
PRINT ''

-- Ver todos los proveedores
PRINT '--- TODOS LOS PROVEEDORES ---'
SELECT 
    IdProveedor,
    RazonSocial,
    RUC,
    Activo,
    FechaRegistro
FROM PROVEEDOR
ORDER BY RazonSocial
GO

PRINT ''
PRINT '--- PROVEEDORES ACTIVOS ---'
SELECT COUNT(*) AS TotalActivos
FROM PROVEEDOR
WHERE Activo = 1
GO

PRINT ''
PRINT '--- PROVEEDORES INACTIVOS ---'
SELECT COUNT(*) AS TotalInactivos
FROM PROVEEDOR
WHERE Activo = 0
GO

PRINT ''
PRINT '========================================='
PRINT 'Si ves proveedores arriba, el problema'
PRINT 'esta en el JavaScript o el controlador'
PRINT '========================================='
