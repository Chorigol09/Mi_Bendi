-- =============================================
-- Script: 035_AGREGAR_LISTA_PRECIO_VENTA.sql
-- Descripción: Agrega la columna IdListaPrecio a la tabla VENTA
--              para vincular cada venta con su lista de precios
-- Fecha: 12/11/2024
-- =============================================

USE DBVENTAS_WEB
GO

PRINT '======================================='
PRINT 'Iniciando actualización de tabla VENTA'
PRINT '======================================='
PRINT ''

-- 1. Agregar columna IdListaPrecio si no existe
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'VENTA' AND COLUMN_NAME = 'IdListaPrecio')
BEGIN
    PRINT 'Agregando columna IdListaPrecio a tabla VENTA...'
    
    ALTER TABLE VENTA
    ADD IdListaPrecio INT NULL
    
    -- Agregar clave foránea
    ALTER TABLE VENTA
    ADD CONSTRAINT FK_VENTA_LISTA_PRECIO 
    FOREIGN KEY (IdListaPrecio) REFERENCES LISTA_PRECIO(IdListaPrecio)
    
    PRINT 'Columna IdListaPrecio agregada correctamente'
    PRINT ''
END
ELSE
BEGIN
    PRINT 'La columna IdListaPrecio ya existe en tabla VENTA'
    PRINT ''
END

-- 2. Agregar columna MetodoPago si no existe
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'VENTA' AND COLUMN_NAME = 'MetodoPago')
BEGIN
    PRINT 'Agregando columna MetodoPago a tabla VENTA...'
    
    ALTER TABLE VENTA
    ADD MetodoPago VARCHAR(50) DEFAULT 'Efectivo'
    
    PRINT 'Columna MetodoPago agregada correctamente'
    PRINT ''
END
ELSE
BEGIN
    PRINT 'La columna MetodoPago ya existe en tabla VENTA'
    PRINT ''
END

GO

-- 3. Actualizar o crear stored procedure para registrar venta
PRINT 'Actualizando stored procedure usp_RegistrarVenta...'
GO

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_RegistrarVenta')
    DROP PROCEDURE usp_RegistrarVenta
GO

