# 📋 Guía de Uso - Sistema de Listas de Precios

## ✅ Funcionalidades Implementadas

### 1. Ver Listas de Precios
### 2. Crear Nueva Lista (Manual o desde otra lista)
### 3. Editar Precios Individuales
### 4. Usar Listas en Ventas

---

## 🎯 1. Ver Listas de Precios

### Acceder al Módulo
1. Ir a **Administración** > **Listas de Precios**
2. Verás una tabla con todas las listas:
   - **Nombre**: Nombre de la lista
   - **Tipo**: Minorista, Mayorista, Distribuidor, Promoción
   - **Productos**: Cantidad total de productos
   - **Vigentes**: Productos con precio vigente actual
   - **Estado**: Activo / Inactivo
   - **Acciones**: Ver productos o Editar lista

### Ver Productos de una Lista
1. Click en el botón **[📋]** (azul) en la columna Acciones
2. Se abre la vista de detalle con todos los productos
3. Muestra para cada producto:
   - Código y nombre
   - Precio de venta
   - Fechas de vigencia (desde - hasta)
   - Estado (Activo/Inactivo)

---

## 🆕 2. Crear Nueva Lista de Precios

Hay **DOS formas** de crear una lista:

### Opción A: Crear Lista Vacía (Manual)

1. Click en **[+ Nueva Lista de Precios]**
2. Completar el formulario:
   - **Nombre**: Ejemplo: "Lista Verano 2024"
   - **Tipo**: Seleccionar tipo (Minorista, Mayorista, etc.)
   - **Descripción**: Opcional
   - **Tienda**: Opcional (dejar vacío para todas las tiendas)
   - **Estado**: Activo/Inactivo
3. Click en **[Guardar]**
4. La lista se crea vacía
5. Ir a la vista de detalle y agregar productos uno por uno

### Opción B: Copiar desde otra Lista con Ajuste 🔥

**Esta es la opción NUEVA y más potente**

1. Click en **[+ Nueva Lista de Precios]**
2. Completar datos básicos (Nombre, Tipo, Descripción)
3. ✅ **Marcar el checkbox**: "Copiar precios desde otra lista"
4. Aparece una sección nueva:
   - **Lista de Origen**: Seleccionar la lista base
   - **Ajuste de Precio (%)**: Ingresar el porcentaje
5. Click en **[Guardar]**
6. ¡Listo! Se copian TODOS los productos con precios ajustados

#### Ejemplos de Ajuste:

**Aumentar precios (+):**
```
Lista Origen: Minorista 2024 (Producto: $1.000)
Ajuste: +10%
Resultado: $1.100 (aumenta 10%)
```

**Reducir precios (-):**
```
Lista Origen: Minorista 2024 (Producto: $1.000)
Ajuste: -20%
Resultado: $800 (baja 20%)
```

**Sin cambios:**
```
Lista Origen: Minorista 2024 (Producto: $1.000)
Ajuste: 0%
Resultado: $1.000 (igual)
```

#### Casos de Uso Comunes:

**📊 Crear lista Mayorista desde Minorista:**
- Lista Origen: Lista Minorista 2024
- Ajuste: `-25%` (25% más barato)
- Uso: Para clientes que compran al por mayor

**🎉 Crear lista Promoción:**
- Lista Origen: Lista Minorista 2024
- Ajuste: `-15%` (15% de descuento)
- Uso: Black Friday, Cyber Monday

**📈 Actualizar precios por inflación:**
- Lista Origen: Lista Minorista 2023
- Ajuste: `+12%` (ajuste inflacionario)
- Uso: Nueva lista con precios actualizados

**🏪 Crear lista para otra sucursal:**
- Lista Origen: Lista Sucursal Centro
- Ajuste: `+5%` (gastos logísticos)
- Uso: Sucursal más alejada

---

## ✏️ 3. Editar Precios en una Lista

### Editar Precio de un Producto Individual

1. Ir a **Listas de Precios**
2. Click en **[📋]** para ver productos de la lista
3. Buscar el producto a editar
4. Click en **[✏️ Editar]** en la fila del producto
5. Se abre modal con datos actuales:
   - Precio actual
   - Fechas de vigencia
6. **Cambiar el precio** al nuevo valor
7. Ajustar fechas de vigencia si es necesario
8. Click en **[Guardar]**
9. ✅ **Solo ese producto cambia de precio**
10. **Los demás productos mantienen su precio original**

### Ejemplo Práctico:

```
Situación:
- Lista: "Mayorista 2024"
- Producto: "Coca Cola 1.5L"
- Precio actual: $1.200
- Proveedor aumentó el costo

Acción:
1. Editar producto "Coca Cola 1.5L"
2. Cambiar precio de $1.200 a $1.400
3. Guardar

Resultado:
✅ Coca Cola 1.5L → $1.400 (nuevo precio)
✅ Pepsi 1.5L → $1.100 (mantiene su precio)
✅ Sprite 1.5L → $1.050 (mantiene su precio)
✅ Todos los demás → (mantienen sus precios)
```

### Agregar Nuevo Producto a Lista Existente

1. Ir a la vista de detalle de la lista
2. Click en **[+ Agregar Producto]**
3. Seleccionar el producto
4. Ingresar el precio de venta
5. Establecer fechas de vigencia
6. Click en **[Guardar]**

---

## 💰 4. Usar Listas en Ventas

### Flujo de Venta con Lista de Precios

1. Ir a **Ventas** > **Registrar Venta**

2. **PASO 1**: Seleccionar Lista de Precios
   - Aparece un selector en la parte superior
   - Elegir la lista apropiada:
     * Minorista (cliente particular)
     * Mayorista (cliente al por mayor)
     * Promoción (si hay descuentos activos)

3. **PASO 2**: Buscar/Seleccionar Producto
   - Por código o búsqueda
   - El sistema busca el producto

4. **PASO 3**: Precio Automático ⭐
   - **El precio aparece automáticamente** de la lista seleccionada
   - **NO puedes editarlo** (solo lectura)
   - Es el precio vigente para hoy

5. **PASO 4**: Ingresar Cantidad
   - Solo ingresas la cantidad a vender

6. **PASO 5**: Agregar a la Venta
   - Click en **[Agregar]**
   - El producto se suma al detalle

7. **PASO 6**: Finalizar Venta
   - Click en **[Imprimir y Terminar Venta]**
   - La venta se registra con la lista utilizada

### Validaciones del Sistema:

❌ **No permite:**
- Agregar productos sin seleccionar lista primero
- Editar el precio manualmente
- Cambiar de lista con productos ya agregados (sin confirmación)

✅ **Permite:**
- Ver el precio antes de agregar
- Cambiar la cantidad
- Quitar productos del detalle
- Cambiar de lista (borra los productos agregados)

### Ejemplo de Venta:

```
Cliente: Comercial "El Ahorro" (compra al por mayor)

1. Seleccionar: "Lista Mayorista 2024"
2. Buscar: Coca Cola 1.5L
   → Precio automático: $1.125 (precio mayorista)
3. Cantidad: 50 unidades
4. Total línea: $56.250
5. Agregar

6. Buscar: Pepsi 1.5L
   → Precio automático: $1.050 (precio mayorista)
7. Cantidad: 30 unidades
8. Total línea: $31.500
9. Agregar

Total Venta: $87.750
Lista utilizada: Mayorista 2024
```

---

## 📊 Reportes y Consultas

### Ver Ventas por Lista de Precios

```sql
-- Ventas del último mes por lista
SELECT 
    LP.Nombre AS ListaPrecio,
    LP.TipoLista,
    COUNT(V.IdVenta) AS CantidadVentas,
    SUM(V.TotalCosto) AS MontoTotal,
    AVG(V.TotalCosto) AS TicketPromedio
FROM VENTA V
INNER JOIN LISTA_PRECIO LP ON V.IdListaPrecio = LP.IdListaPrecio
WHERE V.FechaRegistro >= DATEADD(MONTH, -1, GETDATE())
  AND V.Activo = 1
GROUP BY LP.Nombre, LP.TipoLista
ORDER BY MontoTotal DESC
```

### Productos Más Vendidos por Lista

```sql
-- Top 10 productos por lista
SELECT TOP 10
    LP.Nombre AS ListaPrecio,
    P.Nombre AS Producto,
    COUNT(*) AS CantidadVentas,
    SUM(DV.Cantidad) AS UnidadesVendidas,
    SUM(DV.ImporteTotal) AS MontoTotal
FROM DETALLE_VENTA DV
INNER JOIN VENTA V ON DV.IdVenta = V.IdVenta
INNER JOIN LISTA_PRECIO LP ON V.IdListaPrecio = LP.IdListaPrecio
INNER JOIN PRODUCTO P ON DV.IdProducto = P.IdProducto
WHERE V.FechaRegistro >= DATEADD(MONTH, -1, GETDATE())
GROUP BY LP.Nombre, P.Nombre
ORDER BY UnidadesVendidas DESC
```

---

## 🎯 Casos de Uso Completos

### Caso 1: Nueva Lista Mayorista

**Objetivo:** Crear lista para clientes mayoristas con 25% de descuento

