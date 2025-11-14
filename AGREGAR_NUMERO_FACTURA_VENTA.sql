-- Script para agregar campo NumeroFactura a la tabla VENTA y actualizar procedimientos almacenados
USE DBVENTAS_WEB
GO

-- 1. Agregar columnas faltantes a la tabla VENTA
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('VENTA') AND name = 'NumeroFactura')
BEGIN
    ALTER TABLE VENTA
    ADD NumeroFactura VARCHAR(50) NULL
    PRINT 'Columna NumeroFactura agregada a la tabla VENTA'
END
ELSE
BEGIN
    PRINT 'La columna NumeroFactura ya existe en la tabla VENTA'
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('VENTA') AND name = 'MetodoPago')
BEGIN
    ALTER TABLE VENTA
    ADD MetodoPago VARCHAR(50) NULL
    PRINT 'Columna MetodoPago agregada a la tabla VENTA'
END
ELSE
BEGIN
    PRINT 'La columna MetodoPago ya existe en la tabla VENTA'
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('VENTA') AND name = 'IdListaPrecio')
BEGIN
    ALTER TABLE VENTA
    ADD IdListaPrecio INT NULL
    PRINT 'Columna IdListaPrecio agregada a la tabla VENTA'
END
ELSE
BEGIN
    PRINT 'La columna IdListaPrecio ya existe en la tabla VENTA'
END
GO

-- 2. Actualizar procedimiento usp_RegistrarVenta
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_RegistrarVenta')
    DROP PROCEDURE usp_RegistrarVenta
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
	DECLARE @venta table (idtienda int,idusuario int,idcliente int default 0,tipodocumento varchar(50),numerofactura varchar(50),metodopago varchar(50),cantidadproducto int,cantidadtotal int,totalcosto decimal(18,2),importerecibido decimal(18,2),importecambio decimal(18,2),idlistaprecio int)
	DECLARE @detalleventa table (idventa int,idproducto int,cantidad int,preciounidad decimal(18,2),importetotal decimal(18,2))

	INSERT INTO @cliente(tipodocumento,numerodocumento,nombre,direccion,telefono)
		 SELECT 
		 tipodocumento = Node.Data.value('(TipoDocumento)[1]','varchar(50)'),
		 numerodocumento = Node.Data.value('(NumeroDocumento)[1]','varchar(50)'),
		 nombre = Node.Data.value('(Nombre)[1]','varchar(100)'),
		 direccion = Node.Data.value('(Direccion)[1]','varchar(100)'),
		 telefono = Node.Data.value('(Telefono)[1]','varchar(50)')
		 FROM @Detalle.nodes('/DETALLE/DETALLE_CLIENTE/DATOS') Node(Data)

	INSERT INTO @venta(idtienda,idusuario,idcliente,tipodocumento,numerofactura,metodopago,cantidadproducto,cantidadtotal,totalcosto,importerecibido,importecambio,idlistaprecio)
	SELECT 
		 IdTienda = Node.Data.value('(IdTienda)[1]','int'),
		 IdUsuario = Node.Data.value('(IdUsuario)[1]','int'),
		 IdCliente = Node.Data.value('(IdCliente)[1]','int'),
		 TipoDocumento = Node.Data.value('(TipoDocumento)[1]','varchar(50)'),
		 NumeroFactura = Node.Data.value('(NumeroFactura)[1]','varchar(50)'),
		 MetodoPago = Node.Data.value('(MetodoPago)[1]','varchar(50)'),
		 CantidadProducto = Node.Data.value('(CantidadProducto)[1]','int'),
		 CantidadTotal = Node.Data.value('(CantidadTotal)[1]','int'),
		 TotalCosto = Node.Data.value('(TotalCosto)[1]','decimal(18,2)'),
		 ImporteRecibido = Node.Data.value('(ImporteRecibido)[1]','decimal(18,2)'),
		 ImporteCambio = Node.Data.value('(ImporteCambio)[1]','decimal(18,2)'),
		 IdListaPrecio = Node.Data.value('(IdListaPrecio)[1]','int')
		 FROM @Detalle.nodes('/DETALLE/VENTA') Node(Data)

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

	IF NOT EXISTS(SELECT * FROM CLIENTE WHERE numeroDocumento = (SELECT numerodocumento FROM @cliente))
	INSERT INTO CLIENTE(TipoDocumento,NumeroDocumento,Nombre,Direccion,Telefono)
	OUTPUT inserted.IdCliente INTO @identity
	SELECT tipodocumento,numerodocumento,nombre,direccion,telefono FROM @cliente
	ELSE 
	 INSERT INTO @identity(ID)
	 SELECT IdCliente FROM CLIENTE WHERE numeroDocumento = (SELECT numerodocumento FROM @cliente)

	UPDATE @venta SET idcliente = (SELECT ID FROM @identity)
	DELETE FROM @identity

	INSERT INTO VENTA(Codigo,ValorCodigo,IdTienda,IdUsuario,IdCliente,TipoDocumento,NumeroFactura,MetodoPago,CantidadProducto,CantidadTotal,TotalCosto,ImporteRecibido,ImporteCambio,IdListaPrecio)
	OUTPUT inserted.IdVenta INTO @identity
	SELECT 
	RIGHT('000000' + CONVERT(varchar(max),(SELECT ISNULL(MAX(ValorCodigo),0) + 1 FROM VENTA) ),6),
	(SELECT ISNULL(MAX(ValorCodigo),0) + 1 FROM VENTA),
	idtienda,idusuario,idcliente,tipodocumento,numerofactura,metodopago,cantidadproducto,cantidadtotal,totalcosto,importerecibido,importecambio,idlistaprecio
	FROM @venta

	UPDATE @detalleventa SET idventa = (SELECT ID FROM @identity)

	INSERT INTO DETALLE_VENTA(IdVenta,IdProducto,Cantidad,PrecioUnidad,ImporteTotal)
	SELECT idventa,idproducto,cantidad,preciounidad,importetotal FROM @detalleventa

	 COMMIT
	 SET @Resultado = (SELECT ID FROM @identity)

 END TRY
 BEGIN CATCH
	ROLLBACK
	SET @Resultado = 0
 END CATCH
