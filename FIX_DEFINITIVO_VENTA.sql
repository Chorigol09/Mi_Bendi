USE DBVENTAS_WEB
GO

-- Verificar qué procedimiento está activo actualmente
PRINT '========== VERIFICANDO PROCEDIMIENTO ACTUAL =========='
SELECT 
    OBJECT_NAME(object_id) as NombreProcedimiento,
    create_date as FechaCreacion,
    modify_date as FechaModificacion
FROM sys.objects 
WHERE type = 'P' AND name = 'usp_RegistrarVenta'
GO

-- Eliminar el procedimiento actual SIN IMPORTAR CUÁL SEA
PRINT ''
PRINT '========== ELIMINANDO PROCEDIMIENTO ACTUAL =========='
IF OBJECT_ID('usp_RegistrarVenta', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE usp_RegistrarVenta
    PRINT 'Procedimiento eliminado'
END
GO

-- Esperar un momento
WAITFOR DELAY '00:00:01'
GO

-- Crear el procedimiento NUEVO definitivo
PRINT ''
PRINT '========== CREANDO PROCEDIMIENTO NUEVO =========='
GO

CREATE PROCEDURE usp_RegistrarVenta(
@Detalle VARCHAR(MAX),
@Resultado INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Convertir string a XML
        DECLARE @DetalleXML XML = CAST(@Detalle AS XML)
        
        DECLARE @cliente TABLE (
            tipodocumento VARCHAR(50),
            numerodocumento VARCHAR(50),
            nombre VARCHAR(100),
            direccion VARCHAR(100),
            telefono VARCHAR(50)
        )
        
        DECLARE @venta TABLE (
            idtienda INT,
            idusuario INT,
            idcliente INT DEFAULT 0,
            tipodocumento VARCHAR(50),
            numerofactura VARCHAR(50),
            metodopago VARCHAR(50),
            cantidadproducto INT,
            cantidadtotal INT,
            totalcosto DECIMAL(18,2),
            importerecibido DECIMAL(18,2),
            importecambio DECIMAL(18,2),
            idlistaprecio INT
        )
        
        DECLARE @detalleventa TABLE (
            idventa INT,
            idproducto INT,
            cantidad INT,
            preciounidad DECIMAL(18,2),
            importetotal DECIMAL(18,2)
        )

        -- Leer datos del cliente
        INSERT INTO @cliente(tipodocumento,numerodocumento,nombre,direccion,telefono)
        SELECT 
            tipodocumento = Node.Data.value('(TipoDocumento)[1]','VARCHAR(50)'),
            numerodocumento = Node.Data.value('(NumeroDocumento)[1]','VARCHAR(50)'),
            nombre = Node.Data.value('(Nombre)[1]','VARCHAR(100)'),
            direccion = Node.Data.value('(Direccion)[1]','VARCHAR(100)'),
            telefono = Node.Data.value('(Telefono)[1]','VARCHAR(50)')
        FROM @DetalleXML.nodes('/DETALLE/DETALLE_CLIENTE/DATOS') Node(Data)

        -- Leer datos de la venta
        INSERT INTO @venta(idtienda,idusuario,idcliente,tipodocumento,numerofactura,metodopago,cantidadproducto,cantidadtotal,totalcosto,importerecibido,importecambio,idlistaprecio)
        SELECT 
            IdTienda = Node.Data.value('(IdTienda)[1]','INT'),
            IdUsuario = Node.Data.value('(IdUsuario)[1]','INT'),
            IdCliente = Node.Data.value('(IdCliente)[1]','INT'),
            TipoDocumento = Node.Data.value('(TipoDocumento)[1]','VARCHAR(50)'),
            NumeroFactura = ISNULL(Node.Data.value('(NumeroFactura)[1]','VARCHAR(50)'), ''),
            MetodoPago = ISNULL(Node.Data.value('(MetodoPago)[1]','VARCHAR(50)'), 'Efectivo'),
            CantidadProducto = Node.Data.value('(CantidadProducto)[1]','INT'),
            CantidadTotal = Node.Data.value('(CantidadTotal)[1]','INT'),
            TotalCosto = Node.Data.value('(TotalCosto)[1]','DECIMAL(18,2)'),
            ImporteRecibido = Node.Data.value('(ImporteRecibido)[1]','DECIMAL(18,2)'),
            ImporteCambio = Node.Data.value('(ImporteCambio)[1]','DECIMAL(18,2)'),
            IdListaPrecio = ISNULL(Node.Data.value('(IdListaPrecio)[1]','INT'), 0)
        FROM @DetalleXML.nodes('/DETALLE/VENTA') Node(Data)

        -- Leer detalle de venta
        INSERT INTO @detalleventa(idventa,idproducto,cantidad,preciounidad,importetotal)
        SELECT 
            IdVenta = Node.Data.value('(IdVenta)[1]','INT'),
            IdProducto = Node.Data.value('(IdProducto)[1]','INT'),
            Cantidad = Node.Data.value('(Cantidad)[1]','INT'),
            PrecioUnidad = Node.Data.value('(PrecioUnidad)[1]','DECIMAL(18,2)'),
            ImporteTotal = Node.Data.value('(ImporteTotal)[1]','DECIMAL(18,2)')
        FROM @DetalleXML.nodes('/DETALLE/DETALLE_VENTA/DATOS') Node(Data)

        -- Área de trabajo
        DECLARE @identity AS TABLE(ID INT)

        -- Insertar o buscar cliente
        IF NOT EXISTS(SELECT * FROM CLIENTE WHERE numeroDocumento = (SELECT numerodocumento FROM @cliente))
        BEGIN
            INSERT INTO CLIENTE(TipoDocumento,NumeroDocumento,Nombre,Direccion,Telefono)
            OUTPUT inserted.IdCliente INTO @identity
            SELECT tipodocumento,numerodocumento,nombre,direccion,telefono FROM @cliente
        END
        ELSE 
        BEGIN
            INSERT INTO @identity(ID)
            SELECT IdCliente FROM CLIENTE WHERE numeroDocumento = (SELECT numerodocumento FROM @cliente)
        END

        UPDATE @venta SET idcliente = (SELECT ID FROM @identity)
        DELETE FROM @identity

        -- Insertar venta
        INSERT INTO VENTA(Codigo,ValorCodigo,IdTienda,IdUsuario,IdCliente,TipoDocumento,NumeroFactura,MetodoPago,CantidadProducto,CantidadTotal,TotalCosto,ImporteRecibido,ImporteCambio,IdListaPrecio)
        OUTPUT inserted.IdVenta INTO @identity
        SELECT 
            RIGHT('000000' + CONVERT(VARCHAR(MAX),(SELECT ISNULL(MAX(ValorCodigo),0) + 1 FROM VENTA)),6),
            (SELECT ISNULL(MAX(ValorCodigo),0) + 1 FROM VENTA),
            idtienda,idusuario,idcliente,tipodocumento,numerofactura,metodopago,cantidadproducto,cantidadtotal,totalcosto,importerecibido,importecambio,idlistaprecio
        FROM @venta

        UPDATE @detalleventa SET idventa = (SELECT ID FROM @identity)

        -- Insertar detalle venta
        INSERT INTO DETALLE_VENTA(IdVenta,IdProducto,Cantidad,PrecioUnidad,ImporteTotal)
        SELECT idventa,idproducto,cantidad,preciounidad,importetotal FROM @detalleventa

        COMMIT
        SET @Resultado = (SELECT ID FROM @identity)

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK
        
        SET @Resultado = 0
        
        -- Para debugging
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        PRINT 'ERROR EN usp_RegistrarVenta: ' + @ErrorMessage
        
    END CATCH
END
GO

PRINT ''
PRINT '========== PROCEDIMIENTO CREADO EXITOSAMENTE =========='
GO

-- Verificar que se creó correctamente
SELECT 
    OBJECT_NAME(object_id) as NombreProcedimiento,
    create_date as FechaCreacion,
    modify_date as FechaModificacion
FROM sys.objects 
WHERE type = 'P' AND name = 'usp_RegistrarVenta'
GO
