# 🚀 GUÍA: CÓMO COMPILAR Y EJECUTAR LA APLICACIÓN

---

## 📋 PASOS PREVIOS OBLIGATORIOS

### ✅ **PASO 1: Ejecutar Scripts SQL**

Antes de compilar, debes ejecutar estos scripts en SQL Server:

1. **Abrir SQL Server Management Studio**
2. **Conectarte a tu base de datos**
3. **Ejecutar en orden**:

```sql
-- 1. Script principal (si no lo hiciste)
-- Ubicación: Utilidad/SQL Server/004_MEJORAS_SISTEMA_OC_REMITOS_FACTURAS.sql

-- 2. Stored Procedures (de la GUIA_IMPLEMENTACION_COMPLETA.md)
-- Copiar y ejecutar los procedimientos de la guía

-- 3. Script de menús (CRÍTICO para que aparezcan Remitos y Facturas)
-- Ubicación: Utilidad/SQL Server/006_AGREGAR_MENUS_REMITO_FACTURA.sql
```

**Sin ejecutar estos scripts, la aplicación dará errores.**

---

## 🔨 OPCIÓN 1: COMPILAR Y EJECUTAR DESDE VISUAL STUDIO

### **Requisitos:**
- Visual Studio 2019 o superior
- .NET Framework 4.7.2 o superior
- SQL Server instalado y corriendo

### **Pasos:**

1. **Abrir el proyecto**
   - Doble clic en `VentasWeb.sln`
   - Visual Studio se abrirá automáticamente

2. **Restaurar paquetes NuGet**
   ```
   Tools > NuGet Package Manager > Manage NuGet Packages for Solution
   Click en "Restore" si aparece el botón
   ```

3. **Configurar cadena de conexión**
   - Abrir `Web.config` en el proyecto VentasWeb
   - Buscar la sección `<connectionStrings>`
   - Actualizar con tu servidor SQL:
   ```xml
   <connectionStrings>
       <add name="CN" connectionString="Data Source=TU_SERVIDOR;Initial Catalog=DBVENTAS_WEB;Integrated Security=True" providerName="System.Data.SqlClient"/>
   </connectionStrings>
   ```

4. **Compilar (Build)**
   - Presiona `Ctrl + Shift + B`
   - O menú: `Build > Build Solution`
   - Espera a que diga "Build succeeded"

5. **Ejecutar (Run)**
   - Presiona `F5` (con debugging)
   - O `Ctrl + F5` (sin debugging)
   - Se abrirá el navegador automáticamente

---

## 🌐 OPCIÓN 2: COMPILAR DESDE LÍNEA DE COMANDOS (PowerShell)

### **Desde WindSurf o Terminal:**

```powershell
# 1. Navegar a la carpeta del proyecto
cd "c:\Users\santi\Downloads\Ventas2\022_SistemaVentaAspMVC-main"

# 2. Restaurar paquetes NuGet
nuget restore VentasWeb.sln

# 3. Compilar con MSBuild
msbuild VentasWeb.sln /p:Configuration=Release /p:Platform="Any CPU"

# Si no tienes MSBuild en el PATH, usar ruta completa:
"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" VentasWeb.sln /p:Configuration=Release
```

### **Ejecutar con IIS Express:**

```powershell
# Navegar a la carpeta del proyecto web
cd "c:\Users\santi\Downloads\Ventas2\022_SistemaVentaAspMVC-main\VentasWeb"

# Ejecutar con IIS Express (ajusta la ruta si es diferente)
& "C:\Program Files\IIS Express\iisexpress.exe" /path:"$PWD" /port:8080
```

Luego abrir navegador en: `http://localhost:8080`

---

## 🐛 SOLUCIÓN DE PROBLEMAS COMUNES

### **Error: "Could not load file or assembly"**
```powershell
# Solución: Restaurar paquetes NuGet
cd "c:\Users\santi\Downloads\Ventas2\022_SistemaVentaAspMVC-main"
nuget restore VentasWeb.sln
```

### **Error: "Cannot open database DBVENTAS_WEB"**
- ✅ Verifica que SQL Server esté corriendo
- ✅ Ejecuta los scripts SQL que faltan
- ✅ Revisa la cadena de conexión en Web.config

