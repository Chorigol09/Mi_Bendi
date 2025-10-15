USE [DBVENTAS_WEB]
GO

-- =============================================
-- Crear tabla MOVIMIENTO_STOCK
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MOVIMIENTO_STOCK]') AND type in (N'U'))
BEGIN
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
        FOREIGN KEY ([IdTienda]) REFERENCES [dbo].[TIENDA]([IdTienda]),
        FOREIGN KEY ([IdProducto]) REFERENCES [dbo].[PRODUCTO]([IdProducto]),
        FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[USUARIO]([IdUsuario])
    )
    PRINT 'Tabla MOVIMIENTO_STOCK creada exitosamente'
END
ELSE
BEGIN
    PRINT 'La tabla MOVIMIENTO_STOCK ya existe'
END
GO

-- =============================================
-- Stored Procedure: usp_ObtenerMovimientosStock
-- Descripción: Obtiene el historial de movimientos de stock
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
        u.Nombre AS NombreUsuario,
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

-- =============================================
-- Stored Procedure: usp_RegistrarMovimientoStock
-- Descripción: Registra un movimiento de stock y actualiza el inventario
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
        
        -- Obtener el stock actual
        SELECT @StockActual = Stock 
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
        
        -- Actualizar el stock general del producto (suma de todas las tiendas)
        DECLARE @StockTotal INT
        SELECT @StockTotal = SUM(Stock) 
        FROM PRODUCTO_TIENDA 
        WHERE IdProducto = @IdProducto
        
        UPDATE PRODUCTO 
        SET Stock = @StockTotal
        WHERE IdProducto = @IdProducto
        
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

PRINT 'Stored Procedures creados exitosamente'
GO

-- =============================================
-- Agregar permisos al menú (opcional)
-- =============================================
-- Si deseas agregar un item de menú para los movimientos de stock, 
-- deberás ejecutar los siguientes scripts según tu estructura de permisos:

/*
-- Ejemplo de cómo agregar un nuevo item al menú
-- Ajusta según tu estructura de menús y permisos

DECLARE @IdMenu INT

-- Insertar en MENU si aún no existe
IF NOT EXISTS (SELECT 1 FROM MENU WHERE Nombre = 'Inventario')
BEGIN
    INSERT INTO MENU (Nombre, Icono, Activo, FechaRegistro)
    VALUES ('Inventario', 'fa fa-warehouse', 1, GETDATE())
    
    SET @IdMenu = SCOPE_IDENTITY()
END
ELSE
BEGIN
    SELECT @IdMenu = IdMenu FROM MENU WHERE Nombre = 'Inventario'
END

-- Insertar en SUBMENU si aún no existe
IF NOT EXISTS (SELECT 1 FROM SUBMENU WHERE Nombre = 'Movimientos de Stock')
BEGIN
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Accion, Activo, FechaRegistro)
    VALUES (@IdMenu, 'Movimientos de Stock', 'MovimientoStock', 'Crear', 1, GETDATE())
    
    PRINT 'Menú de Movimientos de Stock agregado'
END
ELSE
BEGIN
    PRINT 'El menú de Movimientos de Stock ya existe'
END
*/

GO
