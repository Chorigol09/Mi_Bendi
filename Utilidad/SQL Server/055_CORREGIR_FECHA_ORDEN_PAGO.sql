-- =============================================
-- Script: Corregir fecha en consulta de ordenes de pago
-- Descripcion: Mostrar fecha de registro de la orden en lugar de fecha de factura
-- Fecha: 2025-11-10
-- =============================================

USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'ACTUALIZANDO SP_OBTENER_ORDENES_PAGO'
PRINT '========================================='
PRINT ''

-- =============================================
-- SP: Obtener Ordenes de Pago (con fecha de orden)
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
        -- Concatenar numeros de facturas
        STUFF((
            SELECT ', ' + f.NumeroFactura
            FROM DETALLE_ORDEN_PAGO dop
            INNER JOIN FACTURA f ON dop.IdFactura = f.IdFactura
            WHERE dop.IdOrdenPago = op.IdOrdenPago
            FOR XML PATH('')
        ), 1, 2, '') AS NumeroFactura,
        -- Fecha de registro de la orden de pago (NO fecha de factura)
        CONVERT(VARCHAR(10), op.FechaRegistro, 103) AS FechaEmision,
        -- Cantidad de facturas en la orden
        (SELECT COUNT(*)
         FROM DETALLE_ORDEN_PAGO dop
         WHERE dop.IdOrdenPago = op.IdOrdenPago) AS CantidadFacturas,
        op.MetodoPago,
        op.MontoTotal,
        op.FechaRegistro,
        op.Estado,
        op.UsuarioRegistro,
        0 AS IdFactura -- Para compatibilidad con codigo existente
    FROM ORDEN_PAGO op
    INNER JOIN PROVEEDOR p ON op.IdProveedor = p.IdProveedor
    WHERE (@IdProveedor IS NULL OR op.IdProveedor = @IdProveedor)
    ORDER BY op.FechaRegistro DESC
END
GO

PRINT '✓ SP_OBTENER_ORDENES_PAGO actualizado'
PRINT '  - Ahora muestra FechaRegistro de la orden de pago'
PRINT '  - Eliminados campos Productos y Cantidad (ya no se usan)'
PRINT ''
PRINT '========================================='
PRINT 'ACTUALIZACION COMPLETADA'
PRINT '========================================='
GO
