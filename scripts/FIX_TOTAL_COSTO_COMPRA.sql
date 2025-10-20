USE DBVENTAS_WEB
GO

-- =============================================
-- CORREGIR CÁLCULO DE TOTAL COSTO EN CONSULTA DE COMPRAS
-- =============================================

PRINT '╔════════════════════════════════════════════════╗'
PRINT '║   CORRIGIENDO TOTAL COSTO EN CONSULTA COMPRAS  ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

PRINT '1. Actualizando SP usp_ObtenerListaCompra...'
PRINT '   - Calculando TotalCosto desde DETALLE_ORDEN_COMPRA'
GO

CREATE OR ALTER PROCEDURE usp_ObtenerListaCompra
    @FechaInicio DATE,
    @FechaFin DATE,
    @IdProveedor INT,
    @IdTienda INT
AS
BEGIN
    SELECT 
        oc.IdCompra,
        CONVERT(VARCHAR(10), oc.FechaRegistro, 103) AS NumeroCompra,
        p.RazonSocial,
        t.Nombre,
        CONVERT(VARCHAR(10), oc.FechaRegistro, 103) AS FechaCompra,
        -- CALCULAR el total desde los detalles en lugar de usar oc.TotalCosto
        ISNULL(detalle.TotalCostoCalculado, 0) AS TotalCosto,
        ISNULL(oc.Estado, 'Abierta') AS Estado,
        ISNULL(detalle.CantidadProductos, 0) AS CantidadProductos,
        ISNULL(productos.Productos, '') AS Productos
    FROM ORDEN_COMPRA oc
    INNER JOIN PROVEEDOR p ON oc.IdProveedor = p.IdProveedor
    INNER JOIN TIENDA t ON oc.IdTienda = t.IdTienda
    -- Cantidad de productos Y total calculado
    OUTER APPLY (
        SELECT 
            SUM(doc.Cantidad) AS CantidadProductos,
            SUM(doc.TotalCosto) AS TotalCostoCalculado
        FROM DETALLE_ORDEN_COMPRA doc
        WHERE doc.IdOrdenCompra = oc.IdCompra
    ) detalle
    -- Lista de productos
    OUTER APPLY (
        SELECT STUFF((
            SELECT ', ' + pr.Nombre + ' (' + CAST(doc2.Cantidad AS VARCHAR(10)) + ')'
            FROM DETALLE_ORDEN_COMPRA doc2
            INNER JOIN PRODUCTO pr ON doc2.IdProducto = pr.IdProducto
            WHERE doc2.IdOrdenCompra = oc.IdCompra
            FOR XML PATH('')
        ), 1, 2, '') AS Productos
    ) productos
    WHERE 
        CONVERT(DATE, oc.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
        AND (@IdProveedor = 0 OR oc.IdProveedor = @IdProveedor)
        AND (@IdTienda = 0 OR oc.IdTienda = @IdTienda)
    ORDER BY oc.FechaRegistro DESC
END
GO

PRINT '   ✓ SP usp_ObtenerListaCompra actualizado'
PRINT ''

-- Verificación
PRINT '2. Verificando cambios...'
PRINT ''

-- Test del SP
DECLARE @Resultado TABLE (
    IdCompra INT,
    NumeroCompra VARCHAR(10),
    RazonSocial VARCHAR(100),
    Nombre VARCHAR(100),
    FechaCompra VARCHAR(10),
    TotalCosto DECIMAL(18,2),
    Estado VARCHAR(20),
    CantidadProductos INT,
    Productos NVARCHAR(MAX)
)

INSERT INTO @Resultado
EXEC usp_ObtenerListaCompra 
    @FechaInicio = '2020-01-01',
    @FechaFin = '2030-12-31',
    @IdProveedor = 0,
    @IdTienda = 0

DECLARE @TotalOrdenes INT
SELECT @TotalOrdenes = COUNT(*) FROM @Resultado

IF @TotalOrdenes > 0
BEGIN
    PRINT '   ✓ SP ejecuta correctamente'
    PRINT '   Órdenes encontradas: ' + CAST(@TotalOrdenes AS VARCHAR(10))
    PRINT ''
    PRINT '   Comparación de totales (primeras 5 órdenes):'
    PRINT ''
    
    SELECT TOP 5
        oc.IdCompra,
        oc.TotalCosto AS [Total_Tabla_ORDEN_COMPRA],
        ISNULL(SUM(doc.TotalCosto), 0) AS [Total_Calculado_Detalles],
        CASE 
            WHEN ABS(oc.TotalCosto - ISNULL(SUM(doc.TotalCosto), 0)) < 0.01 THEN '✓ Correcto'
            ELSE '✗ Diferencia: ' + CAST(ABS(oc.TotalCosto - ISNULL(SUM(doc.TotalCosto), 0)) AS VARCHAR(20))
        END AS Verificacion
    FROM ORDEN_COMPRA oc
    LEFT JOIN DETALLE_ORDEN_COMPRA doc ON oc.IdCompra = doc.IdOrdenCompra
    GROUP BY oc.IdCompra, oc.TotalCosto
    ORDER BY oc.IdCompra DESC
END
ELSE
BEGIN
    PRINT '   ℹ️  No hay órdenes de compra registradas'
END

PRINT ''
PRINT '╔════════════════════════════════════════════════╗'
PRINT '║           ✅ CORRECCIÓN COMPLETADA             ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''
PRINT 'CAMBIOS REALIZADOS:'
PRINT '  ✓ El TotalCosto ahora se calcula desde DETALLE_ORDEN_COMPRA'
PRINT '  ✓ Suma correcta: SUM(Cantidad × PrecioUnitario)'
PRINT ''
PRINT 'PRÓXIMOS PASOS:'
PRINT '  1. Ir a: Compras > Consultar Ordenes de Compra'
PRINT '  2. Verificar que los totales coincidan con los detalles'
PRINT ''
GO
