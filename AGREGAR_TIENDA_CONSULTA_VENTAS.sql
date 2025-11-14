USE DBVENTAS_WEB
GO

-- Actualizar procedimiento para incluir información de la tienda
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerListaVenta')
    DROP PROCEDURE usp_ObtenerListaVenta
GO

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
SELECT 
    v.IdVenta, 
    v.TipoDocumento, 
    v.Codigo, 
    v.NumeroFactura, 
    v.MetodoPago, 
    v.FechaRegistro, 
    v.FechaRegistro AS VFechaRegistro,
    c.NumeroDocumento, 
    c.Nombre, 
    v.TotalCosto,
    t.IdTienda,
    t.Nombre AS NombreTienda,
    t.RUC AS RUCTienda
FROM VENTA v 
INNER JOIN CLIENTE c ON c.IdCliente = v.IdCliente
INNER JOIN TIENDA t ON t.IdTienda = v.IdTienda
WHERE 
v.Codigo = IIF(@Codigo='',v.Codigo,@Codigo) AND
CONVERT(date,v.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin AND
c.NumeroDocumento LIKE CONCAT('%',@NumeroDocumento,'%') AND
c.Nombre LIKE CONCAT('%',@Nombre,'%')

END
GO

PRINT 'Procedimiento usp_ObtenerListaVenta actualizado con información de tienda'
