# SOLUCIÓN: Órdenes de Compra no aparecen

## Problema Identificado
El método `Obtener` en el controlador de Compras tenía un error en la conversión de fechas. Ya fue corregido.

## Pasos para solucionar (EN ORDEN):

### 1. DETENER LA APLICACIÓN
- Si la aplicación está corriendo, detenerla (Stop en Visual Studio o cerrar IIS Express)
- **Importante**: Los cambios en C# requieren recompilación

### 2. VERIFICAR LA BASE DE DATOS
Ejecutar el siguiente script en SQL Server Management Studio:

```sql
-- Abrir: VERIFICAR_DATOS_COMPRA.sql
```

**Resultado esperado:**
- ✓ Debe mostrar que el SP `usp_ObtenerListaCompra` existe
- ✓ Debe mostrar las órdenes de compra existentes

**Si el SP NO EXISTE:**
```sql
-- Ejecutar: 015_MEJORAR_CONSULTA_COMPRAS.sql
```

### 3. LIMPIAR Y RECOMPILAR LA APLICACIÓN
En Visual Studio:
1. **Build** → **Clean Solution**
2. **Build** → **Rebuild Solution**
3. Esperar a que termine la compilación sin errores

### 4. INICIAR LA APLICACIÓN
- Presionar F5 o hacer clic en "Start" en Visual Studio
- Esperar a que abra el navegador

### 5. ABRIR HERRAMIENTAS DE DESARROLLADOR
En el navegador (Google Chrome/Edge):
- Presionar **F12**
- Ir a la pestaña **Console**
- Ir a la pestaña **Network**

### 6. IR A CONSULTAR COMPRAS
- Navegar a: Compras → Consultar Compra
- Observar la consola del navegador

### 7. VERIFICAR ERRORES
**En la pestaña Console:**
- ¿Hay errores en rojo?
- ¿Dice algo sobre "dataTable is not a function"?
- ¿Hay errores de red (404, 500)?

**En la pestaña Network:**
- Filtrar por XHR
- Buscar la petición que va a `/Compra/Obtener`
- Hacer clic en ella
- Ver la respuesta: ¿Devuelve datos?

## Cambio Realizado

**Archivo:** `VentasWeb\Controllers\CompraController.cs`

**Antes:**
```csharp
public JsonResult Obtener(string fechainicio, string fechafin, int idproveedor, int idtienda)
{
    List<Compra> lista = CD_Compra.Instancia.ObtenerListaCompra(
        Convert.ToDateTime(fechainicio), 
        Convert.ToDateTime(fechafin), 
        idproveedor, 
        idtienda
    );
    return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
}
```

**Después:**
```csharp
public JsonResult Obtener(string fechainicio, string fechafin, int idproveedor, int idtienda)
{
    try
    {
        // Parsear fechas en formato dd/MM/yyyy (español)
        System.Globalization.CultureInfo culture = new System.Globalization.CultureInfo("es-AR");
        DateTime dtInicio = DateTime.ParseExact(fechainicio, "dd/MM/yyyy", culture);
        DateTime dtFin = DateTime.ParseExact(fechafin, "dd/MM/yyyy", culture);
        
        List<Compra> lista = CD_Compra.Instancia.ObtenerListaCompra(dtInicio, dtFin, idproveedor, idtienda);
        return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
    }
    catch (Exception ex)
    {
        System.Diagnostics.Debug.WriteLine("Error al obtener compras: " + ex.Message);
        return Json(new { data = new List<Compra>() }, JsonRequestBehavior.AllowGet);
    }
}
```

## Qué hace la corrección
- Parsea correctamente las fechas en formato español (25/10/2025)
- Maneja errores gracefully, devolviendo una lista vacía en vez de romper
- Registra errores en el log de debug

## Si aún no funciona después de estos pasos
Compartir:
1. Captura de pantalla de la consola del navegador (F12)
2. Captura de pantalla de la pestaña Network mostrando la petición a `/Compra/Obtener`
3. Resultado del script SQL `VERIFICAR_DATOS_COMPRA.sql`
