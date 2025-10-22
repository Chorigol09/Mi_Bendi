USE DBVENTAS_WEB
GO

-- ========== AGREGAR COLUMNA IdTienda A FACTURA ==========
PRINT '1. Verificando columna IdTienda en tabla FACTURA...'
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'FACTURA' AND COLUMN_NAME = 'IdTienda')
BEGIN
    ALTER TABLE FACTURA ADD IdTienda INT NULL REFERENCES TIENDA(IdTienda)
    PRINT '   ✓ Columna IdTienda agregada a tabla FACTURA'
END
ELSE
BEGIN
    PRINT '   ✓ Columna IdTienda ya existe en tabla FACTURA'
END
GO

PRINT ''
GO

-- ========== CREAR STORED PROCEDURE PARA REGISTRAR FACTURA CON DETALLES ==========
PRINT '2. Creando stored procedure usp_RegistrarFacturaConDetalles...'
GO

CREATE OR ALTER PROCEDURE usp_RegistrarFacturaConDetalles
@XML XML,
@Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    
    BEGIN TRY
        DECLARE @IdFactura INT = 0
        DECLARE @IdProveedor INT = 0
        DECLARE @IdTienda INT = 0
        DECLARE @NumeroFactura VARCHAR(50) = ''
        DECLARE @FechaEmision DATE = NULL
        DECLARE @Total DECIMAL(18,2) = 0

        -- Extraer datos de la factura del XML
        SELECT 
            @IdProveedor = T.Item.value('IdProveedor[1]', 'INT'),
            @IdTienda = T.Item.value('IdTienda[1]', 'INT'),
            @NumeroFactura = T.Item.value('NumeroFactura[1]', 'VARCHAR(50)'),
            @FechaEmision = T.Item.value('FechaEmision[1]', 'DATE'),
            @Total = T.Item.value('Total[1]', 'DECIMAL(18,2)')
        FROM @XML.nodes('DETALLE/FACTURA') AS T(Item)
        
        -- Si no se proporciona fecha, usar la fecha actual
        IF @FechaEmision IS NULL
            SET @FechaEmision = GETDATE()

        -- Validar que no exista una factura con el mismo número para el mismo proveedor
        IF EXISTS (SELECT 1 FROM FACTURA WHERE NumeroFactura = @NumeroFactura AND IdProveedor = @IdProveedor AND Activo = 1)
        BEGIN
            RAISERROR('Ya existe una factura con este número para el proveedor seleccionado', 16, 1)
            RETURN
        END

        -- Extraer detalles del XML
        DECLARE @detalles TABLE(
            IdProducto INT,
            Cantidad INT,
            PrecioUnitario DECIMAL(18,2),
            Subtotal DECIMAL(18,2)
        )

        INSERT INTO @detalles
        SELECT 
            T.Item.value('IdProducto[1]', 'INT'),
            T.Item.value('Cantidad[1]', 'INT'),
            T.Item.value('PrecioUnitario[1]', 'DECIMAL(18,2)'),
            T.Item.value('Subtotal[1]', 'DECIMAL(18,2)')
        FROM @XML.nodes('DETALLE/DETALLE_FACTURA/DETALLE') AS T(Item)

        BEGIN TRANSACTION REGISTRAR_FACTURA

        -- Insertar Factura con estado Pendiente
        INSERT INTO FACTURA(IdOrdenCompra, IdProveedor, IdTienda, NumeroFactura, Total, Estado, Activo, FechaEmision)
        VALUES(0, @IdProveedor, @IdTienda, @NumeroFactura, @Total, 'Pendiente', 1, @FechaEmision)

        SET @IdFactura = SCOPE_IDENTITY()

        -- Insertar Detalles de la Factura
        INSERT INTO DETALLE_FACTURA(IdFactura, IdProducto, Cantidad, PrecioUnitario, Subtotal, Activo, FechaRegistro)
        SELECT @IdFactura, IdProducto, Cantidad, PrecioUnitario, Subtotal, 1, GETDATE() 
        FROM @detalles

        COMMIT TRANSACTION REGISTRAR_FACTURA
        
        SET @Resultado = 1

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION REGISTRAR_FACTURA
        
        SET @Resultado = 0
        
        -- Log del error (opcional)
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END
GO

PRINT '   ✓ Stored procedure usp_RegistrarFacturaConDetalles creado exitosamente'
PRINT ''
GO

-- ========== ACTUALIZAR STORED PROCEDURE PARA OBTENER FACTURAS ==========
PRINT '3. Actualizando stored procedure usp_ObtenerFacturas...'
GO

CREATE OR ALTER PROCEDURE usp_ObtenerFacturas
AS
BEGIN
    SELECT 
        f.IdFactura,
        ISNULL(f.IdOrdenCompra, 0) AS IdOrdenCompra,
        f.IdProveedor,
        p.RazonSocial,
        f.NumeroFactura,
        f.Total,
        f.Estado,
        f.Observaciones,
        f.Activo,
        f.FechaEmision,
        f.FechaPago,
        CASE 
            WHEN f.IdOrdenCompra > 0 THEN CONVERT(VARCHAR(10), oc.FechaRegistro, 103)
            ELSE CONVERT(VARCHAR(10), f.FechaEmision, 103)
        END AS FechaOrdenCompra,
        ISNULL((SELECT COUNT(*) FROM DETALLE_FACTURA WHERE IdFactura = f.IdFactura AND Activo = 1), 0) AS CantidadProductos,
        ISNULL(STUFF((
            SELECT ', ' + pr.Nombre
            FROM DETALLE_FACTURA df
            INNER JOIN PRODUCTO pr ON df.IdProducto = pr.IdProducto
            WHERE df.IdFactura = f.IdFactura AND df.Activo = 1
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, ''), '') AS Productos
    FROM FACTURA f
    INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
    LEFT JOIN ORDEN_COMPRA oc ON f.IdOrdenCompra = oc.IdCompra
    WHERE f.Activo = 1
    ORDER BY f.FechaEmision DESC, f.IdFactura DESC
END
GO

PRINT '   ✓ Stored procedure usp_ObtenerFacturas actualizado'
PRINT ''
GO

-- ========== VERIFICACIÓN ==========
PRINT '4. Verificando stored procedures...'
PRINT ''
GO

SELECT 
    ROUTINE_NAME AS 'Procedimiento',
    CREATED AS 'Fecha Creación',
    LAST_ALTERED AS 'Última Modificación'
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
    AND ROUTINE_NAME IN (
        'usp_RegistrarFacturaConDetalles',
        'usp_ObtenerFacturas'
    )
ORDER BY ROUTINE_NAME
GO

PRINT ''
PRINT '=========================================='
PRINT 'Script ejecutado correctamente'
PRINT '=========================================='
PRINT ''
PRINT 'RESUMEN:'
PRINT '  ✓ Columna IdTienda agregada a FACTURA'
PRINT '  ✓ SP usp_RegistrarFacturaConDetalles creado'
PRINT '  ✓ SP usp_ObtenerFacturas actualizado'
PRINT ''
GO
