USE DBVENTAS_WEB
GO

-- Actualizar procedimiento para incluir NumeroFactura y MetodoPago
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerDetalleVenta')
    DROP PROCEDURE usp_ObtenerDetalleVenta
GO

CREATE PROC usp_ObtenerDetalleVenta(
@IdVenta int
)
AS
BEGIN

SELECT 
    V.TipoDocumento, 
    V.NumeroFactura,
    V.MetodoPago,
    V.Codigo,
    CONVERT(decimal(10,2), V.TotalCosto)[TotalCosto],
    CONVERT(decimal(10,2),V.ImporteRecibido)[ImporteRecibido],
    CONVERT(decimal(10,2), V.ImporteCambio)[ImporteCambio],
    CONVERT(char(10),v.fechaRegistro,103)[FechaRegistro],
    
    (SELECT u.Nombres,u.Apellidos FROM USUARIO U
     WHERE U.IdUsuario = v.IdUsuario
     FOR XML PATH (''),TYPE) AS 'DETALLE_USUARIO',

    (SELECT T.RUC, T.Nombre, T.Direccion FROM TIENDA T
     WHERE T.IdTienda = V.IdTienda
     FOR XML PATH (''),TYPE) AS 'DETALLE_TIENDA',

    (SELECT C.Nombre,C.Direccion,C.NumeroDocumento,C.Telefono FROM CLIENTE c
     WHERE c.IdCliente = V.IdCliente
     FOR XML PATH (''),TYPE) AS 'DETALLE_CLIENTE',

    (SELECT dv.Cantidad,CONCAT(p.Nombre,'-',p.Descripcion)[NombreProducto],
     CONVERT(decimal(10,2),dv.PrecioUnidad)[PrecioUnidad],
     CONVERT(decimal(10,2),dv.ImporteTotal)[ImporteTotal] 
     FROM DETALLE_VENTA dv
     INNER JOIN PRODUCTO p ON p.IdProducto = dv.IdProducto
     WHERE dv.IdVenta = v.IdVenta
     FOR XML PATH ('PRODUCTO'),TYPE) AS 'DETALLE_PRODUCTO'

FROM VENTA v
WHERE v.IdVenta = @IdVenta
FOR XML PATH(''), ROOT('DETALLE_VENTA') 

END
GO

PRINT 'Procedimiento usp_ObtenerDetalleVenta actualizado con NumeroFactura y MetodoPago'
