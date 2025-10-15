USE [DBVENTAS_WEB]
GO

-- Agregar columna IdLote para agrupar movimientos registrados juntos
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'MOVIMIENTO_STOCK' AND COLUMN_NAME = 'IdLote')
BEGIN
    ALTER TABLE MOVIMIENTO_STOCK 
    ADD IdLote VARCHAR(50) NULL
    
    PRINT 'Columna IdLote agregada a MOVIMIENTO_STOCK'
END
ELSE
BEGIN
    PRINT 'La columna IdLote ya existe'
END
GO

-- Actualizar stored procedure para incluir IdLote
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_RegistrarMovimientoStock]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_RegistrarMovimientoStock]
GO

CREATE PROCEDURE [dbo].[usp_RegistrarMovimientoStock]
    @IdTienda INT,
    @IdProducto INT,
    @TipoMovimiento VARCHAR(20),
    @Cantidad INT,
    @Motivo VARCHAR(500),
    @IdUsuario INT,
    @IdLote VARCHAR(50),
    @Resultado BIT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StockActual INT
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Validar que existe el producto en la tienda
        IF NOT EXISTS (SELECT 1 FROM PRODUCTO_TIENDA WHERE IdProducto = @IdProducto AND IdTienda = @IdTienda)
        BEGIN
            SET @Resultado = 0
            SET @Mensaje = 'El producto no está asignado a esta tienda'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Obtener el stock actual de PRODUCTO_TIENDA
        SELECT @StockActual = ISNULL(Stock, 0)
        FROM PRODUCTO_TIENDA 
        WHERE IdProducto = @IdProducto AND IdTienda = @IdTienda
        
        -- Calcular el nuevo stock
        DECLARE @NuevoStock INT
        
        IF @TipoMovimiento = 'Ingreso'
        BEGIN
            SET @NuevoStock = @StockActual + @Cantidad
        END
        ELSE IF @TipoMovimiento = 'Egreso'
        BEGIN
            SET @NuevoStock = @StockActual - @Cantidad
            
            -- Validar que no quede stock negativo
            IF @NuevoStock < 0
            BEGIN
                SET @Resultado = 0
                SET @Mensaje = 'No hay suficiente stock. Stock actual: ' + CAST(@StockActual AS VARCHAR(10))
                ROLLBACK TRANSACTION
                RETURN
            END
        END
        ELSE
        BEGIN
            SET @Resultado = 0
            SET @Mensaje = 'Tipo de movimiento inválido'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Registrar el movimiento con IdLote
        INSERT INTO MOVIMIENTO_STOCK (IdTienda, IdProducto, TipoMovimiento, Cantidad, Motivo, IdUsuario, IdLote, FechaRegistro)
        VALUES (@IdTienda, @IdProducto, @TipoMovimiento, @Cantidad, @Motivo, @IdUsuario, @IdLote, GETDATE())
        
        -- Actualizar el stock en PRODUCTO_TIENDA
        UPDATE PRODUCTO_TIENDA 
        SET Stock = @NuevoStock
        WHERE IdProducto = @IdProducto AND IdTienda = @IdTienda
        
        SET @Resultado = 1
        SET @Mensaje = 'Movimiento registrado correctamente. Nuevo stock: ' + CAST(@NuevoStock AS VARCHAR(10))
        
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        SET @Resultado = 0
        SET @Mensaje = ERROR_MESSAGE()
    END CATCH
END
GO

PRINT 'Procedimiento usp_RegistrarMovimientoStock actualizado con IdLote'
GO

PRINT ''
PRINT '===================================='
PRINT '✓ Script ejecutado exitosamente!'
PRINT '===================================='
GO
