-- =============================================
-- Script: Stored Procedures para ORDEN_PAGO
-- Descripción: Procedimientos para gestionar Órdenes de Pago
-- Fecha: 2025-10-23
-- =============================================

USE DBVENTAS_WEB
GO

-- =============================================
-- SP: Generar Número de Orden de Pago
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_GENERAR_NUMERO_ORDEN_PAGO' AND type = 'P')
    DROP PROCEDURE SP_GENERAR_NUMERO_ORDEN_PAGO
GO

CREATE PROCEDURE SP_GENERAR_NUMERO_ORDEN_PAGO
AS
BEGIN
    DECLARE @NumeroOrden VARCHAR(20)
    DECLARE @Correlativo INT
    
    -- Obtener el último correlativo
    SELECT @Correlativo = ISNULL(MAX(CAST(SUBSTRING(NumeroOrdenPago, 3, LEN(NumeroOrdenPago)) AS INT)), 0) + 1
    FROM ORDEN_PAGO
    
    -- Generar número con formato OP000001
    SET @NumeroOrden = 'OP' + RIGHT('000000' + CAST(@Correlativo AS VARCHAR), 6)
    
    SELECT @NumeroOrden AS NumeroOrdenPago
END
GO

PRINT '✓ SP_GENERAR_NUMERO_ORDEN_PAGO creado'
GO

-- =============================================
-- SP: Obtener Facturas Pendientes por Proveedor
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_OBTENER_FACTURAS_PENDIENTES' AND type = 'P')
    DROP PROCEDURE SP_OBTENER_FACTURAS_PENDIENTES
GO

CREATE PROCEDURE SP_OBTENER_FACTURAS_PENDIENTES
    @IdProveedor INT
AS
BEGIN
    -- Traer facturas pendientes SIN validar ORDEN_PAGO (por ahora)
    -- Basado en la consulta que SI funciona en el diagnostico
    SELECT 
        f.IdFactura,
        f.NumeroFactura,
        p.RazonSocial AS NombreProveedor,
        CONVERT(VARCHAR(10), f.FechaEmision, 103) AS FechaEmision,
        ISNULL(STUFF((
            SELECT ', ' + pr.Nombre
            FROM DETALLE_FACTURA df
            INNER JOIN PRODUCTO pr ON df.IdProducto = pr.IdProducto
            WHERE df.IdFactura = f.IdFactura
            FOR XML PATH('')
        ), 1, 2, ''), 'Sin productos') AS Productos,
        ISNULL((
            SELECT SUM(df.Cantidad)
            FROM DETALLE_FACTURA df
            WHERE df.IdFactura = f.IdFactura
        ), 0) AS Cantidad,
        f.Total AS MontoTotal
    FROM FACTURA f
    INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
    WHERE f.IdProveedor = @IdProveedor
      AND f.Estado = 'Pendiente'
    ORDER BY f.FechaEmision DESC
END
GO

PRINT '✓ SP_OBTENER_FACTURAS_PENDIENTES creado'
GO

-- =============================================
-- SP: Registrar Orden de Pago
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_REGISTRAR_ORDEN_PAGO' AND type = 'P')
    DROP PROCEDURE SP_REGISTRAR_ORDEN_PAGO
GO

CREATE PROCEDURE SP_REGISTRAR_ORDEN_PAGO
    @IdFactura INT,
    @IdProveedor INT,
    @MetodoPago VARCHAR(100),
    @MontoTotal DECIMAL(18,2),
    @UsuarioRegistro VARCHAR(100),
    @Resultado BIT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT,
    @IdOrdenPago INT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Verificar que la factura existe y está pendiente
        IF NOT EXISTS(SELECT 1 FROM FACTURA WHERE IdFactura = @IdFactura AND Estado = 'Pendiente')
        BEGIN
            SET @Mensaje = 'La factura no existe o ya fue pagada'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Verificar que no exista ya una orden de pago para esta factura
        IF EXISTS(SELECT 1 FROM ORDEN_PAGO WHERE IdFactura = @IdFactura)
        BEGIN
            SET @Mensaje = 'Ya existe una orden de pago para esta factura'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Generar número de orden de pago
        DECLARE @NumeroOrdenPago VARCHAR(20)
        EXEC SP_GENERAR_NUMERO_ORDEN_PAGO
        SELECT @NumeroOrdenPago = NumeroOrdenPago FROM 
            (SELECT TOP 1 'OP' + RIGHT('000000' + CAST(ISNULL(MAX(CAST(SUBSTRING(NumeroOrdenPago, 3, LEN(NumeroOrdenPago)) AS INT)), 0) + 1 AS VARCHAR), 6) AS NumeroOrdenPago
             FROM ORDEN_PAGO) AS Temp
        
        -- Insertar orden de pago
        INSERT INTO ORDEN_PAGO (
            NumeroOrdenPago,
            IdFactura,
            IdProveedor,
            MetodoPago,
            MontoTotal,
            FechaRegistro,
            Estado,
            UsuarioRegistro
        )
        VALUES (
            @NumeroOrdenPago,
            @IdFactura,
            @IdProveedor,
            @MetodoPago,
            @MontoTotal,
            GETDATE(),
            'Pagado',
            @UsuarioRegistro
        )
        
        SET @IdOrdenPago = SCOPE_IDENTITY()
        
        -- Actualizar estado de la factura a 'Pagado'
        UPDATE FACTURA
        SET Estado = 'Pagado'
        WHERE IdFactura = @IdFactura
        
        SET @Resultado = 1
        SET @Mensaje = 'Orden de pago registrada correctamente con número: ' + @NumeroOrdenPago
        
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
            
        SET @Mensaje = ERROR_MESSAGE()
        SET @Resultado = 0
    END CATCH