CREATE PROCEDURE usp_RegistrarVenta(
    @DetalleVenta VARCHAR(max),
    @Resultado INT OUTPUT
)
AS
BEGIN
    SET @Resultado = 0
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        DECLARE @IdVenta INT
        DECLARE @IdTienda INT
        DECLARE @IdUsuario INT
        DECLARE @IdCliente INT
        DECLARE @IdListaPrecio INT
        DECLARE @TipoDocumento VARCHAR(50)
        DECLARE @MetodoPago VARCHAR(50)
        DECLARE @CantidadProducto INT
        DECLARE @CantidadTotal INT
        DECLARE @TotalCosto DECIMAL(18,2)
        DECLARE @ImporteRecibido DECIMAL(18,2)
        DECLARE @ImporteCambio DECIMAL(18,2)
        
        DECLARE @TipoDocumentoCliente VARCHAR(50)
        DECLARE @NumeroDocumentoCliente VARCHAR(50)
        DECLARE @NombreCliente VARCHAR(50)
        DECLARE @DireccionCliente VARCHAR(50)
        DECLARE @TelefonoCliente VARCHAR(40)
        
        -- Parsear XML de VENTA
        SELECT 
            @IdTienda = V.value('(IdTienda)[1]','INT'),
            @IdUsuario = V.value('(IdUsuario)[1]','INT'),
            @IdCliente = V.value('(IdCliente)[1]','INT'),
            @IdListaPrecio = V.value('(IdListaPrecio)[1]','INT'),
            @TipoDocumento = V.value('(TipoDocumento)[1]','VARCHAR(50)'),
            @MetodoPago = V.value('(MetodoPago)[1]','VARCHAR(50)'),
            @CantidadProducto = V.value('(CantidadProducto)[1]','INT'),
            @CantidadTotal = V.value('(CantidadTotal)[1]','INT'),
            @TotalCosto = V.value('(TotalCosto)[1]','DECIMAL(18,2)'),
            @ImporteRecibido = V.value('(ImporteRecibido)[1]','DECIMAL(18,2)'),
            @ImporteCambio = V.value('(ImporteCambio)[1]','DECIMAL(18,2)')
        FROM (SELECT CAST(@DetalleVenta AS XML) AS DetalleXML) AS T1
        CROSS APPLY T1.DetalleXML.nodes('/DETALLE/VENTA') AS T2(V)
        
        -- Parsear XML de CLIENTE
        SELECT 
            @TipoDocumentoCliente = C.value('(TipoDocumento)[1]','VARCHAR(50)'),
            @NumeroDocumentoCliente = C.value('(NumeroDocumento)[1]','VARCHAR(50)'),
            @NombreCliente = C.value('(Nombre)[1]','VARCHAR(50)'),
            @DireccionCliente = C.value('(Direccion)[1]','VARCHAR(50)'),
            @TelefonoCliente = C.value('(Telefono)[1]','VARCHAR(40)')
        FROM (SELECT CAST(@DetalleVenta AS XML) AS DetalleXML) AS T1
        CROSS APPLY T1.DetalleXML.nodes('/DETALLE/DETALLE_CLIENTE/DATOS') AS T2(C)
        
        -- Validar que se haya seleccionado una lista de precios
        IF @IdListaPrecio IS NULL OR @IdListaPrecio = 0
        BEGIN
            RAISERROR('Debe seleccionar una lista de precios', 16, 1)
            RETURN
        END
        
        -- Verificar que la lista de precios esté activa
        IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE IdListaPrecio = @IdListaPrecio AND Activo = 1)
        BEGIN
            RAISERROR('La lista de precios seleccionada no está activa', 16, 1)
            RETURN
        END
        
        -- Verificar o crear cliente
        IF NOT EXISTS (SELECT 1 FROM CLIENTE WHERE NumeroDocumento = @NumeroDocumentoCliente)
        BEGIN
            INSERT INTO CLIENTE (TipoDocumento, NumeroDocumento, Nombre, Direccion, Telefono)
            VALUES (@TipoDocumentoCliente, @NumeroDocumentoCliente, @NombreCliente, @DireccionCliente, @TelefonoCliente)
            
            SET @IdCliente = SCOPE_IDENTITY()
        END
        ELSE
        BEGIN
            -- Actualizar datos del cliente existente
            UPDATE CLIENTE 
            SET 
                TipoDocumento = @TipoDocumentoCliente,
                Nombre = @NombreCliente,
                Direccion = @DireccionCliente,
                Telefono = @TelefonoCliente
            WHERE NumeroDocumento = @NumeroDocumentoCliente
            
            SELECT @IdCliente = IdCliente FROM CLIENTE WHERE NumeroDocumento = @NumeroDocumentoCliente
        END
        
        -- Generar código de venta
        DECLARE @NumeroCodigo INT
        DECLARE @CodigoVenta VARCHAR(100)
        
        SELECT @NumeroCodigo = ISNULL(MAX(ValorCodigo), 0) + 1 FROM VENTA
        SET @CodigoVenta = RIGHT('00000000' + CAST(@NumeroCodigo AS VARCHAR), 8)
        
        -- Insertar venta con lista de precios
        INSERT INTO VENTA (
            Codigo, ValorCodigo, IdTienda, IdUsuario, IdCliente, IdListaPrecio,
            TipoDocumento, MetodoPago, CantidadProducto, CantidadTotal, 
            TotalCosto, ImporteRecibido, ImporteCambio
        )
        VALUES (
            @CodigoVenta, @NumeroCodigo, @IdTienda, @IdUsuario, @IdCliente, @IdListaPrecio,
            @TipoDocumento, @MetodoPago, @CantidadProducto, @CantidadTotal, 
            @TotalCosto, @ImporteRecibido, @ImporteCambio
        )
        
        SET @IdVenta = SCOPE_IDENTITY()
        
        -- Insertar detalle de venta
        INSERT INTO DETALLE_VENTA (IdVenta, IdProducto, Cantidad, PrecioUnidad, ImporteTotal)
        SELECT 
            @IdVenta,
            DV.value('(IdProducto)[1]','INT'),
            DV.value('(Cantidad)[1]','INT'),
            DV.value('(PrecioUnidad)[1]','DECIMAL(18,2)'),
            DV.value('(ImporteTotal)[1]','DECIMAL(18,2)')
        FROM (SELECT CAST(@DetalleVenta AS XML) AS DetalleXML) AS T1
        CROSS APPLY T1.DetalleXML.nodes('/DETALLE/DETALLE_VENTA/DATOS') AS T2(DV)
        
        SET @Resultado = @IdVenta
        
        COMMIT TRANSACTION
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        
        SET @Resultado = 0
        
        DECLARE @ErrorMessage VARCHAR(MAX) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

PRINT 'Stored procedure usp_RegistrarVenta actualizado correctamente'
PRINT ''

-- 4. Crear índice para mejorar consultas
IF NOT EXISTS (SELECT * FROM sys.indexes 
               WHERE name = 'IX_VENTA_IdListaPrecio' AND object_id = OBJECT_ID('VENTA'))
BEGIN
    PRINT 'Creando índice IX_VENTA_IdListaPrecio...'
    
    CREATE NONCLUSTERED INDEX IX_VENTA_IdListaPrecio
    ON VENTA (IdListaPrecio)
    INCLUDE (FechaRegistro, TotalCosto, Activo)
    
    PRINT 'Índice creado correctamente'
    PRINT ''
END

PRINT '========================================='
PRINT 'Actualización completada exitosamente'
PRINT '========================================='
PRINT ''
PRINT 'RESUMEN:'
PRINT '- Columna IdListaPrecio agregada a tabla VENTA'
PRINT '- Columna MetodoPago agregada a tabla VENTA'
PRINT '- Stored procedure usp_RegistrarVenta actualizado'
PRINT '- Índice IX_VENTA_IdListaPrecio creado'
PRINT ''
PRINT 'La tabla VENTA ahora vincula cada venta con su lista de precios.'
PRINT ''

GO
