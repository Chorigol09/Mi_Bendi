-- =============================================
-- DIAGNÓSTICO COMPLETO DE FACTURAS
-- =============================================
USE DBVENTAS_WEB
GO

PRINT '=========================================='
PRINT 'DIAGNÓSTICO DE FACTURAS'
PRINT '=========================================='
PRINT ''

-- 1. Verificar si hay facturas
PRINT '1. FACTURAS EN LA BASE DE DATOS:'
PRINT '-----------------------------------'
SELECT COUNT(*) as 'Total Facturas' FROM FACTURA
SELECT COUNT(*) as 'Facturas Activas' FROM FACTURA WHERE Activo = 1
PRINT ''

-- 2. Ver todas las facturas
PRINT '2. LISTADO DE FACTURAS:'
PRINT '-----------------------------------'
SELECT 
    f.IdFactura,
    f.NumeroFactura,
    f.IdProveedor,
    p.RazonSocial as Proveedor,
    f.FechaEmision,
    f.Total,
    f.Estado,
    f.Activo
FROM FACTURA f
LEFT JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
ORDER BY f.IdFactura DESC
PRINT ''

-- 3. Verificar que el SP existe
PRINT '3. VERIFICAR STORED PROCEDURE:'
PRINT '-----------------------------------'
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerFacturas')
BEGIN
    PRINT '✓ SP usp_ObtenerFacturas existe'
END
ELSE
BEGIN
    PRINT '✗ ERROR: SP usp_ObtenerFacturas NO EXISTE'
END
PRINT ''

-- 4. Ejecutar el SP
PRINT '4. RESULTADO DEL SP usp_ObtenerFacturas:'
PRINT '-----------------------------------'
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerFacturas')
BEGIN
    EXEC usp_ObtenerFacturas
END
PRINT ''

-- 5. Verificar detalles de facturas
PRINT '5. DETALLES DE FACTURAS:'
PRINT '-----------------------------------'
SELECT 
    df.IdFactura,
    f.NumeroFactura,
    df.IdProducto,
    p.Nombre as Producto,
    df.Cantidad,
    df.PrecioUnitario,
    df.Subtotal,
    df.Activo
FROM DETALLE_FACTURA df
LEFT JOIN FACTURA f ON df.IdFactura = f.IdFactura
LEFT JOIN PRODUCTO p ON df.IdProducto = p.IdProducto
ORDER BY df.IdFactura DESC
PRINT ''

PRINT '=========================================='
PRINT 'FIN DEL DIAGNÓSTICO'
PRINT '=========================================='
