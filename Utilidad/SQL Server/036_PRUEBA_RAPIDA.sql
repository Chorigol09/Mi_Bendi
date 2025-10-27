USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'PRUEBA RAPIDA - FACTURAS PENDIENTES'
PRINT '========================================='
PRINT ''

-- Paso 1: Ver si existe DETALLE_FACTURA
PRINT '--- VERIFICAR TABLA DETALLE_FACTURA ---'
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DETALLE_FACTURA')
    PRINT '✓ Tabla DETALLE_FACTURA existe'
ELSE
    PRINT '✗ Tabla DETALLE_FACTURA NO existe'
GO

PRINT ''
PRINT '--- PROVEEDORES CON FACTURAS PENDIENTES ---'
SELECT 
    p.IdProveedor,
    p.RazonSocial,
    COUNT(f.IdFactura) AS CantidadPendientes
FROM PROVEEDOR p
INNER JOIN FACTURA f ON p.IdProveedor = f.IdProveedor
WHERE f.Estado = 'Pendiente'
  AND p.Activo = 1
GROUP BY p.IdProveedor, p.RazonSocial
ORDER BY p.RazonSocial
GO

PRINT ''
PRINT '--- PRUEBA DEL SP (Proveedor ID 1) ---'
EXEC SP_OBTENER_FACTURAS_PENDIENTES 1
GO

PRINT ''
PRINT '========================================='
PRINT 'Si ves facturas arriba, funciona!'
PRINT 'Si NO ves facturas, prueba con otro ID'
PRINT '========================================='
