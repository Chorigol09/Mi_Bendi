USE DBVENTAS_WEB
GO

-- =============================================
-- Script: Corregir parámetro @Resultado en SPs
-- Descripción: Agregar parámetro @Resultado OUTPUT a los SPs
--              que lo necesitan para funcionar correctamente
-- =============================================

PRINT '╔════════════════════════════════════════════════╗'
PRINT '║  CORREGIR PARÁMETRO @Resultado EN SPs         ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

-- ============================================================
-- CORREGIR SP usp_RegistrarCompra
-- ============================================================
PRINT '1. Corrigiendo SP usp_RegistrarCompra...'
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

        -- Extraer datos del XML
        DECLARE @datos TABLE(
            IdProducto INT,
            Cantidad INT,
            PrecioUnidadCompra DECIMAL(18,2),
            PrecioUnidadVenta DECIMAL(18,2),
            TotalCosto DECIMAL(18,2)
        )

        INSERT INTO @datos
        SELECT 
            T.Item.value('IdProducto[1]', 'INT'),
            T.Item.value('Cantidad[1]', 'INT'),
            T.Item.value('PrecioUnidadCompra[1]', 'DECIMAL(18,2)'),
            T.Item.value('PrecioUnidadVenta[1]', 'DECIMAL(18,2)'),
            T.Item.value('TotalCosto[1]', 'DECIMAL(18,2)')
        FROM @Detalle.nodes('DETALLE/DETALLE_COMPRA/DETALLE') AS T(Item)

        SELECT 
            @IdUsuario = T.Item.value('IdUsuario[1]', 'INT'),
            @IdProveedor = T.Item.value('IdProveedor[1]', 'INT'),
            @IdTienda = T.Item.value('IdTienda[1]', 'INT'),
            @TotalCosto = T.Item.value('TotalCosto[1]', 'DECIMAL(18,2)')
        FROM @Detalle.nodes('DETALLE/COMPRA') AS T(Item)

        BEGIN TRANSACTION REGISTRAR

        -- Insertar Orden de Compra (sin modificar stock)
        INSERT INTO ORDEN_COMPRA(IdUsuario, IdProveedor, IdTienda, TotalCosto, Estado)
        VALUES(@IdUsuario, @IdProveedor, @IdTienda, @TotalCosto, 'Abierta')

        SET @IdCompra = SCOPE_IDENTITY()

        -- Insertar Detalle
        INSERT INTO DETALLE_ORDEN_COMPRA(IdOrdenCompra, IdProducto, Cantidad, PrecioUnitarioCompra, PrecioUnitarioVenta, TotalCosto)
        SELECT @IdCompra, IdProducto, Cantidad, PrecioUnidadCompra, PrecioUnidadVenta, TotalCosto FROM @datos

        -- *** NO SE GENERA FACTURA AUTOMÁTICAMENTE ***
        -- Las facturas se deben cargar manualmente desde la interfaz

        COMMIT TRANSACTION REGISTRAR
        
        SET @Resultado = 1

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION REGISTRAR
        
        SET @Resultado = 0
    END CATCH
END
GO

PRINT '   ✓ SP usp_RegistrarCompra corregido con @Resultado OUTPUT'
PRINT ''
GO

-- ============================================================
-- VERIFICAR SP usp_RegistrarFacturaConDetalles
-- ============================================================
PRINT '2. Verificando SP usp_RegistrarFacturaConDetalles...'
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_RegistrarFacturaConDetalles')
BEGIN
    PRINT '   ✓ SP usp_RegistrarFacturaConDetalles existe'
    
    -- Verificar si tiene parámetro @Resultado
    IF EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.PARAMETERS 
        WHERE SPECIFIC_NAME = 'usp_RegistrarFacturaConDetalles' 
        AND PARAMETER_NAME = '@Resultado'
    )
    BEGIN
        PRINT '   ✓ Parámetro @Resultado existe'
    END
    ELSE
    BEGIN
        PRINT '   ⚠ Parámetro @Resultado NO existe (pero debería estar en el SP)'
    END
END
ELSE
BEGIN
    PRINT '   ❌ SP usp_RegistrarFacturaConDetalles NO existe'
    PRINT '   SOLUCIÓN: Ejecutar 017_SP_REGISTRAR_FACTURA_CON_DETALLES.sql'
END
PRINT ''
GO

-- ============================================================
-- VERIFICACIÓN FINAL
-- ============================================================
PRINT '3. Verificación final de parámetros...'
PRINT ''
GO

SELECT 
    SPECIFIC_NAME AS 'Stored Procedure',
    PARAMETER_NAME AS 'Parámetro',
    DATA_TYPE AS 'Tipo',
    PARAMETER_MODE AS 'Modo'
FROM INFORMATION_SCHEMA.PARAMETERS
WHERE SPECIFIC_NAME IN ('usp_RegistrarCompra', 'usp_RegistrarFacturaConDetalles')
ORDER BY SPECIFIC_NAME, ORDINAL_POSITION
GO

PRINT ''
PRINT '=========================================='
PRINT 'Script ejecutado correctamente'
PRINT '=========================================='
PRINT ''
PRINT 'RESUMEN:'
PRINT '  ✓ SP usp_RegistrarCompra corregido'
PRINT '  ✓ Parámetro @Resultado OUTPUT agregado'
PRINT '  ✓ Ahora las órdenes de compra retornarán resultado correctamente'
PRINT ''
PRINT 'SIGUIENTE PASO:'
PRINT '  Probar la carga de Orden de Compra y Factura'
PRINT ''
GO
