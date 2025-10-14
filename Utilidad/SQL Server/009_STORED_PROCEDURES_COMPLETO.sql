USE DBVENTAS_WEB
GO

-- =============================================
-- Script: Stored Procedures Completos para el Sistema
-- =============================================

PRINT '======================================'
PRINT 'CREANDO STORED PROCEDURES'
PRINT '======================================'
PRINT ''

-- ========== PROCEDIMIENTOS PARA REMITOS ==========

PRINT '1. Creando procedimientos para Remitos...'
GO

-- Obtener todos los remitos
CREATE OR ALTER PROCEDURE usp_ObtenerRemitos
AS
BEGIN
    SELECT 
        r.IdRemito,
        r.IdOrdenCompra,
        r.IdProveedor,
        p.RazonSocial,
        r.NumeroRemito,
        r.Estado,
        r.Observaciones,
        r.Activo,
        r.FechaRegistro,
        r.FechaRecepcion
    FROM REMITO r
    INNER JOIN PROVEEDOR p ON r.IdProveedor = p.IdProveedor
    WHERE r.Activo = 1
    ORDER BY r.FechaRegistro DESC
END
GO

-- Registrar remito
CREATE OR ALTER PROCEDURE usp_RegistrarRemito
    @IdOrdenCompra INT,
    @IdProveedor INT,
    @NumeroRemito VARCHAR(50),
    @Observaciones VARCHAR(500),
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    BEGIN TRY
        INSERT INTO REMITO (IdOrdenCompra, IdProveedor, NumeroRemito, Observaciones, Estado)
        VALUES (@IdOrdenCompra, @IdProveedor, @NumeroRemito, @Observaciones, 'En Espera')
        
        SET @Resultado = 1
    END TRY
    BEGIN CATCH
        SET @Resultado = 0
    END CATCH
END
GO

-- Actualizar estado de remito
CREATE OR ALTER PROCEDURE usp_ActualizarEstadoRemito
    @IdRemito INT,
    @Estado VARCHAR(20),
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    BEGIN TRY
        UPDATE REMITO 
        SET Estado = @Estado,
            FechaRecepcion = CASE WHEN @Estado = 'Recibido' THEN GETDATE() ELSE FechaRecepcion END
        WHERE IdRemito = @IdRemito
        
        SET @Resultado = 1
    END TRY
    BEGIN CATCH
        SET @Resultado = 0
    END CATCH
END
GO

PRINT '   ✓ Procedimientos de Remitos creados'
PRINT ''
GO

-- ========== PROCEDIMIENTOS PARA FACTURAS ==========

PRINT '2. Creando procedimientos para Facturas...'
GO

-- Obtener todas las facturas
CREATE OR ALTER PROCEDURE usp_ObtenerFacturas
AS
BEGIN
    SELECT 
        f.IdFactura,
        f.IdOrdenCompra,
        f.IdProveedor,
        p.RazonSocial,
        f.NumeroFactura,
        f.Total,
        f.Estado,
        f.Observaciones,
        f.Activo,
        f.FechaEmision,
        f.FechaPago
    FROM FACTURA f
    INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
    WHERE f.Activo = 1
    ORDER BY f.FechaEmision DESC
END
GO

-- Registrar factura
CREATE OR ALTER PROCEDURE usp_RegistrarFactura
    @IdOrdenCompra INT,
    @IdProveedor INT,
    @NumeroFactura VARCHAR(50),
    @Total DECIMAL(18,2),
    @Observaciones VARCHAR(500),
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    BEGIN TRY
        INSERT INTO FACTURA (IdOrdenCompra, IdProveedor, NumeroFactura, Total, Observaciones, Estado)
        VALUES (@IdOrdenCompra, @IdProveedor, @NumeroFactura, @Total, @Observaciones, 'Pendiente')
        
        SET @Resultado = 1
    END TRY
    BEGIN CATCH
        SET @Resultado = 0
    END CATCH
END
GO

-- Actualizar estado de factura
CREATE OR ALTER PROCEDURE usp_ActualizarEstadoFactura
    @IdFactura INT,
    @Estado VARCHAR(20),
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    BEGIN TRY
        UPDATE FACTURA 
        SET Estado = @Estado,
            FechaPago = CASE WHEN @Estado = 'Pagado' THEN GETDATE() ELSE FechaPago END
        WHERE IdFactura = @IdFactura
        
        SET @Resultado = 1
    END TRY
    BEGIN CATCH
        SET @Resultado = 0
    END CATCH
