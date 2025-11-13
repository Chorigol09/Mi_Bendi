-- =============================================
-- Script: 037_SEED_PRECIOS_TODAS_LISTAS.sql
-- Descripcion: Asigna precios a TODOS los productos existentes
--              en TODAS las listas de precios
-- Fecha: 12/11/2024
-- =============================================

USE DBVENTAS_WEB
GO

PRINT '======================================='
PRINT 'Asignando Precios a Todos los Productos'
PRINT '======================================='
PRINT ''

-- Verificar que existan listas de precios
IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE Activo = 1)
BEGIN
    PRINT 'ERROR: No hay listas de precios activas'
    PRINT 'Ejecuta primero el script 036_GENERAR_PRECIOS_AUTOMATICOS.sql'
    RETURN
END

-- Verificar que existan productos
IF NOT EXISTS (SELECT 1 FROM PRODUCTO WHERE Activo = 1)
BEGIN
    PRINT 'ERROR: No hay productos activos en la base de datos'
    RETURN
END

DECLARE @CantidadListas INT
DECLARE @CantidadProductos INT

SELECT @CantidadListas = COUNT(*) FROM LISTA_PRECIO WHERE Activo = 1
SELECT @CantidadProductos = COUNT(*) FROM PRODUCTO WHERE Activo = 1

PRINT 'Listas de precios activas: ' + CAST(@CantidadListas AS VARCHAR)
PRINT 'Productos activos: ' + CAST(@CantidadProductos AS VARCHAR)
PRINT ''

BEGIN TRANSACTION

