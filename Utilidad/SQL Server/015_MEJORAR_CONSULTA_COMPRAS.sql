USE DBVENTAS_WEB
GO

-- =============================================
-- MEJORAS EN CONSULTA DE ÓRDENES DE COMPRA
-- =============================================

PRINT '╔════════════════════════════════════════════════╗'
PRINT '║   MEJORANDO CONSULTA DE ÓRDENES DE COMPRA      ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

PRINT '1. Actualizando SP usp_ObtenerListaCompra...'
PRINT '   - Agregando cantidad de productos'
PRINT '   - Agregando lista de productos'
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
        oc.TotalCosto,
        ISNULL(oc.Estado, 'Abierta') AS Estado,
        ISNULL(detalle.CantidadProductos, 0) AS CantidadProductos,
        ISNULL(productos.Productos, '') AS Productos
    FROM ORDEN_COMPRA oc
    INNER JOIN PROVEEDOR p ON oc.IdProveedor = p.IdProveedor
    INNER JOIN TIENDA t ON oc.IdTienda = t.IdTienda
    -- Cantidad de productos
    OUTER APPLY (
        SELECT SUM(doc.Cantidad) AS CantidadProductos
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
    PRINT '   Ejemplo de registro:'
    SELECT TOP 1 
        IdCompra,
        NumeroCompra,
        Estado,
        CantidadProductos,
        CASE 
            WHEN LEN(Productos) > 50 THEN SUBSTRING(Productos, 1, 50) + '...'
            ELSE Productos 
        END AS Productos_Preview
    FROM @Resultado
END
ELSE
BEGIN
    PRINT '   ℹ️  No hay órdenes de compra registradas'
    PRINT '   Ejecuta: 007_SEED_DATOS_PRUEBA_COMPLETO.sql'
END

PRINT ''
PRINT '╔════════════════════════════════════════════════╗'
PRINT '║           ✅ ACTUALIZACIÓN COMPLETADA          ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''
PRINT 'PRÓXIMOS PASOS:'
PRINT '  1. Recompilar aplicación'
PRINT '  2. Ir a: Compras > Consultar Ordenes de Compra'
PRINT '  3. Verás:'
PRINT '     - Cantidad de productos'
PRINT '     - Lista de productos'
PRINT '     - Estado editable (Abierta/Cerrada)'
PRINT ''
GO
