-- =============================================
-- Script: Optimizar SPs de Orden Pago (sin columnas Productos y Cantidad)
-- Descripción: Eliminar campos no necesarios para mejorar rendimiento
-- Fecha: 2025-11-10
-- =============================================

USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'OPTIMIZANDO STORED PROCEDURES'
PRINT '========================================='
PRINT ''

-- =============================================
-- SP: Obtener Facturas Pendientes (SIN productos ni cantidad)
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_OBTENER_FACTURAS_PENDIENTES' AND type = 'P')
    DROP PROCEDURE SP_OBTENER_FACTURAS_PENDIENTES
GO

CREATE PROCEDURE SP_OBTENER_FACTURAS_PENDIENTES
    @IdProveedor INT
AS
BEGIN
    SELECT 
        f.IdFactura,
        f.NumeroFactura,
        p.RazonSocial AS NombreProveedor,
        CONVERT(VARCHAR(10), f.FechaEmision, 103) AS FechaEmision,
        f.Total AS MontoTotal
    FROM FACTURA f
    INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
    WHERE f.IdProveedor = @IdProveedor
      AND f.Estado = 'Pendiente'
    ORDER BY f.FechaEmision DESC
END
GO

PRINT '✓ SP_OBTENER_FACTURAS_PENDIENTES optimizado (sin Productos ni Cantidad)'
GO

-- =============================================
-- SP: Obtener Órdenes de Pago (SIN productos ni cantidad)
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_OBTENER_ORDENES_PAGO' AND type = 'P')
    DROP PROCEDURE SP_OBTENER_ORDENES_PAGO
GO

CREATE PROCEDURE SP_OBTENER_ORDENES_PAGO
    @IdProveedor INT = NULL
AS
BEGIN
    SELECT 
        op.IdOrdenPago,
        op.NumeroOrdenPago,
        op.IdProveedor,
        p.RazonSocial AS NombreProveedor,
        -- Concatenar números de facturas
        STUFF((
            SELECT ', ' + f.NumeroFactura
            FROM DETALLE_ORDEN_PAGO dop
            INNER JOIN FACTURA f ON dop.IdFactura = f.IdFactura
            WHERE dop.IdOrdenPago = op.IdOrdenPago
            FOR XML PATH('')
        ), 1, 2, '') AS NumeroFactura,
        -- Primera fecha de emisión (para ordenar/mostrar)
        (SELECT TOP 1 CONVERT(VARCHAR(10), f.FechaEmision, 103)
         FROM DETALLE_ORDEN_PAGO dop
         INNER JOIN FACTURA f ON dop.IdFactura = f.IdFactura
         WHERE dop.IdOrdenPago = op.IdOrdenPago
         ORDER BY f.FechaEmision) AS FechaEmision,
        -- Cantidad de facturas en la orden
        (SELECT COUNT(*)
         FROM DETALLE_ORDEN_PAGO dop
         WHERE dop.IdOrdenPago = op.IdOrdenPago) AS CantidadFacturas,
        op.MetodoPago,
        op.MontoTotal,
        op.FechaRegistro,
        op.Estado,
        op.UsuarioRegistro,
        0 AS IdFactura -- Para compatibilidad con código existente
    FROM ORDEN_PAGO op
    INNER JOIN PROVEEDOR p ON op.IdProveedor = p.IdProveedor
    WHERE (@IdProveedor IS NULL OR op.IdProveedor = @IdProveedor)
    ORDER BY op.FechaRegistro DESC
END
GO

PRINT '✓ SP_OBTENER_ORDENES_PAGO optimizado (sin Productos ni Cantidad)'
GO

PRINT ''
PRINT '========================================='
PRINT 'OPTIMIZACIÓN COMPLETADA'
PRINT '========================================='
PRINT 'Los stored procedures ya no devuelven'
PRINT 'las columnas Productos y Cantidad'
PRINT '========================================='
GO
