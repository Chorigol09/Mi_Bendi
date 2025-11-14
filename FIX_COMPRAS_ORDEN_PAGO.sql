USE DBVENTAS_WEB
GO

-- ========================================
-- ACTUALIZAR PROCEDIMIENTOS DE COMPRAS
-- ========================================

-- 1. Compras por Proveedor
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorComprasPorProveedor')
    DROP PROCEDURE usp_IndicadorComprasPorProveedor
GO

CREATE PROCEDURE usp_IndicadorComprasPorProveedor(
    @FechaInicio VARCHAR(20),
    @FechaFin VARCHAR(20)
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    DECLARE @FechaInicioDate DATE = CONVERT(DATE, @FechaInicio, 103);
    DECLARE @FechaFinDate DATE = CONVERT(DATE, @FechaFin, 103);
    
    SELECT 
        p.RazonSocial AS Proveedor,
        COUNT(DISTINCT op.IdOrdenPago) AS CantidadCompras,
        ISNULL(SUM(f.ImporteTotal), 0) AS TotalComprado
    FROM PROVEEDOR p
    LEFT JOIN ORDEN_COMPRA oc ON oc.IdProveedor = p.IdProveedor
    LEFT JOIN FACTURA f ON f.IdOrdenCompra = oc.IdOrdenCompra
    LEFT JOIN ORDEN_PAGO op ON op.IdFactura = f.IdFactura
        AND CONVERT(DATE, op.FechaRegistro) BETWEEN @FechaInicioDate AND @FechaFinDate
    GROUP BY p.IdProveedor, p.RazonSocial
    HAVING SUM(f.ImporteTotal) > 0
    ORDER BY TotalComprado DESC
END
GO

-- 2. Compras por Día
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorComprasPorDia')
    DROP PROCEDURE usp_IndicadorComprasPorDia
GO

CREATE PROCEDURE usp_IndicadorComprasPorDia(
    @FechaInicio VARCHAR(20),
    @FechaFin VARCHAR(20)
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    DECLARE @FechaInicioDate DATE = CONVERT(DATE, @FechaInicio, 103);
    DECLARE @FechaFinDate DATE = CONVERT(DATE, @FechaFin, 103);
    
    SELECT 
        CONVERT(DATE, op.FechaRegistro) AS Fecha,
        COUNT(DISTINCT op.IdOrdenPago) AS CantidadCompras,
        ISNULL(SUM(f.ImporteTotal), 0) AS TotalComprado
    FROM ORDEN_PAGO op
    INNER JOIN FACTURA f ON f.IdFactura = op.IdFactura
    WHERE CONVERT(DATE, op.FechaRegistro) BETWEEN @FechaInicioDate AND @FechaFinDate
    GROUP BY CONVERT(DATE, op.FechaRegistro)
    ORDER BY Fecha
END
GO

PRINT '========================================='
PRINT 'Procedimientos de Compras actualizados con ORDEN_PAGO'
PRINT '========================================='
GO
