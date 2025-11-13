-- =============================================
-- CONSULTAS ÚTILES PARA LISTAS DE PRECIOS
-- Fecha: 2025-11-12
-- Descripción: Conjunto de consultas para administrar y monitorear el sistema
-- =============================================

USE DBVENTAS_WEB
GO

PRINT '====================================='
PRINT 'CONSULTAS ÚTILES - LISTAS DE PRECIOS'
PRINT '====================================='

-- =============================================
-- 1. VER TODAS LAS LISTAS DE PRECIOS
-- =============================================
PRINT ''
PRINT '1. TODAS LAS LISTAS DE PRECIOS:'
PRINT '-------------------------------------'

SELECT 
    lp.IdListaPrecio,
    lp.Nombre,
    lp.TipoLista,
    lp.Descripcion,
    ISNULL(t.Nombre, 'Todas las tiendas') AS Tienda,
    lp.Activo,
    COUNT(DISTINCT lpd.IdProducto) AS CantidadProductos,
    COUNT(CASE WHEN lpd.Activo = 1 AND GETDATE() BETWEEN lpd.FechaVigenciaDesde AND lpd.FechaVigenciaHasta THEN 1 END) AS ProductosVigentes,
    lp.FechaRegistro
FROM LISTA_PRECIO lp
LEFT JOIN TIENDA t ON lp.IdTienda = t.IdTienda
LEFT JOIN LISTA_PRECIO_DETALLE lpd ON lp.IdListaPrecio = lpd.IdListaPrecio
GROUP BY lp.IdListaPrecio, lp.Nombre, lp.TipoLista, lp.Descripcion, t.Nombre, lp.Activo, lp.FechaRegistro
ORDER BY lp.TipoLista, lp.Nombre

-- =============================================
-- 2. PRODUCTOS POR LISTA CON ESTADO DE VIGENCIA
-- =============================================
PRINT ''
PRINT '2. PRODUCTOS EN CADA LISTA (con vigencia):'
PRINT '-------------------------------------'

SELECT 
    lp.Nombre AS Lista,
    lp.TipoLista,
    p.Codigo,
    p.Nombre AS Producto,
    c.Descripcion AS Categoria,
    lpd.PrecioVenta,
    lpd.FechaVigenciaDesde,
    lpd.FechaVigenciaHasta,
    CASE 
        WHEN lpd.Activo = 1 AND GETDATE() BETWEEN lpd.FechaVigenciaDesde AND lpd.FechaVigenciaHasta THEN 'Vigente'
        WHEN lpd.Activo = 0 THEN 'Inactivo'
        WHEN GETDATE() < lpd.FechaVigenciaDesde THEN 'Futuro'
        WHEN GETDATE() > lpd.FechaVigenciaHasta THEN 'Vencido'
        ELSE 'Desconocido'
    END AS Estado
FROM LISTA_PRECIO_DETALLE lpd
INNER JOIN LISTA_PRECIO lp ON lpd.IdListaPrecio = lp.IdListaPrecio
INNER JOIN PRODUCTO p ON lpd.IdProducto = p.IdProducto
INNER JOIN CATEGORIA c ON p.IdCategoria = c.IdCategoria
ORDER BY lp.Nombre, p.Nombre

-- =============================================
-- 3. COMPARACIÓN DE PRECIOS ENTRE LISTAS
-- =============================================
PRINT ''
PRINT '3. COMPARACIÓN DE PRECIOS ENTRE LISTAS (solo vigentes):'
PRINT '-------------------------------------'

SELECT 
    p.Codigo,
    p.Nombre AS Producto,
    MAX(CASE WHEN lp.TipoLista = 'Minorista' THEN lpd.PrecioVenta END) AS Precio_Minorista,
    MAX(CASE WHEN lp.TipoLista = 'Mayorista' THEN lpd.PrecioVenta END) AS Precio_Mayorista,
    MAX(CASE WHEN lp.TipoLista = 'Distribuidor' THEN lpd.PrecioVenta END) AS Precio_Distribuidor,
    MAX(CASE WHEN lp.TipoLista = 'Promocion' THEN lpd.PrecioVenta END) AS Precio_Promocion
FROM PRODUCTO p
LEFT JOIN LISTA_PRECIO_DETALLE lpd ON p.IdProducto = lpd.IdProducto 
    AND lpd.Activo = 1 
    AND GETDATE() BETWEEN lpd.FechaVigenciaDesde AND lpd.FechaVigenciaHasta
LEFT JOIN LISTA_PRECIO lp ON lpd.IdListaPrecio = lp.IdListaPrecio
WHERE p.Activo = 1
GROUP BY p.IdProducto, p.Codigo, p.Nombre
HAVING MAX(CASE WHEN lp.TipoLista IS NOT NULL THEN 1 ELSE 0 END) = 1
ORDER BY p.Nombre

