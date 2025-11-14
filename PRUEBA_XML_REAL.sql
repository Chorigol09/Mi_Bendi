USE DBVENTAS_WEB
GO

-- Este es el XML EXACTO que se está enviando desde el navegador
DECLARE @xml VARCHAR(MAX) = '<DETALLE><VENTA><IdTienda>2</IdTienda><IdUsuario>1</IdUsuario><IdCliente>0</IdCliente><IdListaPrecio>6</IdListaPrecio><TipoDocumento>Factura</TipoDocumento><NumeroFactura>B-NORI-12141431</NumeroFactura><MetodoPago>Tarjeta Debito</MetodoPago><CantidadProducto>1</CantidadProducto><CantidadTotal>6</CantidadTotal><TotalCosto>5325.00</TotalCosto><ImporteRecibido>5325.00</ImporteRecibido><ImporteCambio>0.00</ImporteCambio></VENTA ><DETALLE_CLIENTE><DATOS><TipoDocumento>RUC</TipoDocumento><NumeroDocumento>20456789123</NumeroDocumento><Nombre>EMPRESA XYZ SAC</Nombre><Direccion>Av. Empresarial 123</Direccion><Telefono>01-4567890</Telefono></DATOS></DETALLE_CLIENTE><DETALLE_VENTA><DATOS><IdVenta>0</IdVenta ><IdProducto>6</IdProducto><Cantidad>6</Cantidad><PrecioUnidad>5325.00</PrecioUnidad><ImporteTotal>5325.00</ImporteTotal></DATOS></DETALLE_VENTA></DETALLE>'

PRINT '========== XML A PROBAR =========='
PRINT @xml
PRINT ''

DECLARE @Resultado INT

BEGIN TRY
    PRINT '========== EJECUTANDO PROCEDIMIENTO =========='
    EXEC usp_RegistrarVenta @xml, @Resultado OUTPUT
    
    PRINT ''
    PRINT '========== RESULTADO =========='
    PRINT 'Resultado: ' + CAST(@Resultado AS VARCHAR)
    
    IF @Resultado > 0
    BEGIN
        PRINT 'EXITO: Venta ID = ' + CAST(@Resultado AS VARCHAR)
        
        SELECT TOP 1 
            IdVenta,
            TipoDocumento,
            NumeroFactura,
            MetodoPago,
            Codigo,
            TotalCosto
        FROM VENTA 
        ORDER BY IdVenta DESC
    END
    ELSE
    BEGIN
        PRINT 'ERROR: El procedimiento retorno 0'
    END
    
END TRY
BEGIN CATCH
    PRINT ''
    PRINT '========== ERROR CAPTURADO =========='
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR)
    PRINT 'Error Message: ' + ERROR_MESSAGE()
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A')
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR)
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR)
END CATCH
GO
