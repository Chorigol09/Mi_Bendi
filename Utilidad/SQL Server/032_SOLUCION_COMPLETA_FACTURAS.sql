USE DBVENTAS_WEB
GO

PRINT ''
PRINT '=========================================='
PRINT '   SOLUCIÓN COMPLETA SISTEMA FACTURAS'
PRINT '=========================================='
PRINT ''
PRINT 'Este script:'
PRINT '1. Verificará la estructura de la tabla FACTURA'
PRINT '2. Agregará columnas faltantes si es necesario'
PRINT '3. Creará/actualizará los stored procedures'
PRINT '4. Verificará que todo funcione'
PRINT ''
PRINT 'Presiona Enter para continuar...'
PRINT ''

-- =============================================
-- PASO 1: VERIFICAR Y CORREGIR TABLA FACTURA
-- =============================================

PRINT '=========================================='
PRINT 'PASO 1: VERIFICAR TABLA FACTURA'
PRINT '=========================================='
PRINT ''

-- Agregar columna Observaciones si no existe
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'FACTURA' AND COLUMN_NAME = 'Observaciones'
)
BEGIN
    PRINT 'Agregando columna Observaciones...'
    ALTER TABLE FACTURA ADD Observaciones VARCHAR(500) NULL
    PRINT '✓ Columna Observaciones agregada'
END
ELSE
BEGIN
    PRINT '✓ Columna Observaciones ya existe'
END

PRINT ''
PRINT 'Estructura actual de FACTURA:'
SELECT 
    COLUMN_NAME as Columna,
    DATA_TYPE as Tipo
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FACTURA'
ORDER BY ORDINAL_POSITION
PRINT ''

-- Actualizar facturas viejas que no tienen número de OC
PRINT 'Actualizando facturas antiguas sin número de OC...'
UPDATE FACTURA 
SET Observaciones = 'No asociado a una OC'
WHERE Observaciones IS NULL OR Observaciones = '' OR Observaciones = 'Sin OC'
PRINT '✓ Facturas antiguas actualizadas'
PRINT ''

-- =============================================
-- PASO 2: SP REGISTRAR FACTURA CON DETALLES
-- =============================================

PRINT '=========================================='
PRINT 'PASO 2: SP REGISTRAR FACTURA'
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
        DECLARE @NumeroOrdenCompra VARCHAR(50) = ''
        DECLARE @FechaEmision DATETIME
        DECLARE @Total DECIMAL(18,2) = 0

        -- Extraer datos de la factura del XML
        SELECT 
            @IdProveedor = T.Item.value('IdProveedor[1]', 'INT'),
            @NumeroFactura = T.Item.value('NumeroFactura[1]', 'VARCHAR(50)'),
            @NumeroOrdenCompra = T.Item.value('NumeroOrdenCompra[1]', 'VARCHAR(50)'),
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

        -- Insertar Factura
        INSERT INTO FACTURA (
            IdProveedor,
            NumeroFactura,
            FechaEmision,
            Total,
            Estado,
            Observaciones,
            Activo
        )
        VALUES (
            @IdProveedor,
            @NumeroFactura,
            @FechaEmision,
            @Total,
            'Pendiente',
            ISNULL(@NumeroOrdenCompra, 'No asociado a una OC'),
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

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        
        SET @Resultado = 0
        
        DECLARE @ErrorMsg NVARCHAR(4000)
        SET @ErrorMsg = ERROR_MESSAGE()
        RAISERROR(@ErrorMsg, 16, 1)
    END CATCH
END
GO

PRINT '✓ SP usp_RegistrarFacturaConDetalles creado'
PRINT ''

-- =============================================
-- PASO 3: SP OBTENER FACTURAS
-- =============================================

PRINT '=========================================='
PRINT 'PASO 3: SP OBTENER FACTURAS'
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
        ISNULL(f.Observaciones, 'No asociado a una OC') AS Observaciones,
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
        -- Usar Observaciones como número de orden de compra
        ISNULL(f.Observaciones, 'No asociado a una OC') AS IdOrdenCompra
    FROM FACTURA f
    INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
    WHERE f.Activo = 1
    ORDER BY f.FechaEmision DESC, f.IdFactura DESC
END
GO

PRINT '✓ SP usp_ObtenerFacturas creado'
PRINT ''

-- =============================================
-- PASO 4: VERIFICACIÓN FINAL
-- =============================================

PRINT '=========================================='
PRINT 'PASO 4: VERIFICACIÓN FINAL'
PRINT '=========================================='
PRINT ''

-- Verificar SPs
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_RegistrarFacturaConDetalles')
    PRINT '✓ usp_RegistrarFacturaConDetalles: OK'
ELSE
    PRINT '✗ usp_RegistrarFacturaConDetalles: ERROR'

IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_ObtenerFacturas')
    PRINT '✓ usp_ObtenerFacturas: OK'
ELSE
    PRINT '✗ usp_ObtenerFacturas: ERROR'

PRINT ''
PRINT 'Facturas actuales en la base de datos:'
SELECT COUNT(*) as TotalFacturas FROM FACTURA WHERE Activo = 1
PRINT ''

PRINT 'Probando SP usp_ObtenerFacturas:'
EXEC usp_ObtenerFacturas
PRINT ''

PRINT '=========================================='
PRINT 'PROCESO COMPLETADO'
PRINT '=========================================='
PRINT ''
PRINT 'PRÓXIMOS PASOS:'
PRINT '1. Recarga la aplicación web (Ctrl + F5)'
PRINT '2. Ve a Facturas → Index'
PRINT '3. Click en "Actualizar"'
PRINT '4. Abre la consola del navegador (F12)'
PRINT '5. Verifica los logs'
PRINT ''
PRINT 'Si aún no aparecen las facturas:'
PRINT '- Ejecuta: 030_VERIFICAR_FACTURAS_EN_BD.sql'
PRINT '- Revisa la consola del navegador'
PRINT ''
GO
