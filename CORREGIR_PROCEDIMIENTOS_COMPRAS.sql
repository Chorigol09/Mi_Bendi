USE DBVENTAS_WEB
GO

-- ========================================
-- CORREGIR PROCEDIMIENTOS PARA USAR FACTURA EN LUGAR DE COMPRA
-- ========================================

-- 1. Resumen General (KPIs) - Corregido para usar FACTURA
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
        
        -- Compras (desde órdenes de pago)
        (SELECT ISNULL(SUM(op.MontoTotal), 0) 
         FROM ORDEN_PAGO op
         WHERE CONVERT(DATE, op.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin) AS TotalCompras,
        
        (SELECT COUNT(op.IdOrdenPago) 
         FROM ORDEN_PAGO op
         WHERE CONVERT(DATE, op.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin) AS CantidadCompras,
        
        -- Margen (Ventas - Compras)
        ISNULL(SUM(v.TotalCosto), 0) - 
        (SELECT ISNULL(SUM(op.MontoTotal), 0) 
         FROM ORDEN_PAGO op
         WHERE CONVERT(DATE, op.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin) AS MargenBruto,
        
        -- Clientes únicos
        COUNT(DISTINCT v.IdCliente) AS ClientesUnicos
        
    FROM VENTA v
    WHERE CONVERT(DATE, v.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
END
GO

-- 2. Compras por Proveedor - Corregido para usar ORDEN_PAGO (fecha de pago)
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
        COUNT(op.IdOrdenPago) AS CantidadCompras,
        ISNULL(SUM(op.MontoTotal), 0) AS TotalComprado
    FROM PROVEEDOR p
    INNER JOIN ORDEN_PAGO op ON p.IdProveedor = op.IdProveedor
    WHERE CONVERT(DATE, op.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY p.IdProveedor, p.RazonSocial
    HAVING SUM(op.MontoTotal) > 0
    ORDER BY TotalComprado DESC
END
GO

-- 3. Compras por Día - Corregido para usar ORDEN_PAGO (fecha de pago)
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
        CONVERT(DATE, op.FechaRegistro) AS Fecha,
        COUNT(op.IdOrdenPago) AS CantidadCompras,
        ISNULL(SUM(op.MontoTotal), 0) AS TotalComprado
    FROM ORDEN_PAGO op
    WHERE CONVERT(DATE, op.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    GROUP BY CONVERT(DATE, op.FechaRegistro)
    ORDER BY Fecha
END
GO

PRINT '========================================='
PRINT 'Procedimientos corregidos para usar FACTURA'
PRINT '========================================='
GO
