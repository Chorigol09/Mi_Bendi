USE [DBVENTAS_WEB]
GO

PRINT '========================================='
PRINT 'SCRIPT COMPLETO - TIPO_MOV'
PRINT '========================================='
GO

-- PASO 1: LIMPIAR TODO
PRINT 'PASO 1: Limpiando estructuras anteriores...'

-- Eliminar constraint FK si existe
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_MOVIMIENTO_STOCK_TIPO_MOV')
BEGIN
    ALTER TABLE MOVIMIENTO_STOCK DROP CONSTRAINT FK_MOVIMIENTO_STOCK_TIPO_MOV
    PRINT '- FK eliminado'
END

-- Eliminar columna IdTipoMov si existe
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'MOVIMIENTO_STOCK' AND COLUMN_NAME = 'IdTipoMov')
BEGIN
    ALTER TABLE MOVIMIENTO_STOCK DROP COLUMN IdTipoMov
    PRINT '- Columna IdTipoMov eliminada'
END

-- Eliminar stored procedures
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'usp_ObtenerMovimientosStock' AND type = 'P')
    DROP PROCEDURE usp_ObtenerMovimientosStock

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'usp_RegistrarMovimientoStock' AND type = 'P')
    DROP PROCEDURE usp_RegistrarMovimientoStock

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'usp_ObtenerTiposMov' AND type = 'P')
    DROP PROCEDURE usp_ObtenerTiposMov

-- Eliminar tabla TIPO_MOV si existe
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'TIPO_MOV' AND type = 'U')
BEGIN
    DROP TABLE TIPO_MOV
    PRINT '- Tabla TIPO_MOV eliminada'
END

PRINT 'PASO 1: Completado'
GO

-- PASO 2: CREAR TABLA TIPO_MOV
PRINT 'PASO 2: Creando tabla TIPO_MOV...'

CREATE TABLE [dbo].[TIPO_MOV](
    [IdTipoMov] INT IDENTITY(1,1) NOT NULL,
    [Descripcion] VARCHAR(100) NOT NULL,
    [TipoOperacion] VARCHAR(20) NOT NULL,
    [Activo] BIT NOT NULL DEFAULT 1,
    [FechaRegistro] DATETIME NULL DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([IdTipoMov] ASC)
)

INSERT INTO TIPO_MOV (Descripcion, TipoOperacion, Activo)
VALUES 
    ('Compra de mercaderia', 'Ingreso', 1),
    ('Ajuste de inventario (suma)', 'Ingreso', 1),
    ('Devolucion de cliente', 'Ingreso', 1),
    ('Venta de productos', 'Egreso', 1),
    ('Ajuste de inventario (resta)', 'Egreso', 1),
    ('Merma o perdida', 'Egreso', 1),
    ('Traslado a otra tienda', 'Egreso', 1)

PRINT 'PASO 2: Completado - 7 tipos insertados'
GO

-- PASO 3: AGREGAR COLUMNA IdLote
PRINT 'PASO 3: Verificando columna IdLote...'

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'MOVIMIENTO_STOCK' AND COLUMN_NAME = 'IdLote')
BEGIN
    ALTER TABLE MOVIMIENTO_STOCK ADD IdLote VARCHAR(50) NULL
    PRINT '- Columna IdLote agregada'
END
ELSE
BEGIN
    PRINT '- Columna IdLote ya existe'
END
GO

-- PASO 4: AGREGAR COLUMNA IdTipoMov
PRINT 'PASO 4: Agregando columna IdTipoMov...'

ALTER TABLE MOVIMIENTO_STOCK ADD IdTipoMov INT NULL
PRINT '- Columna creada'
GO

-- PASO 5: MIGRAR DATOS EXISTENTES
PRINT 'PASO 5: Migrando datos existentes...'

UPDATE MOVIMIENTO_STOCK 
SET IdTipoMov = CASE 
    WHEN TipoMovimiento = 'Ingreso' THEN 1
    WHEN TipoMovimiento = 'Egreso' THEN 4
    ELSE 1
END
WHERE IdTipoMov IS NULL

PRINT '- Datos migrados'
GO

-- PASO 6: HACER COLUMNA NOT NULL Y AGREGAR FK
PRINT 'PASO 6: Configurando columna IdTipoMov...'

ALTER TABLE MOVIMIENTO_STOCK ALTER COLUMN IdTipoMov INT NOT NULL

ALTER TABLE MOVIMIENTO_STOCK 
ADD CONSTRAINT FK_MOVIMIENTO_STOCK_TIPO_MOV 
FOREIGN KEY (IdTipoMov) REFERENCES TIPO_MOV(IdTipoMov)

PRINT '- Columna configurada y FK creado'
GO

-- PASO 7: CREAR SP usp_ObtenerMovimientosStock
PRINT 'PASO 7: Creando SP usp_ObtenerMovimientosStock...'
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

PRINT '- SP creado'
GO

-- PASO 8: CREAR SP usp_RegistrarMovimientoStock
PRINT 'PASO 8: Creando SP usp_RegistrarMovimientoStock...'
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
        VALUES (@IdTienda, @IdProducto, @TipoOperacion, @IdTipoMov, @Cantidad, @Motivo, @IdUsuario, @IdLote, GETDATE())
        
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

PRINT '- SP creado'
GO

-- PASO 9: CREAR SP usp_ObtenerTiposMov
PRINT 'PASO 9: Creando SP usp_ObtenerTiposMov...'
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

PRINT '- SP creado'
GO

PRINT ''
PRINT '========================================='
PRINT 'SCRIPT COMPLETADO EXITOSAMENTE'
PRINT '========================================='
PRINT 'Tabla TIPO_MOV: OK'
PRINT 'Columna IdTipoMov: OK'
PRINT 'Columna IdLote: OK'
PRINT 'SPs creados: 3'
PRINT 'Tipos de movimiento: 7'
PRINT '========================================='
GO