END
GO

PRINT '   ✓ Procedimientos de Facturas creados'
PRINT ''
GO

-- ========== ACTUALIZAR PROCEDIMIENTO DE ORDEN DE COMPRA ==========

PRINT '3. Actualizando procedimientos de Orden de Compra...'
GO

-- Modificar usp_RegistrarCompra para NO incrementar stock
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

        COMMIT TRANSACTION REGISTRAR

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION REGISTRAR
    END CATCH
END
GO

-- Obtener lista de compras con Estado
CREATE OR ALTER PROCEDURE usp_ObtenerListaCompra
    @FechaInicio DATE,
    @FechaFin DATE,
    @IdProveedor INT,
    @IdTienda INT
AS
BEGIN
    SELECT 
        oc.IdCompra,
        CONVERT(VARCHAR(10), oc.FechaRegistro, 103) AS NumeroCompra,
        p.RazonSocial,
        t.Nombre,
        CONVERT(VARCHAR(10), oc.FechaRegistro, 103) AS FechaCompra,
        oc.TotalCosto,
        ISNULL(oc.Estado, 'Abierta') AS Estado
    FROM ORDEN_COMPRA oc
    INNER JOIN PROVEEDOR p ON oc.IdProveedor = p.IdProveedor
    INNER JOIN TIENDA t ON oc.IdTienda = t.IdTienda
    WHERE 
        CONVERT(DATE, oc.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
        AND (@IdProveedor = 0 OR oc.IdProveedor = @IdProveedor)
        AND (@IdTienda = 0 OR oc.IdTienda = @IdTienda)
        AND oc.Activo = 1
    ORDER BY oc.FechaRegistro DESC
END
GO

-- Obtener detalle de compra
CREATE OR ALTER PROCEDURE usp_ObtenerDetalleCompra
    @IdCompra INT
AS
BEGIN
    SELECT 
        oc.IdCompra AS Codigo,
        oc.TotalCosto,
        CONVERT(VARCHAR(10), oc.FechaRegistro, 103) AS FechaCompra,
        p.RUC,
        p.RazonSocial,
        t.RUC AS RucTienda,
        t.Nombre AS NombreTienda,
        t.Direccion AS DireccionTienda,
        doc.Cantidad,
        pr.Nombre AS NombreProducto,
        doc.PrecioUnitarioCompra,
        doc.TotalCosto AS TotalCostoDetalle
    FROM ORDEN_COMPRA oc
    INNER JOIN PROVEEDOR p ON oc.IdProveedor = p.IdProveedor
    INNER JOIN TIENDA t ON oc.IdTienda = t.IdTienda
    LEFT JOIN DETALLE_ORDEN_COMPRA doc ON oc.IdCompra = doc.IdOrdenCompra
    LEFT JOIN PRODUCTO pr ON doc.IdProducto = pr.IdProducto
    WHERE oc.IdCompra = @IdCompra
    FOR XML PATH('DETALLE_COMPRA'), ROOT('DETALLE')
END
GO

PRINT '   ✓ Procedimientos de Orden de Compra actualizados'
PRINT ''
GO

-- ========== VERIFICACIÓN ==========

PRINT '4. Verificando stored procedures creados...'
PRINT ''
GO

SELECT 
    ROUTINE_NAME AS 'Procedimiento',
    CREATED AS 'Fecha Creación',
    LAST_ALTERED AS 'Última Modificación'
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
    AND ROUTINE_NAME IN (
        'usp_ObtenerRemitos',
        'usp_RegistrarRemito',
        'usp_ActualizarEstadoRemito',
        'usp_ObtenerFacturas',
        'usp_RegistrarFactura',
        'usp_ActualizarEstadoFactura',
        'usp_RegistrarCompra',
        'usp_ObtenerListaCompra',
        'usp_ObtenerDetalleCompra'
    )
ORDER BY ROUTINE_NAME

PRINT ''
PRINT '======================================'
PRINT '   ✓ TODOS LOS SP CREADOS'
PRINT '======================================'
GO
