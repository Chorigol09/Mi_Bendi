# Sistema de Listas de Precios en Ventas

## 📋 Funcionalidad Implementada

El sistema de ventas ahora está **completamente integrado** con las listas de precios. Al registrar una venta:

1. ✅ **Se debe seleccionar primero una lista de precios**
2. ✅ **Solo aparecen productos vinculados a esa lista**
3. ✅ **Se aplica automáticamente el precio de la lista seleccionada**

---

## 🎯 Flujo de Venta con Lista de Precios

### Paso 1: Seleccionar Lista de Precios

```
┌─────────────────────────────────────┐
│ Lista de Precios: [Seleccionar ▼]  │
└─────────────────────────────────────┘
```

El usuario **DEBE** seleccionar una lista antes de agregar productos.

**Listas disponibles:**
- Minorista
- Mayorista
- Distribuidor
- Promoción
- etc.

---

### Paso 2: Buscar Producto

Al hacer clic en "Buscar Producto" o ingresar un código:

```
✅ Validación: Lista de precios seleccionada
✅ Se muestran SOLO productos de esa lista
✅ Solo productos con stock > 0
```

#### Modal de Productos:

| Código | Nombre | Descripción | Stock | Acción |
|--------|--------|-------------|-------|--------|
| P001 | Coca Cola 1.5L | Bebida | 50 | ✔️ |
| P002 | Pepsi 2L | Bebida | 30 | ✔️ |

**Importante:** Solo aparecen productos que:
- Están en la lista de precios seleccionada
- Tienen precio vigente
- Tienen stock disponible en la tienda

---

### Paso 3: Precio Automático

Al seleccionar un producto:

```
1. Se obtiene el IdProducto
2. Se consulta el precio en la lista seleccionada
3. Se asigna automáticamente al campo "Precio"
```

**Ejemplo:**
```
Lista Seleccionada: "Mayorista"
Producto: Coca Cola 1.5L

Precio Minorista: $1,500
Precio Mayorista: $1,125  ← Se usa este
```

---

## 🔧 Componentes Técnicos

### 1. **Frontend - Vista (`Crear.cshtml`)**

Selector de lista de precios (ya existía):

```html
<select class="custom-select" id="cboListaPrecio">
    <option value="0">-- Seleccionar Lista --</option>
</select>
```

**Ubicación:** Líneas 28-33

---

### 2. **Frontend - JavaScript (`Venta_Crear.js`)**

#### Cargar Listas:
```javascript
function cargarListasPrecios() {
    // Carga listas activas en el dropdown
    // Endpoint: /ListaPrecio/ObtenerListasPreciosActivas
}
```

#### Validación al Buscar Producto:
```javascript
$('#btnBuscarProducto').on('click', function () {
    var idListaPrecio = parseInt($("#cboListaPrecio").val());
    
    if (idListaPrecio == 0) {
        swal("Mensaje", "Debe seleccionar una lista de precios primero", "warning");
        return;
    }
    
    // Cargar productos FILTRADOS por lista
    tablaproducto.ajax.url(
        '/ListaPrecio/ObtenerProductosListaPrecioConStock?idListaPrecio=' + idListaPrecio + '&idTienda=' + idTienda
    ).load();
});
```

#### Obtener Precio Automático:
```javascript
function obtenerPrecioProducto(idListaPrecio, idProducto) {
    // Consulta precio vigente de la lista
    // Endpoint: /ListaPrecio/ObtenerPrecioProductoVigente
    // Asigna el precio al campo txtproductoprecio
}
```

#### Validación al Escanear Código:
```javascript
$("#txtproductocodigo").on('keypress', function (e) {
    if (e.which == 13) { // Enter
        // Valida lista seleccionada
        // Busca producto y obtiene precio de la lista
    }
});
```

---

### 3. **Backend - Controlador (`ListaPrecioController.cs`)**

#### Método 1: Obtener Listas Activas
```csharp
[HttpGet]
public JsonResult ObtenerListasPreciosActivas()
{
    List<ListaPrecio> lista = CD_ListaPrecio.Instancia.ObtenerListasPrecios();
    lista = lista.Where(x => x.Activo).ToList();
    return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
}
```

