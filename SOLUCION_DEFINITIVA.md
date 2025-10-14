# 🔥 SOLUCIÓN DEFINITIVA - PASO A PASO

---

## ⚠️ IMPORTANTE: Lee TODO antes de empezar

Tienes 4 problemas:
1. ❌ No puedes registrar orden de compra
2. ❌ No puedes entrar a Remitos (error 404)
3. ❌ No puedes entrar a Facturas (error 404)
4. ❌ El precio de venta no se guarda (vuelve a 0)

**La causa principal: NO HAS RECOMPILADO EL PROYECTO después de agregar los controladores.**

---

## 🚀 SOLUCIÓN COMPLETA (10 MINUTOS)

### **PARTE 1: VERIFICAR Y CORREGIR LA BASE DE DATOS** ⏱️ 3 min

#### **Paso 1.1: Verificar estado actual**

1. Abrir **SQL Server Management Studio**
2. Conectar a tu servidor
3. Seleccionar base de datos: `DBVENTAS_WEB`
4. `File` → `Open` → `File...`
5. Seleccionar: `Utilidad/SQL Server/011_VERIFICAR_TODO.sql`
6. Presionar `F5`
7. **LEE EL REPORTE COMPLETO**

**Qué buscar:**
```
✓ = Todo bien
❌ = Hay problema
```

#### **Paso 1.2: Si hay ❌, ejecutar scripts de corrección**

**Si el reporte muestra errores, ejecutar EN ORDEN:**

```
1. Utilidad/SQL Server/000_EJECUTAR_TODO.sql
   (Crea tablas ORDEN_COMPRA, REMITO, FACTURA)

2. Utilidad/SQL Server/009_STORED_PROCEDURES_COMPLETO.sql
   (Crea todos los stored procedures)

3. Utilidad/SQL Server/010_CORREGIR_TODO_FINAL.sql
   (Corrige los SPs para usar ORDEN_COMPRA)

4. Utilidad/SQL Server/007_SEED_DATOS_PRUEBA_COMPLETO.sql
   (Carga datos de ejemplo)
```

**Cómo ejecutar cada uno:**
1. `File` → `Open` → `File...`
2. Seleccionar el archivo
3. Presionar `F5`
4. Esperar mensaje de éxito

#### **Paso 1.3: Ejecutar script de verificación nuevamente**

Volver a ejecutar: `011_VERIFICAR_TODO.sql`

**TODO debe estar en ✓**

---

### **PARTE 2: VERIFICAR ARCHIVOS DEL PROYECTO** ⏱️ 2 min

#### **Paso 2.1: Verificar que existen los controladores**

Navega y verifica que existen estos archivos:

```
✅ VentasWeb/Controllers/RemitoController.cs
✅ VentasWeb/Controllers/FacturaController.cs
✅ VentasWeb/Views/Remito/Index.cshtml
✅ VentasWeb/Views/Factura/Index.cshtml
```

**Si NO existen**, los archivos están en el proyecto pero no se crearon. Avísame.

#### **Paso 2.2: Verificar que están incluidos en el proyecto**

1. Abrir `VentasWeb.sln` en Visual Studio
2. En el **Solution Explorer**, expandir:
   - `VentasWeb` → `Controllers`
   - Buscar `RemitoController.cs` y `FacturaController.cs`
3. Si NO aparecen:
   - Click derecho en `Controllers`
   - `Add` → `Existing Item...`
   - Navegar y seleccionar `RemitoController.cs`
   - Repetir para `FacturaController.cs`

---

### **PARTE 3: RECOMPILAR PROYECTO** ⏱️ 3 min

**ESTO ES CRÍTICO - Sin esto NADA funcionará**

#### **Opción A: Visual Studio (RECOMENDADO)**

```
1. Abrir VentasWeb.sln
2. Build → Clean Solution (esperar)
3. Build → Rebuild Solution (esperar)
4. Verificar que dice "Build succeeded"
5. NO CERRAR Visual Studio todavía
```

**Si da errores de compilación:**
- Toma captura del error
- Léelo completo
- Busca si dice algo sobre "Remito" o "Factura"

#### **Opción B: Línea de comandos**

