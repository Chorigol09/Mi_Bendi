USE DBVENTAS_WEB
GO

-- ========================================
-- PROCEDIMIENTO 1: RESUMEN GENERAL
-- ========================================
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_IndicadorResumenGeneral')
    DROP PROCEDURE usp_IndicadorResumenGeneral
GO

CREATE PROCEDURE usp_IndicadorResumenGeneral(
    @FechaInicio VARCHAR(20),
    @FechaFin VARCHAR(20)
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    -- Convertir las fechas de string a date
    DECLARE @FechaInicioDate DATE = CONVERT(DATE, @FechaInicio, 103);
    DECLARE @FechaFinDate DATE = CONVERT(DATE, @FechaFin, 103);
    
    -- Ventas
    DECLARE @TotalVentas DECIMAL(18,2);
    DECLARE @CantidadVentas INT;
    DECLARE @PromedioVenta DECIMAL(18,2);
    DECLARE @UnidadesVendidas INT;
    DECLARE @ClientesUnicos INT;
    
    SELECT 
        @TotalVentas = ISNULL(SUM(TotalCosto), 0),
        @CantidadVentas = COUNT(*),
        @PromedioVenta = ISNULL(AVG(TotalCosto), 0),
        @UnidadesVendidas = ISNULL(SUM(CantidadTotal), 0),
        @ClientesUnicos = COUNT(DISTINCT IdCliente)
    FROM VENTA
    WHERE CONVERT(DATE, FechaRegistro) BETWEEN @FechaInicioDate AND @FechaFinDate;
    
    -- Compras desde ORDEN_PAGO
    DECLARE @TotalCompras DECIMAL(18,2) = 0;
    DECLARE @CantidadCompras INT = 0;
    
    SELECT 
        @TotalCompras = ISNULL(SUM(op.MontoTotal), 0),
        @CantidadCompras = COUNT(*)
    FROM ORDEN_PAGO op
    WHERE CONVERT(DATE, op.FechaRegistro) BETWEEN @FechaInicioDate AND @FechaFinDate;
    
    -- Margen
    DECLARE @MargenBruto DECIMAL(18,2) = @TotalVentas - @TotalCompras;
    
    -- Retornar resultados
    SELECT 
        @TotalVentas AS TotalVentas,
        @CantidadVentas AS CantidadVentas,
        @PromedioVenta AS PromedioVenta,
        @UnidadesVendidas AS UnidadesVendidas,
        @TotalCompras AS TotalCompras,
        @CantidadCompras AS CantidadCompras,
        @MargenBruto AS MargenBruto,
        @ClientesUnicos AS ClientesUnicos;
END
GO

-- ========================================
-- PROCEDIMIENTO 2: COMPRAS POR PROVEEDOR
-- ========================================
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
        ISNULL(SUM(op.MontoTotal), 0) AS TotalComprado
    FROM PROVEEDOR p
    LEFT JOIN FACTURA f ON f.IdProveedor = p.IdProveedor
    LEFT JOIN ORDEN_PAGO op ON op.IdFactura = f.IdFactura
        AND CONVERT(DATE, op.FechaRegistro) BETWEEN @FechaInicioDate AND @FechaFinDate
    GROUP BY p.IdProveedor, p.RazonSocial
    HAVING SUM(op.MontoTotal) > 0
    ORDER BY TotalComprado DESC
END
GO

-- ========================================
-- PROCEDIMIENTO 3: COMPRAS POR DIA
-- ========================================
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
        COUNT(*) AS CantidadCompras,
        ISNULL(SUM(op.MontoTotal), 0) AS TotalComprado
    FROM ORDEN_PAGO op
    WHERE CONVERT(DATE, op.FechaRegistro) BETWEEN @FechaInicioDate AND @FechaFinDate
    GROUP BY CONVERT(DATE, op.FechaRegistro)
    ORDER BY Fecha
END
GO

PRINT '========================================='
PRINT 'Todos los procedimientos de indicadores creados correctamente'
PRINT '========================================='
GO

-- Probar el procedimiento principal
EXEC usp_IndicadorResumenGeneral '13/10/2025', '13/11/2025'
GO
