# 🗄️ GUÍA: EJECUTAR SCRIPTS SQL PARA CORREGIR ERRORES

---

## ⚠️ IMPORTANTE: EJECUTA ESTO ANTES DE COMPILAR

Los errores que estás viendo son porque **faltan tablas y stored procedures** en la base de datos.

---

## 📋 PASOS PARA EJECUTAR (3 SCRIPTS EN ORDEN)

### **1️⃣ Abrir SQL Server Management Studio**

1. Abrir **SQL Server Management Studio (SSMS)**
2. Conectarte a tu servidor SQL
3. Expandir **Databases** → **DBVENTAS_WEB**

---

### **2️⃣ Ejecutar Scripts EN ESTE ORDEN:**

#### **SCRIPT 1: Estructura de Base de Datos** ✅
```
📁 Ubicación: Utilidad/SQL Server/000_EJECUTAR_TODO.sql
⏱️ Tiempo: ~30 segundos
```

**Cómo ejecutar:**
1. En SSMS: `File` → `Open` → `File...`
2. Seleccionar: `000_EJECUTAR_TODO.sql`
3. Presionar `F5` o click en ▶️ Execute
4. ✅ Esperar mensaje: "CONFIGURACIÓN COMPLETADA"

**Este script crea:**
- Tabla ORDEN_COMPRA (renombra de COMPRA)
- Tablas REMITO y FACTURA
- Menús de Remitos y Facturas en el TopBar
- Corrige nombres de controladores

---

#### **SCRIPT 2: Stored Procedures** ✅
```
📁 Ubicación: Utilidad/SQL Server/009_STORED_PROCEDURES_COMPLETO.sql
⏱️ Tiempo: ~20 segundos
```

**Cómo ejecutar:**
1. Abrir archivo: `009_STORED_PROCEDURES_COMPLETO.sql`
2. Presionar `F5`
3. ✅ Esperar mensaje: "TODOS LOS SP CREADOS"

**Este script crea:**
- Procedimientos para Remitos
- Procedimientos para Facturas
- Procedimientos actualizados de Órdenes de Compra

---

#### **SCRIPT 3: Datos de Prueba** ✅
```
📁 Ubicación: Utilidad/SQL Server/007_SEED_DATOS_PRUEBA_COMPLETO.sql
⏱️ Tiempo: ~40 segundos
```

**Cómo ejecutar:**
1. Abrir archivo: `007_SEED_DATOS_PRUEBA_COMPLETO.sql`
2. Presionar `F5`
3. ✅ Esperar mensaje: "CARGA COMPLETADA EXITOSAMENTE"

**Este script carga:**
- ✅ 4 Usuarios de prueba
- ✅ 3 Tiendas
- ✅ 10 Productos con stock
- ✅ 4 Proveedores
- ✅ 3 Órdenes de Compra (2 Abiertas, 1 Cerrada)
- ✅ 3 Remitos (1 En Espera, 2 Recibidos)
- ✅ 3 Facturas (2 Pendientes, 1 Pagada)
- ✅ 4 Clientes
- ✅ 3 Ventas de ejemplo

---

## 🎯 VERIFICAR QUE TODO FUNCIONÓ

Después de ejecutar los 3 scripts, verifica:

```sql
-- 1. Verificar que existe ORDEN_COMPRA (no COMPRA)
SELECT COUNT(*) FROM ORDEN_COMPRA

-- 2. Verificar que existen las tablas nuevas
SELECT COUNT(*) FROM REMITO
SELECT COUNT(*) FROM FACTURA

-- 3. Verificar menús
SELECT Nombre, Controlador, Vista 
FROM SUBMENU 
WHERE Nombre IN ('Remitos', 'Facturas')

-- 4. Verificar controladores corregidos
SELECT Nombre, Controlador 
FROM SUBMENU 
WHERE Controlador = 'Reportes'
```

