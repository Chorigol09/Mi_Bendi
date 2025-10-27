USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'PRUEBA SIMPLE - FACTURAS PENDIENTES'
PRINT '========================================='
PRINT ''

-- Ver estructura de FACTURA
PRINT '--- COLUMNAS DE FACTURA ---'
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FACTURA'
ORDER BY ORDINAL_POSITION
GO

PRINT ''
PRINT '--- FACTURAS PENDIENTES POR PROVEEDOR ---'
SELECT 
    p.IdProveedor,
    p.RazonSocial,
    COUNT(f.IdFactura) AS CantidadPendientes
FROM PROVEEDOR p
LEFT JOIN FACTURA f ON p.IdProveedor = f.IdProveedor AND f.Estado = 'Pendiente'
WHERE p.Activo = 1
GROUP BY p.IdProveedor, p.RazonSocial
HAVING COUNT(f.IdFactura) > 0
ORDER BY p.RazonSocial
GO

PRINT ''
PRINT '--- PRUEBA DEL SP (Proveedor ID 5) ---'
EXEC SP_OBTENER_FACTURAS_PENDIENTES 5
GO

PRINT ''
PRINT '========================================='
PRINT 'Si ves facturas arriba, el SP funciona!'
PRINT '========================================='
