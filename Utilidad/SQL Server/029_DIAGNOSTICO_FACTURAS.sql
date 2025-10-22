USE DBVENTAS_WEB
GO

PRINT '=========================================='
PRINT 'DIAGNÓSTICO DE FACTURAS'
PRINT '=========================================='
PRINT ''

-- 1. Verificar que existen facturas en la tabla
PRINT '1. Facturas en la tabla FACTURA:'
PRINT '-----------------------------------'
SELECT 
    IdFactura,
    IdProveedor,
    NumeroFactura,
    FechaEmision,
    Total,
    Estado,
    Activo
FROM FACTURA
ORDER BY IdFactura DESC
PRINT ''

-- 2. Verificar que el SP existe
PRINT '2. Verificando SP usp_ObtenerFacturas:'
PRINT '-----------------------------------'
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerFacturas')
BEGIN
    PRINT '✓ SP existe'
END
ELSE
BEGIN
    PRINT '✗ SP NO existe'
END
PRINT ''

-- 3. Ejecutar el SP y ver qué devuelve
PRINT '3. Ejecutando SP usp_ObtenerFacturas:'
PRINT '-----------------------------------'
EXEC usp_ObtenerFacturas
PRINT ''

-- 4. Verificar detalles de facturas
PRINT '4. Detalles de facturas:'
PRINT '-----------------------------------'
SELECT 
    df.IdFactura,
    COUNT(*) as CantidadDetalles,
    SUM(df.Subtotal) as TotalCalculado
FROM DETALLE_FACTURA df
WHERE df.Activo = 1
GROUP BY df.IdFactura
ORDER BY df.IdFactura DESC
PRINT ''

-- 5. Ver productos por factura
PRINT '5. Productos por factura (últimas 3):'
PRINT '-----------------------------------'
SELECT TOP 3
    f.IdFactura,
    f.NumeroFactura,
    p.Nombre as Producto,
    df.Cantidad,
    df.PrecioUnitario,
    df.Subtotal
FROM FACTURA f
INNER JOIN DETALLE_FACTURA df ON f.IdFactura = df.IdFactura
INNER JOIN PRODUCTO p ON df.IdProducto = p.IdProducto
WHERE f.Activo = 1 AND df.Activo = 1
ORDER BY f.IdFactura DESC
PRINT ''

PRINT '=========================================='
PRINT 'FIN DEL DIAGNÓSTICO'
PRINT '=========================================='
GO
