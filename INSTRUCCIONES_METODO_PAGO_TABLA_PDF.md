# Instrucciones para Agregar Método de Pago en Tabla y PDF de Ventas

## ✅ Cambios Realizados

### 1. **Tabla de Consulta de Ventas**
- ✅ Agregada columna "Metodo Pago" en la tabla de ventas (`Consultar.cshtml`)
- ✅ Actualizado JavaScript para mostrar el método de pago (`Venta_Consultar.js`)
- ✅ Valor por defecto "Efectivo" para ventas existentes sin método de pago

### 2. **PDF de Ventas**
- ✅ Agregado campo "Metodo Pago" en el documento PDF (`Documento.cshtml`)
- ✅ **Ventas nuevas:** Muestra el método de pago seleccionado
- ✅ **Ventas con Efectivo:** Muestra método + "Pago con" + "Cambio"
- ✅ **Ventas con otros métodos:** Solo muestra el método de pago
- ✅ **Ventas existentes (sin método):** Muestra "Efectivo" como valor por defecto

### 3. **Backend - Capa de Datos**
- ✅ Actualizada lectura del campo `MetodoPago` en `CD_Venta.cs`
- ✅ Manejo de valores NULL (por defecto "Efectivo")

### 4. **Base de Datos - Script SQL**
Se creó 1 nuevo script en la carpeta `/scripts`:

#### Script: `Actualizar_SP_ListaVentas_MetodoPago.sql`
- Actualiza el stored procedure `usp_ObtenerListaVenta` para incluir `MetodoPago`
- Devuelve "Efectivo" como valor por defecto para registros sin método de pago

---

## 📋 Pasos para Aplicar los Cambios

### Paso 1: Ejecutar Script SQL
```sql
-- Ejecutar: scripts/Actualizar_SP_ListaVentas_MetodoPago.sql
```

Este script actualiza el stored procedure que obtiene la lista de ventas para incluir el campo `MetodoPago`.

### Paso 2: Compilar el Proyecto
1. Abre Visual Studio
2. Compila el proyecto (Build → Build Solution o F6)
3. Verifica que no haya errores de compilación

### Paso 3: Probar la Funcionalidad
1. Ejecuta la aplicación (F5)
2. **Prueba la tabla de ventas:**
   - Ve a **Ventas → Consultar Venta**
   - Verifica que aparezca la columna "Metodo Pago"
   - Las ventas existentes deberían mostrar "Efectivo"
   - Las ventas nuevas mostrarán el método seleccionado

3. **Prueba el PDF:**
   - Haz clic en el botón "Ver" de cualquier venta
   - **Ventas antiguas (sin método):**
     - Deberían mostrar "Metodo Pago: Efectivo"
     - Deberían mostrar "Pago con" y "Cambio"
   - **Ventas nuevas con Efectivo:**
     - Muestra "Metodo Pago: Efectivo"
     - Muestra "Pago con" y "Cambio"
   - **Ventas nuevas con otro método (ej: Tarjeta):**
     - Muestra "Metodo Pago: Tarjeta de Debito"
     - NO muestra "Pago con" ni "Cambio"

---

## 🎯 Comportamiento Esperado

### En la Tabla de Ventas:
| Tipo Documento | Codigo | Fecha | Cliente | **Metodo Pago** | Total |
|----------------|--------|-------|---------|-----------------|-------|
| Boleta | 000010 | 31/10/2025 | Cliente A | Efectivo | $3,600.00 |
| Factura | 000009 | 22/10/2025 | Cliente B | Tarjeta de Debito | $8,500.00 |

### En el PDF:

**Para ventas con Efectivo (o ventas antiguas):**
```
Metodo Pago | Efectivo | Pago con | $10,000.00 | Cambio | $500.00 | Total: $9,500.00
```

**Para ventas con otros métodos:**
```
Metodo Pago | Tarjeta de Debito |                                     | Total: $9,500.00
```

---

## 📝 Resumen de Scripts SQL Necesarios

### Scripts ya ejecutados (de implementación anterior):
1. ✅ `Agregar_MetodoPago_Venta.sql` - Agrega columna a la tabla
2. ✅ `Actualizar_SP_Venta_MetodoPago.sql` - Actualiza SP de registro

### Nuevo script a ejecutar:
3. 🔲 `Actualizar_SP_ListaVentas_MetodoPago.sql` - Actualiza SP de consulta

---

## 🔧 Solución de Problemas

### Si la columna "Metodo Pago" no aparece en la tabla:
1. Verifica que ejecutaste el script `Actualizar_SP_ListaVentas_MetodoPago.sql`
2. Limpia el caché del navegador (Ctrl + Shift + R)
3. Verifica la consola del navegador (F12) por errores

### Si el método de pago no aparece en el PDF:
1. Verifica que compilaste el proyecto después de los cambios
2. Reinicia la aplicación
3. Cierra y vuelve a abrir el PDF

### Si aparece error en el stored procedure:
Verifica que todos los scripts anteriores se ejecutaron correctamente:
```sql
-- Verificar que la columna existe
SELECT * FROM sys.columns 
WHERE object_id = OBJECT_ID(N'[dbo].[VENTA]') 
AND name = 'MetodoPago'

-- Verificar que el SP existe
SELECT * FROM sys.objects 
WHERE type = 'P' AND name = 'usp_ObtenerListaVenta'
```

---

## ✅ Checklist de Verificación

- [ ] Script `Actualizar_SP_ListaVentas_MetodoPago.sql` ejecutado exitosamente
- [ ] Proyecto compilado sin errores
- [ ] Tabla de ventas muestra columna "Metodo Pago" ✓
- [ ] Ventas antiguas muestran "Efectivo" por defecto ✓
- [ ] Ventas nuevas muestran el método seleccionado ✓
- [ ] PDF de ventas antiguas muestra "Efectivo" + campos de pago ✓
- [ ] PDF de ventas con efectivo muestra campos "Pago con" y "Cambio" ✓
- [ ] PDF de ventas con otros métodos NO muestra campos de pago/cambio ✓

---

**Fecha de Implementación:** 31 de Octubre de 2025  
**Desarrollado por:** Asistente Cascade

## 📌 Nota Importante

- Las **ventas existentes** (registradas antes de esta actualización) automáticamente mostrarán "Efectivo" como método de pago
- Solo las **ventas nuevas** registrarán el método de pago específico seleccionado
- El PDF se adapta automáticamente según el método de pago
