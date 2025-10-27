# 📦 Módulo de Órdenes de Pago - Instrucciones de Instalación

## 🎯 Resumen
Este módulo permite gestionar órdenes de pago a proveedores, vinculadas a facturas pendientes. Incluye:
- ✅ Registro de órdenes de pago
- ✅ Consulta de órdenes de pago
- ✅ Comprobantes profesionales
- ✅ Actualización automática de estados de facturas

---

## 📋 Requisitos Previos
- SQL Server con base de datos `DBVENTAS_WEB`
- Visual Studio 2019 o superior
- .NET Framework 4.7.2 o superior
- Permisos de administrador en la base de datos

---

## 🚀 Instalación Paso a Paso

### **PASO 1: Actualizar desde GitHub**
```bash
git checkout develop
git pull origin develop
```

### **PASO 2: Ejecutar Scripts SQL (EN ORDEN)**

Abre SQL Server Management Studio y ejecuta los siguientes scripts en orden:

#### 2.1. Crear Tabla de Órdenes de Pago
```sql
-- Archivo: Utilidad/SQL Server/020_CREAR_TABLA_ORDEN_PAGO.sql
```
Este script crea la tabla `ORDEN_PAGO` con todos sus campos.

#### 2.2. Crear Stored Procedures
```sql
-- Archivo: Utilidad/SQL Server/021_SP_ORDEN_PAGO.sql
```
Este script crea los siguientes SPs:
- `SP_OBTENER_FACTURAS_PENDIENTES`
- `SP_REGISTRAR_ORDEN_PAGO`
- `SP_OBTENER_ORDENES_PAGO`
- `SP_OBTENER_DETALLE_ORDEN_PAGO`

#### 2.3. Agregar Menús y Permisos
```sql
-- Archivo: Utilidad/SQL Server/029_AGREGAR_MENUS_FINAL.sql
```
Este script:
- Crea el menú "Ordenes de Pago"
- Agrega submenús "Registrar Orden de Pago" y "Consultar Ordenes de Pago"
- Asigna permisos al usuario administrador

### **PASO 3: Compilar la Solución**

#### Opción A: Usando el script batch
```batch
FORZAR_RECOMPILACION.bat
```

#### Opción B: Desde Visual Studio
1. Abrir la solución en Visual Studio
2. Clic derecho en la solución → `Clean Solution`
3. Clic derecho en la solución → `Rebuild Solution`

### **PASO 4: Verificar Instalación**

1. Ejecutar la aplicación (F5)
2. Iniciar sesión como administrador
3. Verificar que aparezca el menú "Ordenes de Pago" con dos opciones:
   - Registrar Orden de Pago
   - Consultar Ordenes de Pago

---

## 📊 Estructura de Archivos Nuevos

### **Backend (C#)**
```
CapaDatos/
  └── CD_OrdenPago.cs                    # Capa de datos para órdenes de pago

CapaModelo/
  ├── OrdenPago.cs                       # Modelo de orden de pago
  ├── Factura.cs                         # Actualizado con campos adicionales
  └── DetalleFactura.cs                  # Actualizado

VentasWeb/Controllers/
  └── OrdenPagoController.cs             # Controlador con métodos CRUD
```

### **Frontend (Views & JavaScript)**
```
VentasWeb/Views/OrdenPago/
  ├── Registrar.cshtml                   # Vista para registrar órdenes
  └── Consultar.cshtml                   # Vista para consultar órdenes

VentasWeb/Scripts/Views/
  ├── OrdenPago_Registrar.js             # Lógica de registro
  └── OrdenPago_Consultar.js             # Lógica de consulta
```

### **Base de Datos (SQL)**
```
Utilidad/SQL Server/
  ├── 020_CREAR_TABLA_ORDEN_PAGO.sql     # Crear tabla
  ├── 021_SP_ORDEN_PAGO.sql              # Stored procedures
  └── 029_AGREGAR_MENUS_FINAL.sql        # Menús y permisos
```

---

## 🎨 Funcionalidades

