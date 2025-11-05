USE [DBVENTAS_WEB]
GO

-- =============================================
-- Actualizar SP para incluir MetodoPago en lista de ventas
-- =============================================

-- Eliminar procedimiento anterior
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerListaVenta')
DROP PROCEDURE usp_ObtenerListaVenta
GO

-- PROCEDIMIENTO ACTUALIZADO PARA OBTENER LISTA VENTA CON MÉTODO DE PAGO
CREATE PROCEDURE usp_ObtenerListaVenta(
    @Codigo varchar(50) = '',
    @FechaInicio date,
    @FechaFin date,
    @NumeroDocumento varchar(50) = '',
    @Nombre varchar(100) = ''
)
AS
BEGIN
    SET DATEFORMAT dmy;
    
    SELECT v.IdVenta, 
           v.TipoDocumento,
           ISNULL(v.MetodoPago, 'Efectivo') AS MetodoPago,
           v.Codigo,
           v.FechaRegistro,
           c.NumeroDocumento,
           c.Nombre,
           v.TotalCosto 
    FROM VENTA v 
    INNER JOIN CLIENTE c ON c.IdCliente = v.IdCliente
    WHERE 
        v.Codigo = IIF(@Codigo='', v.Codigo, @Codigo) AND
        CONVERT(date, v.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin AND
        c.NumeroDocumento LIKE CONCAT('%', @NumeroDocumento, '%') AND
        c.Nombre LIKE CONCAT('%', @Nombre, '%')
END
GO

PRINT 'Stored procedure usp_ObtenerListaVenta actualizado exitosamente'

-- Ver el contenido del stored procedure
EXEC sp_helptext 'usp_ObtenerListaVenta'