BEGIN TRY

    -- Variables
    DECLARE @IdLista INT
    DECLARE @NombreLista VARCHAR(100)
    DECLARE @TipoLista VARCHAR(50)
    DECLARE @IdProducto INT
    DECLARE @NombreProducto VARCHAR(100)
    DECLARE @PrecioBase DECIMAL(18,2)
    DECLARE @PrecioFinal DECIMAL(18,2)
    DECLARE @Factor DECIMAL(5,2)
    DECLARE @FechaInicio DATE = DATEADD(MONTH, -1, GETDATE())
    DECLARE @FechaFin DATE = DATEADD(YEAR, 1, GETDATE())
    DECLARE @Contador INT = 0
    DECLARE @TotalInsertados INT = 0

    -- Cursor de listas
    DECLARE curListas CURSOR FOR
    SELECT IdListaPrecio, Nombre, TipoLista
    FROM LISTA_PRECIO
    WHERE Activo = 1
    ORDER BY IdListaPrecio

    OPEN curListas
    FETCH NEXT FROM curListas INTO @IdLista, @NombreLista, @TipoLista

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Procesando: ' + @NombreLista + ' (' + @TipoLista + ')'
        SET @Contador = 0

        -- Determinar factor de precio segun tipo de lista
        SET @Factor = CASE @TipoLista
            WHEN 'Minorista' THEN 1.00      -- Precio base
            WHEN 'Mayorista' THEN 0.75      -- 25% descuento
            WHEN 'Distribuidor' THEN 0.60   -- 40% descuento
            WHEN 'Promocion' THEN 0.85      -- 15% descuento
            ELSE 1.00
        END

        -- Cursor de productos
        DECLARE curProductos CURSOR FOR
        SELECT IdProducto, Nombre
        FROM PRODUCTO
        WHERE Activo = 1
        ORDER BY IdProducto

        OPEN curProductos
        FETCH NEXT FROM curProductos INTO @IdProducto, @NombreProducto

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Generar precio base aleatorio entre 500 y 20000
            SET @PrecioBase = ROUND(RAND(CHECKSUM(NEWID())) * 19500 + 500, -2)
            
            -- Aplicar factor segun tipo de lista
            SET @PrecioFinal = ROUND(@PrecioBase * @Factor, 2)

            -- Verificar si ya existe el producto en esta lista
            IF NOT EXISTS (
                SELECT 1 FROM LISTA_PRECIO_DETALLE
                WHERE IdListaPrecio = @IdLista
                AND IdProducto = @IdProducto
                AND Activo = 1
            )
            BEGIN
                -- Insertar el precio
                INSERT INTO LISTA_PRECIO_DETALLE (
                    IdListaPrecio,
                    IdProducto,
                    PrecioVenta,
                    FechaVigenciaDesde,
                    FechaVigenciaHasta,
                    Activo
                )
                VALUES (
                    @IdLista,
                    @IdProducto,
                    @PrecioFinal,
                    @FechaInicio,
                    @FechaFin,
                    1
                )

                SET @Contador = @Contador + 1
                SET @TotalInsertados = @TotalInsertados + 1
            END

            FETCH NEXT FROM curProductos INTO @IdProducto, @NombreProducto
        END

        CLOSE curProductos
        DEALLOCATE curProductos

        PRINT '  > Productos agregados: ' + CAST(@Contador AS VARCHAR)
        PRINT ''

        FETCH NEXT FROM curListas INTO @IdLista, @NombreLista, @TipoLista
    END

    CLOSE curListas
    DEALLOCATE curListas

    COMMIT TRANSACTION

    PRINT '======================================='
    PRINT 'PROCESO COMPLETADO EXITOSAMENTE'
    PRINT '======================================='
    PRINT ''
    PRINT 'Total de precios insertados: ' + CAST(@TotalInsertados AS VARCHAR)
    PRINT ''

    -- Mostrar resumen por lista
    PRINT '======================================='
    PRINT 'RESUMEN POR LISTA DE PRECIOS'
    PRINT '======================================='
    PRINT ''

    DECLARE @IdListaResumen INT
    DECLARE @NombreListaResumen VARCHAR(100)
    DECLARE @CantidadProductosResumen INT
    DECLARE @PrecioMin DECIMAL(18,2)
    DECLARE @PrecioMax DECIMAL(18,2)
    DECLARE @PrecioPromedio DECIMAL(18,2)

    DECLARE curResumen CURSOR FOR
    SELECT 
        LP.IdListaPrecio,
        LP.Nombre,
        COUNT(LPD.IdListaPrecioDetalle) AS Cantidad,
        MIN(LPD.PrecioVenta) AS PrecioMin,
        MAX(LPD.PrecioVenta) AS PrecioMax,
        AVG(LPD.PrecioVenta) AS PrecioPromedio
    FROM LISTA_PRECIO LP
    INNER JOIN LISTA_PRECIO_DETALLE LPD ON LP.IdListaPrecio = LPD.IdListaPrecio
    WHERE LP.Activo = 1 AND LPD.Activo = 1
    GROUP BY LP.IdListaPrecio, LP.Nombre
    ORDER BY LP.IdListaPrecio

    OPEN curResumen
    FETCH NEXT FROM curResumen INTO @IdListaResumen, @NombreListaResumen, @CantidadProductosResumen, @PrecioMin, @PrecioMax, @PrecioPromedio

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @NombreListaResumen
        PRINT '  - Productos: ' + CAST(@CantidadProductosResumen AS VARCHAR)
        PRINT '  - Precio minimo: $' + CAST(@PrecioMin AS VARCHAR)
        PRINT '  - Precio maximo: $' + CAST(@PrecioMax AS VARCHAR)
        PRINT '  - Precio promedio: $' + CAST(@PrecioPromedio AS VARCHAR)
        PRINT ''

        FETCH NEXT FROM curResumen INTO @IdListaResumen, @NombreListaResumen, @CantidadProductosResumen, @PrecioMin, @PrecioMax, @PrecioPromedio
    END

    CLOSE curResumen
    DEALLOCATE curResumen

    PRINT '======================================='
    PRINT 'LISTO - Todas las listas tienen precios'
    PRINT '======================================='

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    
    PRINT ''
    PRINT 'ERROR al asignar precios:'
    PRINT ERROR_MESSAGE()
    PRINT ''
END CATCH

GO
