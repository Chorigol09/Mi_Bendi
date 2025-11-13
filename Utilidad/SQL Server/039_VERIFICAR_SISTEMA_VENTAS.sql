-- =============================================
-- Script de Verificación del Sistema de Ventas
-- Verifica que todo esté configurado correctamente
-- =============================================

USE DBVENTAS_WEB
GO

PRINT ''
PRINT '========================================='
PRINT 'VERIFICACIÓN DEL SISTEMA DE VENTAS'
PRINT '========================================='
PRINT ''

-- 1. Verificar columna IdListaPrecio en VENTA
PRINT '1. Verificando columna IdListaPrecio en tabla VENTA...'
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('VENTA') AND name = 'IdListaPrecio')
    PRINT '   ✅ Columna IdListaPrecio EXISTE'
ELSE
BEGIN
    PRINT '   ❌ ERROR: Columna IdListaPrecio NO EXISTE'
    PRINT '   ⚠️  SOLUCIÓN: Ejecutar script 035_AGREGAR_LISTA_PRECIO_VENTA.sql'
END
PRINT ''

-- 2. Verificar columna MetodoPago en VENTA
PRINT '2. Verificando columna MetodoPago en tabla VENTA...'
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('VENTA') AND name = 'MetodoPago')
    PRINT '   ✅ Columna MetodoPago EXISTE'
ELSE
BEGIN
    PRINT '   ❌ ERROR: Columna MetodoPago NO EXISTE'
    PRINT '   ⚠️  SOLUCIÓN: Ejecutar script 035_AGREGAR_LISTA_PRECIO_VENTA.sql'
END
PRINT ''

-- 3. Verificar stored procedure existe
PRINT '3. Verificando stored procedure usp_RegistrarVenta...'
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_RegistrarVenta')
    PRINT '   ✅ Stored procedure EXISTE'
ELSE
BEGIN
    PRINT '   ❌ ERROR: Stored procedure NO EXISTE'
    PRINT '   ⚠️  SOLUCIÓN: Ejecutar script 035_AGREGAR_LISTA_PRECIO_VENTA.sql'
END
PRINT ''

-- 4. Verificar parámetro correcto del SP
PRINT '4. Verificando parámetros del stored procedure...'
IF EXISTS (
    SELECT * FROM sys.parameters 
    WHERE object_id = OBJECT_ID('usp_RegistrarVenta') 
    AND name = '@DetalleVenta'
)
    PRINT '   ✅ Parámetro @DetalleVenta CORRECTO'
ELSE
BEGIN
    PRINT '   ❌ ERROR: Stored procedure usa parámetro antiguo @Detalle'
    PRINT '   ⚠️  SOLUCIÓN: Ejecutar script 035_AGREGAR_LISTA_PRECIO_VENTA.sql'
END
PRINT ''

-- 5. Verificar índice
PRINT '5. Verificando índice IX_VENTA_IdListaPrecio...'
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VENTA_IdListaPrecio' AND object_id = OBJECT_ID('VENTA'))
    PRINT '   ✅ Índice EXISTE'
ELSE
    PRINT '   ⚠️  ADVERTENCIA: Índice no existe (opcional, mejora performance)'
PRINT ''

-- 6. Verificar que hay listas de precios
PRINT '6. Verificando listas de precios...'
IF EXISTS (SELECT * FROM LISTA_PRECIO WHERE Activo = 1)
BEGIN
    DECLARE @CantidadListas INT
    DECLARE @ListasConProductos INT
    
    SELECT @CantidadListas = COUNT(*) FROM LISTA_PRECIO WHERE Activo = 1
    
    SELECT @ListasConProductos = COUNT(DISTINCT IdListaPrecio) 
    FROM LISTA_PRECIO_DETALLE 
    WHERE Activo = 1 
    AND GETDATE() BETWEEN FechaVigenciaDesde AND FechaVigenciaHasta
    
    PRINT '   ✅ Hay ' + CAST(@CantidadListas AS VARCHAR) + ' lista(s) de precios activa(s)'
    PRINT '   ✅ ' + CAST(@ListasConProductos AS VARCHAR) + ' lista(s) tienen productos vigentes'
    
    -- Mostrar las listas
    PRINT ''
    PRINT '   Listas de precios activas:'
    SELECT 
        '   - ' + Nombre + ' (' + TipoLista + ')' AS Lista
    FROM LISTA_PRECIO 
    WHERE Activo = 1
    ORDER BY Nombre
END
ELSE
BEGIN
    PRINT '   ❌ ERROR: No hay listas de precios activas'
    PRINT '   ⚠️  SOLUCIÓN: Crear al menos una lista de precios en el módulo de Listas'
END
PRINT ''

-- 7. Verificar productos con stock
PRINT '7. Verificando productos con stock...'
IF EXISTS (SELECT * FROM PRODUCTO_TIENDA WHERE Stock > 0)
BEGIN
    DECLARE @ProductosConStock INT
    SELECT @ProductosConStock = COUNT(*) FROM PRODUCTO_TIENDA WHERE Stock > 0
    PRINT '   ✅ Hay ' + CAST(@ProductosConStock AS VARCHAR) + ' producto(s) con stock'
