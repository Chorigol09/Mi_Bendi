USE DBVENTAS_WEB
GO

-- =============================================
-- Stored Procedure: usp_RegistrarFacturaConDetalles
-- Descripción: Registra una factura con sus detalles desde XML
-- =============================================

PRINT '╔════════════════════════════════════════════════╗'
PRINT '║  CREAR SP: usp_RegistrarFacturaConDetalles    ║'
PRINT '╚════════════════════════════════════════════════╝'
PRINT ''

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_RegistrarFacturaConDetalles]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[usp_RegistrarFacturaConDetalles]
    PRINT '  ✓ Procedimiento anterior eliminado'
END
GO

CREATE PROCEDURE usp_RegistrarFacturaConDetalles
@XML XML,
@Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    
    BEGIN TRY
        DECLARE @IdFactura INT = 0
        DECLARE @IdProveedor INT = 0
        DECLARE @IdTienda INT = 0
        DECLARE @IdUsuario INT = 1  -- Usuario por defecto, puedes modificar esto
        DECLARE @NumeroFactura VARCHAR(50) = ''
        DECLARE @FechaEmision DATE
        DECLARE @Total DECIMAL(18,2) = 0

        -- Extraer datos de la factura del XML
        SELECT 
            @IdProveedor = T.Item.value('IdProveedor[1]', 'INT'),
            @IdTienda = T.Item.value('IdTienda[1]', 'INT'),
            @NumeroFactura = T.Item.value('NumeroFactura[1]', 'VARCHAR(50)'),
            @FechaEmision = T.Item.value('FechaEmision[1]', 'DATE'),
            @Total = T.Item.value('Total[1]', 'DECIMAL(18,2)')
        FROM @XML.nodes('DETALLE/FACTURA') AS T(Item)

        -- Extraer detalles de productos
        DECLARE @Detalles TABLE(
            IdProducto INT,
            Cantidad INT,
            PrecioUnitario DECIMAL(18,2),
            Subtotal DECIMAL(18,2)
        )

        INSERT INTO @Detalles
        SELECT 
            T.Item.value('IdProducto[1]', 'INT'),
            T.Item.value('Cantidad[1]', 'INT'),
            T.Item.value('PrecioUnitario[1]', 'DECIMAL(18,2)'),
            T.Item.value('Subtotal[1]', 'DECIMAL(18,2)')
        FROM @XML.nodes('DETALLE/DETALLE_FACTURA/DETALLE') AS T(Item)

        BEGIN TRANSACTION REGISTRAR_FACTURA

        -- Insertar Factura
        INSERT INTO FACTURA (
            IdUsuario,
            IdProveedor,
            IdTienda,
            NumeroFactura,
            FechaEmision,
            Total,
            Estado,
            Activo,
            FechaRegistro
        )
        VALUES (
            @IdUsuario,
            @IdProveedor,
            @IdTienda,
            @NumeroFactura,
            @FechaEmision,
            @Total,
            'Pendiente',
            1,
            GETDATE()
        )

        SET @IdFactura = SCOPE_IDENTITY()

        -- Insertar Detalles de Factura
        INSERT INTO DETALLE_FACTURA (
            IdFactura,
            IdProducto,
            Cantidad,
            PrecioUnitario,
            Subtotal,
            Activo,
            FechaRegistro
        )
        SELECT 
            @IdFactura,
            IdProducto,
            Cantidad,
            PrecioUnitario,
            Subtotal,
            1,
            GETDATE()
        FROM @Detalles

        COMMIT TRANSACTION REGISTRAR_FACTURA
        
        SET @Resultado = 1
        PRINT '  ✓ Factura registrada exitosamente. ID: ' + CAST(@IdFactura AS VARCHAR(10))

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION REGISTRAR_FACTURA
        
        SET @Resultado = 0
        
        PRINT '  ❌ ERROR al registrar factura:'
        PRINT '     ' + ERROR_MESSAGE()
    END CATCH
END
GO

PRINT ''
PRINT '✓ Stored Procedure usp_RegistrarFacturaConDetalles creado exitosamente'
PRINT ''
PRINT '=========================================='
PRINT 'Script completado'
PRINT '=========================================='
PRINT ''
GO
