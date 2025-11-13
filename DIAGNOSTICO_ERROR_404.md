# Diagnóstico Error 404 - Sistema de Listas de Precios en Ventas

## 🔴 Error Actual
```
"Not Found" (404)
No se pudieron cargar los productos de la lista
```

---

## 🔍 Cambios Realizados para Solucionar

### 1. **URL Dinámica en JavaScript**

**Antes (podía fallar):**
```javascript
url: '/ListaPrecio/ObtenerProductosListaPrecioConStock?...'
```

**Ahora (robusto):**
```javascript
var urlBase = window.location.protocol + "//" + window.location.host;
var url = urlBase + '/ListaPrecio/ObtenerProductosListaPrecioConStock';
```

### 2. **Logs de Diagnóstico**

El JavaScript ahora muestra en consola (F12):
- URL completa intentada
- Parámetros enviados
- Código de status HTTP
- Respuesta del servidor

---

## 🚀 Pasos para Probar

### 1. **Limpiar Todo**
```
1. Cerrar Visual Studio
2. Borrar carpetas:
   - bin\
   - obj\
3. Abrir Visual Studio
4. Clean Solution
5. Rebuild Solution (Ctrl + Shift + B)
```

### 2. **Verificar el Método del Controlador**

Abre: `VentasWeb\Controllers\ListaPrecioController.cs`

Busca el método y verifica que tenga **[HttpGet]**:

```csharp
[HttpGet]
public JsonResult ObtenerProductosListaPrecioConStock(int idListaPrecio = 0, int idTienda = 0)
{
    // ... código ...
}
```

### 3. **Ejecutar y Probar**
```
1. F5 para ejecutar
2. Ir a Ventas → Registrar Venta
3. Abrir consola del navegador (F12)
4. Seleccionar lista de precios
5. Click "Buscar Producto"
6. VER LA CONSOLA - Te dirá exactamente qué está pasando
```

---

## 📋 Qué Buscar en la Consola (F12)

### Si Funciona:
```javascript
Intentando cargar desde: http://localhost:64927/ListaPrecio/ObtenerProductosListaPrecioConStock
Parametros: {idListaPrecio: 1, idTienda: 1}
Respuesta del servidor: {success: true, data: Array(10)}
```

### Si Falla (404):
```javascript
Error AJAX completo: {xhr: ..., status: "error", error: "Not Found"}
URL intentada: http://localhost:64927/ListaPrecio/ObtenerProductosListaPrecioConStock
Status Code: 404
Response Text: (verás HTML de error o mensaje)
```

---

## 🔧 Posibles Causas del 404

### Causa 1: **Método No Existe**
**Verificar:** Abrir `ListaPrecioController.cs` y buscar:
```csharp
public JsonResult ObtenerProductosListaPrecioConStock
```

**Debe existir el método con [HttpGet]**

---

### Causa 2: **Nombre del Controlador Incorrecto**
**Verificar:** El archivo debe llamarse exactamente:
```
ListaPrecioController.cs
```

Y la clase:
```csharp
public class ListaPrecioController : Controller
{
    // ...
}
```

---

### Causa 3: **Routing Incorrecto**
**Verificar:** Archivo `App_Start\RouteConfig.cs`

Debe tener algo como:
```csharp
routes.MapRoute(
    name: "Default",
    url: "{controller}/{action}/{id}",
    defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
);
```

---

### Causa 4: **Proyecto No Recompilado**
**Solución:**
```
1. Clean Solution
2. Rebuild Solution
3. Cerrar navegador completamente
4. F5 de nuevo
```

---

## 🧪 Test Alternativo - Probar Directamente la URL

### Mientras la app está corriendo (F5):

Abre una nueva pestaña y pega esta URL:
```
http://localhost:TU_PUERTO/ListaPrecio/ObtenerProductosListaPrecioConStock?idListaPrecio=1&idTienda=1
```

**Reemplaza TU_PUERTO** con el puerto que ves en tu navegador (ejemplo: 64927)

### Resultados Esperados:

**✅ Si funciona (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "IdProductoTienda": 1,
      "oProducto": {...},
      "Stock": 50,
      "PrecioVenta": 1125.00
    }
  ]
}
```

**❌ Si falla (404):**
```html
<html>
  <head><title>404 - Not Found</title></head>
  ...
</html>
```

---

## 🛠️ Solución Alternativa - Verificar Rutas

Si el método NO se encuentra, verifica estas rutas en orden:

### 1. **Namespace Correcto**
```csharp
namespace VentasWeb.Controllers
{
    public class ListaPrecioController : Controller
    {
        // ...
    }
}
```

### 2. **Método Público**
```csharp
[HttpGet]
public JsonResult ObtenerProductosListaPrecioConStock(int idListaPrecio = 0, int idTienda = 0)
{
    // Debe ser PUBLIC, no private o protected
}
```

### 3. **Heredar de Controller**
```csharp
public class ListaPrecioController : Controller
{
    // Debe heredar de Controller o ApiController
}
```

---

## 📞 Si Persiste el Error

### Información a Proporcionar:

1. **Captura de consola (F12)**
   - Pestaña Console
   - Ver todos los mensajes que aparecen

2. **URL completa que se muestra en consola**
   - Ejemplo: `http://localhost:64927/...`

3. **Código de status**
   - Ejemplo: `404`, `500`, etc.

4. **Response Text completo**
   - Lo que retorna el servidor

5. **Verificar archivo existe**
   ```
   Carpeta: VentasWeb\Controllers
   Archivo: ListaPrecioController.cs
   Método: ObtenerProductosListaPrecioConStock
   ```

---

## ✅ Checklist de Verificación

- [ ] Proyecto limpiado (Clean Solution)
- [ ] Proyecto recompilado (Rebuild)
- [ ] Archivo `ListaPrecioController.cs` existe
- [ ] Método `ObtenerProductosListaPrecioConStock` existe en el archivo
- [ ] Método tiene atributo `[HttpGet]`
- [ ] Método es `public`
- [ ] Navegador completamente cerrado y reabierto
- [ ] Probado en nueva ventana de incógnito
- [ ] Consola (F12) muestra logs detallados

---

**Fecha:** 12/11/2024  
**Versión:** 1.0  
**Estado:** En diagnóstico
