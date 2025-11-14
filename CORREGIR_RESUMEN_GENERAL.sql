USE DBVENTAS_WEB
GO

-- Corregir procedimiento de resumen general
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
    
    DECLARE @TotalVentas DECIMAL(18,2) = 0;
    DECLARE @CantidadVentas INT = 0;
    DECLARE @PromedioVenta DECIMAL(18,2) = 0;
    DECLARE @UnidadesVendidas INT = 0;
    DECLARE @TotalCompras DECIMAL(18,2) = 0;
    DECLARE @CantidadCompras INT = 0;
    DECLARE @MargenBruto DECIMAL(18,2) = 0;
    DECLARE @ClientesUnicos INT = 0;
    
    -- Calcular ventas
    SELECT 
        @TotalVentas = ISNULL(SUM(TotalCosto), 0),
        @CantidadVentas = COUNT(*),
        @PromedioVenta = ISNULL(AVG(TotalCosto), 0),
        @UnidadesVendidas = ISNULL(SUM(CantidadTotal), 0),
        @ClientesUnicos = COUNT(DISTINCT IdCliente)
    FROM VENTA
    WHERE CONVERT(DATE, FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    
    -- Calcular compras
    SELECT 
        @TotalCompras = ISNULL(SUM(TotalCosto), 0),
        @CantidadCompras = COUNT(*)
    FROM COMPRA
    WHERE CONVERT(DATE, FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
    
    -- Calcular margen
    SET @MargenBruto = @TotalVentas - @TotalCompras
    
    -- Retornar resultados
    SELECT 
        @TotalVentas AS TotalVentas,
        @CantidadVentas AS CantidadVentas,
        @PromedioVenta AS PromedioVenta,
        @UnidadesVendidas AS UnidadesVendidas,
        @TotalCompras AS TotalCompras,
        @CantidadCompras AS CantidadCompras,
        @MargenBruto AS MargenBruto,
        @ClientesUnicos AS ClientesUnicos
END
GO

PRINT 'Procedimiento usp_IndicadorResumenGeneral corregido'
GO
