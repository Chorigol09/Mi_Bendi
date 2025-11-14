USE DBVENTAS_WEB
GO

-- Eliminar procedimiento anterior
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
    
    -- Compras desde ORDEN_PAGO y FACTURA
    DECLARE @TotalCompras DECIMAL(18,2) = 0;
    DECLARE @CantidadCompras INT = 0;
    
    SELECT 
        @TotalCompras = ISNULL(SUM(f.ImporteTotal), 0),
        @CantidadCompras = COUNT(DISTINCT op.IdOrdenPago)
    FROM ORDEN_PAGO op
    INNER JOIN FACTURA f ON f.IdFactura = op.IdFactura
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

PRINT 'Procedimiento usp_IndicadorResumenGeneral creado correctamente (con ORDEN_PAGO y FACTURA)'
GO

-- Probar el procedimiento
EXEC usp_IndicadorResumenGeneral '13/10/2025', '13/11/2025'
GO
