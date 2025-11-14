USE DBVENTAS_WEB
GO

-- Verificar columnas de la tabla VENTA
PRINT '========== COLUMNAS DE LA TABLA VENTA =========='
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'VENTA'
ORDER BY ORDINAL_POSITION
GO

-- Ver el procedimiento almacenado actual
PRINT ''
PRINT '========== PROCEDIMIENTO usp_RegistrarVenta ACTUAL =========='
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_RegistrarVenta'))
GO

-- Intentar insertar una venta de prueba para ver el error específico
PRINT ''
PRINT '========== PRUEBA DE INSERCIÓN =========='
DECLARE @xml VARCHAR(MAX) = '
<DETALLE>
    <VENTA>
        <IdTienda>1</IdTienda>
        <IdUsuario>1</IdUsuario>
        <IdCliente>0</IdCliente>
        <TipoDocumento>Factura</TipoDocumento>
        <NumeroFactura>A-TEST-00000001</NumeroFactura>
        <MetodoPago>Efectivo</MetodoPago>
        <CantidadProducto>1</CantidadProducto>
        <CantidadTotal>1</CantidadTotal>
        <TotalCosto>100.00</TotalCosto>
        <ImporteRecibido>100.00</ImporteRecibido>
        <ImporteCambio>0.00</ImporteCambio>
        <IdListaPrecio>1</IdListaPrecio>
    </VENTA>
    <DETALLE_CLIENTE>
        <DATOS>
            <TipoDocumento>DNI</TipoDocumento>
            <NumeroDocumento>12345678</NumeroDocumento>
            <Nombre>Cliente Prueba</Nombre>
            <Direccion>Calle Test 123</Direccion>
            <Telefono>123456789</Telefono>
        </DATOS>
    </DETALLE_CLIENTE>
    <DETALLE_VENTA>
        <DATOS>
            <IdVenta>0</IdVenta>
            <IdProducto>1</IdProducto>
            <Cantidad>1</Cantidad>
            <PrecioUnidad>100.00</PrecioUnidad>
            <ImporteTotal>100.00</ImporteTotal>
        </DATOS>
    </DETALLE_VENTA>
</DETALLE>'

DECLARE @Resultado INT
BEGIN TRY
    EXEC usp_RegistrarVenta @xml, @Resultado OUTPUT
    PRINT 'Resultado: ' + CAST(@Resultado AS VARCHAR)
END TRY
BEGIN CATCH
    PRINT 'ERROR: ' + ERROR_MESSAGE()
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR)
END CATCH
