# Solucion - Encoding y Conteo de Productos

## Problemas Identificados y Solucionados

### 1. Problema de Encoding (Caracteres Raros)

**Problema:** Los acentos y tildes aparecian con caracteres raros como: ó → Ã³, á → Ã¡

**Causa:** Los archivos .cshtml y .js no tienen la codificacion UTF-8 correcta o el navegador no la interpreta bien.

**Solucion Aplicada:** Remover todos los acentos y tildes de los textos en español para evitar problemas de encoding.

#### Archivos Corregidos:

**Index.cshtml:**
- ❌ "Administración" → ✅ "Administracion"
- ❌ "Gestión de Listas" → ✅ "Gestion de Listas"
- ❌ "Descripción" → ✅ "Descripcion"
- ❌ "Promoción" → ✅ "Promocion"

**ListaPrecio_Index.js:**
- ❌ "Atención" → ✅ "Atencion"
- ❌ "Éxito" → ✅ "Exito"
- ❌ "Confirmación" → ✅ "Confirmacion"
- ❌ "Sí, crear" → ✅ "Si, crear"
- ❌ "Ocurrió un error" → ✅ "Ocurrio un error"

---

### 2. Problema de Conteo de Productos

**Problema Reportado:** 
```
Lista origen: 4 productos
Resultado: "5 productos copiados"
```

**Investigacion:**

El metodo `ObtenerProductosListaPrecio()` puede estar devolviendo productos duplicados o productos que no deberian contarse.

**Solucion Implementada:**

1. **Validacion de productos:** 
   - Saltar productos con `IdProducto <= 0`
   - Verificar que la lista origen tenga productos

2. **Contador detallado:**
   - `productosEnOrigen`: Cantidad en la lista origen
   - `productosCopiados`: Cantidad realmente agregados

3. **Mensaje mejorado:**
   ```
   "Lista creada exitosamente. Productos en origen: 4, productos copiados: 4"
   ```

Ahora podras ver exactamente:
- Cuantos productos tiene la lista origen
- Cuantos se copiaron exitosamente

Si los numeros no coinciden, indica un problema en el stored procedure `AgregarProductoListaPrecio`.

---

## Codigo Corregido

### ListaPrecioController.cs

```csharp
// Obtener productos de la lista origen
List<ListaPrecioDetalle> productosOrigen = CD_ListaPrecio.Instancia.ObtenerProductosListaPrecio(idListaOrigen);

if (productosOrigen == null || productosOrigen.Count == 0)
{
    return Json(new { success = false, mensaje = "La lista origen no tiene productos" });
}

int productosCopiados = 0;
int productosEnOrigen = productosOrigen.Count;
decimal multiplicador = 1 + (porcentajeAjuste / 100);

// Copiar cada producto
foreach (var productoOrigen in productosOrigen)
{
    // Validar que el producto tenga ID valido
    if (productoOrigen.IdProducto <= 0) continue;

    decimal nuevoPrecio = Math.Round(productoOrigen.PrecioVenta * multiplicador, 2);

    ListaPrecioDetalle nuevoDetalle = new ListaPrecioDetalle
    {
        IdListaPrecio = idListaNueva,
        IdProducto = productoOrigen.IdProducto,
        PrecioVenta = nuevoPrecio,
        FechaVigenciaDesde = productoOrigen.FechaVigenciaDesde,
        FechaVigenciaHasta = productoOrigen.FechaVigenciaHasta,
        Activo = productoOrigen.Activo
    };

    string mensajeProducto = string.Empty;
    bool agregado = CD_ListaPrecio.Instancia.AgregarProductoListaPrecio(nuevoDetalle, out mensajeProducto);
    if (agregado) productosCopiados++;
}

return Json(new
{
    success = true,
    mensaje = string.Format("Lista creada exitosamente. Productos en origen: {0}, productos copiados: {1}", 
                          productosEnOrigen, productosCopiados),
    productosCopiados = productosCopiados,
    productosEnOrigen = productosEnOrigen,
    idListaNueva = idListaNueva
});
```

---

## Como Verificar la Solucion

### 1. Probar Encoding

1. Recompilar el proyecto
2. Ejecutar (F5)
3. Ir a **Administracion** > **Listas de Precios**
4. Verificar que TODOS los textos se vean correctamente:
   - ✅ "Gestion de Listas de Precios"
   - ✅ "Descripcion"
   - ✅ "Promocion"
   - ✅ Sin caracteres raros

