USE DBVENTAS_WEB
GO

PRINT '=========================================='
PRINT 'ACTUALIZANDO SP OBTENER FACTURAS'
PRINT '=========================================='
PRINT ''

-- Eliminar SP si existe
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerFacturas')
BEGIN
    DROP PROCEDURE usp_ObtenerFacturas
    PRINT 'SP anterior eliminado'
END
GO

CREATE PROCEDURE usp_ObtenerFacturas
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        f.IdFactura,
        f.IdProveedor,
        p.RazonSocial,
        f.NumeroFactura,
        f.Total,
        f.Estado,
        f.Activo,
        f.FechaEmision,
        f.FechaPago,
        ISNULL(f.Observaciones, '') AS Observaciones,
        -- Campos adicionales para la vista
        CONVERT(VARCHAR(10), f.FechaEmision, 103) AS FechaOrdenCompra,
        ISNULL((
            SELECT COUNT(DISTINCT df.IdProducto)
            FROM DETALLE_FACTURA df
            WHERE df.IdFactura = f.IdFactura AND df.Activo = 1
        ), 0) AS CantidadProductos,
        ISNULL((
            SELECT STUFF((
                SELECT ', ' + pr.Nombre
                FROM DETALLE_FACTURA df
                INNER JOIN PRODUCTO pr ON df.IdProducto = pr.IdProducto
                WHERE df.IdFactura = f.IdFactura AND df.Activo = 1
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 2, '')
        ), '') AS Productos,
        0 AS IdOrdenCompra -- Campo para compatibilidad
    FROM FACTURA f
    INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
    WHERE f.Activo = 1
    ORDER BY f.FechaEmision DESC, f.IdFactura DESC
END
GO

PRINT ''
PRINT 'SP actualizado exitosamente'
PRINT ''

-- Verificar que se creó
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerFacturas')
BEGIN
    PRINT 'VERIFICACION OK: SP existe'
    PRINT ''
    
    -- Probar el SP
    PRINT 'Probando SP...'
    EXEC usp_ObtenerFacturas
    PRINT ''
    PRINT 'SP ejecutado correctamente'
END
ELSE
BEGIN
    PRINT 'ERROR: SP NO se creo'
END

PRINT ''
PRINT '=========================================='
PRINT 'COMPLETADO'
PRINT '=========================================='
GO
