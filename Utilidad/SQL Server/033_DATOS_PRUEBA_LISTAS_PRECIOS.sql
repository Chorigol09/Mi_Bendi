-- =============================================
-- SCRIPT: DATOS DE PRUEBA PARA LISTAS DE PRECIOS
-- Fecha: 2025-11-12
-- Descripción: Inserta datos de ejemplo para probar el sistema de listas de precios
-- ADVERTENCIA: Solo ejecutar en ambiente de desarrollo/pruebas
-- =============================================

USE DBVENTAS_WEB
GO

PRINT '====================================='
PRINT 'INSERTANDO DATOS DE PRUEBA'
PRINT 'SISTEMA DE LISTAS DE PRECIOS'
PRINT '====================================='

-- =============================================
-- LISTAS DE PRECIOS DE EJEMPLO
-- =============================================

-- Lista 1: Minorista
IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE Nombre = 'Lista Minorista 2025')
BEGIN
    INSERT INTO LISTA_PRECIO (Nombre, Descripcion, TipoLista, IdTienda, Activo)
    VALUES ('Lista Minorista 2025', 'Precios al público general', 'Minorista', NULL, 1)
    PRINT 'Lista Minorista creada'
END

-- Lista 2: Mayorista
IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE Nombre = 'Lista Mayorista 2025')
BEGIN
    INSERT INTO LISTA_PRECIO (Nombre, Descripcion, TipoLista, IdTienda, Activo)
    VALUES ('Lista Mayorista 2025', 'Precios para compras al por mayor (mínimo 10 unidades)', 'Mayorista', NULL, 1)
    PRINT 'Lista Mayorista creada'
END

-- Lista 3: Distribuidores
IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE Nombre = 'Lista Distribuidores 2025')
BEGIN
    INSERT INTO LISTA_PRECIO (Nombre, Descripcion, TipoLista, IdTienda, Activo)
    VALUES ('Lista Distribuidores 2025', 'Precios especiales para distribuidores autorizados', 'Distribuidor', NULL, 1)
    PRINT 'Lista Distribuidores creada'
END

-- Lista 4: Promoción Black Friday
IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO WHERE Nombre = 'Promoción Black Friday 2025')
BEGIN
    INSERT INTO LISTA_PRECIO (Nombre, Descripcion, TipoLista, IdTienda, Activo)
    VALUES ('Promoción Black Friday 2025', 'Descuentos especiales por Black Friday', 'Promocion', NULL, 1)
    PRINT 'Lista Promoción Black Friday creada'
END

PRINT ''
PRINT 'Listas de precios creadas: 4'
PRINT ''

-- =============================================
-- ASIGNACIÓN DE PRODUCTOS A LISTAS (EJEMPLOS)
-- =============================================
PRINT 'Asignando productos a listas...'

DECLARE @IdListaMinorista INT
DECLARE @IdListaMayorista INT
DECLARE @IdListaDistribuidor INT
DECLARE @IdListaPromocion INT

-- Obtener IDs de las listas
SELECT @IdListaMinorista = IdListaPrecio FROM LISTA_PRECIO WHERE Nombre = 'Lista Minorista 2025'
SELECT @IdListaMayorista = IdListaPrecio FROM LISTA_PRECIO WHERE Nombre = 'Lista Mayorista 2025'
SELECT @IdListaDistribuidor = IdListaPrecio FROM LISTA_PRECIO WHERE Nombre = 'Lista Distribuidores 2025'
SELECT @IdListaPromocion = IdListaPrecio FROM LISTA_PRECIO WHERE Nombre = 'Promoción Black Friday 2025'

-- Obtener algunos productos de ejemplo (asumiendo que existen productos)
DECLARE @IdProducto1 INT, @IdProducto2 INT, @IdProducto3 INT, @IdProducto4 INT, @IdProducto5 INT

-- Tomar los primeros 5 productos activos
SELECT TOP 5 
    @IdProducto1 = MAX(CASE WHEN rn = 1 THEN IdProducto END),
    @IdProducto2 = MAX(CASE WHEN rn = 2 THEN IdProducto END),
    @IdProducto3 = MAX(CASE WHEN rn = 3 THEN IdProducto END),
    @IdProducto4 = MAX(CASE WHEN rn = 4 THEN IdProducto END),
    @IdProducto5 = MAX(CASE WHEN rn = 5 THEN IdProducto END)
