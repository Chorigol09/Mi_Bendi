USE [DBVENTAS_WEB]
GO

-- =============================================
-- Actualizar procedimientos para incluir MetodoPago
-- =============================================

-- Eliminar procedimiento anterior
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegistrarVenta')
DROP PROCEDURE usp_RegistrarVenta
GO

-- PROCEDIMIENTO ACTUALIZADO PARA REGISTRAR VENTA CON MÉTODO DE PAGO
CREATE PROCEDURE usp_RegistrarVenta(
    @Detalle xml,
    @Resultado int output
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        
        DECLARE @cliente TABLE (tipodocumento varchar(50), numerodocumento varchar(50), nombre varchar(100), direccion varchar(100), telefono varchar(50))
        DECLARE @venta TABLE (idtienda int, idusuario int, idcliente int DEFAULT 0, tipodocumento varchar(50), metodopago varchar(50), cantidadproducto int, cantidadtotal int, totalcosto decimal(18,2), importerecibido decimal(18,2), importecambio decimal(18,2))
        DECLARE @detalleventa TABLE (idventa int, idproducto int, cantidad int, preciounidad decimal(18,2), importetotal decimal(18,2))

        INSERT INTO @cliente(tipodocumento, numerodocumento, nombre, direccion, telefono)
        SELECT 
            tipodocumento = Node.Data.value('(TipoDocumento)[1]', 'varchar(50)'),
            numerodocumento = Node.Data.value('(NumeroDocumento)[1]', 'varchar(50)'),
            nombre = Node.Data.value('(Nombre)[1]', 'varchar(100)'),
            direccion = Node.Data.value('(Direccion)[1]', 'varchar(100)'),
            telefono = Node.Data.value('(Telefono)[1]', 'varchar(50)')
        FROM @Detalle.nodes('/DETALLE/DETALLE_CLIENTE/DATOS') Node(Data)

        INSERT INTO @venta(idtienda, idusuario, idcliente, tipodocumento, metodopago, cantidadproducto, cantidadtotal, totalcosto, importerecibido, importecambio)
        SELECT 
            IdTienda = Node.Data.value('(IdTienda)[1]', 'int'),
            IdUsuario = Node.Data.value('(IdUsuario)[1]', 'int'),
            IdCliente = Node.Data.value('(IdCliente)[1]', 'int'),
            TipoDocumento = Node.Data.value('(TipoDocumento)[1]', 'varchar(50)'),
            MetodoPago = ISNULL(Node.Data.value('(MetodoPago)[1]', 'varchar(50)'), 'Efectivo'),
            CantidadProducto = Node.Data.value('(CantidadProducto)[1]', 'int'),
            CantidadTotal = Node.Data.value('(CantidadTotal)[1]', 'int'),
            TotalCosto = Node.Data.value('(TotalCosto)[1]', 'decimal(18,2)'),
            ImporteRecibido = Node.Data.value('(ImporteRecibido)[1]', 'decimal(18,2)'),
            ImporteCambio = Node.Data.value('(ImporteCambio)[1]', 'decimal(18,2)')
        FROM @Detalle.nodes('/DETALLE/VENTA') Node(Data)

        INSERT INTO @detalleventa(idventa, idproducto, cantidad, preciounidad, importetotal)
        SELECT 
            IdVenta = Node.Data.value('(IdVenta)[1]', 'int'),
            IdProducto = Node.Data.value('(IdProducto)[1]', 'int'),
            Cantidad = Node.Data.value('(Cantidad)[1]', 'int'),
            PrecioUnidad = Node.Data.value('(PrecioUnidad)[1]', 'decimal(18,2)'),
            ImporteTotal = Node.Data.value('(ImporteTotal)[1]', 'decimal(18,2)')
        FROM @Detalle.nodes('/DETALLE/DETALLE_VENTA/DATOS') Node(Data)

        --******************* AREA DE TRABAJO *************************
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

        INSERT INTO VENTA(Codigo, ValorCodigo, IdTienda, IdUsuario, IdCliente, TipoDocumento, MetodoPago, CantidadProducto, CantidadTotal, TotalCosto, ImporteRecibido, ImporteCambio)
        OUTPUT inserted.IdVenta INTO @identity
        SELECT 
            RIGHT('000000' + CONVERT(varchar(max), (SELECT ISNULL(MAX(ValorCodigo), 0) + 1 FROM VENTA)), 6),
            (SELECT ISNULL(MAX(ValorCodigo), 0) + 1 FROM VENTA),
            idtienda, idusuario, idcliente, tipodocumento, metodopago, cantidadproducto, cantidadtotal, totalcosto, importerecibido, importecambio
        FROM @venta

        UPDATE @detalleventa SET idventa = (SELECT ID FROM @identity)

        INSERT INTO DETALLE_VENTA(IdVenta, IdProducto, Cantidad, PrecioUnidad, ImporteTotal)
        SELECT idventa, idproducto, cantidad, preciounidad, importetotal FROM @detalleventa

        COMMIT
        SET @Resultado = (SELECT ID FROM @identity)

    END TRY
    BEGIN CATCH
        ROLLBACK
        SET @Resultado = 0
    END CATCH
END
GO

-- Eliminar procedimiento anterior de detalle
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerDetalleVenta')
DROP PROCEDURE usp_ObtenerDetalleVenta
GO

-- PROCEDIMIENTO ACTUALIZADO PARA OBTENER DETALLE VENTA CON MÉTODO DE PAGO
CREATE PROC usp_ObtenerDetalleVenta(
    @IdVenta int
)
AS
BEGIN
    SELECT V.TipoDocumento, 
           ISNULL(V.MetodoPago, 'Efectivo') AS MetodoPago,
           V.Codigo,
           CONVERT(decimal(10,2), V.TotalCosto)[TotalCosto],
           CONVERT(decimal(10,2), V.ImporteRecibido)[ImporteRecibido],
           CONVERT(decimal(10,2), V.ImporteCambio)[ImporteCambio],
           CONVERT(char(10), v.fechaRegistro, 103)[FechaRegistro],
           (SELECT u.Nombres, u.Apellidos FROM USUARIO U
            WHERE U.IdUsuario = v.IdUsuario
            FOR XML PATH (''), TYPE) AS 'DETALLE_USUARIO',

           (SELECT T.RUC, T.Nombre, T.Direccion FROM TIENDA T
            WHERE T.IdTienda = V.IdTienda
            FOR XML PATH (''), TYPE) AS 'DETALLE_TIENDA',

           (SELECT C.Nombre, C.Direccion, C.NumeroDocumento, C.Telefono FROM CLIENTE c
            WHERE c.IdCliente = V.IdCliente
            FOR XML PATH (''), TYPE) AS 'DETALLE_CLIENTE',

           (SELECT dv.Cantidad, CONCAT(p.Nombre, '-', p.Descripcion)[NombreProducto],
                   CONVERT(decimal(10,2), dv.PrecioUnidad)[PrecioUnidad],
                   CONVERT(decimal(10,2), dv.ImporteTotal)[ImporteTotal] 
            FROM DETALLE_VENTA dv
            INNER JOIN PRODUCTO p ON p.IdProducto = dv.IdProducto
            WHERE dv.IdVenta = v.IdVenta
            FOR XML PATH ('PRODUCTO'), TYPE) AS 'DETALLE_PRODUCTO'

    FROM VENTA v
    WHERE v.IdVenta = @IdVenta
    FOR XML PATH(''), ROOT('DETALLE_VENTA') 
END
GO

PRINT 'Procedimientos actualizados exitosamente con soporte para MetodoPago'
