USE DBVENTAS_WEB
GO

-- Probar el registro de una venta con los mismos datos que estás usando
DECLARE @xml XML = '
<DETALLE>
    <VENTA>
        <IdTienda>1</IdTienda>
        <IdUsuario>1</IdUsuario>
        <IdCliente>0</IdCliente>
        <IdListaPrecio>1</IdListaPrecio>
        <TipoDocumento>Factura</TipoDocumento>
        <NumeroFactura>A-CENT-11111111</NumeroFactura>
        <MetodoPago>Tarjeta Debito</MetodoPago>
        <CantidadProducto>1</CantidadProducto>
        <CantidadTotal>12</CantidadTotal>
        <TotalCosto>102000.00</TotalCosto>
        <ImporteRecibido>102000.00</ImporteRecibido>
        <ImporteCambio>0.00</ImporteCambio>
    </VENTA>
    <DETALLE_CLIENTE>
        <DATOS>
            <TipoDocumento>DNI</TipoDocumento>
            <NumeroDocumento>45678912</NumeroDocumento>
            <Nombre>Pedro Sanchez</Nombre>
            <Direccion>Calle Los Pinos 321</Direccion>
            <Telefono>987654323</Telefono>
        </DATOS>
    </DETALLE_CLIENTE>
    <DETALLE_VENTA>
        <DATOS>
            <IdVenta>0</IdVenta>
            <IdProducto>1</IdProducto>
            <Cantidad>12</Cantidad>
            <PrecioUnidad>8500.00</PrecioUnidad>
            <ImporteTotal>102000.00</ImporteTotal>
        </DATOS>
    </DETALLE_VENTA>
</DETALLE>'

DECLARE @Resultado INT

BEGIN TRY
    PRINT '========== INICIANDO PRUEBA DE REGISTRO =========='
    
    EXEC usp_RegistrarVenta @xml, @Resultado OUTPUT
    
    PRINT 'Resultado: ' + CAST(@Resultado AS VARCHAR)
    
    IF @Resultado > 0
    BEGIN
        PRINT 'ÉXITO: Venta registrada con ID = ' + CAST(@Resultado AS VARCHAR)
        
        -- Mostrar la venta registrada
        SELECT * FROM VENTA WHERE IdVenta = @Resultado
    END
    ELSE
    BEGIN
        PRINT 'ERROR: El procedimiento retornó 0'
    END
    
END TRY
BEGIN CATCH
    PRINT '========== ERROR CAPTURADO =========='
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR)
    PRINT 'Error Message: ' + ERROR_MESSAGE()
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR)
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR)
    
    IF ERROR_PROCEDURE() IS NOT NULL
        PRINT 'Error Procedure: ' + ERROR_PROCEDURE()
END CATCH
GO