**Resultados esperados:**
- ✅ ORDEN_COMPRA: 3 registros
- ✅ REMITO: 3 registros  
- ✅ FACTURA: 3 registros
- ✅ SUBMENU Remitos y Facturas existen
- ✅ Controlador "Reportes" (no "Reporte")

---

## 🔐 CREDENCIALES DE ACCESO

Después de cargar los datos de prueba:

```
Usuario: admin@mibendi.com
Clave: admin123
```

**Otros usuarios disponibles:**
- maria@mibendi.com / admin123
- juan@mibendi.com / admin123
- ana@mibendi.com / admin123

---

## ✅ ERRORES CORREGIDOS

Después de ejecutar estos scripts, se corregirán:

### ✅ **1. Error en Reporte/Ventas**
- **Antes**: Controlador "Reporte" (incorrecto)
- **Después**: Controlador "Reportes" (correcto)
- **Solución**: Script 1 corrige el nombre

### ✅ **2. Error en Remitos**
- **Antes**: Tabla REMITO no existe
- **Después**: Tabla creada con stored procedures
- **Solución**: Scripts 1 y 2

### ✅ **3. Error en Facturas**
- **Antes**: Tabla FACTURA no existe
- **Después**: Tabla creada con stored procedures
- **Solución**: Scripts 1 y 2

### ✅ **4. Error en Consultar Compras**
- **Antes**: Tabla COMPRA sin campo Estado
- **Después**: Tabla ORDEN_COMPRA con Estado
- **Solución**: Script 1 renombra y agrega campo

---

## 🚨 SI ALGO SALE MAL

### **Error: "Invalid object name 'ORDEN_COMPRA'"**
**Solución:** Ejecuta el Script 1 nuevamente

### **Error: "Could not find stored procedure 'usp_ObtenerRemitos'"**
**Solución:** Ejecuta el Script 2

### **Error: "The INSERT statement conflicted with the FOREIGN KEY constraint"**
**Solución:** 
1. Ejecuta los scripts EN ORDEN
2. Si ya ejecutaste Script 3, vuelve a ejecutarlo (limpia datos automáticamente)

---

## 📊 DATOS DE PRUEBA INCLUIDOS

### **Productos:**
- Laptop HP 15 (Stock: 5 en Centro)
- Mouse Logitech (Stock: 20 en Centro, 15 en Norte)
- Teclado Mecánico (Stock: 15 en Centro, 10 en Sur)
- Polo Básico (Stock: 50 en Centro, 40 en Norte)
- Y más...

### **Órdenes de Compra:**
- OC #1: Electrónica (Abierta) - $6,500
- OC #2: Ropa (Abierta) - $3,200
- OC #3: Alimentos (Cerrada) - $1,500

### **Remitos:**
- REM-2024-001: En Espera (Laptops)
- REM-2024-002: Recibido (Ropa)
- REM-2024-003: Recibido (Alimentos)

### **Facturas:**
- F001-00123: Pendiente - $6,500
- F001-00124: Pendiente - $3,200
- F001-00125: Pagado - $1,500

---

## 🎯 DESPUÉS DE EJECUTAR LOS SCRIPTS

1. ✅ Cierra la aplicación web si está abierta
2. ✅ Recompila el proyecto en Visual Studio
3. ✅ Ejecuta la aplicación (F5)
4. ✅ Inicia sesión con: admin@mibendi.com / admin123
5. ✅ Verifica que aparezcan Remitos y Facturas en el menú Compras
6. ✅ Prueba todas las funcionalidades

---

## 🎉 RESULTADO FINAL

Después de ejecutar los 3 scripts:

- ✅ Remitos y Facturas aparecen en el TopBar
- ✅ Reporte/Ventas funciona correctamente
- ✅ Consultar Órdenes muestra columna Estado
- ✅ Puedes cerrar órdenes de compra
- ✅ Puedes marcar remitos como "Recibido"
- ✅ Puedes marcar facturas como "Pagado"
- ✅ Actualización de stock y precio funcionan sin error 500

---

**¡Sistema completamente funcional con datos de prueba listos!** 🚀