END
GO

-- 3. Actualizar procedimiento usp_ObtenerDetalleVenta
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerDetalleVenta')
    DROP PROCEDURE usp_ObtenerDetalleVenta
GO

CREATE PROC usp_ObtenerDetalleVenta(
@IdVenta int
)
AS
BEGIN

SELECT V.TipoDocumento, V.Codigo, V.NumeroFactura, V.MetodoPago,
CONVERT(decimal(10,2), V.TotalCosto)[TotalCosto],
CONVERT(decimal(10,2),V.ImporteRecibido)[ImporteRecibido],
CONVERT(decimal(10,2), V.ImporteCambio)[ImporteCambio],
CONVERT(char(10),v.fechaRegistro,103)[FechaRegistro],
(SELECT u.Nombres,u.Apellidos FROM USUARIO U
 WHERE U.IdUsuario = v.IdUsuario
FOR XML PATH (''),TYPE) AS 'DETALLE_USUARIO',

(SELECT T.RUC, T.Nombre, T.Direccion FROM TIENDA T
 WHERE T.IdTienda = V.IdTienda
FOR XML PATH (''),TYPE) AS 'DETALLE_TIENDA',

(SELECT C.Nombre,C.Direccion,C.NumeroDocumento,C.Telefono FROM CLIENTE c
 WHERE c.IdCliente = V.IdCliente
FOR XML PATH (''),TYPE) AS 'DETALLE_CLIENTE',

(SELECT dv.Cantidad,CONCAT(p.Nombre,'-',p.Descripcion)[NombreProducto],
CONVERT(decimal(10,2),dv.PrecioUnidad)[PrecioUnidad],
CONVERT(decimal(10,2),dv.ImporteTotal)[ImporteTotal] 
FROM DETALLE_VENTA dv
INNER JOIN PRODUCTO p ON p.IdProducto = dv.IdProducto
WHERE dv.IdVenta = v.IdVenta
FOR XML PATH ('PRODUCTO'),TYPE) AS 'DETALLE_PRODUCTO'

FROM VENTA v
WHERE v.IdVenta = @IdVenta
FOR XML PATH(''), ROOT('DETALLE_VENTA') 

END
GO

-- 4. Actualizar procedimiento usp_ObtenerListaVenta
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ObtenerListaVenta')
    DROP PROCEDURE usp_ObtenerListaVenta
GO

CREATE PROCEDURE usp_ObtenerListaVenta(
@Codigo varchar(50) = '',
@FechaInicio date,
@FechaFin date,
@NumeroDocumento varchar(50) = '',
@Nombre varchar(100) = ''
)
AS
BEGIN
SET DATEFORMAT dmy;
SELECT v.IdVenta, v.TipoDocumento, v.Codigo, v.NumeroFactura, v.MetodoPago, v.FechaRegistro, v.FechaRegistro AS VFechaRegistro,
c.NumeroDocumento, c.Nombre, v.TotalCosto 
FROM VENTA v 
INNER JOIN CLIENTE c ON c.IdCliente = v.IdCliente
WHERE 
v.Codigo = IIF(@Codigo='',v.Codigo,@Codigo) AND
CONVERT(date,v.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin AND
c.NumeroDocumento LIKE CONCAT('%',@NumeroDocumento,'%') AND
c.Nombre LIKE CONCAT('%',@Nombre,'%')

END
GO

PRINT 'Script completado exitosamente. Campo NumeroFactura agregado y procedimientos almacenados actualizados.'