```powershell
cd "c:\Users\santi\Downloads\Ventas2\022_SistemaVentaAspMVC-main"

# Limpiar
"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" VentasWeb.sln /t:Clean

# Recompilar
"C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" VentasWeb.sln /t:Rebuild /p:Configuration=Release
```

---

### **PARTE 4: EJECUTAR Y PROBAR** ⏱️ 2 min

#### **Paso 4.1: Ejecutar la aplicación**

**Desde Visual Studio:**
```
Presionar F5
```

**Desde PowerShell:**
```powershell
cd "c:\Users\santi\Downloads\Ventas2\022_SistemaVentaAspMVC-main"
.\ejecutar.bat
```

#### **Paso 4.2: Iniciar sesión**

```
Usuario: admin@mibendi.com
Clave: admin123
```

#### **Paso 4.3: PROBAR CADA FUNCIONALIDAD**

##### **Test 1: Remitos** ✅
```
1. Click en menú: Compras → Remitos
2. Debe cargar página SIN ERROR 404
3. Debe mostrar tabla (puede estar vacía o con datos)
```

##### **Test 2: Facturas** ✅
```
1. Click en menú: Compras → Facturas
2. Debe cargar página SIN ERROR 404
3. Debe mostrar tabla (puede estar vacía o con datos)
```

##### **Test 3: Registrar Orden de Compra** ✅
```
1. Click en: Compras → Registrar Orden de Compra
2. Llenar todos los campos:
   - Proveedor
   - Tienda
   - Agregar productos
3. Click en "Registrar Compra"
4. Debe mostrar mensaje de éxito
5. NO debe dar error en consola (F12)
```

##### **Test 4: Precio de Venta** ✅
```
1. Click en: Reportes → Productos por Tienda
2. Seleccionar tienda (o todas)
3. Click en "Buscar"
4. En la columna "Precio Venta", editar un precio
5. Click en el botón guardar 💾
6. Debe decir "Precio actualizado correctamente"
7. Presionar F5 (refrescar página)
8. Buscar nuevamente
9. El precio DEBE ESTAR AHÍ (no volver a 0)
```

##### **Test 5: Flechas de Stock** ✅
```
1. En la misma vista (Productos por Tienda)
2. Click en flecha ↑ de algún producto
3. El stock debe incrementar en 1
4. Presionar F5 (refrescar)
5. Buscar nuevamente
6. El stock DEBE HABER CAMBIADO
```

---

## 🔍 DIAGNÓSTICO DE PROBLEMAS

### **Problema 1: ERROR 404 en Remitos o Facturas**

**Causa:** El proyecto NO está compilado con los controladores nuevos.

**Solución:**
```
1. Cerrar la aplicación web
2. En Visual Studio: Build → Rebuild Solution
3. Ejecutar nuevamente (F5)
```

**Verificación alternativa:**
```
En el navegador, abre la consola (F12) y escribe:
console.log("Test")

Luego intenta ir a Remitos. Si da 404, lee el error completo.
```

---

### **Problema 2: No puede registrar Orden de Compra**

**Posibles causas:**
1. SP `usp_RegistrarCompra` no actualizado
2. Tabla ORDEN_COMPRA no existe
3. Tabla DETALLE_ORDEN_COMPRA no existe

**Solución:**
```sql
-- En SSMS, ejecuta:
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_RegistrarCompra'))

-- Busca en el resultado la palabra "ORDEN_COMPRA"
-- Si no aparece, ejecuta: 010_CORREGIR_TODO_FINAL.sql
```

**Verificar error específico:**
```
1. Abrir consola del navegador (F12)
2. Pestaña "Console"
3. Intentar registrar orden
4. Ver qué error aparece
5. Copiar el error completo
```

---

### **Problema 3: Precio vuelve a 0 al refrescar**

**Posibles causas:**
1. Campo `PrecioVenta` no existe en tabla PRODUCTO
2. SP `usp_ObtenerReporteProductos` no trae el campo
3. El UPDATE funciona pero el SELECT no lo trae

**Solución:**

