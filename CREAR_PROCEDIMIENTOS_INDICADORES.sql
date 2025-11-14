USE DBVENTAS_WEB
GO

-- ========================================
-- PROCEDIMIENTOS PARA INDICADORES/DASHBOARD
-- ========================================

-- 1. Ventas por Tienda
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorVentasPorTienda')
    DROP PROCEDURE usp_IndicadorVentasPorTienda
GO

CREATE PROCEDURE usp_IndicadorVentasPorTienda(
    @FechaInicio DATE,
    @FechaFin DATE
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    SELECT 
        t.Nombre AS Tienda,
        COUNT(v.IdVenta) AS CantidadVentas,
        ISNULL(SUM(v.TotalCosto), 0) AS TotalVendido,
        ISNULL(AVG(v.TotalCosto), 0) AS PromedioVenta
    FROM TIENDA t
    LEFT JOIN VENTA v ON t.IdTienda = v.IdTienda 
        AND CONVERT(DATE, v.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY t.IdTienda, t.Nombre
    ORDER BY TotalVendido DESC
END
GO

-- 2. Ventas por Tipo de Documento
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorVentasPorTipoDocumento')
    DROP PROCEDURE usp_IndicadorVentasPorTipoDocumento
GO

CREATE PROCEDURE usp_IndicadorVentasPorTipoDocumento(
    @FechaInicio DATE,
    @FechaFin DATE
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    SELECT 
        v.TipoDocumento,
        COUNT(v.IdVenta) AS Cantidad,
        ISNULL(SUM(v.TotalCosto), 0) AS Total
    FROM VENTA v
    WHERE CONVERT(DATE, v.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY v.TipoDocumento
    ORDER BY Total DESC
END
GO

-- 3. Ventas por Método de Pago
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorVentasPorMetodoPago')
    DROP PROCEDURE usp_IndicadorVentasPorMetodoPago
GO

CREATE PROCEDURE usp_IndicadorVentasPorMetodoPago(
    @FechaInicio DATE,
    @FechaFin DATE
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    SELECT 
        ISNULL(v.MetodoPago, 'Efectivo') AS MetodoPago,
        COUNT(v.IdVenta) AS Cantidad,
        ISNULL(SUM(v.TotalCosto), 0) AS Total
    FROM VENTA v
    WHERE CONVERT(DATE, v.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY v.MetodoPago
    ORDER BY Total DESC
END
GO

-- 4. Top 10 Clientes
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorTopClientes')
    DROP PROCEDURE usp_IndicadorTopClientes
GO

CREATE PROCEDURE usp_IndicadorTopClientes(
    @FechaInicio DATE,
    @FechaFin DATE,
    @Top INT = 10
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    SELECT TOP (@Top)
        c.Nombre AS Cliente,
        c.NumeroDocumento,
        COUNT(v.IdVenta) AS CantidadCompras,
        ISNULL(SUM(v.TotalCosto), 0) AS TotalComprado
    FROM CLIENTE c
    INNER JOIN VENTA v ON c.IdCliente = v.IdCliente
    WHERE CONVERT(DATE, v.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY c.IdCliente, c.Nombre, c.NumeroDocumento
    ORDER BY TotalComprado DESC
END
GO

-- 5. Top 10 Productos Más Vendidos
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorTopProductos')
    DROP PROCEDURE usp_IndicadorTopProductos
GO

CREATE PROCEDURE usp_IndicadorTopProductos(
    @FechaInicio DATE,
    @FechaFin DATE,
    @Top INT = 10
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    SELECT TOP (@Top)
        p.Nombre AS Producto,
        p.Codigo,
        SUM(dv.Cantidad) AS CantidadVendida,
        ISNULL(SUM(dv.ImporteTotal), 0) AS TotalVendido
    FROM PRODUCTO p
    INNER JOIN DETALLE_VENTA dv ON p.IdProducto = dv.IdProducto
    INNER JOIN VENTA v ON dv.IdVenta = v.IdVenta
    WHERE CONVERT(DATE, v.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY p.IdProducto, p.Nombre, p.Codigo
    ORDER BY CantidadVendida DESC
END
GO

-- 6. Ventas por Día (para gráfico de línea)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorVentasPorDia')
    DROP PROCEDURE usp_IndicadorVentasPorDia
GO

CREATE PROCEDURE usp_IndicadorVentasPorDia(
    @FechaInicio DATE,
    @FechaFin DATE
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    SELECT 
        CONVERT(DATE, v.FechaRegistro) AS Fecha,
        COUNT(v.IdVenta) AS CantidadVentas,
        ISNULL(SUM(v.TotalCosto), 0) AS TotalVendido
    FROM VENTA v
    WHERE CONVERT(DATE, v.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY CONVERT(DATE, v.FechaRegistro)
    ORDER BY Fecha
END
GO

-- 7. Resumen General (KPIs)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorResumenGeneral')
    DROP PROCEDURE usp_IndicadorResumenGeneral
GO

CREATE PROCEDURE usp_IndicadorResumenGeneral(
    @FechaInicio DATE,
    @FechaFin DATE
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    SELECT 
        -- Ventas
        ISNULL(SUM(v.TotalCosto), 0) AS TotalVentas,
        COUNT(v.IdVenta) AS CantidadVentas,
        ISNULL(AVG(v.TotalCosto), 0) AS PromedioVenta,
        ISNULL(SUM(v.CantidadTotal), 0) AS UnidadesVendidas,
        
        -- Compras
        (SELECT ISNULL(SUM(c.TotalCosto), 0) 
         FROM COMPRA c 
         WHERE CONVERT(DATE, c.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin) AS TotalCompras,
        
        (SELECT COUNT(c.IdCompra) 
         FROM COMPRA c 
         WHERE CONVERT(DATE, c.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin) AS CantidadCompras,
        
        -- Margen (Ventas - Compras)
        ISNULL(SUM(v.TotalCosto), 0) - 
        (SELECT ISNULL(SUM(c.TotalCosto), 0) 
         FROM COMPRA c 
         WHERE CONVERT(DATE, c.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin) AS MargenBruto,
        
        -- Clientes únicos
        COUNT(DISTINCT v.IdCliente) AS ClientesUnicos
        
    FROM VENTA v
    WHERE CONVERT(DATE, v.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
END
GO

-- 8. Compras por Proveedor
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorComprasPorProveedor')
    DROP PROCEDURE usp_IndicadorComprasPorProveedor
GO

CREATE PROCEDURE usp_IndicadorComprasPorProveedor(
    @FechaInicio DATE,
    @FechaFin DATE
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    SELECT 
        p.RazonSocial AS Proveedor,
        COUNT(c.IdCompra) AS CantidadCompras,
        ISNULL(SUM(c.TotalCosto), 0) AS TotalComprado
    FROM PROVEEDOR p
    LEFT JOIN COMPRA c ON p.IdProveedor = c.IdProveedor
        AND CONVERT(DATE, c.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY p.IdProveedor, p.RazonSocial
    HAVING SUM(c.TotalCosto) > 0
    ORDER BY TotalComprado DESC
END
GO

-- 9. Compras por Día
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorComprasPorDia')
    DROP PROCEDURE usp_IndicadorComprasPorDia
GO

CREATE PROCEDURE usp_IndicadorComprasPorDia(
    @FechaInicio DATE,
    @FechaFin DATE
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    SELECT 
        CONVERT(DATE, c.FechaRegistro) AS Fecha,
        COUNT(c.IdCompra) AS CantidadCompras,
        ISNULL(SUM(c.TotalCosto), 0) AS TotalComprado
    FROM COMPRA c
    WHERE CONVERT(DATE, c.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY CONVERT(DATE, c.FechaRegistro)
    ORDER BY Fecha
END
GO

PRINT '========================================='
PRINT 'Procedimientos de Indicadores creados exitosamente'
PRINT '========================================='
GO
