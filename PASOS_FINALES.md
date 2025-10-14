# ✅ PASOS FINALES PARA COMPLETAR LA IMPLEMENTACIÓN

---

## 🚨 PASO CRÍTICO: EJECUTAR SCRIPTS SQL

**ANTES DE EJECUTAR LA APLICACIÓN, DEBES HACER ESTO:**

### 1️⃣ **Abrir SQL Server Management Studio**

### 2️⃣ **Ejecutar estos scripts EN ORDEN:**

```sql
-- Script 1: Estructura de base de datos
-- Ubicación: Utilidad/SQL Server/004_MEJORAS_SISTEMA_OC_REMITOS_FACTURAS.sql
-- Este script:
--   - Renombra COMPRA a ORDEN_COMPRA
--   - Agrega campo Estado
--   - Crea tablas REMITO y FACTURA
```

```sql
-- Script 2: Stored Procedures
-- Copiar el código desde: GUIA_IMPLEMENTACION_COMPLETA.md
-- Buscar la sección: "PASO 2: Crear Stored Procedures"
-- Ejecutar todo el código de esa sección
```

```sql
-- Script 3: Menús del TopBar (CRÍTICO)
-- Ubicación: Utilidad/SQL Server/006_AGREGAR_MENUS_REMITO_FACTURA.sql
-- Este script:
--   - Crea menú de Remitos
--   - Crea menú de Facturas
--   - Asigna permisos al Administrador
```

### 3️⃣ **Verificar que los scripts se ejecutaron bien:**

```sql
-- Ejecuta esto para verificar:
SELECT * FROM SUBMENU WHERE Nombre IN ('Remitos', 'Facturas')

-- Debe mostrar 2 filas (Remitos y Facturas)
```

---

## 🚀 CÓMO EJECUTAR LA APLICACIÓN

### **OPCIÓN 1: Desde WindSurf/Terminal (MÁS RÁPIDO)**

```powershell
# En la terminal de WindSurf, ejecuta:
cd "c:\Users\santi\Downloads\Ventas2\022_SistemaVentaAspMVC-main"
.\ejecutar.ps1
```

Si da error de permisos:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\ejecutar.ps1
```

### **OPCIÓN 2: Archivo ejecutar.bat (MÁS SIMPLE)**

1. Ir a la carpeta: `c:\Users\santi\Downloads\Ventas2\022_SistemaVentaAspMVC-main`
2. Doble clic en `ejecutar.bat`
3. Se abrirá Visual Studio
4. Presiona `F5` en Visual Studio

### **OPCIÓN 3: Directamente con Visual Studio**

1. Doble clic en `VentasWeb.sln`
2. Esperar que cargue
3. Presionar `F5`

---

## 📋 CHECKLIST ANTES DE EJECUTAR

- [ ] SQL Server está corriendo
- [ ] Script `004_MEJORAS_SISTEMA_OC_REMITOS_FACTURAS.sql` ejecutado ✅
- [ ] Stored Procedures ejecutados ✅
- [ ] Script `006_AGREGAR_MENUS_REMITO_FACTURA.sql` ejecutado ✅
- [ ] Verificaste que los menús existen en la BD (query arriba) ✅

---

## 🎯 QUÉ DEBES VER CUANDO EJECUTES

### **1. TopBar del sistema debe mostrar:**
```
[Inicio] [Productos] [Compras ▼] [Reportes ▼] [Usuario]
                        |
                        ├─ Registrar Orden de Compra
                        ├─ Consultar Ordenes de Compra
                        ├─ Remitos          ← ¡NUEVO!
                        └─ Facturas         ← ¡NUEVO!