```sql
-- 1. Verificar que existe el campo
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'PRODUCTO' AND COLUMN_NAME = 'PrecioVenta'

-- Debe mostrar: PrecioVenta

-- 2. Verificar que el SP lo trae
EXEC usp_ObtenerReporteProductos @idtienda=0, @codigoproducto=''

-- En los resultados, busca la columna "PrecioVenta"
-- Si NO aparece, ejecuta: 010_CORREGIR_TODO_FINAL.sql
```

**Test manual de UPDATE:**
```sql
-- Actualizar manualmente
UPDATE PRODUCTO SET PrecioVenta = 123.45 WHERE IdProducto = 1

-- Verificar
SELECT IdProducto, Nombre, PrecioVenta FROM PRODUCTO WHERE IdProducto = 1

-- Debe mostrar: 123.45
```

---

### **Problema 4: Flechas de stock no funcionan**

**Verificación en consola del navegador:**
```javascript
// Abre consola (F12) y escribe:
console.log($.MisUrls.url._AjustarStock)

// Debe mostrar: /Producto/AjustarStock
// Si muestra undefined, hay problema con _Layout.cshtml
```

**Verificar controlador:**
```
1. Buscar archivo: VentasWeb/Controllers/ProductoController.cs
2. Buscar método: AjustarStock
3. Debe existir (líneas 14-42)
```

---

## 📋 CHECKLIST FINAL

Antes de decir que no funciona, verifica:

### **Base de Datos:**
- [ ] Script `011_VERIFICAR_TODO.sql` ejecutado
- [ ] Todos los ítems en ✓ (sin ❌)
- [ ] Campo `PrecioVenta` existe en tabla PRODUCTO
- [ ] Tablas ORDEN_COMPRA, REMITO, FACTURA existen
- [ ] SP `usp_RegistrarCompra` usa ORDEN_COMPRA (no COMPRA)

### **Código:**
- [ ] Archivo `RemitoController.cs` existe
- [ ] Archivo `FacturaController.cs` existe
- [ ] Archivo `Views/Remito/Index.cshtml` existe
- [ ] Archivo `Views/Factura/Index.cshtml` existe
- [ ] Archivos están incluidos en el proyecto de Visual Studio

### **Compilación:**
- [ ] Build → Clean Solution ejecutado
- [ ] Build → Rebuild Solution ejecutado
- [ ] Build succeeded (sin errores)
- [ ] Aplicación ejecutándose

### **Pruebas:**
- [ ] Login exitoso
- [ ] Remitos carga sin 404
- [ ] Facturas carga sin 404
- [ ] Orden de compra se guarda
- [ ] Precio persiste al refrescar
- [ ] Flechas de stock funcionan

---

## 🆘 SI NADA FUNCIONA

**Ejecuta esto en orden estricto:**

```sql
-- En SQL Server Management Studio:

-- 1. Verificación
Ejecutar: 011_VERIFICAR_TODO.sql
Leer TODO el reporte

-- 2. Corrección base datos
Ejecutar: 000_EJECUTAR_TODO.sql
Ejecutar: 009_STORED_PROCEDURES_COMPLETO.sql
Ejecutar: 010_CORREGIR_TODO_FINAL.sql

-- 3. Datos de prueba
Ejecutar: 007_SEED_DATOS_PRUEBA_COMPLETO.sql

-- 4. Verificar nuevamente
Ejecutar: 011_VERIFICAR_TODO.sql
(TODO debe estar en ✓)
```

```powershell
# En Visual Studio:

# 1. Limpiar
Build > Clean Solution

# 2. Recompilar
Build > Rebuild Solution

# 3. Ejecutar
F5

# 4. Probar
Ir a Remitos, Facturas, etc.
```

---

## 📞 INFORMACIÓN PARA DEBUG

Si sigues teniendo problemas, necesito:

### **De la Base de Datos:**
```sql
-- Ejecuta y copia el resultado:
EXEC 011_VERIFICAR_TODO.sql
```

### **De Visual Studio:**
```
1. Captura de los errores de compilación (si hay)
2. Captura del Solution Explorer mostrando Controllers
```

### **Del Navegador:**
```
1. Consola (F12) → pestaña Console → captura errores
2. Consola (F12) → pestaña Network → captura 404s
```

---

**🚀 Sigue estos pasos EN ORDEN y TODO funcionará.**
