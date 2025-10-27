USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'VERIFICAR TABLA FACTURA'
PRINT '========================================='
PRINT ''

-- Ver estructura de FACTURA
PRINT '--- ESTRUCTURA DE TABLA FACTURA ---'
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FACTURA'
ORDER BY ORDINAL_POSITION
GO

PRINT ''
PRINT '--- DATOS DE EJEMPLO DE FACTURA ---'
SELECT TOP 10 
    IdFactura,
    NumeroFactura,
    FechaEmision,
    IdProveedor,
    Total,
    Estado
FROM FACTURA
ORDER BY IdFactura DESC
GO

PRINT ''
PRINT '--- FACTURAS POR PROVEEDOR ---'
SELECT 
    p.IdProveedor,
    p.RazonSocial,
    COUNT(f.IdFactura) AS CantidadFacturas,
    SUM(CASE WHEN f.Estado = 'Pendiente' THEN 1 ELSE 0 END) AS Pendientes,
    SUM(CASE WHEN f.Estado = 'Pagado' THEN 1 ELSE 0 END) AS Pagadas
FROM PROVEEDOR p
LEFT JOIN FACTURA f ON p.IdProveedor = f.IdProveedor
WHERE p.Activo = 1
GROUP BY p.IdProveedor, p.RazonSocial
HAVING COUNT(f.IdFactura) > 0
ORDER BY p.RazonSocial
GO

PRINT ''
PRINT '========================================='
PRINT 'VERIFICACION COMPLETADA'
PRINT '========================================='
