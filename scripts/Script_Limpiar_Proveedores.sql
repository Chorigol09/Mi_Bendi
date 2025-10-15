USE [DBVENTAS_WEB]
GO

-- ====================================================================
-- Script para limpiar proveedores
-- ADVERTENCIA: Este script eliminará:
-- - Todas las ordenes de compra (encabezado y detalle)
-- - Todos los proveedores
-- ====================================================================

PRINT '======================================================================'
PRINT 'LIMPIEZA DE PROVEEDORES'
PRINT '======================================================================'
PRINT ''

-- Mostrar cantidades antes de borrar
DECLARE @CantDetalleOrdenCompra INT = 0, @CantOrdenCompra INT = 0, @CantProveedores INT = 0

IF OBJECT_ID('DETALLE_ORDEN_COMPRA', 'U') IS NOT NULL
    SELECT @CantDetalleOrdenCompra = COUNT(*) FROM DETALLE_ORDEN_COMPRA

IF OBJECT_ID('ORDEN_COMPRA', 'U') IS NOT NULL
    SELECT @CantOrdenCompra = COUNT(*) FROM ORDEN_COMPRA

IF OBJECT_ID('PROVEEDOR', 'U') IS NOT NULL
    SELECT @CantProveedores = COUNT(*) FROM PROVEEDOR

PRINT 'Registros a eliminar:'
PRINT '  - Detalles de ordenes de compra: ' + CAST(@CantDetalleOrdenCompra AS VARCHAR(10))
PRINT '  - Ordenes de compra: ' + CAST(@CantOrdenCompra AS VARCHAR(10))
PRINT '  - Proveedores: ' + CAST(@CantProveedores AS VARCHAR(10))
PRINT ''

-- Eliminar todo en el orden correcto (respetando foreign keys)
BEGIN TRANSACTION

BEGIN TRY
    -- 1. Eliminar detalles de ordenes de compra (si existen)
    IF OBJECT_ID('DETALLE_ORDEN_COMPRA', 'U') IS NOT NULL
    BEGIN
        DELETE FROM DETALLE_ORDEN_COMPRA
        PRINT '1. Detalles de ordenes de compra eliminados'
    END
    
    -- 2. Eliminar ordenes de compra (si existen)
    IF OBJECT_ID('ORDEN_COMPRA', 'U') IS NOT NULL
    BEGIN
        DELETE FROM ORDEN_COMPRA
        PRINT '2. Ordenes de compra eliminadas'
    END
    
    -- 3. Eliminar proveedores (si existen)
    IF OBJECT_ID('PROVEEDOR', 'U') IS NOT NULL
    BEGIN
        DELETE FROM PROVEEDOR
        PRINT '3. Proveedores eliminados'
    END
    
    PRINT ''
    COMMIT TRANSACTION
    PRINT 'Limpieza de proveedores exitosa'
    
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
IF OBJECT_ID('DETALLE_ORDEN_COMPRA', 'U') IS NOT NULL
    SELECT COUNT(*) AS 'Detalles Orden Compra Restantes' FROM DETALLE_ORDEN_COMPRA
IF OBJECT_ID('ORDEN_COMPRA', 'U') IS NOT NULL
    SELECT COUNT(*) AS 'Ordenes Compra Restantes' FROM ORDEN_COMPRA
IF OBJECT_ID('PROVEEDOR', 'U') IS NOT NULL
    SELECT COUNT(*) AS 'Proveedores Restantes' FROM PROVEEDOR

GO

PRINT ''
PRINT '======================================================================'
PRINT 'Proceso completado'
PRINT '======================================================================'
GO