-- =============================================
-- 4. PRODUCTOS CON PRECIOS QUE VENCEN PRONTO (próximos 30 días)
-- =============================================
PRINT ''
PRINT '4. PRECIOS QUE VENCEN EN LOS PRÓXIMOS 30 DÍAS:'
PRINT '-------------------------------------'

SELECT 
    lp.Nombre AS Lista,
    p.Codigo,
    p.Nombre AS Producto,
    lpd.PrecioVenta,
    lpd.FechaVigenciaHasta AS FechaVencimiento,
    DATEDIFF(DAY, GETDATE(), lpd.FechaVigenciaHasta) AS DiasRestantes
FROM LISTA_PRECIO_DETALLE lpd
INNER JOIN LISTA_PRECIO lp ON lpd.IdListaPrecio = lp.IdListaPrecio
INNER JOIN PRODUCTO p ON lpd.IdProducto = p.IdProducto
WHERE lpd.Activo = 1
  AND lpd.FechaVigenciaHasta BETWEEN GETDATE() AND DATEADD(DAY, 30, GETDATE())
ORDER BY lpd.FechaVigenciaHasta, lp.Nombre

-- =============================================
-- 5. PRODUCTOS SIN PRECIO EN UNA LISTA ESPECÍFICA
-- =============================================
PRINT ''
PRINT '5. PRODUCTOS SIN PRECIO VIGENTE EN LISTA MINORISTA:'
PRINT '-------------------------------------'

DECLARE @IdLista INT
SELECT @IdLista = IdListaPrecio FROM LISTA_PRECIO WHERE TipoLista = 'Minorista' AND Activo = 1

SELECT 
    p.IdProducto,
    p.Codigo,
    p.Nombre,
    c.Descripcion AS Categoria
FROM PRODUCTO p
INNER JOIN CATEGORIA c ON p.IdCategoria = c.IdCategoria
WHERE p.Activo = 1
  AND NOT EXISTS (
      SELECT 1 
      FROM LISTA_PRECIO_DETALLE lpd
      WHERE lpd.IdProducto = p.IdProducto
        AND lpd.IdListaPrecio = @IdLista
        AND lpd.Activo = 1
        AND GETDATE() BETWEEN lpd.FechaVigenciaDesde AND lpd.FechaVigenciaHasta
  )
ORDER BY p.Nombre

-- =============================================
-- 6. HISTORIAL DE CAMBIOS DE PRECIO DE UN PRODUCTO
-- =============================================
PRINT ''
PRINT '6. HISTORIAL DE PRECIOS DEL PRIMER PRODUCTO:'
PRINT '-------------------------------------'

DECLARE @IdProductoHist INT
SELECT TOP 1 @IdProductoHist = IdProducto FROM PRODUCTO WHERE Activo = 1 ORDER BY IdProducto

SELECT 
    lp.Nombre AS Lista,
    lp.TipoLista,
    lpd.PrecioVenta,
    lpd.FechaVigenciaDesde,
    lpd.FechaVigenciaHasta,
    CASE 
        WHEN lpd.Activo = 1 AND GETDATE() BETWEEN lpd.FechaVigenciaDesde AND lpd.FechaVigenciaHasta THEN 'Vigente'
        WHEN lpd.Activo = 0 THEN 'Inactivo'
        WHEN GETDATE() < lpd.FechaVigenciaDesde THEN 'Futuro'
        WHEN GETDATE() > lpd.FechaVigenciaHasta THEN 'Vencido'
    END AS Estado,
    lpd.FechaRegistro
FROM LISTA_PRECIO_DETALLE lpd
INNER JOIN LISTA_PRECIO lp ON lpd.IdListaPrecio = lp.IdListaPrecio
WHERE lpd.IdProducto = @IdProductoHist
ORDER BY lp.Nombre, lpd.FechaVigenciaDesde DESC

-- =============================================
-- 7. ESTADÍSTICAS GENERALES
-- =============================================
PRINT ''
PRINT '7. ESTADÍSTICAS GENERALES:'
PRINT '-------------------------------------'

SELECT 
    'Total de Listas' AS Metrica,
    COUNT(*) AS Valor
FROM LISTA_PRECIO
UNION ALL
SELECT 
    'Listas Activas',
    COUNT(*)
FROM LISTA_PRECIO
WHERE Activo = 1
UNION ALL
SELECT 
    'Total de Precios Configurados',
    COUNT(*)
FROM LISTA_PRECIO_DETALLE
UNION ALL
SELECT 
    'Precios Vigentes Hoy',
    COUNT(*)
FROM LISTA_PRECIO_DETALLE
WHERE Activo = 1 
  AND GETDATE() BETWEEN FechaVigenciaDesde AND FechaVigenciaHasta
UNION ALL
SELECT 
    'Precios Vencidos',
    COUNT(*)
