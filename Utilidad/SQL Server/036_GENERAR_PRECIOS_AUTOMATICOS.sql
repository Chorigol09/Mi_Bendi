-- =============================================
-- Script: 036_GENERAR_PRECIOS_AUTOMATICOS.sql
-- Descripción: Genera listas de precios automáticamente
--              con precios lógicos para todos los productos
--              Mayorista: 20-30% más barato que Minorista
-- Fecha: 12/11/2024
-- =============================================

USE DBVENTAS_WEB
GO

PRINT '======================================='
PRINT 'Generando Listas de Precios Automáticas'
PRINT '======================================='
PRINT ''

-- Verificar que las tablas existan
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'LISTA_PRECIO')
BEGIN
    PRINT '❌ ERROR: La tabla LISTA_PRECIO no existe'
    PRINT 'Debes ejecutar primero el script: 031_SISTEMA_LISTAS_PRECIOS.sql'
    RETURN
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'LISTA_PRECIO_DETALLE')
BEGIN
    PRINT '❌ ERROR: La tabla LISTA_PRECIO_DETALLE no existe'
    PRINT 'Debes ejecutar primero el script: 031_SISTEMA_LISTAS_PRECIOS.sql'
    RETURN
END

PRINT '✅ Tablas verificadas correctamente'
PRINT ''

-- Limpiar listas anteriores (opcional)
-- DESCOMENTA SI QUIERES BORRAR Y REGENERAR TODO
/*
DELETE FROM LISTA_PRECIO_DETALLE
DELETE FROM LISTA_PRECIO
DBCC CHECKIDENT ('LISTA_PRECIO', RESEED, 0)
DBCC CHECKIDENT ('LISTA_PRECIO_DETALLE', RESEED, 0)
*/

BEGIN TRANSACTION