FROM (
    SELECT IdProducto, ROW_NUMBER() OVER (ORDER BY IdProducto) as rn
    FROM PRODUCTO
    WHERE Activo = 1
) AS ProductosNumerados

IF @IdProducto1 IS NOT NULL
BEGIN
    -- =============================================
    -- PRODUCTO 1: En todas las listas
    -- =============================================
    
    -- Minorista: $100
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecio = @IdListaMinorista AND IdProducto = @IdProducto1)
    BEGIN
        INSERT INTO LISTA_PRECIO_DETALLE (IdListaPrecio, IdProducto, PrecioVenta, FechaVigenciaDesde, FechaVigenciaHasta, Activo)
        VALUES (@IdListaMinorista, @IdProducto1, 100.00, '2025-01-01', '2025-12-31', 1)
    END
    
    -- Mayorista: $85 (15% descuento)
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecio = @IdListaMayorista AND IdProducto = @IdProducto1)
    BEGIN
        INSERT INTO LISTA_PRECIO_DETALLE (IdListaPrecio, IdProducto, PrecioVenta, FechaVigenciaDesde, FechaVigenciaHasta, Activo)
        VALUES (@IdListaMayorista, @IdProducto1, 85.00, '2025-01-01', '2025-12-31', 1)
    END
    
    -- Distribuidor: $75 (25% descuento)
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecio = @IdListaDistribuidor AND IdProducto = @IdProducto1)
    BEGIN
        INSERT INTO LISTA_PRECIO_DETALLE (IdListaPrecio, IdProducto, PrecioVenta, FechaVigenciaDesde, FechaVigenciaHasta, Activo)
        VALUES (@IdListaDistribuidor, @IdProducto1, 75.00, '2025-01-01', '2025-12-31', 1)
    END
    
    -- Promoción Black Friday: $70 (30% descuento - solo noviembre)
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecio = @IdListaPromocion AND IdProducto = @IdProducto1)
    BEGIN
        INSERT INTO LISTA_PRECIO_DETALLE (IdListaPrecio, IdProducto, PrecioVenta, FechaVigenciaDesde, FechaVigenciaHasta, Activo)
        VALUES (@IdListaPromocion, @IdProducto1, 70.00, '2025-11-01', '2025-11-30', 1)
    END
    
    PRINT 'Producto 1 asignado a 4 listas con precios diferenciados'
END

IF @IdProducto2 IS NOT NULL
BEGIN
    -- =============================================
    -- PRODUCTO 2: Solo en listas Minorista y Mayorista
    -- =============================================
    
    -- Minorista: $150
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecio = @IdListaMinorista AND IdProducto = @IdProducto2)
    BEGIN
        INSERT INTO LISTA_PRECIO_DETALLE (IdListaPrecio, IdProducto, PrecioVenta, FechaVigenciaDesde, FechaVigenciaHasta, Activo)
        VALUES (@IdListaMinorista, @IdProducto2, 150.00, '2025-01-01', '2025-12-31', 1)
    END
    
    -- Mayorista: $130
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecio = @IdListaMayorista AND IdProducto = @IdProducto2)
    BEGIN
        INSERT INTO LISTA_PRECIO_DETALLE (IdListaPrecio, IdProducto, PrecioVenta, FechaVigenciaDesde, FechaVigenciaHasta, Activo)
        VALUES (@IdListaMayorista, @IdProducto2, 130.00, '2025-01-01', '2025-12-31', 1)
    END
    
    PRINT 'Producto 2 asignado a 2 listas'
END

