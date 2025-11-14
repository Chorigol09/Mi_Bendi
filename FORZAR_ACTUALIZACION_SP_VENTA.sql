USE DBVENTAS_WEB
GO

-- FORZAR la eliminación y recreación del procedimiento usp_RegistrarVenta
IF OBJECT_ID('usp_RegistrarVenta', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE usp_RegistrarVenta
    PRINT 'Procedimiento usp_RegistrarVenta eliminado'
END
GO

CREATE PROCEDURE usp_RegistrarVenta(
@Detalle xml,
@Resultado int output
)
AS
BEGIN

BEGIN TRY

	BEGIN TRANSACTION
	
	DECLARE @cliente table (tipodocumento varchar(50),numerodocumento varchar(50),nombre varchar(100),direccion varchar(100),telefono varchar(50))
	DECLARE @venta table (
		idtienda int,
		idusuario int,
		idcliente int default 0,
		tipodocumento varchar(50),
		numerofactura varchar(50),
		metodopago varchar(50),
		cantidadproducto int,
		cantidadtotal int,
		totalcosto decimal(18,2),
		importerecibido decimal(18,2),
		importecambio decimal(18,2),
		idlistaprecio int
	)
	DECLARE @detalleventa table (idventa int,idproducto int,cantidad int,preciounidad decimal(18,2),importetotal decimal(18,2))

	-- Leer datos del cliente
	INSERT INTO @cliente(tipodocumento,numerodocumento,nombre,direccion,telefono)
	SELECT 
		tipodocumento = Node.Data.value('(TipoDocumento)[1]','varchar(50)'),
		numerodocumento = Node.Data.value('(NumeroDocumento)[1]','varchar(50)'),
		nombre = Node.Data.value('(Nombre)[1]','varchar(100)'),
		direccion = Node.Data.value('(Direccion)[1]','varchar(100)'),
		telefono = Node.Data.value('(Telefono)[1]','varchar(50)')
	FROM @Detalle.nodes('/DETALLE/DETALLE_CLIENTE/DATOS') Node(Data)

	-- Leer datos de la venta
	INSERT INTO @venta(idtienda,idusuario,idcliente,tipodocumento,numerofactura,metodopago,cantidadproducto,cantidadtotal,totalcosto,importerecibido,importecambio,idlistaprecio)
	SELECT 
		IdTienda = Node.Data.value('(IdTienda)[1]','int'),
		IdUsuario = Node.Data.value('(IdUsuario)[1]','int'),
		IdCliente = Node.Data.value('(IdCliente)[1]','int'),
		TipoDocumento = Node.Data.value('(TipoDocumento)[1]','varchar(50)'),
		NumeroFactura = Node.Data.value('(NumeroFactura)[1]','varchar(50)'),
		MetodoPago = ISNULL(Node.Data.value('(MetodoPago)[1]','varchar(50)'), 'Efectivo'),
		CantidadProducto = Node.Data.value('(CantidadProducto)[1]','int'),
		CantidadTotal = Node.Data.value('(CantidadTotal)[1]','int'),
		TotalCosto = Node.Data.value('(TotalCosto)[1]','decimal(18,2)'),
		ImporteRecibido = Node.Data.value('(ImporteRecibido)[1]','decimal(18,2)'),
		ImporteCambio = Node.Data.value('(ImporteCambio)[1]','decimal(18,2)'),
		IdListaPrecio = ISNULL(Node.Data.value('(IdListaPrecio)[1]','int'), 0)
	FROM @Detalle.nodes('/DETALLE/VENTA') Node(Data)

	-- Leer detalle de venta
	INSERT INTO @detalleventa(idventa,idproducto,cantidad,preciounidad,importetotal)
	SELECT 
		IdVenta = Node.Data.value('(IdVenta)[1]','int'),
		IdProducto = Node.Data.value('(IdProducto)[1]','int'),
		Cantidad = Node.Data.value('(Cantidad)[1]','int'),
		PrecioUnidad = Node.Data.value('(PrecioUnidad)[1]','decimal(18,2)'),
		ImporteTotal = Node.Data.value('(ImporteTotal)[1]','decimal(18,2)')
	FROM @Detalle.nodes('/DETALLE/DETALLE_VENTA/DATOS') Node(Data)

	--******************* AREA DE TRABAJO *************************
	DECLARE @identity as table(ID int)

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

	-- Insertar venta con TODOS los campos
	INSERT INTO VENTA(Codigo,ValorCodigo,IdTienda,IdUsuario,IdCliente,TipoDocumento,NumeroFactura,MetodoPago,CantidadProducto,CantidadTotal,TotalCosto,ImporteRecibido,ImporteCambio,IdListaPrecio)
	OUTPUT inserted.IdVenta INTO @identity
	SELECT 
		RIGHT('000000' + CONVERT(varchar(max),(SELECT ISNULL(MAX(ValorCodigo),0) + 1 FROM VENTA)),6),
		(SELECT ISNULL(MAX(ValorCodigo),0) + 1 FROM VENTA),
		idtienda,
		idusuario,
		idcliente,
		tipodocumento,
		numerofactura,
		metodopago,
		cantidadproducto,
		cantidadtotal,
		totalcosto,
		importerecibido,
		importecambio,
		idlistaprecio
	FROM @venta

	UPDATE @detalleventa SET idventa = (SELECT ID FROM @identity)

	-- Insertar detalle venta
	INSERT INTO DETALLE_VENTA(IdVenta,IdProducto,Cantidad,PrecioUnidad,ImporteTotal)
	SELECT idventa,idproducto,cantidad,preciounidad,importetotal FROM @detalleventa

	COMMIT
	SET @Resultado = (SELECT ID FROM @identity)

END TRY
BEGIN CATCH
	ROLLBACK
	SET @Resultado = 0
	
	-- Mostrar el error para debug
	DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
	DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
	DECLARE @ErrorState INT = ERROR_STATE()
	
	RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
END
GO

PRINT 'Procedimiento usp_RegistrarVenta recreado exitosamente'
GO
