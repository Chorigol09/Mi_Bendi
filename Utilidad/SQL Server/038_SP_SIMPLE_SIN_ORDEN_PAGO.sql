USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'SP SIMPLIFICADO - SIN VALIDAR ORDEN_PAGO'
PRINT '========================================='
PRINT ''

-- Eliminar SP si existe
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_OBTENER_FACTURAS_PENDIENTES_SIMPLE' AND type = 'P')
    DROP PROCEDURE SP_OBTENER_FACTURAS_PENDIENTES_SIMPLE
GO

-- Crear SP simplificado
CREATE PROCEDURE SP_OBTENER_FACTURAS_PENDIENTES_SIMPLE
    @IdProveedor INT
AS
BEGIN
    -- Version SIMPLE: Solo buscar facturas pendientes, sin validar ORDEN_PAGO
    SELECT 
        f.IdFactura,
        f.NumeroFactura,
        p.RazonSocial AS NombreProveedor,
        CONVERT(VARCHAR(10), f.FechaEmision, 103) AS FechaEmision,
        'Sin productos' AS Productos,
        0 AS Cantidad,
        f.Total AS MontoTotal
    FROM FACTURA f
    INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
    WHERE f.IdProveedor = @IdProveedor
      AND f.Estado = 'Pendiente'
    ORDER BY f.FechaEmision DESC
END
GO

PRINT '✓ SP_OBTENER_FACTURAS_PENDIENTES_SIMPLE creado'
PRINT ''

-- Probar el SP
PRINT '--- PRUEBA CON PROVEEDOR ID 1 ---'
EXEC SP_OBTENER_FACTURAS_PENDIENTES_SIMPLE 1
GO

PRINT ''
PRINT '--- PRUEBA CON PROVEEDOR ID 2 ---'
EXEC SP_OBTENER_FACTURAS_PENDIENTES_SIMPLE 2
GO

PRINT ''
PRINT '--- PRUEBA CON PROVEEDOR ID 3 ---'
EXEC SP_OBTENER_FACTURAS_PENDIENTES_SIMPLE 3
GO

PRINT ''
PRINT '========================================='
PRINT 'Si este SP funciona, el problema esta en'
PRINT 'la validacion de ORDEN_PAGO'
PRINT '========================================='