#### Método 2: Obtener Productos con Stock (**NUEVO**)
```csharp
[HttpGet]
public JsonResult ObtenerProductosListaPrecioConStock(int idListaPrecio, int idTienda)
{
    // 1. Obtener productos de la lista (solo vigentes)
    // 2. Obtener stock de la tienda
    // 3. JOIN: solo productos en lista CON stock > 0
    // 4. Retornar: Producto + Stock + Precio
}
```

#### Método 3: Obtener Precio Vigente
```csharp
[HttpGet]
public JsonResult ObtenerPrecioProductoVigente(int idListaPrecio, int idProducto)
{
    ListaPrecioDetalle detalle = CD_ListaPrecio.Instancia.ObtenerPrecioProductoVigente(
        idListaPrecio, idProducto, DateTime.Now
    );
    
    if (detalle != null)
    {
        return Json(new { resultado = true, precio = detalle.PrecioVenta }, ...);
    }
    else
    {
        return Json(new { resultado = false, mensaje = "Sin precio vigente" }, ...);
    }
}
```

---

### 4. **Capa de Datos (`CD_ListaPrecio.cs`)**

Ya existe el método:
```csharp
public ListaPrecioDetalle ObtenerPrecioProductoVigente(
    int IdListaPrecio, 
    int IdProducto, 
    DateTime? Fecha = null
)
{
    // Consulta BD para obtener precio vigente
    // Verifica fechas de vigencia
    // Retorna precio o null
}
```

---

## ✅ Validaciones Implementadas

### 1. **Lista Obligatoria**
```
Si usuario NO seleccionó lista:
  ❌ No puede buscar productos
  ❌ No puede escanear código
  ⚠️ Mensaje: "Debe seleccionar una lista de precios primero"
```

### 2. **Solo Productos de la Lista**
```
Modal de productos muestra SOLO:
  ✅ Productos con precio en la lista seleccionada
  ✅ Precio vigente (fecha actual entre vigencia desde/hasta)
  ✅ Stock > 0 en la tienda
```

### 3. **Advertencia al Cambiar Lista**
```
Si hay productos en el carrito y cambia la lista:
  ⚠️ Alerta: "Se borrarán los productos agregados"
  Opciones: [Sí, cambiar] [Cancelar]
```

### 4. **Producto Sin Precio**
```
Si producto NO tiene precio en la lista:
  ❌ No aparece en el modal
  ⚠️ Si se busca por código: "Sin precio vigente en esta lista"
```

---

## 🧪 Casos de Prueba

### Caso 1: Venta Normal con Lista

```
1. Seleccionar "Lista Mayorista"
2. Buscar producto → Aparecen solo productos de lista mayorista
3. Seleccionar "Coca Cola 1.5L"
4. Precio: $1,125 (precio mayorista)
5. Agregar cantidad: 10
6. Total: $11,250
✅ Venta registrada con precio mayorista
```

---

### Caso 2: Intentar sin Lista

```
1. NO seleccionar lista
2. Click en "Buscar Producto"
❌ Mensaje: "Debe seleccionar una lista de precios primero"
3. No se abre el modal
```

---

### Caso 3: Cambiar Lista con Productos

```
1. Seleccionar "Lista Minorista"
2. Agregar producto: Coca Cola ($1,500)
3. Cambiar a "Lista Mayorista"
⚠️ Alerta: "Se borrarán los productos. ¿Continuar?"
   [Sí] → Carrito se vacía
   [No] → Se mantiene lista anterior
```

---

### Caso 4: Producto Sin Stock

```
Lista: "Minorista"
Producto: Pepsi 2L
Stock en Tienda: 0

❌ Producto NO aparece en el modal
   (aunque esté en la lista de precios)
```

---

### Caso 5: Escanear Código

```
1. Seleccionar "Lista Promoción"
2. Escanear código: "P001"
3. Enter
✅ Producto autocompletado con precio de promoción
```

---

## 📊 Ejemplo de Precios por Lista

