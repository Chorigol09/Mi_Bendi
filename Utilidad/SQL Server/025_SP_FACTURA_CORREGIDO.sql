USE DBVENTAS_WEB
GO

PRINT '=========================================='
PRINT 'CREANDO SP FACTURA (CORREGIDO)'
PRINT '=========================================='
PRINT ''

-- Eliminar SP si existe
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_RegistrarFacturaConDetalles')
BEGIN
    DROP PROCEDURE usp_RegistrarFacturaConDetalles
    PRINT 'SP anterior eliminado'
END
GO

CREATE PROCEDURE usp_RegistrarFacturaConDetalles
    @XML XML,
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    SET NOCOUNT ON
    
    BEGIN TRY
        DECLARE @IdFactura INT = 0
        DECLARE @IdProveedor INT = 0
        DECLARE @NumeroFactura VARCHAR(50) = ''
        DECLARE @FechaEmision DATETIME
        DECLARE @Total DECIMAL(18,2) = 0

        -- Extraer datos de la factura del XML
        SELECT 
            @IdProveedor = T.Item.value('IdProveedor[1]', 'INT'),
            @NumeroFactura = T.Item.value('NumeroFactura[1]', 'VARCHAR(50)'),
            @FechaEmision = T.Item.value('FechaEmision[1]', 'DATETIME'),
            @Total = T.Item.value('Total[1]', 'DECIMAL(18,2)')
        FROM @XML.nodes('DETALLE/FACTURA') AS T(Item)

        -- Tabla temporal para detalles
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

        BEGIN TRANSACTION

        -- Insertar Factura (solo con las columnas que existen)
        INSERT INTO FACTURA (
            IdProveedor,
            NumeroFactura,
            FechaEmision,
            Total,
            Estado,
            Activo
        )
        VALUES (
            @IdProveedor,
            @NumeroFactura,
            @FechaEmision,
            @Total,
            'Pendiente',
            1
        )

        SET @IdFactura = SCOPE_IDENTITY()

        -- Insertar Detalles
        INSERT INTO DETALLE_FACTURA (
            IdFactura,
            IdProducto,
            Cantidad,
            PrecioUnitario,
            Subtotal,
            Activo
        )
        SELECT 
            @IdFactura,
            IdProducto,
            Cantidad,
            PrecioUnitario,
            Subtotal,
            1
        FROM @Detalles

        COMMIT TRANSACTION
        
        SET @Resultado = 1
        PRINT 'Factura #' + CAST(@IdFactura AS VARCHAR(10)) + ' registrada exitosamente'

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        
        SET @Resultado = 0
        
        DECLARE @ErrorMsg NVARCHAR(4000)
        SET @ErrorMsg = ERROR_MESSAGE()
        PRINT 'ERROR: ' + @ErrorMsg
        RAISERROR(@ErrorMsg, 16, 1)
    END CATCH
END
GO

PRINT ''
PRINT 'SP creado exitosamente'
PRINT ''

-- Verificar que se creó
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_RegistrarFacturaConDetalles')
BEGIN
    PRINT 'VERIFICACION OK: SP existe'
    PRINT ''
    PRINT 'Parametros del SP:'
    
    SELECT 
        pm.name AS 'Parametro',
        TYPE_NAME(pm.user_type_id) AS 'Tipo',
        CASE pm.is_output WHEN 1 THEN 'OUTPUT' ELSE 'INPUT' END AS 'Direccion'
    FROM sys.procedures p
    INNER JOIN sys.parameters pm ON p.object_id = pm.object_id
    WHERE p.name = 'usp_RegistrarFacturaConDetalles'
    ORDER BY pm.parameter_id
END
ELSE
BEGIN
    PRINT 'ERROR: SP NO se creo'
END

PRINT ''
PRINT '=========================================='
PRINT 'COMPLETADO'
PRINT '=========================================='
GO
