USE DBVENTAS_WEB
GO

-- =============================================
-- FIX: Corregir interpretación de decimales
-- =============================================

PRINT 'Corrigiendo formato de decimales en stored procedure...'
GO

CREATE OR ALTER PROCEDURE usp_RegistrarCompra
@Detalle XML,
@Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    BEGIN TRY
        DECLARE @IdCompra INT = 0
        DECLARE @IdUsuario INT = 0
        DECLARE @IdProveedor INT = 0
        DECLARE @IdTienda INT = 0
        DECLARE @TotalCosto DECIMAL(18,2) = 0

        DECLARE @datos TABLE(
            IdProducto INT,
            Cantidad INT,
            PrecioUnidadCompra DECIMAL(18,2),
            PrecioUnidadVenta DECIMAL(18,2),
            TotalCosto DECIMAL(18,2)
        )

        -- Extraer datos del XML con CAST explícito para decimales
        INSERT INTO @datos
        SELECT 
            T.Item.value('IdProducto[1]', 'INT'),
            T.Item.value('Cantidad[1]', 'INT'),
            CAST(T.Item.value('PrecioUnidadCompra[1]', 'VARCHAR(50)') AS DECIMAL(18,2)),
            CAST(T.Item.value('PrecioUnidadVenta[1]', 'VARCHAR(50)') AS DECIMAL(18,2)),
            CAST(T.Item.value('TotalCosto[1]', 'VARCHAR(50)') AS DECIMAL(18,2))
        FROM @Detalle.nodes('DETALLE/DETALLE_COMPRA/DETALLE') AS T(Item)

        SELECT 
            @IdUsuario = T.Item.value('IdUsuario[1]', 'INT'),
            @IdProveedor = T.Item.value('IdProveedor[1]', 'INT'),
            @IdTienda = T.Item.value('IdTienda[1]', 'INT')
        FROM @Detalle.nodes('DETALLE/COMPRA') AS T(Item)

        -- CALCULAR el total desde los detalles
        SELECT @TotalCosto = SUM(TotalCosto) FROM @datos

        -- Debug: Imprimir valores (comentar en producción)
        PRINT 'Total calculado: ' + CAST(@TotalCosto AS VARCHAR(20))

        BEGIN TRANSACTION REGISTRAR

        INSERT INTO ORDEN_COMPRA(IdUsuario, IdProveedor, IdTienda, TotalCosto, Estado)
        VALUES(@IdUsuario, @IdProveedor, @IdTienda, @TotalCosto, 'Abierta')

        SET @IdCompra = SCOPE_IDENTITY()

        INSERT INTO DETALLE_ORDEN_COMPRA(IdOrdenCompra, IdProducto, Cantidad, PrecioUnitarioCompra, PrecioUnitarioVenta, TotalCosto)
        SELECT @IdCompra, IdProducto, Cantidad, PrecioUnidadCompra, PrecioUnidadVenta, TotalCosto FROM @datos

        COMMIT TRANSACTION REGISTRAR
        
        SET @Resultado = 1

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION REGISTRAR
        SET @Resultado = 0
        
        -- Debug: Mostrar error
        PRINT 'Error: ' + ERROR_MESSAGE()
    END CATCH
END
GO

PRINT '✓ Stored procedure actualizado con formato decimal correcto'
PRINT ''
PRINT 'Prueba ahora:'
PRINT '1. Crear una orden de compra'
PRINT '2. Verificar que el total sea correcto'
GO