**Pasos:**
1. Click en **[+ Nueva Lista]**
2. Nombre: "Lista Mayorista 2024"
3. Tipo: Mayorista
4. Descripción: "Descuento 25% para compras mayores a 10 unidades"
5. ✅ Marcar "Copiar precios desde otra lista"
6. Lista Origen: "Lista Minorista 2024"
7. Ajuste: `-25%`
8. Guardar
9. ✅ Se copian todos los productos con 25% menos

**Resultado:**
- Lista creada con 100+ productos
- Todos los precios 25% más baratos
- Lista para usar en ventas mayoristas

---

### Caso 2: Actualizar Precio de un Solo Producto

**Objetivo:** Coca Cola subió de precio, actualizar solo ese producto

**Pasos:**
1. Ir a **Listas de Precios**
2. Abrir "Lista Minorista 2024"
3. Buscar "Coca Cola 1.5L"
4. Click en **[✏️ Editar]**
5. Cambiar precio de $1.500 a $1.700
6. Guardar
7. ✅ Solo Coca Cola cambia de precio

**Resultado:**
- Coca Cola: $1.500 → $1.700 ✅
- Pepsi: $1.400 → $1.400 (sin cambios)
- Sprite: $1.350 → $1.350 (sin cambios)
- Resto de productos: sin cambios

---

### Caso 3: Promoción Black Friday

**Objetivo:** Crear lista promocional con 20% de descuento

**Pasos:**
1. Click en **[+ Nueva Lista]**
2. Nombre: "Black Friday 2024"
3. Tipo: Promocion
4. ✅ Marcar "Copiar precios desde otra lista"
5. Lista Origen: "Lista Minorista 2024"
6. Ajuste: `-20%`
7. Guardar

**Uso en ventas:**
1. Durante Black Friday, seleccionar "Black Friday 2024"
2. Todos los productos con 20% de descuento automático
3. Cliente ve precios reducidos
4. Venta se registra con la lista promocional

---

## ⚙️ Configuración Avanzada

### Vigencia de Precios

Cada precio tiene:
- **Fecha Desde**: Inicio de validez
- **Fecha Hasta**: Fin de validez

**Ejemplo:**
```
Producto: Helado
Precio Verano: $500 (01/12/2024 - 31/03/2025)
Precio Invierno: $400 (01/04/2025 - 30/11/2025)
```

El sistema usa automáticamente el precio vigente según la fecha actual.

### Listas por Tienda

Puedes crear listas específicas para cada tienda:

```
Lista: "Precios Sucursal Centro"
Tienda: Centro
Uso: Solo en sucursal Centro

Lista: "Precios Sucursal Norte"
Tienda: Norte
Uso: Solo en sucursal Norte
```

---

## 🆘 Preguntas Frecuentes

### ¿Puedo cambiar múltiples precios a la vez?

**Sí**, usa la opción "Copiar desde otra lista":
1. Crea una lista nueva desde la actual
2. Aplica el ajuste porcentual deseado
3. Desactiva la lista antigua
4. Activa la nueva lista

### ¿Qué pasa si cambio el precio de un producto en una lista?

Solo cambia en **esa lista específica**. Otras listas no se afectan.

### ¿Puedo tener un producto en varias listas con precios diferentes?

**Sí**, perfectamente. Ejemplo:
- Lista Minorista: Coca Cola $1.500
- Lista Mayorista: Coca Cola $1.125
- Lista Promoción: Coca Cola $1.200

### ¿Qué pasa si un producto no tiene precio en la lista seleccionada?

El sistema muestra `$0,00` y avisa que el producto no tiene precio en esa lista.

### ¿Puedo editar precios mientras hay ventas en curso?

Sí, pero las ventas en curso mantienen el precio que obtuvieron al momento de agregar el producto.

---

## 📈 Mejores Prácticas

### 1. Nomenclatura Clara
```
✅ Bueno: "Lista Mayorista 2024"
✅ Bueno: "Promoción Black Friday"
✅ Bueno: "Precios Sucursal Centro"

❌ Malo: "Lista 1"
❌ Malo: "Precios"
❌ Malo: "Nueva"
```

### 2. Mantener Listas Activas
- Desactiva listas obsoletas
- Mantén solo listas vigentes activas
- Archiva listas antiguas (inactivar)

### 3. Documentar Ajustes
Usa la descripción para documentar:
```
Descripción: "Creada desde Minorista 2024 con -25% para clientes mayoristas. Válida para pedidos superiores a 10 unidades"
```

### 4. Revisar Vigencias
- Establece fechas de vigencia claras
- Revisa productos vencidos periódicamente
- Actualiza precios antes de que expiren

---

## 📞 Soporte

Si tienes dudas o problemas:
1. Revisa esta guía
2. Consulta los reportes SQL
3. Verifica los logs de la aplicación

---

**Última actualización:** 12/11/2024  
**Versión:** 2.0  
**Estado:** ✅ Sistema completamente funcional
