USE DBVENTAS_WEB
GO

PRINT ''
PRINT '=========================================='
PRINT '   FIX COMPLETO SISTEMA DE FACTURAS'
PRINT '=========================================='
PRINT ''
PRINT 'Este script corregirá:'
PRINT '1. SP para registrar facturas con detalles'
PRINT '2. SP para obtener facturas con todos los campos'
PRINT ''
PRINT 'Iniciando...'
PRINT ''

-- =============================================
-- FIX 1: SP REGISTRAR FACTURA CON DETALLES
-- =============================================

PRINT '=========================================='
PRINT 'FIX 1: SP REGISTRAR FACTURA CON DETALLES'
PRINT '=========================================='
PRINT ''

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

        PRINT 'Iniciando registro de factura...'
        
        -- Extraer datos de la factura del XML
        SELECT 
            @IdProveedor = T.Item.value('IdProveedor[1]', 'INT'),
            @NumeroFactura = T.Item.value('NumeroFactura[1]', 'VARCHAR(50)'),
            @FechaEmision = T.Item.value('FechaEmision[1]', 'DATETIME'),
            @Total = T.Item.value('Total[1]', 'DECIMAL(18,2)')
        FROM @XML.nodes('DETALLE/FACTURA') AS T(Item)

        PRINT 'Datos extraidos - Proveedor: ' + CAST(@IdProveedor AS VARCHAR(10)) + ', Numero: ' + @NumeroFactura

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

        DECLARE @CantidadDetalles INT
        SELECT @CantidadDetalles = COUNT(*) FROM @Detalles
        PRINT 'Cantidad de detalles: ' + CAST(@CantidadDetalles AS VARCHAR(10))

        BEGIN TRANSACTION

        -- Insertar Factura
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
        PRINT 'Factura insertada con ID: ' + CAST(@IdFactura AS VARCHAR(10))

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

        PRINT 'Detalles insertados correctamente'

        COMMIT TRANSACTION
        
        SET @Resultado = 1
        PRINT 'Factura registrada exitosamente'

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

PRINT '✓ SP usp_RegistrarFacturaConDetalles creado'
PRINT ''

-- =============================================
-- FIX 2: SP OBTENER FACTURAS
-- =============================================

PRINT '=========================================='
PRINT 'FIX 2: SP OBTENER FACTURAS'
PRINT '=========================================='
PRINT ''

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerFacturas')
BEGIN
    DROP PROCEDURE usp_ObtenerFacturas
    PRINT 'SP anterior eliminado'
END
GO

CREATE PROCEDURE usp_ObtenerFacturas
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT 
        f.IdFactura,
        f.IdProveedor,
        p.RazonSocial,
        f.NumeroFactura,
        f.Total,
        f.Estado,
        f.Activo,
        f.FechaEmision,
        f.FechaPago,
        ISNULL(f.Observaciones, '') AS Observaciones,
        -- Campos adicionales para la vista
        CONVERT(VARCHAR(10), f.FechaEmision, 103) AS FechaOrdenCompra,
        ISNULL((
            SELECT COUNT(DISTINCT df.IdProducto)
            FROM DETALLE_FACTURA df
            WHERE df.IdFactura = f.IdFactura AND df.Activo = 1
        ), 0) AS CantidadProductos,
        ISNULL((
            SELECT STUFF((
                SELECT ', ' + pr.Nombre
                FROM DETALLE_FACTURA df
                INNER JOIN PRODUCTO pr ON df.IdProducto = pr.IdProducto
                WHERE df.IdFactura = f.IdFactura AND df.Activo = 1
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 2, '')
        ), '') AS Productos,
        0 AS IdOrdenCompra -- Campo para compatibilidad
    FROM FACTURA f
    INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
    WHERE f.Activo = 1
    ORDER BY f.FechaEmision DESC, f.IdFactura DESC
END
GO

PRINT '✓ SP usp_ObtenerFacturas creado'
PRINT ''

-- =============================================
-- VERIFICACIÓN FINAL
-- =============================================

PRINT '=========================================='
PRINT 'VERIFICACIÓN FINAL'
PRINT '=========================================='
PRINT ''

-- Verificar SP de registro
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_RegistrarFacturaConDetalles')
BEGIN
    PRINT '✓ usp_RegistrarFacturaConDetalles: OK'
END
ELSE
BEGIN
    PRINT '✗ usp_RegistrarFacturaConDetalles: ERROR'
END

-- Verificar SP de obtención
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerFacturas')
BEGIN
    PRINT '✓ usp_ObtenerFacturas: OK'
END
ELSE
BEGIN
    PRINT '✗ usp_ObtenerFacturas: ERROR'
END

PRINT ''
PRINT '=========================================='
PRINT 'PROCESO COMPLETADO'
PRINT '=========================================='
PRINT ''
PRINT 'Ahora puedes:'
PRINT '1. Registrar nuevas facturas'
PRINT '2. Ver todas las facturas en la lista'
PRINT ''
GO