| Producto | Minorista | Mayorista | Distribuidor | Promoción |
|----------|-----------|-----------|--------------|-----------|
| Coca Cola 1.5L | $1,500 | $1,125 | $900 | $1,275 |
| Pepsi 2L | $1,800 | $1,350 | $1,080 | $1,530 |
| Agua 500ml | $800 | $600 | $480 | $680 |

---

## 🚀 Cómo Usar

### Para Usuarios:

1. **Abrir "Registrar Venta"**
2. **Seleccionar Lista de Precios** (obligatorio)
3. **Buscar productos** (solo aparecen de esa lista)
4. **Agregar al carrito** (precio automático)
5. **Completar venta**

---

### Para Desarrolladores:

#### Ejecutar Script SQL:
```sql
-- Ya ejecutado:
-- 031_SISTEMA_LISTAS_PRECIOS.sql (crea tablas y SPs)
-- 036_GENERAR_PRECIOS_AUTOMATICOS.sql (genera datos)
-- 037_SEED_PRECIOS_TODAS_LISTAS.sql (asigna precios)
```

#### Recompilar Proyecto:
```
1. Clean Solution
2. Rebuild (Ctrl + Shift + B)
3. Run (F5)
```

---

## 🎨 Interfaz de Usuario

### Selector de Lista (arriba):
```
┌───────────────────────────────────────────────┐
│ Lista de Precios: [Lista Mayorista 2024 ▼]   │
│ Tipo Documento: [Boleta ▼]  Fecha: 12/11/24  │
└───────────────────────────────────────────────┘
```

### Detalle Producto:
```
┌────────────────────────────────────────┐
│ Código: P001         [🔍 Buscar]      │
│ Nombre: Coca Cola 1.5L                │
│ Stock: 50    Precio: $1,125.00        │
│ Cantidad: [10]       [➕ Agregar]     │
└────────────────────────────────────────┘
```

---

## ✅ Estado de Implementación

| Componente | Estado | Descripción |
|------------|--------|-------------|
| Selector de Lista | ✅ | Ya existía en HTML |
| Cargar Listas | ✅ | Función JS implementada |
| Validación Obligatoria | ✅ | Modal y código validados |
| Filtrar Productos | ✅ | **NUEVO** - Solo productos de lista |
| Precio Automático | ✅ | Ya funcionaba |
| Endpoint Stock | ✅ | **NUEVO** - Agregado al controlador |
| Cambio de Lista | ✅ | Advertencia implementada |

---

## 🎯 Beneficios

### Para el Negocio:
- ✅ **Precios diferenciados** por tipo de cliente
- ✅ **Control total** sobre qué productos vender a quién
- ✅ **Promociones** fáciles de gestionar
- ✅ **Descuentos** automáticos por volumen

### Para el Cajero:
- ✅ **Simple:** Solo seleccionar lista y buscar producto
- ✅ **Rápido:** Precios automáticos
- ✅ **Sin errores:** Sistema valida todo
- ✅ **Flexible:** Cambiar de lista fácilmente

### Para el Sistema:
- ✅ **Integrado:** Listas + Stock + Ventas
- ✅ **Consistente:** Mismos precios en toda la app
- ✅ **Trazable:** Se registra qué lista se usó
- ✅ **Escalable:** Fácil agregar más listas

---

## 📝 Notas Importantes

1. **Lista Obligatoria:** El sistema NO permite vender sin lista
2. **Solo Vigentes:** Se usan precios con vigencia actual
3. **Stock Real:** Solo productos disponibles en tienda
4. **Cambio de Lista:** Vacía el carrito para evitar mezclar precios
5. **Producto Sin Precio:** No aparece si no está en la lista

---

## 🔍 Troubleshooting

### Problema: "Modal vacío"
**Causa:** Lista seleccionada sin productos  
**Solución:** Agregar productos a la lista en módulo de Listas de Precios

### Problema: "Precio $0,00"
**Causa:** Producto sin precio vigente  
**Solución:** Verificar fechas de vigencia del precio

### Problema: "No carga listas"
**Causa:** Error en endpoint  
**Solución:** Verificar que existan listas activas en BD

---

**Fecha:** 12/11/2024  
**Versión:** 2.0  
**Estado:** ✅ **Completamente Funcional**
