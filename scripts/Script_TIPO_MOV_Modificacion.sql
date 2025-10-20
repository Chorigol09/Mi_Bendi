USE [DBVENTAS_WEB]
GO

-- =============================================
-- Script para agregar tabla TIPO_MOV y modificar MOVIMIENTO_STOCK
-- =============================================

PRINT 'Iniciando modificación de Movimientos de Stock...'
GO

-- 1. Eliminar constraint FK si existe antes de eliminar tabla
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_MOVIMIENTO_STOCK_TIPO_MOV')
BEGIN
    PRINT 'Eliminando constraint FK_MOVIMIENTO_STOCK_TIPO_MOV...';
    ALTER TABLE MOVIMIENTO_STOCK DROP CONSTRAINT FK_MOVIMIENTO_STOCK_TIPO_MOV;
    PRINT 'Constraint eliminado.';
END
GO

-- 2. Eliminar columna IdTipoMov si existe
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'MOVIMIENTO_STOCK' AND COLUMN_NAME = 'IdTipoMov')
BEGIN
    PRINT 'Eliminando columna IdTipoMov de MOVIMIENTO_STOCK...';
    ALTER TABLE MOVIMIENTO_STOCK DROP COLUMN IdTipoMov;
    PRINT 'Columna eliminada.';
END
GO

-- 3. Eliminar y recrear tabla TIPO_MOV
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TIPO_MOV]') AND type in (N'U'))
BEGIN
    PRINT 'Eliminando tabla TIPO_MOV existente...';
    DROP TABLE [dbo].[TIPO_MOV];
    PRINT 'Tabla eliminada.';
END
GO

PRINT 'Creando tabla TIPO_MOV...';

CREATE TABLE [dbo].[TIPO_MOV](
    [IdTipoMov] [int] IDENTITY(1,1) NOT NULL,
    [Descripcion] [varchar](100) NOT NULL,
    [TipoOperacion] [varchar](20) NOT NULL,
    [Activo] [bit] NOT NULL DEFAULT 1,
    [FechaRegistro] [datetime] NULL DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([IdTipoMov] ASC)
);

PRINT 'Tabla TIPO_MOV creada exitosamente.';

-- Insertar tipos de movimiento por defecto
INSERT INTO TIPO_MOV (Descripcion, TipoOperacion, Activo)
VALUES 
    ('Compra de mercaderia', 'Ingreso', 1),
    ('Ajuste de inventario (suma)', 'Ingreso', 1),
    ('Devolucion de cliente', 'Ingreso', 1),
    ('Venta de productos', 'Egreso', 1),
    ('Ajuste de inventario (resta)', 'Egreso', 1),
    ('Merma o perdida', 'Egreso', 1),
    ('Traslado a otra tienda', 'Egreso', 1);

PRINT 'Tipos de movimiento por defecto insertados.';
GO

-- 4. Verificar si la columna IdLote existe en MOVIMIENTO_STOCK
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'MOVIMIENTO_STOCK' AND COLUMN_NAME = 'IdLote')
BEGIN
    PRINT 'Agregando columna IdLote a MOVIMIENTO_STOCK...';
    ALTER TABLE MOVIMIENTO_STOCK ADD IdLote VARCHAR(50) NULL;
    PRINT 'Columna IdLote agregada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La columna IdLote ya existe en MOVIMIENTO_STOCK.';
END
GO

-- 5. Agregar columna IdTipoMov
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'MOVIMIENTO_STOCK' AND COLUMN_NAME = 'IdTipoMov')
BEGIN
    PRINT 'Agregando columna IdTipoMov a MOVIMIENTO_STOCK...';

    -- Agregamos la columna como NULL
    ALTER TABLE MOVIMIENTO_STOCK ADD IdTipoMov INT NULL;

    -- Migramos datos existentes: asignamos IdTipoMov basado en TipoMovimiento actual
    UPDATE MOVIMIENTO_STOCK 
    SET IdTipoMov = CASE 
        WHEN TipoMovimiento = 'Ingreso' THEN 1
        WHEN TipoMovimiento = 'Egreso' THEN 4
        ELSE 1
    END
    WHERE IdTipoMov IS NULL;

    -- Ahora hacemos NOT NULL
    ALTER TABLE MOVIMIENTO_STOCK ALTER COLUMN IdTipoMov INT NOT NULL;

    -- Agregar foreign key
    ALTER TABLE MOVIMIENTO_STOCK 
    ADD CONSTRAINT FK_MOVIMIENTO_STOCK_TIPO_MOV 
    FOREIGN KEY (IdTipoMov) REFERENCES TIPO_MOV(IdTipoMov);

    PRINT 'Columna IdTipoMov agregada y configurada exitosamente.';
END
ELSE
BEGIN
    PRINT 'La columna IdTipoMov ya existe en MOVIMIENTO_STOCK.';
END
GO

-- 6. Recrear SP usp_ObtenerMovimientosStock
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

PRINT 'Procedimiento usp_ObtenerMovimientosStock actualizado exitosamente.'
GO

-- 7. Recrear SP usp_RegistrarMovimientoStock
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
        
        -- Registrar el movimiento (mantenemos TipoMovimiento para compatibilidad)
        INSERT INTO MOVIMIENTO_STOCK (IdTienda, IdProducto, TipoMovimiento, IdTipoMov, Cantidad, Motivo, IdUsuario, IdLote, FechaRegistro)
        VALUES (@IdTienda, @IdProducto, @TipoOperacion, @IdTipoMov, @Cantidad, @Motivo, @IdUsuario, @IdLote, GETDATE());
        
        -- Actualizar el stock en PRODUCTO_TIENDA
        UPDATE PRODUCTO_TIENDA 
        SET Stock = @NuevoStock
        WHERE IdProducto = @IdProducto AND IdTienda = @IdTienda;
        
        SET @Resultado = 1;
        SET @Mensaje = 'Movimiento registrado correctamente. Nuevo stock: ' + CAST(@NuevoStock AS VARCHAR(10));
        
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

PRINT 'Procedimiento usp_RegistrarMovimientoStock actualizado exitosamente.'
GO

-- 8. Crear SP para obtener tipos de movimiento
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ObtenerTiposMov]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_ObtenerTiposMov];
GO

CREATE PROCEDURE [dbo].[usp_ObtenerTiposMov]
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        IdTipoMov,
        Descripcion,
        TipoOperacion,
        Activo,
        FechaRegistro
    FROM 
        TIPO_MOV
    WHERE 
        Activo = 1
    ORDER BY 
        TipoOperacion, Descripcion
END
GO

PRINT 'Procedimiento usp_ObtenerTiposMov creado exitosamente.'
GO

PRINT ''
PRINT '===================================='
PRINT '✓ Script ejecutado exitosamente!'
PRINT '===================================='
PRINT '- Tabla TIPO_MOV creada'
PRINT '- Columna IdTipoMov agregada a MOVIMIENTO_STOCK'
PRINT '- Columna IdLote verificada'
PRINT '- Stored Procedures actualizados'
PRINT '- Tipos de movimiento por defecto insertados'
PRINT ''
PRINT 'Sistema listo para usar.'
PRINT '===================================='
GO
