# Instrucciones - Seed de Precios para Todos los Productos

## Objetivo

Asignar precios a **TODOS los productos existentes** en **TODAS las listas de precios** de forma automática.

---

## Pasos para Ejecutar

### 1. Abrir SQL Server Management Studio

Conectarse a la base de datos `DBVENTAS_WEB`

### 2. Ejecutar Script de Seed

```sql
USE DBVENTAS_WEB
GO

-- Ejecutar TODO el contenido de:
-- 037_SEED_PRECIOS_TODAS_LISTAS.sql
```

### 3. Resultado Esperado

Veras un mensaje como este:

```
=======================================
Asignando Precios a Todos los Productos
=======================================

Listas de precios activas: 5
Productos activos: 50

Procesando: Lista Minorista 2024 (Minorista)
  > Productos agregados: 50

Procesando: Lista Mayorista 2024 (Mayorista)
  > Productos agregados: 50

Procesando: Lista Promocion Black Friday (Promocion)
  > Productos agregados: 50

Procesando: Lista Distribuidor 2024 (Distribuidor)
  > Productos agregados: 50

Procesando: Lista Cyber Monday 2024 (Promocion)
  > Productos agregados: 50

=======================================
PROCESO COMPLETADO EXITOSAMENTE
=======================================

Total de precios insertados: 250

=======================================
RESUMEN POR LISTA DE PRECIOS
=======================================

Lista Minorista 2024
  - Productos: 50
  - Precio minimo: $500
  - Precio maximo: $20000
  - Precio promedio: $10250

Lista Mayorista 2024
  - Productos: 50
  - Precio minimo: $375
  - Precio maximo: $15000
  - Precio promedio: $7687.50

(... y asi para todas las listas)
```

---

## Como Funciona el Script

### 1. Factores de Precio por Tipo de Lista

```
Minorista:     100% (precio base)
Mayorista:      75% (25% descuento)
Distribuidor:   60% (40% descuento)
Promocion:      85% (15% descuento)
```

### 2. Ejemplo de Precios para un Producto

Supongamos que el precio base generado es **$10,000**:

```
Lista Minorista:     $10,000 (100%)
Lista Mayorista:      $7,500 (75%)
Lista Distribuidor:   $6,000 (60%)
Lista Promocion:      $8,500 (85%)
```

### 3. Validaciones del Script

- ✅ Verifica que existan listas activas
- ✅ Verifica que existan productos activos
- ✅ No duplica productos (verifica antes de insertar)
- ✅ Solo procesa registros activos
- ✅ Muestra resumen detallado al finalizar

---

## Verificar los Resultados

### Query 1: Ver cuantos productos tiene cada lista

```sql
SELECT 
    LP.Nombre AS Lista,
    COUNT(LPD.IdListaPrecioDetalle) AS CantidadProductos
FROM LISTA_PRECIO LP
LEFT JOIN LISTA_PRECIO_DETALLE LPD ON LP.IdListaPrecio = LPD.IdListaPrecio
    AND LPD.Activo = 1
WHERE LP.Activo = 1
GROUP BY LP.Nombre
ORDER BY LP.Nombre
```

### Query 2: Ver precios de un producto especifico en todas las listas

```sql
SELECT 
    LP.Nombre AS Lista,
    LP.TipoLista,
    P.Nombre AS Producto,
    LPD.PrecioVenta
FROM LISTA_PRECIO_DETALLE LPD
INNER JOIN LISTA_PRECIO LP ON LPD.IdListaPrecio = LP.IdListaPrecio
INNER JOIN PRODUCTO P ON LPD.IdProducto = P.IdProducto
WHERE P.IdProducto = 1  -- Cambiar por el ID del producto que quieras ver
  AND LPD.Activo = 1
  AND LP.Activo = 1
ORDER BY LPD.PrecioVenta DESC
```

### Query 3: Ver productos sin precio en alguna lista

```sql
-- Esta query debe devolver 0 resultados si el seed funciono bien
SELECT 
    LP.Nombre AS Lista,
    COUNT(P.IdProducto) AS ProductosSinPrecio
FROM LISTA_PRECIO LP
CROSS JOIN PRODUCTO P
WHERE P.Activo = 1
  AND LP.Activo = 1
  AND NOT EXISTS (
      SELECT 1 FROM LISTA_PRECIO_DETALLE LPD
      WHERE LPD.IdListaPrecio = LP.IdListaPrecio
        AND LPD.IdProducto = P.IdProducto
        AND LPD.Activo = 1
  )
GROUP BY LP.Nombre
HAVING COUNT(P.IdProducto) > 0
```

---

## Si Necesitas Re-ejecutar el Script

El script es **idempotente**, es decir, puedes ejecutarlo varias veces y no duplicara productos.

**Si quieres limpiar y volver a generar TODO:**

```sql
-- CUIDADO: Esto borra TODOS los precios
DELETE FROM LISTA_PRECIO_DETALLE

-- Luego re-ejecuta el script 037
```

---

## Probar en la Aplicacion

1. **Recompilar** el proyecto (Ctrl + Shift + B)
2. **Ejecutar** (F5)
3. Ir a **Listas de Precios**
4. Abrir cualquier lista
5. Deberia ver **TODOS** los productos con sus precios

---

## Ventajas de este Script

✅ **Simple y rapido** - Asigna precios a todos los productos en segundos
✅ **Seguro** - Verifica antes de insertar, no duplica
✅ **Logico** - Aplica descuentos segun tipo de lista
✅ **Idempotente** - Puedes ejecutarlo multiples veces sin problemas
✅ **Informativo** - Muestra resumen detallado al finalizar
✅ **Transaccional** - Si hay error, no deja datos a medias

---

## Troubleshooting

### "No hay listas de precios activas"

**Solucion:** Ejecutar primero el script `036_GENERAR_PRECIOS_AUTOMATICOS.sql` para crear las listas.

### "No hay productos activos"

**Solucion:** Agregar productos a la base de datos desde la aplicacion.

### "Productos agregados: 0"

**Solucion:** Los productos ya tienen precio en esa lista. Si quieres regenerar, ejecuta:

```sql
DELETE FROM LISTA_PRECIO_DETALLE WHERE IdListaPrecio = [ID_DE_LA_LISTA]
```

Y vuelve a ejecutar el script.

---

**Fecha:** 12/11/2024  
**Version:** 1.0  
**Estado:** ✅ Listo para usar
