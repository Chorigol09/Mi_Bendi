USE [DBVENTAS_WEB]
GO

-- Actualizar SP para incluir IdLote
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ObtenerMovimientosStock]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_ObtenerMovimientosStock]
GO

CREATE PROCEDURE [dbo].[usp_ObtenerMovimientosStock]
    @IdTienda INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        m.IdMovimiento,
        m.IdTienda,
        t.Nombre AS NombreTienda,
        m.IdProducto,
        p.Codigo AS CodigoProducto,
        p.Nombre AS NombreProducto,
        m.TipoMovimiento,
        m.Cantidad,
        m.Motivo,
        m.IdUsuario,
        u.Nombres AS NombreUsuario,
        m.IdLote,
        m.FechaRegistro
    FROM 
        MOVIMIENTO_STOCK m
        INNER JOIN TIENDA t ON m.IdTienda = t.IdTienda
        INNER JOIN PRODUCTO p ON m.IdProducto = p.IdProducto
        INNER JOIN USUARIO u ON m.IdUsuario = u.IdUsuario
    WHERE 
        (@IdTienda = 0 OR m.IdTienda = @IdTienda)
    ORDER BY 
        m.FechaRegistro DESC
END
GO

PRINT 'SP usp_ObtenerMovimientosStock actualizado con IdLote'
GO
