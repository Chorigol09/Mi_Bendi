USE DBVENTAS_WEB
GO

-- XML EXACTO que se está enviando desde el navegador
DECLARE @xml VARCHAR(MAX) = '<DETALLE><VENTA><IdTienda>2</IdTienda><IdUsuario>1</IdUsuario><IdCliente>0</IdCliente><IdListaPrecio>1</IdListaPrecio><TipoDocumento>Factura</TipoDocumento><NumeroFactura>A-NORT-11111111</NumeroFactura><MetodoPago>Transferencia</MetodoPago><CantidadProducto>1</CantidadProducto><CantidadTotal>2</CantidadTotal><TotalCosto>34200.00</TotalCosto><ImporteRecibido>34200.00</ImporteRecibido><ImporteCambio>0.00</ImporteCambio></VENTA><DETALLE_CLIENTE><DATOS><TipoDocumento>DNI</TipoDocumento><NumeroDocumento>45678912</NumeroDocumento><Nombre>Pedro Sánchez</Nombre><Direccion>Calle Los Pinos 321</Direccion><Telefono>987654323</Telefono></DATOS></DETALLE_CLIENTE><DETALLE_VENTA><DATOS><IdVenta>0</IdVenta><IdProducto>41</IdProducto><Cantidad>2</Cantidad><PrecioUnidad>17100.00</PrecioUnidad><ImporteTotal>34200.00</ImporteTotal></DATOS></DETALLE_VENTA></DETALLE>'

PRINT '========== PROBANDO XML EXACTO DEL NAVEGADOR =========='
PRINT @xml
PRINT ''

DECLARE @Resultado INT

BEGIN TRY
    EXEC usp_RegistrarVenta @xml, @Resultado OUTPUT
    
    PRINT '========== RESULTADO =========='
    PRINT 'Resultado: ' + CAST(@Resultado AS VARCHAR)
    
    IF @Resultado > 0
    BEGIN
        PRINT 'EXITO: Venta ID = ' + CAST(@Resultado AS VARCHAR)
        SELECT TOP 1 * FROM VENTA ORDER BY IdVenta DESC
    END
    ELSE
    BEGIN
        PRINT 'ERROR: Procedimiento retornó 0'
    END
    
END TRY
BEGIN CATCH
    PRINT '========== ERROR =========='
    PRINT 'Error: ' + ERROR_MESSAGE()
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR)
END CATCH
GO

-- Verificar si existe el producto 41
PRINT ''
PRINT '========== VERIFICAR PRODUCTO 41 =========='
SELECT * FROM PRODUCTO WHERE IdProducto = 41
GO

-- Verificar si existe la tienda 2
PRINT ''
PRINT '========== VERIFICAR TIENDA 2 =========='
SELECT * FROM TIENDA WHERE IdTienda = 2
GO