END
GO

PRINT '✓ SP_REGISTRAR_ORDEN_PAGO creado'
GO

-- =============================================
-- SP: Obtener Todas las Órdenes de Pago
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_OBTENER_ORDENES_PAGO' AND type = 'P')
    DROP PROCEDURE SP_OBTENER_ORDENES_PAGO
GO

CREATE PROCEDURE SP_OBTENER_ORDENES_PAGO
    @IdProveedor INT = NULL
AS
BEGIN
    SELECT 
        op.IdOrdenPago,
        op.NumeroOrdenPago,
        op.IdFactura,
        f.NumeroFactura,
        op.IdProveedor,
        p.RazonSocial AS NombreProveedor,
        CONVERT(VARCHAR(10), f.FechaEmision, 103) AS FechaEmision,
        -- Obtener lista de productos
        ISNULL(STUFF((
            SELECT ', ' + pr.Nombre
            FROM DETALLE_FACTURA df
            INNER JOIN PRODUCTO pr ON df.IdProducto = pr.IdProducto
            WHERE df.IdFactura = f.IdFactura
            FOR XML PATH('')
        ), 1, 2, ''), 'Sin productos') AS Productos,
        -- Sumar cantidad total
        ISNULL((
            SELECT SUM(df.Cantidad)
            FROM DETALLE_FACTURA df
            WHERE df.IdFactura = f.IdFactura
        ), 0) AS Cantidad,
        op.MetodoPago,
        op.MontoTotal,
        op.FechaRegistro,
        op.Estado,
        op.UsuarioRegistro
    FROM ORDEN_PAGO op
    INNER JOIN FACTURA f ON op.IdFactura = f.IdFactura
    INNER JOIN PROVEEDOR p ON op.IdProveedor = p.IdProveedor
    WHERE (@IdProveedor IS NULL OR op.IdProveedor = @IdProveedor)
    ORDER BY op.FechaRegistro DESC
END
GO

PRINT '✓ SP_OBTENER_ORDENES_PAGO creado'
GO

-- =============================================
-- SP: Obtener Detalle de Orden de Pago
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_OBTENER_DETALLE_ORDEN_PAGO' AND type = 'P')
    DROP PROCEDURE SP_OBTENER_DETALLE_ORDEN_PAGO
GO

CREATE PROCEDURE SP_OBTENER_DETALLE_ORDEN_PAGO
    @IdOrdenPago INT
AS
BEGIN
    -- Datos de la orden de pago
    SELECT 
        op.IdOrdenPago,
        op.NumeroOrdenPago,
        op.IdFactura,
        f.NumeroFactura,
        op.IdProveedor,
        p.RazonSocial AS NombreProveedor,
        p.RUC AS DocumentoProveedor,
        p.Correo AS CorreoProveedor,
        p.Telefono AS TelefonoProveedor,
        op.MetodoPago,
        op.MontoTotal,
        op.FechaRegistro,
        op.Estado,
        op.UsuarioRegistro,
        op.FechaRegistro AS FechaFactura
    FROM ORDEN_PAGO op
    INNER JOIN FACTURA f ON op.IdFactura = f.IdFactura
    INNER JOIN PROVEEDOR p ON op.IdProveedor = p.IdProveedor
    WHERE op.IdOrdenPago = @IdOrdenPago
    
    -- Detalle de productos de la factura
    SELECT 
        df.IdDetalleFactura,
        df.IdProducto,
        pr.Nombre AS NombreProducto,
        pr.Codigo AS CodigoProducto,
        df.Cantidad,
        df.PrecioUnitario,
        df.Subtotal
    FROM DETALLE_FACTURA df
    INNER JOIN PRODUCTO pr ON df.IdProducto = pr.IdProducto
    INNER JOIN ORDEN_PAGO op ON df.IdFactura = op.IdFactura
    WHERE op.IdOrdenPago = @IdOrdenPago
END
GO

PRINT '✓ SP_OBTENER_DETALLE_ORDEN_PAGO creado'
GO

PRINT ''
PRINT '========================================='
PRINT 'STORED PROCEDURES CREADOS CORRECTAMENTE'
PRINT '========================================='
GO
