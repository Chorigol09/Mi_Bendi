USE DBVENTAS_WEB
GO

PRINT '=========================================='
PRINT 'CREANDO STORED PROCEDURE PARA COMPRAS'
PRINT '=========================================='
PRINT ''

-- Eliminar el SP si existe para recrearlo
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerListaCompra')
BEGIN
    DROP PROCEDURE usp_ObtenerListaCompra
    PRINT '✓ SP anterior eliminado'
END

GO

-- Crear el stored procedure
CREATE PROCEDURE usp_ObtenerListaCompra
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

PRINT '✓ SP usp_ObtenerListaCompra creado exitosamente'
PRINT ''
PRINT 'Probando el SP...'
PRINT ''

-- Probar el SP
EXEC usp_ObtenerListaCompra 
    @FechaInicio = '2025-01-01',
    @FechaFin = '2025-12-31',
    @IdProveedor = 0,
    @IdTienda = 0

PRINT ''
PRINT '=========================================='
PRINT '✅ LISTO! Ahora recarga la página en el navegador'
PRINT '=========================================='
GO
