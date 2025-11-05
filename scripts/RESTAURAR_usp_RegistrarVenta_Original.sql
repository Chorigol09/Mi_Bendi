USE [DBVENTAS_WEB]
GO

PRINT '========================================='
PRINT 'RESTAURAR: Procedimiento usp_RegistrarVenta ORIGINAL'
PRINT '========================================='
GO

-- Eliminar el procedimiento si existe
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegistrarVenta')
    DROP PROCEDURE usp_RegistrarVenta
GO

PRINT 'Creando procedimiento usp_RegistrarVenta ORIGINAL (sin movimientos de stock)...'
GO

-- PROCEDIMIENTO ORIGINAL PARA REGISTRAR VENTA
CREATE PROCEDURE usp_RegistrarVenta(
    @Detalle xml,
    @Resultado int output
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        
        DECLARE @cliente TABLE (tipodocumento varchar(50), numerodocumento varchar(50), nombre varchar(100), direccion varchar(100), telefono varchar(50))
        DECLARE @venta TABLE (idtienda int, idusuario int, idcliente int default 0, tipodocumento varchar(50), cantidadproducto int, cantidadtotal int, totalcosto decimal(18,2), importerecibido decimal(18,2), importecambio decimal(18,2))
        DECLARE @detalleventa TABLE (idventa int, idproducto int, cantidad int, preciounidad decimal(18,2), importetotal decimal(18,2))

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

        -- ******************* AREA DE TRABAJO *************************
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

        INSERT INTO VENTA(Codigo, ValorCodigo, IdTienda, IdUsuario, IdCliente, TipoDocumento, CantidadProducto, CantidadTotal, TotalCosto, ImporteRecibido, ImporteCambio)
        OUTPUT inserted.IdVenta INTO @identity
        SELECT 
            RIGHT('000000' + CONVERT(varchar(max), (SELECT ISNULL(MAX(ValorCodigo), 0) + 1 FROM VENTA)), 6),
            (SELECT ISNULL(MAX(ValorCodigo), 0) + 1 FROM VENTA),
            idtienda, idusuario, idcliente, tipodocumento, cantidadproducto, cantidadtotal, totalcosto, importerecibido, importecambio
        FROM @venta

        UPDATE @detalleventa SET idventa = (SELECT ID FROM @identity)

        INSERT INTO DETALLE_VENTA(IdVenta, IdProducto, Cantidad, PrecioUnidad, ImporteTotal)
        SELECT idventa, idproducto, cantidad, preciounidad, importetotal FROM @detalleventa

        COMMIT TRANSACTION
        SET @Resultado = (SELECT ID FROM @identity)

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SET @Resultado = 0
    END CATCH
END
GO

PRINT 'Procedimiento usp_RegistrarVenta ORIGINAL restaurado correctamente.'
PRINT ''
PRINT '========================================='
PRINT 'IMPORTANTE:'
PRINT '- Este es el procedimiento ORIGINAL sin movimientos de stock'
PRINT '- Use este script si hay problemas con el procedimiento mejorado'
PRINT '- Las ventas deberían funcionar normalmente ahora'
PRINT '========================================='
GO
