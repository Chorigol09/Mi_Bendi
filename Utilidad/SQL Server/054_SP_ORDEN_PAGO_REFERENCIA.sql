-- =============================================
-- Script: Actualizar SP para incluir Referencia y NumeroTransaccion
-- Descripcion: Modificar procedimientos con nuevos campos
-- Fecha: 2025-11-10
-- =============================================

USE DBVENTAS_WEB
GO

PRINT '========================================='
PRINT 'ACTUALIZANDO STORED PROCEDURES'
PRINT '========================================='
PRINT ''

-- =============================================
-- SP: Registrar Orden de Pago (con Referencia y NumeroTransaccion)
-- =============================================
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'SP_REGISTRAR_ORDEN_PAGO' AND type = 'P')
    DROP PROCEDURE SP_REGISTRAR_ORDEN_PAGO
GO

CREATE PROCEDURE SP_REGISTRAR_ORDEN_PAGO
    @IdsFacturas VARCHAR(MAX),
    @IdProveedor INT,
    @MetodoPago VARCHAR(100),
    @MontoTotal DECIMAL(18,2),
    @UsuarioRegistro VARCHAR(100),
    @Referencia VARCHAR(100) = NULL,
    @NumeroTransaccion VARCHAR(100) = NULL,
    @Resultado BIT OUTPUT,
    @Mensaje VARCHAR(500) OUTPUT,
    @IdOrdenPago INT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    SET @Mensaje = ''
    SET @IdOrdenPago = 0
    
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Validar que se enviaron facturas
        IF @IdsFacturas IS NULL OR LEN(RTRIM(LTRIM(@IdsFacturas))) = 0
        BEGIN
            SET @Mensaje = 'Debe seleccionar al menos una factura'
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Crear tabla temporal para los IDs de facturas
        CREATE TABLE #FacturasTemp (IdFactura INT)
        
        -- Insertar IDs en tabla temporal
        INSERT INTO #FacturasTemp (IdFactura)
        SELECT CAST(value AS INT)
        FROM STRING_SPLIT(@IdsFacturas, ',')
        WHERE RTRIM(value) <> ''
        
        -- Verificar que todas las facturas existen y estan pendientes
        DECLARE @FacturasInvalidas INT
        SELECT @FacturasInvalidas = COUNT(*)
        FROM #FacturasTemp ft
        LEFT JOIN FACTURA f ON ft.IdFactura = f.IdFactura
        WHERE f.IdFactura IS NULL OR f.Estado <> 'Pendiente' OR f.IdProveedor <> @IdProveedor
        
        IF @FacturasInvalidas > 0
        BEGIN
            SET @Mensaje = 'Una o mas facturas no existen, ya fueron pagadas o no pertenecen al proveedor seleccionado'
            DROP TABLE #FacturasTemp
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Verificar que ninguna factura ya tenga una orden de pago
        IF EXISTS(SELECT 1 FROM DETALLE_ORDEN_PAGO dop 
                  INNER JOIN #FacturasTemp ft ON dop.IdFactura = ft.IdFactura)
        BEGIN
            SET @Mensaje = 'Una o mas facturas ya tienen una orden de pago asociada'
            DROP TABLE #FacturasTemp
            ROLLBACK TRANSACTION
            RETURN
        END
        
        -- Generar numero de orden de pago
        DECLARE @NumeroOrdenPago VARCHAR(20)
        SELECT @NumeroOrdenPago = 'OP' + RIGHT('000000' + 
            CAST(ISNULL(MAX(CAST(SUBSTRING(NumeroOrdenPago, 3, LEN(NumeroOrdenPago)) AS INT)), 0) + 1 AS VARCHAR), 6)
        FROM ORDEN_PAGO
        
        -- Insertar orden de pago
        INSERT INTO ORDEN_PAGO (
            NumeroOrdenPago,
            IdFactura,
            IdProveedor,
            MetodoPago,
            MontoTotal,
            Referencia,
            NumeroTransaccion,
            FechaRegistro,
            Estado,
            UsuarioRegistro
        )
        VALUES (
            @NumeroOrdenPago,
            NULL,
            @IdProveedor,
            @MetodoPago,
            @MontoTotal,
            @Referencia,
            @NumeroTransaccion,
            GETDATE(),
            'Pagado',
            @UsuarioRegistro
        )
        
        SET @IdOrdenPago = SCOPE_IDENTITY()
        
        -- Insertar detalle de facturas en DETALLE_ORDEN_PAGO
        INSERT INTO DETALLE_ORDEN_PAGO (IdOrdenPago, IdFactura, MontoFactura)
        SELECT 
            @IdOrdenPago,
            f.IdFactura,
            f.Total
        FROM #FacturasTemp ft
        INNER JOIN FACTURA f ON ft.IdFactura = f.IdFactura
        
        -- Actualizar estado de todas las facturas a 'Pagado'
        UPDATE f
        SET Estado = 'Pagado'
        FROM FACTURA f
        INNER JOIN #FacturasTemp ft ON f.IdFactura = ft.IdFactura
        
        -- Obtener cantidad de facturas procesadas
        DECLARE @CantidadFacturas INT
        SELECT @CantidadFacturas = COUNT(*) FROM #FacturasTemp
        
        SET @Resultado = 1
        SET @Mensaje = 'Orden de pago registrada correctamente con numero: ' + @NumeroOrdenPago + 
                      ' (' + CAST(@CantidadFacturas AS VARCHAR) + ' factura(s) procesada(s))'
        
        -- Limpiar tabla temporal
        DROP TABLE #FacturasTemp
        
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        
        IF OBJECT_ID('tempdb..#FacturasTemp') IS NOT NULL
            DROP TABLE #FacturasTemp
            
        SET @Mensaje = ERROR_MESSAGE()
        SET @Resultado = 0
    END CATCH
END
GO

PRINT '✓ SP_REGISTRAR_ORDEN_PAGO actualizado con Referencia y NumeroTransaccion'
GO

-- =============================================
-- SP: Obtener Detalle Orden de Pago (actualizado)
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
        0 AS IdFactura,
        STUFF((
            SELECT ', ' + f.NumeroFactura
            FROM DETALLE_ORDEN_PAGO dop
            INNER JOIN FACTURA f ON dop.IdFactura = f.IdFactura
            WHERE dop.IdOrdenPago = op.IdOrdenPago
            FOR XML PATH('')
        ), 1, 2, '') AS NumeroFactura,
        op.IdProveedor,
        p.RazonSocial AS NombreProveedor,
        p.RUC AS DocumentoProveedor,
        p.Correo AS CorreoProveedor,
        p.Telefono AS TelefonoProveedor,
        op.MetodoPago,
        op.MontoTotal,
        op.Referencia,
        op.NumeroTransaccion,
        op.FechaRegistro,
        op.Estado,
        op.UsuarioRegistro,
        op.FechaRegistro AS FechaFactura
    FROM ORDEN_PAGO op
    INNER JOIN PROVEEDOR p ON op.IdProveedor = p.IdProveedor
    WHERE op.IdOrdenPago = @IdOrdenPago
    
    -- Detalle de productos de TODAS las facturas asociadas
    SELECT 
        df.IdDetalleFactura,
        df.IdProducto,
        pr.Nombre AS NombreProducto,
        pr.Codigo AS CodigoProducto,
        df.Cantidad,
        df.PrecioUnitario,
        df.Subtotal,
        f.NumeroFactura
    FROM DETALLE_ORDEN_PAGO dop
    INNER JOIN FACTURA f ON dop.IdFactura = f.IdFactura
    INNER JOIN DETALLE_FACTURA df ON f.IdFactura = df.IdFactura
    INNER JOIN PRODUCTO pr ON df.IdProducto = pr.IdProducto
    WHERE dop.IdOrdenPago = @IdOrdenPago
    ORDER BY f.NumeroFactura, pr.Nombre
END
GO

PRINT '✓ SP_OBTENER_DETALLE_ORDEN_PAGO actualizado'
GO

PRINT ''
PRINT '========================================='
PRINT 'STORED PROCEDURES ACTUALIZADOS'
PRINT '========================================='
GO
