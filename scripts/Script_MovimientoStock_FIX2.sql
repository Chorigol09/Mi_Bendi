USE [DBVENTAS_WEB]
GO

-- =============================================
-- Verificar estructura de PRODUCTO_TIENDA
-- =============================================
PRINT 'Columnas de la tabla PRODUCTO_TIENDA:'
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'PRODUCTO_TIENDA'
ORDER BY ORDINAL_POSITION
GO

-- =============================================
-- Verificar estructura de PRODUCTO
-- =============================================
PRINT ''
PRINT 'Columnas de la tabla PRODUCTO:'
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'PRODUCTO'
ORDER BY ORDINAL_POSITION
GO

-- =============================================
-- Si la columna Stock no existe, crearla
-- =============================================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'PRODUCTO_TIENDA' AND COLUMN_NAME = 'Stock')
BEGIN
    PRINT ''
    PRINT 'Agregando columna Stock a PRODUCTO_TIENDA...'
    ALTER TABLE PRODUCTO_TIENDA ADD Stock INT NOT NULL DEFAULT 0
    PRINT 'Columna Stock agregada.'
END
ELSE
BEGIN
    PRINT ''
    PRINT 'La columna Stock ya existe en PRODUCTO_TIENDA'
END
GO

-- =============================================
-- Recrear tabla MOVIMIENTO_STOCK
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MOVIMIENTO_STOCK]') AND type in (N'U'))
BEGIN
    PRINT 'Eliminando tabla MOVIMIENTO_STOCK existente...'
    DROP TABLE [dbo].[MOVIMIENTO_STOCK]
END
GO

CREATE TABLE [dbo].[MOVIMIENTO_STOCK](
    [IdMovimiento] [int] IDENTITY(1,1) NOT NULL,
    [IdTienda] [int] NOT NULL,
    [IdProducto] [int] NOT NULL,
    [TipoMovimiento] [varchar](20) NOT NULL,
    [Cantidad] [int] NOT NULL,
    [Motivo] [varchar](500) NULL,
    [IdUsuario] [int] NOT NULL,
    [FechaRegistro] [datetime] NULL DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([IdMovimiento] ASC),
    CONSTRAINT FK_MOVIMIENTO_STOCK_TIENDA FOREIGN KEY ([IdTienda]) REFERENCES [dbo].[TIENDA]([IdTienda]),
    CONSTRAINT FK_MOVIMIENTO_STOCK_PRODUCTO FOREIGN KEY ([IdProducto]) REFERENCES [dbo].[PRODUCTO]([IdProducto]),
    CONSTRAINT FK_MOVIMIENTO_STOCK_USUARIO FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[USUARIO]([IdUsuario])
)
GO

PRINT 'Tabla MOVIMIENTO_STOCK creada'
GO

-- =============================================
-- Stored Procedure: usp_ObtenerMovimientosStock
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ObtenerMovimientosStock]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_ObtenerMovimientosStock]
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
        m.Cantidad,
        m.Motivo,
        m.IdUsuario,
        u.Nombres AS NombreUsuario,
        m.FechaRegistro
    FROM 
        MOVIMIENTO_STOCK m
        INNER JOIN TIENDA t ON m.IdTienda = t.IdTienda
        INNER JOIN PRODUCTO p ON m.IdProducto = p.IdProducto
        INNER JOIN USUARIO u ON m.IdUsuario = u.IdUsuario
    WHERE 
        (@IdTienda = 0 OR m.IdTienda = @IdTienda)
    ORDER BY 
        m.FechaRegistro DESC
END
GO

PRINT 'Procedimiento usp_ObtenerMovimientosStock creado'
GO

-- =============================================
-- Stored Procedure: usp_RegistrarMovimientoStock
-- =============================================
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
        
        -- Registrar el movimiento
        INSERT INTO MOVIMIENTO_STOCK (IdTienda, IdProducto, TipoMovimiento, Cantidad, Motivo, IdUsuario, FechaRegistro)
        VALUES (@IdTienda, @IdProducto, @TipoMovimiento, @Cantidad, @Motivo, @IdUsuario, GETDATE())
        
        -- Actualizar el stock en PRODUCTO_TIENDA
        UPDATE PRODUCTO_TIENDA 
        SET Stock = @NuevoStock
        WHERE IdProducto = @IdProducto AND IdTienda = @IdTienda
        
        -- Actualizar el stock general del producto (suma de todas las tiendas) si existe la columna
        IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PRODUCTO' AND COLUMN_NAME = 'Stock')
        BEGIN
            DECLARE @StockTotal INT
            SELECT @StockTotal = SUM(ISNULL(Stock, 0))
            FROM PRODUCTO_TIENDA 
            WHERE IdProducto = @IdProducto
            
            UPDATE PRODUCTO 
            SET Stock = @StockTotal
            WHERE IdProducto = @IdProducto
        END
        
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

PRINT 'Procedimiento usp_RegistrarMovimientoStock creado'
GO

PRINT '===================================='
PRINT 'Script ejecutado exitosamente!'
PRINT '===================================='
GO
