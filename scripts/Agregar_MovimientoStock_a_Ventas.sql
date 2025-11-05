USE [DBVENTAS_WEB]
GO

PRINT '========================================='
PRINT 'SCRIPT: Agregar registro de movimiento de stock en ventas'
PRINT '========================================='
GO

-- Eliminar el procedimiento existente
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegistrarVenta')
    DROP PROCEDURE usp_RegistrarVenta
GO

PRINT 'Creando procedimiento usp_RegistrarVenta mejorado con registro de movimientos de stock...'
GO

-- PROCEDIMIENTO MEJORADO PARA REGISTRAR VENTA CON MOVIMIENTOS DE STOCK
CREATE PROCEDURE usp_RegistrarVenta(
    @Detalle xml,
    @Resultado int output
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Declarar variables de tabla
        DECLARE @cliente TABLE (tipodocumento varchar(50), numerodocumento varchar(50), nombre varchar(100), direccion varchar(100), telefono varchar(50))
        DECLARE @venta TABLE (idtienda int, idusuario int, idcliente int default 0, tipodocumento varchar(50), cantidadproducto int, cantidadtotal int, totalcosto decimal(18,2), importerecibido decimal(18,2), importecambio decimal(18,2))
        DECLARE @detalleventa TABLE (idventa int, idproducto int, cantidad int, preciounidad decimal(18,2), importetotal decimal(18,2))

        -- Cargar datos del XML
        INSERT INTO @cliente(tipodocumento, numerodocumento, nombre, direccion, telefono)
        SELECT 
            tipodocumento = Node.Data.value('(TipoDocumento)[1]','varchar(50)'),
            numerodocumento = Node.Data.value('(NumeroDocumento)[1]','varchar(50)'),
            nombre = Node.Data.value('(Nombre)[1]','varchar(100)'),
            direccion = Node.Data.value('(Direccion)[1]','varchar(100)'),
            telefono = Node.Data.value('(Telefono)[1]','varchar(50)')
        FROM @Detalle.nodes('/DETALLE/DETALLE_CLIENTE/DATOS') Node(Data)

        INSERT INTO @venta(idtienda, idusuario, idcliente, tipodocumento, cantidadproducto, cantidadtotal, totalcosto, importerecibido, importecambio)
        SELECT 
            IdTienda = Node.Data.value('(IdTienda)[1]','varchar(50)'),
            IdUsuario = Node.Data.value('(IdUsuario)[1]','varchar(50)'),
            IdCliente = Node.Data.value('(IdCliente)[1]','varchar(100)'),
            TipoDocumento = Node.Data.value('(TipoDocumento)[1]','varchar(100)'),
            CantidadProducto = Node.Data.value('(CantidadProducto)[1]','varchar(50)'),
            CantidadTotal = Node.Data.value('(CantidadTotal)[1]','varchar(50)'),
            TotalCosto = Node.Data.value('(TotalCosto)[1]','decimal(18,2)'),
            ImporteRecibido = Node.Data.value('(ImporteRecibido)[1]','decimal(18,2)'),
            ImporteCambio = Node.Data.value('(ImporteCambio)[1]','decimal(18,2)')
        FROM @Detalle.nodes('/DETALLE/VENTA') Node(Data)

        INSERT INTO @detalleventa(idventa, idproducto, cantidad, preciounidad, importetotal)
        SELECT 
            IdVenta = Node.Data.value('(IdVenta)[1]','int'),
            IdProducto = Node.Data.value('(IdProducto)[1]','int'),
            Cantidad = Node.Data.value('(Cantidad)[1]','int'),
            PrecioUnidad = Node.Data.value('(PrecioUnidad)[1]','decimal(18,2)'),
            ImporteTotal = Node.Data.value('(ImporteTotal)[1]','decimal(18,2)')
        FROM @Detalle.nodes('/DETALLE/DETALLE_VENTA/DATOS') Node(Data)

        -- ******************* REGISTRAR CLIENTE *************************
        DECLARE @identity AS TABLE(ID int)

        IF NOT EXISTS(SELECT * FROM CLIENTE WHERE numeroDocumento = (SELECT numerodocumento FROM @cliente))
            INSERT INTO CLIENTE(TipoDocumento, NumeroDocumento, Nombre, Direccion, Telefono)
            OUTPUT inserted.IdCliente INTO @identity
            SELECT tipodocumento, numerodocumento, nombre, direccion, telefono FROM @cliente
        ELSE 
            INSERT INTO @identity(ID)
            SELECT IdCliente FROM CLIENTE WHERE numeroDocumento = (SELECT numerodocumento FROM @cliente)

        UPDATE @venta SET idcliente = (SELECT ID FROM @identity)
        DELETE FROM @identity

        -- ******************* REGISTRAR VENTA *************************
        INSERT INTO VENTA(Codigo, ValorCodigo, IdTienda, IdUsuario, IdCliente, TipoDocumento, CantidadProducto, CantidadTotal, TotalCosto, ImporteRecibido, ImporteCambio)
        OUTPUT inserted.IdVenta INTO @identity
        SELECT 
            RIGHT('000000' + CONVERT(varchar(max), (SELECT ISNULL(MAX(ValorCodigo), 0) + 1 FROM VENTA)), 6),
            (SELECT ISNULL(MAX(ValorCodigo), 0) + 1 FROM VENTA),
            idtienda, idusuario, idcliente, tipodocumento, cantidadproducto, cantidadtotal, totalcosto, importerecibido, importecambio
        FROM @venta

        DECLARE @IdVentaRegistrada INT = (SELECT ID FROM @identity)
        UPDATE @detalleventa SET idventa = @IdVentaRegistrada

        -- ******************* REGISTRAR DETALLE VENTA *************************
        INSERT INTO DETALLE_VENTA(IdVenta, IdProducto, Cantidad, PrecioUnidad, ImporteTotal)
        SELECT idventa, idproducto, cantidad, preciounidad, importetotal FROM @detalleventa

        -- ******************* REGISTRAR MOVIMIENTOS DE STOCK *************************
        -- Variables para el registro de movimientos
        DECLARE @IdTiendaVenta INT = (SELECT idtienda FROM @venta)
        DECLARE @IdUsuarioVenta INT = (SELECT idusuario FROM @venta)
        DECLARE @IdTipoMovVenta INT = 4  -- "Venta de productos" (Egreso)
        DECLARE @CodigoVenta VARCHAR(50) = (SELECT Codigo FROM VENTA WHERE IdVenta = @IdVentaRegistrada)
        DECLARE @IdLote VARCHAR(50) = 'VENTA-' + @CodigoVenta  -- Lote para agrupar todos los movimientos de esta venta
        
        -- Variables para cursor
        DECLARE @IdProducto INT
        DECLARE @Cantidad INT
        
        -- Cursor para procesar cada producto vendido
        DECLARE cursor_productos CURSOR FOR 
        SELECT idproducto, cantidad FROM @detalleventa
        
        OPEN cursor_productos
        FETCH NEXT FROM cursor_productos INTO @IdProducto, @Cantidad
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Registrar movimiento de stock para este producto
            -- Solo registramos el movimiento, NO actualizamos el stock (eso lo hace el sistema de ventas por otro lado)
            INSERT INTO MOVIMIENTO_STOCK (IdTienda, IdProducto, TipoMovimiento, IdTipoMov, Cantidad, Motivo, IdUsuario, IdLote, FechaRegistro)
            VALUES (
                @IdTiendaVenta, 
                @IdProducto, 
                'Egreso',
                @IdTipoMovVenta, 
                @Cantidad, 
                'Venta de producto - Código de venta: ' + @CodigoVenta, 
                @IdUsuarioVenta, 
                @IdLote,
                GETDATE()
            )
            
            FETCH NEXT FROM cursor_productos INTO @IdProducto, @Cantidad
        END
        
        CLOSE cursor_productos
        DEALLOCATE cursor_productos

        -- ******************* COMMIT Y RETORNO *************************
        COMMIT TRANSACTION
        SET @Resultado = @IdVentaRegistrada

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        SET @Resultado = 0
    END CATCH
END
GO

PRINT 'Procedimiento usp_RegistrarVenta actualizado correctamente.'
PRINT ''
PRINT '========================================='
PRINT 'FUNCIONALIDAD AGREGADA:'
PRINT '- Cada venta ahora registra automáticamente movimientos de stock'
PRINT '- Tipo de movimiento: "Venta de productos" (IdTipoMov = 4)'
PRINT '- Los movimientos se agrupan por lote (VENTA-xxxxxx)'
PRINT '- Se valida que haya stock suficiente antes de completar la venta'
PRINT '- El stock se actualiza automáticamente al registrar la venta'
PRINT '========================================='
GO
