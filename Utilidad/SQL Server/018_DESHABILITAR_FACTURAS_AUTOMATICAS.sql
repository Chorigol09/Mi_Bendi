USE DBVENTAS_WEB
GO

-- =============================================
-- Script: Deshabilitar Generación Automática de Facturas
-- Descripción: Modificar SP para que NO genere facturas automáticamente
--              Las facturas se deben cargar manualmente
-- =============================================

PRINT '╔════════════════════════════════════════════════╗'
PRINT '║  DESHABILITAR GENERACIÓN AUTOMÁTICA           ║'
PRINT '║           DE FACTURAS                          ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

-- ============================================================
-- ACTUALIZAR SP DE REGISTRAR COMPRA (SIN GENERAR FACTURAS)
-- ============================================================
PRINT '1. Actualizando SP usp_RegistrarCompra...'
PRINT '   - Mantener generación de Orden de Compra'
PRINT '   - ELIMINAR generación automática de Factura'
PRINT '   - Las facturas se cargarán manualmente'
GO

CREATE OR ALTER PROCEDURE usp_RegistrarCompra
@Detalle XML
AS
BEGIN
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

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION REGISTRAR
    END CATCH
END
GO

PRINT '   ✓ SP usp_RegistrarCompra actualizado'
PRINT '   ✓ Ya NO genera facturas automáticamente'
PRINT ''
GO

-- ============================================================
-- VERIFICACIÓN
-- ============================================================
PRINT '2. Verificando stored procedure...'
GO

SELECT 
    ROUTINE_NAME AS 'Procedimiento',
    LAST_ALTERED AS 'Última Modificación'
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
    AND ROUTINE_NAME = 'usp_RegistrarCompra'
GO

PRINT ''
PRINT '=========================================='
PRINT 'Script ejecutado correctamente'
PRINT '=========================================='
PRINT ''
PRINT 'RESUMEN:'
PRINT '  ✓ SP usp_RegistrarCompra actualizado'
PRINT '  ✓ Generación automática de facturas DESHABILITADA'
PRINT '  ✓ Las facturas se deben cargar manualmente desde:'
PRINT '    /Factura/Crear'
PRINT ''
GO
