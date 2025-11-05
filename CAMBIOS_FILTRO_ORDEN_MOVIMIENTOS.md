# Filtro de Ordenamiento en Movimientos de Stock

## Descripción del Cambio

Se agregó un filtro de ordenamiento por fecha en la sección de **Historial de Movimientos de Stock**, permitiendo al usuario visualizar los movimientos ordenados por más recientes o más antiguos.

## Cambios Realizados

### 1. Vista HTML (`VentasWeb\Views\MovimientoStock\Crear.cshtml`)

Se agregó un nuevo campo de selección en la sección de filtros:

```html
<div class="col-sm-3">
    <label for="cboOrdenFecha">Ordenar por Fecha:</label>
    <select class="form-control form-control-sm" id="cboOrdenFecha">
        <option value="desc">Más recientes primero</option>
        <option value="asc">Más antiguos primero</option>
    </select>
</div>
```

**Ubicación:** Líneas 146-152

### 2. JavaScript (`VentasWeb\Scripts\Views\MovimientoStock_Crear.js`)

Se agregaron las siguientes funcionalidades:

#### a) Event Listener para cambio de orden
```javascript
$('#cboOrdenFecha').on('change', function () {
    aplicarOrdenFecha();
});
```

#### b) Función para aplicar filtros y orden
```javascript
function aplicarFiltrosYOrden() {
    var idTienda = parseInt($("#cboFiltroTienda").val());
    var orden = $("#cboOrdenFecha").val();
    
    // Recargar datos
    tablaMovimientos.ajax.url($.MisUrls.url._ObtenerMovimientosAgrupados + "?idTienda=" + idTienda).load(function() {
        // Aplicar orden después de cargar los datos
        aplicarOrdenFecha();
    });
}
```

#### c) Función para aplicar solo el orden de fecha
```javascript
function aplicarOrdenFecha() {
    var orden = $("#cboOrdenFecha").val();
    // Columna 0 es la fecha
    tablaMovimientos.order([0, orden]).draw();
}
```

**Ubicación:** Líneas 493-519

### 3. Versión del Archivo JavaScript

Se actualizó el número de versión del archivo JavaScript de `v=9` a `v=10` para evitar problemas de caché.

## Funcionalidades

### Ordenamiento por Fecha

El usuario puede seleccionar entre dos opciones:

1. **Más recientes primero (desc)** - Opción por defecto
   - Muestra los movimientos más recientes al principio de la tabla
   - Útil para ver las últimas operaciones realizadas

2. **Más antiguos primero (asc)**
   - Muestra los movimientos más antiguos al principio de la tabla
   - Útil para revisar el historial desde el inicio

### Comportamiento

- **Cambio automático:** Al cambiar la opción en el select, la tabla se reordena inmediatamente sin necesidad de presionar el botón "Filtrar"
- **Combinación con filtro de tienda:** El orden se mantiene al aplicar el filtro por tienda
- **Persistencia:** El orden seleccionado se mantiene al recargar los datos con el botón "Filtrar"

## Uso

### Método 1: Cambio directo
1. En la sección "Historial de Movimientos de Stock"
2. Seleccionar la opción deseada en "Ordenar por Fecha"
3. La tabla se reordena automáticamente

### Método 2: Combinado con filtro de tienda
1. Seleccionar una tienda en "Filtrar por Tienda"
2. Seleccionar el orden deseado en "Ordenar por Fecha"
3. Presionar el botón "Filtrar"
4. Los datos se filtran por tienda y ordenan según la opción seleccionada

## Notas Técnicas

- La columna de fecha (índice 0) es la que se utiliza para el ordenamiento
- El orden se aplica utilizando la función `order()` de DataTables
- No requiere cambios en el backend (controlador o stored procedures)
- Compatible con todas las funcionalidades existentes de la tabla

## Capturas de Pantalla de Ubicación

### Antes
```
[Filtrar por Tienda: dropdown] [Botón Filtrar]
```

### Después
```
[Filtrar por Tienda: dropdown] [Ordenar por Fecha: dropdown] [Botón Filtrar]
```

## Compatibilidad

- ✅ Compatible con filtro por tienda existente
- ✅ Compatible con paginación de DataTables
- ✅ Compatible con búsqueda de DataTables
- ✅ No afecta otras funcionalidades del sistema

## Archivos Modificados

1. `VentasWeb\Views\MovimientoStock\Crear.cshtml`
   - Agregado select de ordenamiento
   - Actualizada versión del script

2. `VentasWeb\Scripts\Views\MovimientoStock_Crear.js`
   - Agregadas funciones de ordenamiento
   - Modificado event handler del botón filtrar

---

**Fecha de implementación:** Noviembre 2024  
**Versión:** 1.0