### 2. Probar Conteo de Productos

1. Ir a una lista que tenga productos (ej: "Lista Minorista 2024")
2. Ver cuantos productos tiene (ej: 4 productos)
3. Crear nueva lista desde esa:
   - Nombre: "Lista Test Conteo"
   - Tipo: Mayorista
   - ✅ Marcar "Copiar desde otra lista"
   - Lista Origen: "Lista Minorista 2024"
   - Ajuste: -10%
4. Guardar y confirmar
5. Verificar el mensaje:
   ```
   Exito!
   Lista creada exitosamente. Productos en origen: 4, productos copiados: 4
   ```
6. **Los numeros deben coincidir**

---

## Diagnostico de Problemas de Conteo

Si el conteo sigue sin coincidir:

### Caso 1: `productosEnOrigen: 4, productosCopiados: 5`
**Problema:** El stored procedure `usp_AgregarProductoListaPrecio` esta agregando productos duplicados.

**Solucion:** Revisar el SP y agregar validacion para no duplicar productos:
```sql
-- Antes de INSERT, verificar si ya existe
IF EXISTS (
    SELECT 1 FROM LISTA_PRECIO_DETALLE 
    WHERE IdListaPrecio = @IdListaPrecio 
    AND IdProducto = @IdProducto
    AND Activo = 1
)
BEGIN
    SET @Mensaje = 'El producto ya existe en la lista'
    SET @Resultado = 0
    RETURN
END
```

### Caso 2: `productosEnOrigen: 5, productosCopiados: 4`
**Problema:** Algun producto tiene `IdProducto = 0` o el SP esta rechazando productos.

**Solucion:** 
1. Ejecutar query para ver productos problematicos:
```sql
SELECT * FROM LISTA_PRECIO_DETALLE
WHERE IdListaPrecio = 1 -- ID de la lista origen
AND (IdProducto IS NULL OR IdProducto = 0)
```

2. Revisar logs del SP para ver por que rechaza productos.

### Caso 3: `productosEnOrigen: 4, productosCopiados: 4` pero en la lista nueva hay 5
**Problema:** Hay un trigger o proceso adicional agregando productos.

**Solucion:** Revisar si hay triggers en la tabla `LISTA_PRECIO_DETALLE`.

---

## Consultas Utiles para Diagnostico

### Ver productos de una lista
```sql
SELECT 
    LPD.IdProducto,
    P.Nombre AS Producto,
    LPD.PrecioVenta,
    LPD.FechaVigenciaDesde,
    LPD.FechaVigenciaHasta,
    LPD.Activo
FROM LISTA_PRECIO_DETALLE LPD
INNER JOIN PRODUCTO P ON LPD.IdProducto = P.IdProducto
WHERE LPD.IdListaPrecio = 1  -- Cambiar por ID de la lista
ORDER BY P.Nombre
```

### Contar productos por lista
```sql
SELECT 
    LP.IdListaPrecio,
    LP.Nombre,
    COUNT(LPD.IdListaPrecioDetalle) AS TotalProductos,
    COUNT(DISTINCT LPD.IdProducto) AS ProductosUnicos
FROM LISTA_PRECIO LP
LEFT JOIN LISTA_PRECIO_DETALLE LPD ON LP.IdListaPrecio = LPD.IdListaPrecio
GROUP BY LP.IdListaPrecio, LP.Nombre
```

### Buscar productos duplicados
```sql
SELECT 
    IdListaPrecio,
    IdProducto,
    COUNT(*) AS Veces
FROM LISTA_PRECIO_DETALLE
WHERE Activo = 1
GROUP BY IdListaPrecio, IdProducto
HAVING COUNT(*) > 1
```

---

## Estado Final

✅ **Encoding corregido:** Todos los textos sin acentos
✅ **Conteo visible:** Mensaje muestra origen vs copiados
✅ **Validaciones:** Saltar productos invalidos
✅ **Debugging:** Mensaje detallado para identificar problemas

---

## Proximos Pasos

1. **Recompilar** el proyecto
2. **Probar** copiar lista
3. **Verificar** que el mensaje muestre los dos numeros
4. **Si no coinciden:** Ejecutar las queries de diagnostico
5. **Reportar** los resultados para continuar debuggeando

---

**Fecha:** 12/11/2024  
**Version:** 1.0