IF @IdProducto3 IS NOT NULL
BEGIN
    -- =============================================
    -- PRODUCTO 3: Precio con cambio de vigencia
    -- =============================================
    
    -- Minorista: $200 hasta junio
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecio = @IdListaMinorista AND IdProducto = @IdProducto3 AND FechaVigenciaDesde = '2025-01-01')
    BEGIN
        INSERT INTO LISTA_PRECIO_DETALLE (IdListaPrecio, IdProducto, PrecioVenta, FechaVigenciaDesde, FechaVigenciaHasta, Activo)
        VALUES (@IdListaMinorista, @IdProducto3, 200.00, '2025-01-01', '2025-06-30', 1)
    END
    
    -- Minorista: $180 desde julio (precio nuevo)
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecio = @IdListaMinorista AND IdProducto = @IdProducto3 AND FechaVigenciaDesde = '2025-07-01')
    BEGIN
        INSERT INTO LISTA_PRECIO_DETALLE (IdListaPrecio, IdProducto, PrecioVenta, FechaVigenciaDesde, FechaVigenciaHasta, Activo)
        VALUES (@IdListaMinorista, @IdProducto3, 180.00, '2025-07-01', '2025-12-31', 1)
    END
    
    PRINT 'Producto 3 asignado con cambio de precio en el tiempo'
END

IF @IdProducto4 IS NOT NULL
BEGIN
    -- =============================================
    -- PRODUCTO 4: Promoción temporal
    -- =============================================
    
    -- Minorista: $50
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecio = @IdListaMinorista AND IdProducto = @IdProducto4)
    BEGIN
        INSERT INTO LISTA_PRECIO_DETALLE (IdListaPrecio, IdProducto, PrecioVenta, FechaVigenciaDesde, FechaVigenciaHasta, Activo)
        VALUES (@IdListaMinorista, @IdProducto4, 50.00, '2025-01-01', '2025-12-31', 1)
    END
    
    -- Promoción: $35 (solo diciembre - promoción navideña)
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecio = @IdListaPromocion AND IdProducto = @IdProducto4)
    BEGIN
        INSERT INTO LISTA_PRECIO_DETALLE (IdListaPrecio, IdProducto, PrecioVenta, FechaVigenciaDesde, FechaVigenciaHasta, Activo)
        VALUES (@IdListaPromocion, @IdProducto4, 35.00, '2025-12-01', '2025-12-31', 1)
    END
    
    PRINT 'Producto 4 con promoción temporal'
END

IF @IdProducto5 IS NOT NULL
BEGIN
    -- =============================================
    -- PRODUCTO 5: Solo para distribuidores
    -- =============================================
    
    -- Distribuidor: $500
    IF NOT EXISTS (SELECT 1 FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecio = @IdListaDistribuidor AND IdProducto = @IdProducto5)
    BEGIN
        INSERT INTO LISTA_PRECIO_DETALLE (IdListaPrecio, IdProducto, PrecioVenta, FechaVigenciaDesde, FechaVigenciaHasta, Activo)
        VALUES (@IdListaDistribuidor, @IdProducto5, 500.00, '2025-01-01', '2025-12-31', 1)
    END
    
    PRINT 'Producto 5 exclusivo para distribuidores'
END

PRINT ''
PRINT '====================================='
PRINT 'PROCESO COMPLETADO'
PRINT '====================================='
PRINT ''

-- =============================================
-- RESUMEN DE DATOS INSERTADOS
-- =============================================
PRINT 'RESUMEN DE DATOS INSERTADOS:'
PRINT ''

-- Contar listas
DECLARE @TotalListas INT
SELECT @TotalListas = COUNT(*) FROM LISTA_PRECIO
PRINT 'Total de Listas de Precios: ' + CAST(@TotalListas AS VARCHAR)

-- Contar productos en listas
DECLARE @TotalProductosEnListas INT
SELECT @TotalProductosEnListas = COUNT(*) FROM LISTA_PRECIO_DETALLE
PRINT 'Total de Productos asignados: ' + CAST(@TotalProductosEnListas AS VARCHAR)

-- Productos vigentes hoy
DECLARE @ProductosVigentes INT
SELECT @ProductosVigentes = COUNT(*) 
FROM LISTA_PRECIO_DETALLE
WHERE Activo = 1 
  AND GETDATE() BETWEEN FechaVigenciaDesde AND FechaVigenciaHasta
PRINT 'Productos con precio vigente hoy: ' + CAST(@ProductosVigentes AS VARCHAR)

PRINT ''
PRINT '====================================='
PRINT 'Datos de prueba insertados exitosamente'
PRINT 'Ya puede probar el sistema de Listas de Precios'
PRINT '====================================='

GO
