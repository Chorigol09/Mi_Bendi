USE DBVENTAS_WEB
GO

PRINT '========== 1. VERIFICAR COLUMNAS DE VENTA =========='
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'VENTA'
ORDER BY ORDINAL_POSITION
GO

PRINT ''
PRINT '========== 2. VERIFICAR PROCEDIMIENTO ACTUAL =========='
SELECT 
    name,
    create_date,
    modify_date,
    type_desc
FROM sys.objects
WHERE name = 'usp_RegistrarVenta'
GO

PRINT ''
PRINT '========== 3. PROBAR CON XML REAL =========='
DECLARE @xml VARCHAR(MAX) = '<DETALLE><VENTA><IdTienda>2</IdTienda><IdUsuario>1</IdUsuario><IdCliente>0</IdCliente><IdListaPrecio>6</IdListaPrecio><TipoDocumento>Factura</TipoDocumento><NumeroFactura>A-NORT-23141241</NumeroFactura><MetodoPago>Transferencia</MetodoPago><CantidadProducto>1</CantidadProducto><CantidadTotal>1</CantidadTotal><TotalCosto>5325.00</TotalCosto><ImporteRecibido>5325.00</ImporteRecibido><ImporteCambio>0.00</ImporteCambio></VENTA><DETALLE_CLIENTE><DATOS><TipoDocumento>DNI</TipoDocumento><NumeroDocumento>45678912</NumeroDocumento><Nombre>Pedro Sanchez</Nombre><Direccion>Calle Los Pinos 321</Direccion><Telefono>987654323</Telefono></DATOS></DETALLE_CLIENTE><DETALLE_VENTA><DATOS><IdVenta>0</IdVenta ><IdProducto>6</IdProducto><Cantidad>1</Cantidad><PrecioUnidad>5325.00</PrecioUnidad><ImporteTotal>5325.00</ImporteTotal></DATOS></DETALLE_VENTA></DETALLE>'

DECLARE @Resultado INT

BEGIN TRY
    EXEC usp_RegistrarVenta @xml, @Resultado OUTPUT
    
    IF @Resultado > 0
    BEGIN
        PRINT 'EXITO: Venta registrada con ID = ' + CAST(@Resultado AS VARCHAR)
        
        SELECT TOP 1 * FROM VENTA ORDER BY IdVenta DESC
    END
    ELSE
    BEGIN
        PRINT 'ERROR: Procedimiento retorno 0'
    END
END TRY
BEGIN CATCH
    PRINT 'ERROR CAPTURADO:'
    PRINT 'Numero: ' + CAST(ERROR_NUMBER() AS VARCHAR)
    PRINT 'Mensaje: ' + ERROR_MESSAGE()
    PRINT 'Linea: ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT 'Procedimiento: ' + ISNULL(ERROR_PROCEDURE(), 'N/A')
END CATCH
GO
