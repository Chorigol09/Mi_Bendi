USE DBVENTAS_WEB
GO

-- Verificar los últimos registros
PRINT '=== VERIFICACIÓN DE DATOS ==='
PRINT ''

-- Ver las últimas 3 órdenes de compra
PRINT '1. Últimas órdenes en ORDEN_COMPRA:'
SELECT TOP 3
    IdCompra,
    TotalCosto AS [Total_en_ORDEN_COMPRA],
    FechaRegistro
FROM ORDEN_COMPRA
ORDER BY IdCompra DESC

PRINT ''
PRINT '2. Detalles de la última orden:'
DECLARE @UltimaOrden INT
SELECT TOP 1 @UltimaOrden = IdCompra FROM ORDEN_COMPRA ORDER BY IdCompra DESC

SELECT 
    doc.IdOrdenCompra,
    p.Nombre AS Producto,
    doc.Cantidad,
    doc.PrecioUnitarioCompra,
    doc.TotalCosto AS [Total_en_DETALLE],
    (doc.Cantidad * doc.PrecioUnitarioCompra) AS [Total_Calculado]
FROM DETALLE_ORDEN_COMPRA doc
INNER JOIN PRODUCTO p ON doc.IdProducto = p.IdProducto
WHERE doc.IdOrdenCompra = @UltimaOrden

PRINT ''
PRINT '3. Comparación:'
SELECT 
    oc.IdCompra,
    oc.TotalCosto AS [Total_ORDEN_COMPRA],
    SUM(doc.TotalCosto) AS [SUM_Detalles],
    SUM(doc.Cantidad * doc.PrecioUnitarioCompra) AS [Calculado_Correcto],
    CASE 
        WHEN ABS(oc.TotalCosto - SUM(doc.TotalCosto)) < 0.01 THEN 'OK'
        ELSE 'ERROR: ' + CAST(oc.TotalCosto / SUM(doc.TotalCosto) AS VARCHAR(20)) + 'x'
    END AS Verificacion
FROM ORDEN_COMPRA oc
LEFT JOIN DETALLE_ORDEN_COMPRA doc ON oc.IdCompra = doc.IdOrdenCompra
WHERE oc.IdCompra = @UltimaOrden
GROUP BY oc.IdCompra, oc.TotalCosto
