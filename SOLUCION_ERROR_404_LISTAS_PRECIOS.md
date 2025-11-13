# Solución al Error 404 - Listas de Precios

## Problema
Al intentar acceder a `/ListaPrecio/Index` aparece el error:
```
Error de servidor en la aplicación '/'
No se encuentra el recurso.
```

## Causa
Los archivos del controlador `ListaPrecioController.cs` y las clases de modelo no estaban incluidos en los proyectos `.csproj`, por lo que no se compilaban.

## Solución Aplicada

Se agregaron las siguientes referencias a los proyectos:

### 1. CapaModelo.csproj
- ✅ `ListaPrecio.cs`
- ✅ `ListaPrecioDetalle.cs`

### 2. CapaDatos.csproj
- ✅ `CD_ListaPrecio.cs`

### 3. VentasWeb.csproj
- ✅ `Controllers\ListaPrecioController.cs`
- ✅ `Views\ListaPrecio\Index.cshtml`
- ✅ `Views\ListaPrecio\Detalle.cshtml`
- ✅ `Scripts\Views\ListaPrecio_Index.js`
- ✅ `Scripts\Views\ListaPrecio_Detalle.js`

## Pasos para Compilar y Probar

### Opción 1: Visual Studio (Recomendado)

1. **Abrir Visual Studio**
2. **Abrir la solución**: `Mi_Bendi.sln`
3. **Compilar la solución**:
   - Menú: `Compilar` > `Recompilar solución`
   - O presionar: `Ctrl + Shift + B`
4. **Esperar** a que termine la compilación
5. **Ejecutar** el proyecto:
   - Presionar `F5` o clic en el botón ▶ (IIS Express)

### Opción 2: Línea de Comandos

Si Visual Studio no está disponible, desde PowerShell:

```powershell
# Navegar a la carpeta del proyecto
cd "C:\Users\camil\proyectos\Mi_Bendi"

# Compilar con MSBuild (requiere Visual Studio Build Tools)
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" VentasWeb\VentasWeb.csproj /t:Rebuild
```

## Verificar la Configuración de Base de Datos

Antes de probar, asegúrate de haber ejecutado los scripts SQL:

```sql
-- 1. Crear tablas y stored procedures
Utilidad\SQL Server\031_SISTEMA_LISTAS_PRECIOS.sql

-- 2. Agregar menú y permisos
Utilidad\SQL Server\032_AGREGAR_MENU_LISTAS_PRECIOS.sql

-- 3. (Opcional) Datos de prueba
Utilidad\SQL Server\033_DATOS_PRUEBA_LISTAS_PRECIOS.sql
```

## Probar el Sistema

1. **Iniciar sesión** en la aplicación
2. **Navegar** al menú: `Administración` > `Listas de Precios`
3. Deberías ver la interfaz de gestión de listas de precios

## Si Persiste el Error

### 1. Limpiar la Solución
En Visual Studio:
- `Compilar` > `Limpiar solución`
- `Compilar` > `Recompilar solución`

### 2. Eliminar carpetas bin y obj
```powershell
Remove-Item -Path "VentasWeb\bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "VentasWeb\obj" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "CapaModelo\bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "CapaModelo\obj" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "CapaDatos\bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "CapaDatos\obj" -Recurse -Force -ErrorAction SilentlyContinue
```

Luego recompilar en Visual Studio.

### 3. Verificar Referencias del Proyecto
En Visual Studio, clic derecho en el proyecto `VentasWeb`:
- `Propiedades` > `Referencias`
- Verificar que `CapaModelo` y `CapaDatos` estén referenciados

### 4. Reiniciar IIS Express
- Cerrar Visual Studio completamente
- Abrir nuevamente y ejecutar

## Archivos Modificados

Los siguientes archivos `.csproj` fueron modificados para incluir las nuevas clases:

- ✅ `CapaModelo\CapaModelo.csproj`
- ✅ `CapaDatos\CapaDatos.csproj`
- ✅ `VentasWeb\VentasWeb.csproj`

## Notas Importantes

- **No editar archivos .csproj manualmente** después de esto
- **Usar Visual Studio** para agregar nuevos archivos al proyecto
- Si agregas archivos manualmente, asegúrate de incluirlos en el proyecto usando:
  - Clic derecho en el proyecto > `Agregar` > `Elemento existente`

---

**Fecha de solución**: 12/11/2024