```

### **2. Al entrar a "Consultar Ordenes de Compra":**
- ✅ Debe mostrar columna "Estado" (Abierta/Cerrada)
- ✅ Debe mostrar botón "Cerrar OC" en órdenes abiertas

### **3. Al entrar a "Remitos":**
- ✅ Debe cargar una tabla vacía (DataTable)
- ✅ Sin errores en consola (F12)

### **4. Al entrar a "Facturas":**
- ✅ Debe cargar una tabla vacía (DataTable)
- ✅ Sin errores en consola (F12)

### **5. Al entrar a "Reportes > Productos por Tienda":**
- ✅ Debe mostrar productos con flechas ↑↓ para stock
- ✅ Debe permitir editar precio de venta
- ✅ NO debe dar error 500

---

## ⚠️ SI LOS MENÚS NO APARECEN

### **Problema: No veo Remitos ni Facturas en el TopBar**

**Solución:**

1. **Verifica que ejecutaste el script SQL:**
   ```sql
   USE DBVENTAS_WEB
   SELECT * FROM SUBMENU WHERE Nombre IN ('Remitos', 'Facturas')
   -- Debe mostrar 2 filas
   ```

2. **Verifica los permisos:**
   ```sql
   SELECT 
       sm.Nombre,
       p.IdRol,
       r.Descripcion as Rol,
       p.Activo
   FROM PERMISOS p
   INNER JOIN SUBMENU sm ON p.IdSubMenu = sm.IdSubMenu
   INNER JOIN ROL r ON p.IdRol = r.IdRol
   WHERE sm.Nombre IN ('Remitos', 'Facturas')
   -- Debe mostrar permisos para tu rol
   ```

3. **Si faltan permisos, ejecuta:**
   ```sql
   -- Obtener tu IdRol (asumiendo que eres admin, IdRol=1)
   DECLARE @IdRol INT = 1
   DECLARE @IdRemito INT, @IdFactura INT
   
   SELECT @IdRemito = IdSubMenu FROM SUBMENU WHERE Nombre = 'Remitos'
   SELECT @IdFactura = IdSubMenu FROM SUBMENU WHERE Nombre = 'Facturas'
   
   -- Agregar permisos
   IF NOT EXISTS (SELECT * FROM PERMISOS WHERE IdRol = @IdRol AND IdSubMenu = @IdRemito)
       INSERT INTO PERMISOS (IdRol, IdSubMenu, Activo) VALUES (@IdRol, @IdRemito, 1)
   
   IF NOT EXISTS (SELECT * FROM PERMISOS WHERE IdRol = @IdRol AND IdSubMenu = @IdFactura)
       INSERT INTO PERMISOS (IdRol, IdSubMenu, Activo) VALUES (@IdRol, @IdFactura, 1)
   ```

4. **Cerrar sesión y volver a iniciar sesión** en la aplicación

---

## 🐛 OTROS PROBLEMAS COMUNES

### **Error: "Cannot open database"**
- ✅ SQL Server está corriendo?
- ✅ El nombre de la base de datos es DBVENTAS_WEB?
- ✅ Revisa Web.config, sección `<connectionStrings>`

### **Error: "Could not load file or assembly"**
```powershell
# Solución: Restaurar paquetes
cd "c:\Users\santi\Downloads\Ventas2\022_SistemaVentaAspMVC-main"
nuget restore VentasWeb.sln
```

### **Error: "The name 'CD_Remito' does not exist"**
- ✅ Verifica que existan los archivos:
  - `CapaDatos/CD_Remito.cs`
  - `CapaDatos/CD_Factura.cs`
  - `CapaModelo/Remito.cs`
  - `CapaModelo/Factura.cs`
- ✅ Recompila: `Build > Clean Solution` → `Build > Build Solution`

---

## 📁 RESUMEN DE ARCHIVOS CREADOS

### **Modelos (CapaModelo)**
- ✅ Remito.cs
- ✅ DetalleRemito.cs
- ✅ Factura.cs
- ✅ DetalleFactura.cs

### **Capas de Datos (CapaDatos)**
- ✅ CD_Remito.cs
- ✅ CD_Factura.cs

### **Controladores (VentasWeb/Controllers)**
- ✅ RemitoController.cs
- ✅ FacturaController.cs

### **Vistas (VentasWeb/Views)**
- ✅ Remito/Index.cshtml
- ✅ Factura/Index.cshtml

### **Scripts SQL (Utilidad/SQL Server)**
- ✅ 004_MEJORAS_SISTEMA_OC_REMITOS_FACTURAS.sql
- ✅ 006_AGREGAR_MENUS_REMITO_FACTURA.sql

### **Documentación**
- ✅ GUIA_IMPLEMENTACION_COMPLETA.md
- ✅ COMO_COMPILAR_Y_EJECUTAR.md
- ✅ PASOS_FINALES.md (este archivo)

---

## 🎉 FLUJO COMPLETO DEL SISTEMA

Una vez que todo funcione:

1. **Registrar Orden de Compra** → Estado: Abierta (NO incrementa stock)
2. **Crear Remito** → Asociado a OC, Estado: En Espera
3. **Marcar Remito como Recibido** → Cambiar estado
4. **Crear Factura** → Asociada a OC, Estado: Pendiente
5. **Marcar Factura como Pagada** → Cambiar estado
6. **Actualizar Stock Manualmente** → Reportes > Productos por Tienda
7. **Cerrar Orden de Compra** → Estado: Cerrada

---

## 📞 ¿NECESITAS AYUDA?

Si sigues teniendo problemas:

1. Revisa los **logs de Visual Studio** (Output window)
2. Revisa la **consola del navegador** (F12 > Console)
3. Verifica que **todos los scripts SQL** estén ejecutados
4. Limpia y recompila el proyecto

---

**¡Éxito! Tu sistema está completamente actualizado y listo para usar!** 🚀
