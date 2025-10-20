USE [DBVENTAS_WEB]
GO

PRINT 'Agregando tipo de movimiento Recepcion de Remito y columna NumeroRemito...'
GO

-- 1. Agregar tipo de movimiento "Recepción de remito"
IF NOT EXISTS (SELECT * FROM TIPO_MOV WHERE Descripcion = 'Recepcion de remito')
BEGIN
    INSERT INTO TIPO_MOV (Descripcion, TipoOperacion, Activo)
    VALUES ('Recepcion de remito', 'Ingreso', 1)
    
    PRINT 'Tipo de movimiento "Recepcion de remito" agregado'
END
ELSE
BEGIN
    PRINT 'El tipo de movimiento "Recepcion de remito" ya existe'
END
GO

-- 2. Agregar columna NumeroRemito a MOVIMIENTO_STOCK
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'MOVIMIENTO_STOCK' AND COLUMN_NAME = 'NumeroRemito')
BEGIN
    ALTER TABLE MOVIMIENTO_STOCK ADD NumeroRemito VARCHAR(50) NULL
    PRINT 'Columna NumeroRemito agregada a MOVIMIENTO_STOCK'
END
ELSE
BEGIN
    PRINT 'La columna NumeroRemito ya existe en MOVIMIENTO_STOCK'
END
GO

-- 3. Actualizar Stored Procedure usp_RegistrarMovimientoStock
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_RegistrarMovimientoStock]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_RegistrarMovimientoStock];
GO

CREATE PROCEDURE [dbo].[usp_RegistrarMovimientoStock]
    @IdTienda INT,
    @IdProducto INT,
    @IdTipoMov INT,
    @Cantidad INT,
    @Motivo VARCHAR(500),
    @IdUsuario INT,
    @IdLote VARCHAR(50),
    @NumeroRemito VARCHAR(50) = NULL,
    @Resultado BIT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StockActual INT
    DECLARE @TipoOperacion VARCHAR(20)
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Obtener el tipo de operación del TIPO_MOV
        SELECT @TipoOperacion = TipoOperacion
        FROM TIPO_MOV
        WHERE IdTipoMov = @IdTipoMov AND Activo = 1
        
        IF @TipoOperacion IS NULL
        BEGIN
            SET @Resultado = 0
            SET @Mensaje = 'Tipo de movimiento no válido o inactivo'
            ROLLBACK TRANSACTION
            RETURN
        END
        
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
        
        -- Calcular el nuevo stock basado en TipoOperacion
        DECLARE @NuevoStock INT
        
        IF @TipoOperacion = 'Ingreso'
        BEGIN
            SET @NuevoStock = @StockActual + @Cantidad
        END
        ELSE IF @TipoOperacion = 'Egreso'
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
            SET @Mensaje = 'Tipo de operación inválido'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Registrar el movimiento (ahora incluye NumeroRemito)
        INSERT INTO MOVIMIENTO_STOCK (IdTienda, IdProducto, TipoMovimiento, IdTipoMov, Cantidad, Motivo, IdUsuario, IdLote, NumeroRemito, FechaRegistro)
        VALUES (@IdTienda, @IdProducto, @TipoOperacion, @IdTipoMov, @Cantidad, @Motivo, @IdUsuario, @IdLote, @NumeroRemito, GETDATE())
        
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

PRINT 'Stored Procedure usp_RegistrarMovimientoStock actualizado'
GO

-- 4. Actualizar Stored Procedure usp_ObtenerMovimientosStock
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ObtenerMovimientosStock]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_ObtenerMovimientosStock];
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
        m.IdTipoMov,
        tm.Descripcion AS DescripcionTipoMov,
        tm.TipoOperacion,
        m.Cantidad,
        m.Motivo,
        m.NumeroRemito,
        m.IdUsuario,
        u.Nombres AS NombreUsuario,
        m.IdLote,
        m.FechaRegistro
    FROM 
        MOVIMIENTO_STOCK m
        INNER JOIN TIENDA t ON m.IdTienda = t.IdTienda
        INNER JOIN PRODUCTO p ON m.IdProducto = p.IdProducto
        INNER JOIN USUARIO u ON m.IdUsuario = u.IdUsuario
        LEFT JOIN TIPO_MOV tm ON m.IdTipoMov = tm.IdTipoMov
    WHERE 
        (@IdTienda = 0 OR m.IdTienda = @IdTienda)
    ORDER BY 
        m.FechaRegistro DESC
END
GO

PRINT 'Stored Procedure usp_ObtenerMovimientosStock actualizado'
GO

PRINT ''
PRINT '========================================='
PRINT 'Script completado exitosamente!'
PRINT '========================================='
PRINT '- Tipo de movimiento agregado'
PRINT '- Columna NumeroRemito agregada'
PRINT '- Stored Procedures actualizados'
PRINT '========================================='
GO