### **Error: "The name 'Remito' does not exist in the current context"**
- ✅ Recompila el proyecto completo: `Ctrl + Shift + B`
- ✅ Limpia y recompila: `Build > Clean Solution` → `Build > Build Solution`

### **Los menús Remitos/Facturas no aparecen:**
- ✅ **Ejecuta el script SQL**: `006_AGREGAR_MENUS_REMITO_FACTURA.sql`
- ✅ Verifica que tu usuario tenga permisos en la tabla PERMISOS
- ✅ Cierra sesión y vuelve a iniciar sesión

---

## 📁 ARCHIVOS IMPORTANTES CREADOS

| Archivo | Descripción | Ubicación |
|---------|-------------|-----------|
| `RemitoController.cs` | Controlador de Remitos | `VentasWeb/Controllers/` |
| `FacturaController.cs` | Controlador de Facturas | `VentasWeb/Controllers/` |
| `Index.cshtml` (Remito) | Vista de Remitos | `VentasWeb/Views/Remito/` |
| `Index.cshtml` (Factura) | Vista de Facturas | `VentasWeb/Views/Factura/` |
| `006_AGREGAR_MENUS_REMITO_FACTURA.sql` | Script SQL para menús | `Utilidad/SQL Server/` |

---

## ✅ CHECKLIST DE VERIFICACIÓN

Antes de ejecutar, verifica que:

- [ ] SQL Server está corriendo
- [ ] Base de datos DBVENTAS_WEB existe
- [ ] Script `004_MEJORAS_SISTEMA_OC_REMITOS_FACTURAS.sql` ejecutado
- [ ] Script `006_AGREGAR_MENUS_REMITO_FACTURA.sql` ejecutado
- [ ] Stored procedures creados (de la guía)
- [ ] Web.config tiene la cadena de conexión correcta
- [ ] Proyecto compilado sin errores
- [ ] Archivos CD_Remito.cs y CD_Factura.cs están en CapaDatos
- [ ] Archivos Remito.cs, Factura.cs, etc. están en CapaModelo

---

## 🎯 PROBAR QUE TODO FUNCIONA

1. **Iniciar sesión** en la aplicación
2. **Verificar el TopBar** - Debes ver:
   - Inicio
   - Productos
   - Compras (con submenú: Registrar OC, Consultar OC, **Remitos**, **Facturas**)
   - Reportes
   - Usuarios/Tiendas/etc.

3. **Probar funcionalidades**:
   - Click en **Compras > Remitos** → Debe mostrar la tabla
   - Click en **Compras > Facturas** → Debe mostrar la tabla
   - Click en **Compras > Consultar Ordenes de Compra** → Debe mostrar columna "Estado" y botón "Cerrar OC"
   - Ir a **Reportes > Productos por Tienda** → Probar actualizar precio y stock

---

## 🚀 PRIMER USO - ORDEN RECOMENDADO

1. **Registrar Orden de Compra** (Compras > Registrar Orden de Compra)
   - Se crea con Estado = "Abierta"
   - NO incrementa el stock automáticamente

2. **Ver Ordenes de Compra** (Compras > Consultar Ordenes de Compra)
   - Verifica que aparece con estado "Abierta"

3. **Gestionar Remitos** (Compras > Remitos)
   - Carga los remitos de las órdenes de compra
   - Cambia estado a "Recibido"

4. **Gestionar Facturas** (Compras > Facturas)
   - Carga las facturas
   - Cambia estado a "Pagado"

5. **Actualizar Stock Manualmente** (Reportes > Productos por Tienda)
   - Usa las flechas ↑↓ para ajustar stock

6. **Cerrar Orden de Compra** (Compras > Consultar Ordenes de Compra)
   - Click en "Cerrar OC"

---

## 📞 AYUDA ADICIONAL

Si sigues teniendo problemas:

1. **Revisa los logs de error** en Visual Studio (Output window)
2. **Verifica la consola del navegador** (F12 > Console) para errores JavaScript
3. **Comprueba que todos los archivos .cs nuevos** estén incluidos en el proyecto
4. **Limpia y recompila**: `Build > Clean Solution` → `Build > Build Solution`

---

**¡Tu aplicación está lista para funcionar!** 🎉
