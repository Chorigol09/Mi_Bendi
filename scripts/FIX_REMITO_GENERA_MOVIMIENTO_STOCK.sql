USE DBVENTAS_WEB
GO

-- =============================================
-- Script: Generar Movimiento de Stock al marcar Remito como Recibido
-- Descripción: Al cambiar estado de remito a "Recibido", se generan automáticamente
--              movimientos de stock tipo "Ingreso" para todos los productos del remito
-- =============================================

PRINT '╔════════════════════════════════════════════════╗'
PRINT '║    CONFIGURAR MOVIMIENTO DE STOCK AUTOMÁTICO   ║'
PRINT '║          AL RECIBIR UN REMITO                  ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

-- ============================================================
-- MODIFICAR SP usp_ActualizarEstadoRemito
-- ============================================================
PRINT '1. Modificando SP usp_ActualizarEstadoRemito...'
GO

CREATE OR ALTER PROCEDURE usp_ActualizarEstadoRemito(
    @IdRemito INT,
    @Estado VARCHAR(20),
    @IdUsuario INT = 1,  -- Usuario que marca como recibido (por defecto admin)
    @Resultado BIT OUTPUT
)
AS
BEGIN
    SET @Resultado = 0
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        DECLARE @EstadoAnterior VARCHAR(20)
        DECLARE @IdOrdenCompra INT
        DECLARE @IdTienda INT
        DECLARE @NumeroRemito VARCHAR(50)
        DECLARE @IdLote VARCHAR(50)
        
        -- Obtener estado anterior y datos del remito
        SELECT 
            @EstadoAnterior = Estado,
            @IdOrdenCompra = IdOrdenCompra,
            @NumeroRemito = NumeroRemito
        FROM REMITO 
        WHERE IdRemito = @IdRemito
        
        -- Obtener la tienda de la orden de compra
        SELECT @IdTienda = IdTienda
        FROM ORDEN_COMPRA
        WHERE IdCompra = @IdOrdenCompra
        
        -- Actualizar estado del remito
        UPDATE REMITO
        SET Estado = @Estado,
            FechaRecepcion = CASE WHEN @Estado = 'Recibido' THEN GETDATE() ELSE FechaRecepcion END
        WHERE IdRemito = @IdRemito
        
        -- ============================================================
        -- SI CAMBIÓ A "RECIBIDO" → GENERAR MOVIMIENTOS DE STOCK
        -- ============================================================
        IF @Estado = 'Recibido' AND @EstadoAnterior != 'Recibido'
        BEGIN
            -- Generar IdLote único para agrupar todos los movimientos de este remito
            SET @IdLote = 'REMITO-' + CAST(@IdRemito AS VARCHAR(10)) + '-' + CONVERT(VARCHAR(20), GETDATE(), 112)
            
            -- Motivo del movimiento
            DECLARE @Motivo VARCHAR(500) = 'Recepción de Remito ' + @NumeroRemito
            
            -- Variables para el cursor
            DECLARE @IdProducto INT
            DECLARE @Cantidad INT
            DECLARE @MensajeMovimiento VARCHAR(500)
            DECLARE @ResultadoMovimiento BIT
            
            -- Cursor para recorrer todos los productos del remito
            DECLARE cursor_productos CURSOR FOR
            SELECT IdProducto, Cantidad
            FROM DETALLE_REMITO
            WHERE IdRemito = @IdRemito
            
            OPEN cursor_productos
            FETCH NEXT FROM cursor_productos INTO @IdProducto, @Cantidad
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Verificar si el producto está asignado a la tienda
                IF NOT EXISTS (SELECT 1 FROM PRODUCTO_TIENDA WHERE IdProducto = @IdProducto AND IdTienda = @IdTienda)
                BEGIN
                    -- Si no existe, crear la relación con stock inicial 0
                    INSERT INTO PRODUCTO_TIENDA (IdProducto, IdTienda, Stock, Activo, FechaRegistro)
                    VALUES (@IdProducto, @IdTienda, 0, 1, GETDATE())
                END
                
                -- Registrar movimiento de stock tipo "Ingreso"
                EXEC usp_RegistrarMovimientoStock
                    @IdTienda = @IdTienda,
                    @IdProducto = @IdProducto,
                    @TipoMovimiento = 'Ingreso',
                    @Cantidad = @Cantidad,
                    @Motivo = @Motivo,
                    @IdUsuario = @IdUsuario,
                    @IdLote = @IdLote,
                    @Resultado = @ResultadoMovimiento OUTPUT,
                    @Mensaje = @MensajeMovimiento OUTPUT
                
                -- Si falla algún movimiento, hacer rollback
                IF @ResultadoMovimiento = 0
                BEGIN
                    CLOSE cursor_productos
                    DEALLOCATE cursor_productos
                    ROLLBACK TRANSACTION
                    RETURN
                END
                
                FETCH NEXT FROM cursor_productos INTO @IdProducto, @Cantidad
            END
            
            CLOSE cursor_productos
            DEALLOCATE cursor_productos
            
            PRINT '   ✓ Movimientos de stock generados para remito ' + @NumeroRemito
        END
        
        COMMIT TRANSACTION
        SET @Resultado = 1
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        
        SET @Resultado = 0
        
        -- Para debug
        PRINT 'Error: ' + ERROR_MESSAGE()
    END CATCH
END
GO

PRINT '   ✓ SP usp_ActualizarEstadoRemito actualizado'
PRINT ''

-- ============================================================
-- VERIFICACIÓN
-- ============================================================
PRINT '2. Verificación de la configuración...'
PRINT ''

-- Verificar que existe la columna IdLote en MOVIMIENTO_STOCK
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'MOVIMIENTO_STOCK' AND COLUMN_NAME = 'IdLote')
BEGIN
    PRINT '   ✓ Columna IdLote existe en MOVIMIENTO_STOCK'
END
ELSE
BEGIN
    PRINT '   ⚠️  ADVERTENCIA: Columna IdLote NO existe'
    PRINT '      Ejecuta primero: Script_Agregar_IdLote_MovimientoStock.sql'
END

-- Verificar que existe el SP usp_RegistrarMovimientoStock
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_RegistrarMovimientoStock]') AND type in (N'P', N'PC'))
BEGIN
    PRINT '   ✓ SP usp_RegistrarMovimientoStock existe'
END
ELSE
BEGIN
    PRINT '   ⚠️  ADVERTENCIA: SP usp_RegistrarMovimientoStock NO existe'
    PRINT '      Ejecuta primero: Script_MovimientoStock_FINAL.sql'
END

PRINT ''
PRINT '╔════════════════════════════════════════════════╗'
PRINT '║           ✅ CONFIGURACIÓN COMPLETADA          ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''
PRINT '✅ Ahora al marcar un remito como "Recibido":'
PRINT '   • Se generan movimientos de stock tipo "Ingreso"'
PRINT '   • Se actualiza el stock en PRODUCTO_TIENDA'
PRINT '   • Los movimientos se agrupan con IdLote único'
PRINT '   • Motivo: "Recepción de Remito REM-XXXXX"'
PRINT ''
PRINT '📝 Próximos pasos:'
PRINT '   1. Ir a Compras > Remitos'
PRINT '   2. Marcar un remito como "Recibido"'
PRINT '   3. Verificar en Reportes > Movimientos de Stock'
PRINT '   4. Verificar en Reportes > Productos por Tienda (stock actualizado)'
PRINT ''
GO
