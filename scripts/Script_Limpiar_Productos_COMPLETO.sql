USE [DBVENTAS_WEB]
GO

-- ====================================================================
-- Script para limpiar COMPLETAMENTE productos y movimientos
-- ADVERTENCIA: Este script eliminará:
-- - Todos los detalles de ventas
-- - Todos los detalles de facturas
-- - Todos los detalles de remitos
-- - Todos los detalles de ordenes de compra
-- - Todos los movimientos de stock
-- - Todas las asignaciones producto-tienda
-- - Todos los productos
-- NOTA: Las ventas, facturas, remitos y ordenes principales se mantienen (solo sus detalles se eliminan)
-- ====================================================================

PRINT '======================================================================'
PRINT 'LIMPIEZA COMPLETA - PRODUCTOS Y MOVIMIENTOS'
PRINT '======================================================================'
PRINT ''

-- Mostrar cantidades antes de borrar
DECLARE @CantMovimientos INT, @CantProductoTienda INT, @CantProductos INT
DECLARE @CantDetalleVenta INT = 0, @CantDetalleFactura INT = 0, @CantDetalleRemito INT = 0, @CantDetalleOrdenCompra INT = 0

SELECT @CantMovimientos = COUNT(*) FROM MOVIMIENTO_STOCK
SELECT @CantProductoTienda = COUNT(*) FROM PRODUCTO_TIENDA
SELECT @CantProductos = COUNT(*) FROM PRODUCTO

IF OBJECT_ID('DETALLE_VENTA', 'U') IS NOT NULL
    SELECT @CantDetalleVenta = COUNT(*) FROM DETALLE_VENTA
IF OBJECT_ID('DETALLE_FACTURA', 'U') IS NOT NULL
    SELECT @CantDetalleFactura = COUNT(*) FROM DETALLE_FACTURA
IF OBJECT_ID('DETALLE_REMITO', 'U') IS NOT NULL
    SELECT @CantDetalleRemito = COUNT(*) FROM DETALLE_REMITO
IF OBJECT_ID('DETALLE_ORDEN_COMPRA', 'U') IS NOT NULL
    SELECT @CantDetalleOrdenCompra = COUNT(*) FROM DETALLE_ORDEN_COMPRA

PRINT 'Registros a eliminar:'
PRINT '  - Detalles de ventas: ' + CAST(@CantDetalleVenta AS VARCHAR(10))
PRINT '  - Detalles de facturas: ' + CAST(@CantDetalleFactura AS VARCHAR(10))
PRINT '  - Detalles de remitos: ' + CAST(@CantDetalleRemito AS VARCHAR(10))
PRINT '  - Detalles de ordenes de compra: ' + CAST(@CantDetalleOrdenCompra AS VARCHAR(10))
PRINT '  - Movimientos de stock: ' + CAST(@CantMovimientos AS VARCHAR(10))
PRINT '  - Producto-Tienda: ' + CAST(@CantProductoTienda AS VARCHAR(10))
PRINT '  - Productos: ' + CAST(@CantProductos AS VARCHAR(10))
PRINT ''

-- Eliminar todo en el orden correcto (respetando foreign keys)
BEGIN TRANSACTION

BEGIN TRY
    -- 1. Eliminar detalles de ventas (si existen)
    IF OBJECT_ID('DETALLE_VENTA', 'U') IS NOT NULL
    BEGIN
        DELETE FROM DETALLE_VENTA
        PRINT '1. Detalles de ventas eliminados'
    END
    
    -- 2. Eliminar detalles de facturas (si existen)
    IF OBJECT_ID('DETALLE_FACTURA', 'U') IS NOT NULL
    BEGIN
        DELETE FROM DETALLE_FACTURA
        PRINT '2. Detalles de facturas eliminados'
    END
    
    -- 3. Eliminar detalles de remitos (si existen)
    IF OBJECT_ID('DETALLE_REMITO', 'U') IS NOT NULL
    BEGIN
        DELETE FROM DETALLE_REMITO
        PRINT '3. Detalles de remitos eliminados'
    END
    
    -- 4. Eliminar detalles de ordenes de compra (si existen)
    IF OBJECT_ID('DETALLE_ORDEN_COMPRA', 'U') IS NOT NULL
    BEGIN
        DELETE FROM DETALLE_ORDEN_COMPRA
        PRINT '4. Detalles de ordenes de compra eliminados'
    END
    
    -- 5. Eliminar movimientos de stock
    DELETE FROM MOVIMIENTO_STOCK
    PRINT '5. Movimientos de stock eliminados'
    
    -- 6. Eliminar relaciones producto-tienda
    DELETE FROM PRODUCTO_TIENDA
    PRINT '6. Relaciones producto-tienda eliminadas'
    
    -- 7. Eliminar productos
    DELETE FROM PRODUCTO
    PRINT '7. Productos eliminados'
    
    PRINT ''
    COMMIT TRANSACTION
    PRINT 'Limpieza completa exitosa'
    
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT ''
    PRINT 'ERROR: ' + ERROR_MESSAGE()
    PRINT 'Ningun cambio fue aplicado (rollback ejecutado)'
END CATCH

GO

-- Verificar resultado
PRINT ''
PRINT 'Verificacion de tablas:'
IF OBJECT_ID('DETALLE_VENTA', 'U') IS NOT NULL
    SELECT COUNT(*) AS 'Detalles Venta Restantes' FROM DETALLE_VENTA
IF OBJECT_ID('DETALLE_FACTURA', 'U') IS NOT NULL
    SELECT COUNT(*) AS 'Detalles Factura Restantes' FROM DETALLE_FACTURA
IF OBJECT_ID('DETALLE_REMITO', 'U') IS NOT NULL
    SELECT COUNT(*) AS 'Detalles Remito Restantes' FROM DETALLE_REMITO
IF OBJECT_ID('DETALLE_ORDEN_COMPRA', 'U') IS NOT NULL
    SELECT COUNT(*) AS 'Detalles Orden Compra Restantes' FROM DETALLE_ORDEN_COMPRA
SELECT COUNT(*) AS 'Movimientos Restantes' FROM MOVIMIENTO_STOCK
SELECT COUNT(*) AS 'Producto-Tienda Restantes' FROM PRODUCTO_TIENDA
SELECT COUNT(*) AS 'Productos Restantes' FROM PRODUCTO

GO

PRINT ''
PRINT '======================================================================'
PRINT 'Proceso completado'
PRINT '======================================================================'
GO
