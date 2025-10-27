USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'ESTRUCTURA COMPLETA DE FACTURAS'
PRINT '========================================='
PRINT ''

-- Ver columnas de FACTURA
PRINT '--- COLUMNAS DE FACTURA ---'
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FACTURA'
ORDER BY ORDINAL_POSITION
GO

PRINT ''
PRINT '--- COLUMNAS DE DETALLE_FACTURA ---'
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DETALLE_FACTURA'
ORDER BY ORDINAL_POSITION
GO

PRINT ''
PRINT '--- DATOS DE EJEMPLO DE FACTURA ---'
SELECT TOP 3
    f.IdFactura,
    f.NumeroFactura,
    p.RazonSocial AS Proveedor,
    f.FechaEmision,
    f.Total,
    f.Estado
FROM FACTURA f
INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
WHERE f.Estado = 'Pendiente'
GO

PRINT ''
PRINT '--- DATOS DE EJEMPLO CON DETALLE ---'
SELECT TOP 3
    f.IdFactura,
    f.NumeroFactura,
    p.RazonSocial AS Proveedor,
    f.FechaEmision,
    df.IdProducto,
    pr.Nombre AS Producto,
    df.Cantidad,
    f.Total,
    f.Estado
FROM FACTURA f
INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
LEFT JOIN DETALLE_FACTURA df ON f.IdFactura = df.IdFactura
LEFT JOIN PRODUCTO pr ON df.IdProducto = pr.IdProducto
WHERE f.Estado = 'Pendiente'
GO

PRINT ''
PRINT '--- QUERY PARA OBTENER FACTURAS CON PRODUCTOS ---'
PRINT 'Este query muestra como obtener los productos de cada factura'
PRINT ''

SELECT 
    f.IdFactura,
    f.NumeroFactura,
    p.RazonSocial AS NombreProveedor,
    CONVERT(VARCHAR(10), f.FechaEmision, 103) AS FechaEmision,
    -- Obtener lista de productos separados por coma
    STUFF((
        SELECT ', ' + pr.Nombre
        FROM DETALLE_FACTURA df
        INNER JOIN PRODUCTO pr ON df.IdProducto = pr.IdProducto
        WHERE df.IdFactura = f.IdFactura
        FOR XML PATH('')
    ), 1, 2, '') AS Productos,
    -- Sumar cantidad total
    ISNULL((
        SELECT SUM(df.Cantidad)
        FROM DETALLE_FACTURA df
        WHERE df.IdFactura = f.IdFactura
    ), 0) AS Cantidad,
    f.Total AS MontoTotal,
    f.Estado
FROM FACTURA f
INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
WHERE f.IdProveedor = 1
  AND f.Estado = 'Pendiente'
  AND NOT EXISTS(SELECT 1 FROM ORDEN_PAGO WHERE IdFactura = f.IdFactura)
ORDER BY f.FechaEmision DESC
GO
