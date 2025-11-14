USE DBVENTAS_WEB
GO

-- ========================================
-- PROCEDIMIENTOS ADICIONALES PARA TOP 10 COMPRAS
-- ========================================

-- Top 10 Productos Mas Comprados (desde órdenes de pago)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorTopProductosComprados')
    DROP PROCEDURE usp_IndicadorTopProductosComprados
GO

CREATE PROCEDURE usp_IndicadorTopProductosComprados(
    @FechaInicio DATE,
    @FechaFin DATE,
    @Top INT = 10000
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    SELECT 
        p.Nombre AS Producto,
        p.Codigo,
        SUM(df.Cantidad) AS CantidadComprada,
        ISNULL(SUM(df.Subtotal), 0) AS TotalComprado
    FROM PRODUCTO p
    INNER JOIN DETALLE_FACTURA df ON p.IdProducto = df.IdProducto
    INNER JOIN FACTURA f ON df.IdFactura = f.IdFactura
    INNER JOIN ORDEN_PAGO op ON f.IdFactura = op.IdFactura
    WHERE CONVERT(DATE, op.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY p.IdProducto, p.Nombre, p.Codigo
    ORDER BY TotalComprado DESC
END
GO

-- Top 10 Proveedores (desde órdenes de pago)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorTopProveedores')
    DROP PROCEDURE usp_IndicadorTopProveedores
GO

CREATE PROCEDURE usp_IndicadorTopProveedores(
    @FechaInicio DATE,
    @FechaFin DATE,
    @Top INT = 10000
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    SELECT 
        p.RazonSocial AS Proveedor,
        p.RUC AS NumeroDocumento,
        COUNT(op.IdOrdenPago) AS CantidadCompras,
        ISNULL(SUM(op.MontoTotal), 0) AS TotalComprado
    FROM PROVEEDOR p
    INNER JOIN ORDEN_PAGO op ON p.IdProveedor = op.IdProveedor
    WHERE CONVERT(DATE, op.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY p.IdProveedor, p.RazonSocial, p.RUC
    ORDER BY TotalComprado DESC
END
GO

PRINT '========================================='
PRINT 'Procedimientos Top 10 Compras creados exitosamente'
PRINT '========================================='
GO