### **1. Registrar Orden de Pago**
- Seleccionar proveedor
- Ver facturas pendientes del proveedor
- Seleccionar factura a pagar
- Elegir método de pago
- Registrar orden de pago
- La factura cambia automáticamente a estado "Pagado"

### **2. Consultar Órdenes de Pago**
- Filtrar por proveedor (o ver todas)
- Ver lista de órdenes de pago con:
  - Número de factura
  - Proveedor
  - Fecha
  - Productos
  - Cantidad
  - Total (formato AR$)
  - Método de pago
  - Estado
- Ver comprobante completo (similar al de factura)
- Imprimir comprobante

---

## 🔧 Configuración Adicional

### **URLs en _Layout.cshtml**
Ya están configuradas las siguientes URLs:
```javascript
$.MisUrls.urls({ _ObtenerProveedoresOrdenPago: '@Url.Action("ObtenerProveedores", "OrdenPago")' });
$.MisUrls.urls({ _ObtenerFacturasPendientes: '@Url.Action("ObtenerFacturasPendientes", "OrdenPago")' });
$.MisUrls.urls({ _RegistrarOrdenPago: '@Url.Action("RegistrarOrdenPago", "OrdenPago")' });
$.MisUrls.urls({ _ObtenerOrdenesPago: '@Url.Action("ObtenerOrdenesPago", "OrdenPago")' });
$.MisUrls.urls({ _ObtenerDetalleOrdenPago: '@Url.Action("ObtenerDetalleOrdenPago", "OrdenPago")' });
```

---

## 🐛 Solución de Problemas

### **Problema: No aparece el menú "Ordenes de Pago"**
**Solución:**
1. Verificar que se ejecutó el script `029_AGREGAR_MENUS_FINAL.sql`
2. Verificar permisos del usuario:
```sql
SELECT * FROM PERMISO WHERE IdUsuario = 1
```
3. Cerrar sesión y volver a iniciar

### **Problema: Error al cargar facturas pendientes**
**Solución:**
1. Verificar que existe la tabla `FACTURA` con el campo `Estado`
2. Verificar que existen facturas con estado "Pendiente"
3. Ejecutar script de diagnóstico:
```sql
-- Archivo: Utilidad/SQL Server/037_DIAGNOSTICO_COMPLETO.sql
```

### **Problema: Fechas muestran "Invalid Date"**
**Solución:**
Ya está corregido en el código. Si persiste:
1. Limpiar caché del navegador (Ctrl + Shift + Delete)
2. Recompilar la solución
3. Hard refresh (Ctrl + F5)

---

## 📝 Notas Importantes

1. **Facturas Pendientes:** Solo se muestran facturas con estado "Pendiente"
2. **Una orden por factura:** No se puede crear más de una orden de pago para la misma factura
3. **Actualización automática:** Al registrar una orden, la factura cambia a "Pagado"
4. **Formato de moneda:** Todos los montos se muestran con formato AR$ X,XXX.XX
5. **Comprobantes:** El diseño es idéntico al de facturas para mantener consistencia

---

## 👥 Soporte

Si tienes problemas durante la instalación:
1. Revisa los archivos de documentación en la raíz del proyecto
2. Verifica los logs de SQL Server
3. Revisa la consola del navegador (F12) para errores de JavaScript

---

## 📅 Información del Commit

- **Rama:** `develop`
- **Commit:** `5575914`
- **Mensaje:** "Implementar modulo completo de Ordenes de Pago"
- **Fecha:** 27 de octubre de 2025
- **Archivos modificados:** 32 archivos
- **Líneas agregadas:** 3,028

---

## ✅ Checklist de Instalación

- [ ] Pull desde GitHub (rama develop)
- [ ] Ejecutar `020_CREAR_TABLA_ORDEN_PAGO.sql`
- [ ] Ejecutar `021_SP_ORDEN_PAGO.sql`
- [ ] Ejecutar `029_AGREGAR_MENUS_FINAL.sql`
- [ ] Recompilar solución
- [ ] Verificar que aparece el menú "Ordenes de Pago"
- [ ] Probar registro de orden de pago
- [ ] Probar consulta de órdenes de pago
- [ ] Verificar comprobante

---

**¡Instalación completada! 🎉**
