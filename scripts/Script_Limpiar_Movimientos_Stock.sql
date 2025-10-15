USE [DBVENTAS_WEB]
GO

-- ====================================================================
-- Script para limpiar datos de Movimientos de Stock
-- ADVERTENCIA: Este script eliminará TODOS los movimientos de stock
-- ====================================================================

PRINT '======================================================================'
PRINT 'LIMPIEZA DE DATOS - MOVIMIENTOS DE STOCK'
PRINT '======================================================================'
PRINT ''

-- Mostrar cantidad de registros antes de borrar
DECLARE @CantidadMovimientos INT
SELECT @CantidadMovimientos = COUNT(*) FROM MOVIMIENTO_STOCK
PRINT 'Movimientos de stock actuales: ' + CAST(@CantidadMovimientos AS VARCHAR(10))
PRINT ''

-- Confirmar antes de continuar
PRINT 'Se eliminaran ' + CAST(@CantidadMovimientos AS VARCHAR(10)) + ' registros de movimientos'
PRINT ''

-- OPCION 1: Eliminar SOLO movimientos de stock (mantiene productos y stocks actuales)
BEGIN TRANSACTION

BEGIN TRY
    -- Eliminar todos los movimientos de stock
    DELETE FROM MOVIMIENTO_STOCK
    
    PRINT 'Movimientos de stock eliminados correctamente'
    PRINT ''
    
    COMMIT TRANSACTION
    PRINT 'Transaccion completada exitosamente'
    
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT 'ERROR: ' + ERROR_MESSAGE()
END CATCH

GO

-- ====================================================================
-- OPCIONAL: Descomentar si tambien quieres RESETEAR STOCKS a 0
-- ====================================================================
/*
BEGIN TRANSACTION

BEGIN TRY
    -- Resetear todos los stocks a 0
    UPDATE PRODUCTO_TIENDA SET Stock = 0
    
    PRINT 'Stocks de productos reseteados a 0'
    
    COMMIT TRANSACTION
    PRINT 'Stocks reseteados exitosamente'
    
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT 'ERROR al resetear stocks: ' + ERROR_MESSAGE()
END CATCH
*/

GO

-- Verificar resultado
SELECT COUNT(*) AS 'Movimientos Restantes' FROM MOVIMIENTO_STOCK
GO

PRINT ''
PRINT '======================================================================'
PRINT 'Proceso completado'
PRINT '======================================================================'
GO