FROM LISTA_PRECIO_DETALLE
WHERE Activo = 1 
  AND GETDATE() > FechaVigenciaHasta
UNION ALL
SELECT 
    'Precios Futuros',
    COUNT(*)
FROM LISTA_PRECIO_DETALLE
WHERE Activo = 1 
  AND GETDATE() < FechaVigenciaDesde

-- =============================================
-- 8. PRECIOS MÁS ALTOS Y MÁS BAJOS POR PRODUCTO
-- =============================================
PRINT ''
PRINT '8. RANGO DE PRECIOS POR PRODUCTO (vigentes):'
PRINT '-------------------------------------'

SELECT 
    p.Codigo,
    p.Nombre AS Producto,
    MIN(lpd.PrecioVenta) AS PrecioMinimo,
    MAX(lpd.PrecioVenta) AS PrecioMaximo,
    MAX(lpd.PrecioVenta) - MIN(lpd.PrecioVenta) AS Diferencia,
    CASE 
        WHEN MIN(lpd.PrecioVenta) > 0 THEN 
            CAST(((MAX(lpd.PrecioVenta) - MIN(lpd.PrecioVenta)) / MIN(lpd.PrecioVenta) * 100) AS DECIMAL(10,2))
        ELSE 0 
    END AS DiferenciaPorcentaje,
    COUNT(*) AS CantidadListas
FROM PRODUCTO p
INNER JOIN LISTA_PRECIO_DETALLE lpd ON p.IdProducto = lpd.IdProducto
WHERE lpd.Activo = 1
  AND GETDATE() BETWEEN lpd.FechaVigenciaDesde AND lpd.FechaVigenciaHasta
GROUP BY p.IdProducto, p.Codigo, p.Nombre
HAVING COUNT(*) > 1
ORDER BY DiferenciaPorcentaje DESC

-- =============================================
-- 9. LISTAS CON MÁS PRODUCTOS
-- =============================================
PRINT ''
PRINT '9. RANKING DE LISTAS POR CANTIDAD DE PRODUCTOS:'
PRINT '-------------------------------------'

SELECT 
    lp.Nombre AS Lista,
    lp.TipoLista,
    COUNT(DISTINCT lpd.IdProducto) AS TotalProductos,
    COUNT(CASE WHEN lpd.Activo = 1 AND GETDATE() BETWEEN lpd.FechaVigenciaDesde AND lpd.FechaVigenciaHasta THEN 1 END) AS ProductosVigentes
FROM LISTA_PRECIO lp
LEFT JOIN LISTA_PRECIO_DETALLE lpd ON lp.IdListaPrecio = lpd.IdListaPrecio
WHERE lp.Activo = 1
GROUP BY lp.IdListaPrecio, lp.Nombre, lp.TipoLista
ORDER BY TotalProductos DESC, ProductosVigentes DESC

-- =============================================
-- 10. VERIFICAR SOLAPAMIENTOS (No deberían existir)
-- =============================================
PRINT ''
PRINT '10. VERIFICAR SOLAPAMIENTOS DE FECHAS (debe estar vacío):'
PRINT '-------------------------------------'

SELECT 
    lp.Nombre AS Lista,
    p.Nombre AS Producto,
    lpd1.PrecioVenta AS Precio1,
    lpd1.FechaVigenciaDesde AS Desde1,
    lpd1.FechaVigenciaHasta AS Hasta1,
    lpd2.PrecioVenta AS Precio2,
    lpd2.FechaVigenciaDesde AS Desde2,
    lpd2.FechaVigenciaHasta AS Hasta2,
    'SOLAPAMIENTO DETECTADO' AS Alerta
FROM LISTA_PRECIO_DETALLE lpd1
INNER JOIN LISTA_PRECIO_DETALLE lpd2 ON lpd1.IdListaPrecio = lpd2.IdListaPrecio 
    AND lpd1.IdProducto = lpd2.IdProducto
    AND lpd1.IdListaPrecioDetalle < lpd2.IdListaPrecioDetalle
INNER JOIN LISTA_PRECIO lp ON lpd1.IdListaPrecio = lp.IdListaPrecio
INNER JOIN PRODUCTO p ON lpd1.IdProducto = p.IdProducto
WHERE lpd1.Activo = 1 
  AND lpd2.Activo = 1
  AND (
      (lpd1.FechaVigenciaDesde BETWEEN lpd2.FechaVigenciaDesde AND lpd2.FechaVigenciaHasta)
      OR (lpd1.FechaVigenciaHasta BETWEEN lpd2.FechaVigenciaDesde AND lpd2.FechaVigenciaHasta)
      OR (lpd2.FechaVigenciaDesde BETWEEN lpd1.FechaVigenciaDesde AND lpd1.FechaVigenciaHasta)
  )

PRINT ''
PRINT '====================================='
PRINT 'FIN DE CONSULTAS ÚTILES'
PRINT '====================================='

GO