END
ELSE
BEGIN
    PRINT '   ⚠️  ADVERTENCIA: No hay productos con stock'
    PRINT '   ⚠️  SOLUCIÓN: Agregar stock a los productos'
END
PRINT ''

-- 8. Verificar que hay productos en listas con precios vigentes
PRINT '8. Verificando productos en listas con precios vigentes...'
IF EXISTS (
    SELECT * FROM LISTA_PRECIO_DETALLE 
    WHERE Activo = 1 
    AND GETDATE() BETWEEN FechaVigenciaDesde AND FechaVigenciaHasta
)
BEGIN
    DECLARE @ProductosVigentes INT
    SELECT @ProductosVigentes = COUNT(*) 
    FROM LISTA_PRECIO_DETALLE 
    WHERE Activo = 1 
    AND GETDATE() BETWEEN FechaVigenciaDesde AND FechaVigenciaHasta
    
    PRINT '   ✅ Hay ' + CAST(@ProductosVigentes AS VARCHAR) + ' producto(s) con precio vigente en listas'
END
ELSE
BEGIN
    PRINT '   ❌ ERROR: No hay productos con precios vigentes en las listas'
    PRINT '   ⚠️  SOLUCIÓN: Agregar productos con precios a las listas o ejecutar script 037_SEED_PRECIOS_TODAS_LISTAS.sql'
END
PRINT ''

-- 9. Resumen final
PRINT '========================================='
PRINT 'RESUMEN'
PRINT '========================================='
PRINT ''

DECLARE @ErrorCount INT = 0
DECLARE @WarningCount INT = 0

-- Contar errores críticos
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('VENTA') AND name = 'IdListaPrecio')
    SET @ErrorCount = @ErrorCount + 1

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('VENTA') AND name = 'MetodoPago')
    SET @ErrorCount = @ErrorCount + 1

IF NOT EXISTS (SELECT * FROM sys.procedures WHERE name = 'usp_RegistrarVenta')
    SET @ErrorCount = @ErrorCount + 1

IF NOT EXISTS (
    SELECT * FROM sys.parameters 
    WHERE object_id = OBJECT_ID('usp_RegistrarVenta') 
    AND name = '@DetalleVenta'
)
    SET @ErrorCount = @ErrorCount + 1

IF NOT EXISTS (SELECT * FROM LISTA_PRECIO WHERE Activo = 1)
    SET @ErrorCount = @ErrorCount + 1

IF NOT EXISTS (
    SELECT * FROM LISTA_PRECIO_DETALLE 
    WHERE Activo = 1 
    AND GETDATE() BETWEEN FechaVigenciaDesde AND FechaVigenciaHasta
)
    SET @ErrorCount = @ErrorCount + 1

-- Contar advertencias
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_VENTA_IdListaPrecio' AND object_id = OBJECT_ID('VENTA'))
    SET @WarningCount = @WarningCount + 1

IF NOT EXISTS (SELECT * FROM PRODUCTO_TIENDA WHERE Stock > 0)
    SET @WarningCount = @WarningCount + 1

-- Mostrar resultado
IF @ErrorCount = 0 AND @WarningCount = 0
BEGIN
    PRINT '✅✅✅ SISTEMA COMPLETAMENTE FUNCIONAL ✅✅✅'
    PRINT ''
    PRINT 'El sistema de ventas está correctamente configurado.'
    PRINT 'Puedes proceder a registrar ventas sin problemas.'
END
ELSE IF @ErrorCount = 0
BEGIN
    PRINT '✅ Sistema funcional con ' + CAST(@WarningCount AS VARCHAR) + ' advertencia(s)'
    PRINT ''
    PRINT 'El sistema funciona pero hay mejoras recomendadas.'
    PRINT 'Revisa las advertencias arriba.'
END
ELSE
BEGIN
    PRINT '❌ SISTEMA CON ERRORES CRÍTICOS ❌'
    PRINT ''
    PRINT 'Se encontraron ' + CAST(@ErrorCount AS VARCHAR) + ' error(es) crítico(s)'
    PRINT 'Se encontraron ' + CAST(@WarningCount AS VARCHAR) + ' advertencia(s)'
    PRINT ''
    PRINT '⚠️  ACCIÓN REQUERIDA:'
    PRINT '   1. Ejecutar script: 035_AGREGAR_LISTA_PRECIO_VENTA.sql'
    PRINT '   2. Ejecutar script: 037_SEED_PRECIOS_TODAS_LISTAS.sql (si no hay productos en listas)'
    PRINT '   3. Recompilar proyecto C# (Clean + Rebuild)'
    PRINT '   4. Volver a ejecutar este script para verificar'
END

PRINT ''
PRINT '========================================='
PRINT 'FIN DE VERIFICACIÓN'
PRINT '========================================='
PRINT ''
GO