BEGIN TRY

    -- =============================================
    -- PASO 1: CREAR LISTAS DE PRECIOS
    -- =============================================
    
    DECLARE @IdListaMinorista INT
    DECLARE @IdListaMayorista INT
    DECLARE @IdListaPromocion INT
    DECLARE @IdListaDistribuidor INT
    DECLARE @IdListaCyberMonday INT
    
    -- Lista Minorista (Precio Regular)
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE Nombre = 'Lista Minorista 2024')
    BEGIN
        INSERT INTO LISTA_PRECIO (Nombre, Descripcion, TipoLista, IdTienda, Activo)
        VALUES ('Lista Minorista 2024', 'Precios de venta al público general', 'Minorista', NULL, 1)
        
        SET @IdListaMinorista = SCOPE_IDENTITY()
        PRINT '✅ Lista Minorista creada - ID: ' + CAST(@IdListaMinorista AS VARCHAR)
    END
    ELSE
    BEGIN
        SELECT @IdListaMinorista = IdListaPrecio 
        FROM LISTA_PRECIO 
        WHERE Nombre = 'Lista Minorista 2024'
        
        PRINT '✅ Lista Minorista ya existe - ID: ' + CAST(@IdListaMinorista AS VARCHAR)
    END
    
    -- Lista Mayorista (20-30% más barato)
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE Nombre = 'Lista Mayorista 2024')
    BEGIN
        INSERT INTO LISTA_PRECIO (Nombre, Descripcion, TipoLista, IdTienda, Activo)
        VALUES ('Lista Mayorista 2024', 'Precios especiales para compras al por mayor (mínimo 10 unidades)', 'Mayorista', NULL, 1)
        
        SET @IdListaMayorista = SCOPE_IDENTITY()
        PRINT '✅ Lista Mayorista creada - ID: ' + CAST(@IdListaMayorista AS VARCHAR)
    END
    ELSE
    BEGIN
        SELECT @IdListaMayorista = IdListaPrecio 
        FROM LISTA_PRECIO 
        WHERE Nombre = 'Lista Mayorista 2024'
        
        PRINT '✅ Lista Mayorista ya existe - ID: ' + CAST(@IdListaMayorista AS VARCHAR)
    END
    
    -- Lista Promoción (15% más barato que minorista)
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE Nombre = 'Lista Promoción Black Friday')
    BEGIN
        INSERT INTO LISTA_PRECIO (Nombre, Descripcion, TipoLista, IdTienda, Activo)
        VALUES ('Lista Promoción Black Friday', 'Precios promocionales con descuentos especiales', 'Promocion', NULL, 1)
        
        SET @IdListaPromocion = SCOPE_IDENTITY()
        PRINT '✅ Lista Promoción creada - ID: ' + CAST(@IdListaPromocion AS VARCHAR)
    END
    ELSE
    BEGIN
        SELECT @IdListaPromocion = IdListaPrecio 
        FROM LISTA_PRECIO 
        WHERE Nombre = 'Lista Promoción Black Friday'
        
        PRINT '✅ Lista Promoción ya existe - ID: ' + CAST(@IdListaPromocion AS VARCHAR)
    END
    
    -- Lista Distribuidor (35-45% más barato que minorista)
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE Nombre = 'Lista Distribuidor 2024')
    BEGIN
        INSERT INTO LISTA_PRECIO (Nombre, Descripcion, TipoLista, IdTienda, Activo)
        VALUES ('Lista Distribuidor 2024', 'Precios especiales para distribuidores (compras superiores a 100 unidades)', 'Distribuidor', NULL, 1)
        
        SET @IdListaDistribuidor = SCOPE_IDENTITY()
        PRINT '✅ Lista Distribuidor creada - ID: ' + CAST(@IdListaDistribuidor AS VARCHAR)
    END
    ELSE
    BEGIN
        SELECT @IdListaDistribuidor = IdListaPrecio 
        FROM LISTA_PRECIO 
        WHERE Nombre = 'Lista Distribuidor 2024'
        
        PRINT '✅ Lista Distribuidor ya existe - ID: ' + CAST(@IdListaDistribuidor AS VARCHAR)
    END
    
    -- Lista Cyber Monday (25% más barato que minorista)
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE Nombre = 'Lista Cyber Monday 2024')
    BEGIN
        INSERT INTO LISTA_PRECIO (Nombre, Descripcion, TipoLista, IdTienda, Activo)
        VALUES ('Lista Cyber Monday 2024', 'Precios promocionales exclusivos para Cyber Monday', 'Promocion', NULL, 1)
        
        SET @IdListaCyberMonday = SCOPE_IDENTITY()
        PRINT '✅ Lista Cyber Monday creada - ID: ' + CAST(@IdListaCyberMonday AS VARCHAR)
    END
    ELSE
    BEGIN
        SELECT @IdListaCyberMonday = IdListaPrecio 
        FROM LISTA_PRECIO 
        WHERE Nombre = 'Lista Cyber Monday 2024'
        
        PRINT '✅ Lista Cyber Monday ya existe - ID: ' + CAST(@IdListaCyberMonday AS VARCHAR)
    END
    
    PRINT ''
    
    -- =============================================
    -- PASO 2: ASIGNAR PRECIOS A PRODUCTOS
    -- =============================================
    
    PRINT 'Asignando precios a productos...'
    PRINT ''
    
    -- Fechas de vigencia
    DECLARE @FechaInicio DATE = DATEADD(MONTH, -1, GETDATE())
    DECLARE @FechaFin DATE = DATEADD(YEAR, 1, GETDATE())
    DECLARE @FechaFinPromocion DATE = DATEADD(MONTH, 1, GETDATE())
    
    -- Variables para generación de precios
    DECLARE @IdProducto INT
    DECLARE @NombreProducto VARCHAR(100)
    DECLARE @PrecioBase DECIMAL(18,2)
    DECLARE @PrecioMinorista DECIMAL(18,2)
    DECLARE @PrecioMayorista DECIMAL(18,2)
    DECLARE @PrecioPromocion DECIMAL(18,2)
    DECLARE @PrecioDistribuidor DECIMAL(18,2)
    DECLARE @PrecioCyberMonday DECIMAL(18,2)
    DECLARE @DescuentoMayorista DECIMAL(5,2)
    DECLARE @ContadorProductos INT = 0
    
    -- Cursor para recorrer productos activos
    DECLARE curProductos CURSOR FOR
    SELECT IdProducto, Nombre
    FROM PRODUCTO
    WHERE Activo = 1
    ORDER BY IdProducto
    
    OPEN curProductos
    FETCH NEXT FROM curProductos INTO @IdProducto, @NombreProducto
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generar precio base aleatorio entre 500 y 50000
        -- (puedes ajustar estos valores según tu negocio)
        SET @PrecioBase = ROUND(RAND(CHECKSUM(NEWID())) * 49500 + 500, -1)
        
        -- PRECIO MINORISTA (precio base + margen del 40-60%)
        SET @PrecioMinorista = ROUND(@PrecioBase * (1 + (RAND(CHECKSUM(NEWID())) * 0.2 + 0.4)), 2)
        
        -- PRECIO MAYORISTA (20-30% más barato que minorista)
        SET @DescuentoMayorista = RAND(CHECKSUM(NEWID())) * 0.1 + 0.2 -- Entre 20% y 30%
        SET @PrecioMayorista = ROUND(@PrecioMinorista * (1 - @DescuentoMayorista), 2)
        
        -- PRECIO PROMOCIÓN (15% más barato que minorista)
        SET @PrecioPromocion = ROUND(@PrecioMinorista * 0.85, 2)
        
        -- PRECIO DISTRIBUIDOR (35-45% más barato que minorista)
        SET @PrecioDistribuidor = ROUND(@PrecioMinorista * (1 - (RAND(CHECKSUM(NEWID())) * 0.1 + 0.35)), 2)
        
        -- PRECIO CYBER MONDAY (25% más barato que minorista)
        SET @PrecioCyberMonday = ROUND(@PrecioMinorista * 0.75, 2)
        
        -- Asegurar que los precios sean lógicos
        IF @PrecioMayorista >= @PrecioMinorista
            SET @PrecioMayorista = ROUND(@PrecioMinorista * 0.75, 2)
        
        IF @PrecioPromocion >= @PrecioMinorista
            SET @PrecioPromocion = ROUND(@PrecioMinorista * 0.85, 2)
            
        IF @PrecioDistribuidor >= @PrecioMayorista
            SET @PrecioDistribuidor = ROUND(@PrecioMayorista * 0.85, 2)
        
        -- INSERTAR PRECIO MINORISTA
        IF NOT EXISTS (
            SELECT 1 FROM LISTA_PRECIO_DETALLE 
            WHERE IdListaPrecio = @IdListaMinorista 
            AND IdProducto = @IdProducto
            AND Activo = 1
        )
        BEGIN
            INSERT INTO LISTA_PRECIO_DETALLE (
                IdListaPrecio, IdProducto, PrecioVenta, 
                FechaVigenciaDesde, FechaVigenciaHasta, Activo
            )
            VALUES (
                @IdListaMinorista, @IdProducto, @PrecioMinorista,
                @FechaInicio, @FechaFin, 1
            )
        END
        
        -- INSERTAR PRECIO MAYORISTA
        IF NOT EXISTS (
            SELECT 1 FROM LISTA_PRECIO_DETALLE 
            WHERE IdListaPrecio = @IdListaMayorista 
            AND IdProducto = @IdProducto
            AND Activo = 1
        )
        BEGIN
            INSERT INTO LISTA_PRECIO_DETALLE (
                IdListaPrecio, IdProducto, PrecioVenta,
                FechaVigenciaDesde, FechaVigenciaHasta, Activo
            )
            VALUES (
                @IdListaMayorista, @IdProducto, @PrecioMayorista,
                @FechaInicio, @FechaFin, 1
            )
        END
        
        -- INSERTAR PRECIO PROMOCIÓN
        IF NOT EXISTS (
            SELECT 1 FROM LISTA_PRECIO_DETALLE 
            WHERE IdListaPrecio = @IdListaPromocion 
            AND IdProducto = @IdProducto
            AND Activo = 1
        )
        BEGIN
            INSERT INTO LISTA_PRECIO_DETALLE (
                IdListaPrecio, IdProducto, PrecioVenta,
                FechaVigenciaDesde, FechaVigenciaHasta, Activo
            )
            VALUES (
                @IdListaPromocion, @IdProducto, @PrecioPromocion,
                @FechaInicio, @FechaFinPromocion, 1
            )
        END
        
        -- INSERTAR PRECIO DISTRIBUIDOR
        IF NOT EXISTS (
            SELECT 1 FROM LISTA_PRECIO_DETALLE 
            WHERE IdListaPrecio = @IdListaDistribuidor 
            AND IdProducto = @IdProducto
            AND Activo = 1
        )
        BEGIN
            INSERT INTO LISTA_PRECIO_DETALLE (
                IdListaPrecio, IdProducto, PrecioVenta,
                FechaVigenciaDesde, FechaVigenciaHasta, Activo
            )
            VALUES (
                @IdListaDistribuidor, @IdProducto, @PrecioDistribuidor,
                @FechaInicio, @FechaFin, 1
            )
        END
        
        -- INSERTAR PRECIO CYBER MONDAY
        IF NOT EXISTS (
            SELECT 1 FROM LISTA_PRECIO_DETALLE 
            WHERE IdListaPrecio = @IdListaCyberMonday 
            AND IdProducto = @IdProducto
            AND Activo = 1
        )
        BEGIN
            INSERT INTO LISTA_PRECIO_DETALLE (
                IdListaPrecio, IdProducto, PrecioVenta,
                FechaVigenciaDesde, FechaVigenciaHasta, Activo
            )
            VALUES (
                @IdListaCyberMonday, @IdProducto, @PrecioCyberMonday,
                @FechaInicio, @FechaFinPromocion, 1
            )
        END
        
        SET @ContadorProductos = @ContadorProductos + 1
        
        -- Mostrar progreso cada 10 productos
        IF @ContadorProductos % 10 = 0
            PRINT '  → Procesados ' + CAST(@ContadorProductos AS VARCHAR) + ' productos...'
        
        FETCH NEXT FROM curProductos INTO @IdProducto, @NombreProducto
    END
    
    CLOSE curProductos
    DEALLOCATE curProductos
    
    PRINT ''
    PRINT '✅ Total de productos procesados: ' + CAST(@ContadorProductos AS VARCHAR)
    PRINT ''
    
    COMMIT TRANSACTION
    
    -- =============================================
    -- RESUMEN FINAL
    -- =============================================
    
    PRINT '========================================='
    PRINT 'RESUMEN DE LISTAS DE PRECIOS'
    PRINT '========================================='
    PRINT ''
    
    -- Variables para resumen (declaradas después del COMMIT)
    DECLARE @ContadorResumen INT
    DECLARE @PrecioMin DECIMAL(18,2)
    DECLARE @PrecioMax DECIMAL(18,2)
    
    -- Lista Minorista
    SELECT 
        @ContadorResumen = COUNT(*),
        @PrecioMin = MIN(PrecioVenta),
        @PrecioMax = MAX(PrecioVenta)
    FROM LISTA_PRECIO_DETALLE
    WHERE IdListaPrecio = @IdListaMinorista AND Activo = 1
    
    PRINT '📋 LISTA MINORISTA:'
    PRINT '   - Productos: ' + CAST(@ContadorResumen AS VARCHAR)
    PRINT '   - Rango de precios: $' + CAST(@PrecioMin AS VARCHAR) + ' - $' + CAST(@PrecioMax AS VARCHAR)
    PRINT ''
    
    -- Lista Mayorista
    SELECT 
        @ContadorResumen = COUNT(*),
        @PrecioMin = MIN(PrecioVenta),
        @PrecioMax = MAX(PrecioVenta)
    FROM LISTA_PRECIO_DETALLE
    WHERE IdListaPrecio = @IdListaMayorista AND Activo = 1
    
    PRINT '📋 LISTA MAYORISTA:'
    PRINT '   - Productos: ' + CAST(@ContadorResumen AS VARCHAR)
    PRINT '   - Rango de precios: $' + CAST(@PrecioMin AS VARCHAR) + ' - $' + CAST(@PrecioMax AS VARCHAR)
    PRINT '   - Descuento promedio: 20-30% respecto a Minorista'
    PRINT ''
    
    -- Lista Promoción
    SELECT 
        @ContadorResumen = COUNT(*),
        @PrecioMin = MIN(PrecioVenta),
        @PrecioMax = MAX(PrecioVenta)
    FROM LISTA_PRECIO_DETALLE
    WHERE IdListaPrecio = @IdListaPromocion AND Activo = 1
    
    PRINT '📋 LISTA PROMOCIÓN:'
    PRINT '   - Productos: ' + CAST(@ContadorResumen AS VARCHAR)
    PRINT '   - Rango de precios: $' + CAST(@PrecioMin AS VARCHAR) + ' - $' + CAST(@PrecioMax AS VARCHAR)
    PRINT '   - Descuento: 15% respecto a Minorista'
    PRINT '   - Vigencia hasta: ' + CONVERT(VARCHAR, @FechaFinPromocion, 103)
    PRINT ''
    
    -- Ejemplo de comparación
    PRINT '========================================='
    PRINT 'EJEMPLO DE COMPARACIÓN DE PRECIOS'
    PRINT '========================================='
    PRINT ''
    
    SELECT TOP 5
        P.Nombre AS Producto,
        MIN_P.PrecioVenta AS Minorista,
        MAY_P.PrecioVenta AS Mayorista,
        ROUND((MIN_P.PrecioVenta - MAY_P.PrecioVenta) / MIN_P.PrecioVenta * 100, 2) AS [Descuento %],
        PRO_P.PrecioVenta AS Promocion
    FROM PRODUCTO P
    INNER JOIN LISTA_PRECIO_DETALLE MIN_P ON P.IdProducto = MIN_P.IdProducto AND MIN_P.IdListaPrecio = @IdListaMinorista
    INNER JOIN LISTA_PRECIO_DETALLE MAY_P ON P.IdProducto = MAY_P.IdProducto AND MAY_P.IdListaPrecio = @IdListaMayorista
    INNER JOIN LISTA_PRECIO_DETALLE PRO_P ON P.IdProducto = PRO_P.IdProducto AND PRO_P.IdListaPrecio = @IdListaPromocion
    WHERE P.Activo = 1
    ORDER BY NEWID()
    
    PRINT ''
    PRINT '========================================='
    PRINT '✅ PROCESO COMPLETADO EXITOSAMENTE'
    PRINT '========================================='
    PRINT ''
    PRINT 'Ahora puedes:'
    PRINT '1. Ir a Ventas > Registrar Venta'
    PRINT '2. Seleccionar una lista de precios'
    PRINT '3. Los precios se asignarán automáticamente'
    PRINT ''
    
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION
    
    PRINT ''
    PRINT '❌ ERROR: ' + ERROR_MESSAGE()
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR)
    PRINT ''
END CATCH

GO
