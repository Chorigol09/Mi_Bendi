# Instrucciones para Implementar Métodos de Pago en Ventas

## ✅ Cambios Realizados

### 1. **Frontend - Vista HTML** (`VentasWeb/Views/Venta/Crear.cshtml`)
- ✅ Agregado selector de método de pago con 4 opciones:
  - Efectivo
  - Tarjeta de Débito
  - Tarjeta de Crédito
  - Transferencia Bancaria
- ✅ Los campos de "Monto Pago" y "Cambio" ahora están en una sección identificada (`#seccionEfectivo`)
- ✅ Solo se muestran cuando el método de pago es "Efectivo"

### 2. **Frontend - JavaScript** (`VentasWeb/Scripts/Views/Venta_Crear.js`)
- ✅ Agregado event listener para el selector de método de pago
- ✅ Muestra/oculta campos según el método seleccionado
- ✅ Validación de monto solo aplica para efectivo
- ✅ Cálculo de cambio solo se ejecuta para efectivo
- ✅ El XML enviado incluye el campo `<MetodoPago>`

### 3. **Backend - Modelo** (`CapaModelo/Venta.cs`)
- ✅ Agregada propiedad `MetodoPago` al modelo `Venta`

### 4. **Backend - Capa de Datos** (`CapaDatos/CD_Venta.cs`)
- ✅ Actualizada lectura del detalle de venta para incluir `MetodoPago`

### 5. **Base de Datos - Scripts SQL**
Se crearon 2 scripts en la carpeta `/scripts`:

#### Script 1: `Agregar_MetodoPago_Venta.sql`
- Agrega la columna `MetodoPago` a la tabla `VENTA`
- Actualiza registros existentes con valor por defecto "Efectivo"

#### Script 2: `Actualizar_SP_Venta_MetodoPago.sql`
- Actualiza el stored procedure `usp_RegistrarVenta` para:
  - Leer el campo `MetodoPago` del XML
  - Insertar el valor en la tabla VENTA
- Actualiza el stored procedure `usp_ObtenerDetalleVenta` para:
  - Devolver el campo `MetodoPago` en el XML de respuesta

---

## 📋 Pasos para Aplicar los Cambios

### Paso 1: Ejecutar Scripts SQL (EN ORDEN)
```sql
-- 1. Primero agregar la columna a la tabla
-- Ejecutar: scripts/Agregar_MetodoPago_Venta.sql

-- 2. Luego actualizar los stored procedures
-- Ejecutar: scripts/Actualizar_SP_Venta_MetodoPago.sql
```

### Paso 2: Compilar el Proyecto
1. Abre Visual Studio
2. Compila el proyecto (Build → Build Solution o F6)
3. Verifica que no haya errores de compilación

### Paso 3: Probar la Funcionalidad
1. Ejecuta la aplicación (F5)
2. Ve a **Ventas → Registrar Venta**
3. **Prueba con Efectivo:**
   - Selecciona "Efectivo" en el método de pago
   - Deberías ver los campos "Monto Pago", "Calcular" y "Cambio"
   - Ingresa productos y completa la venta
4. **Prueba con otros métodos:**
   - Selecciona "Tarjeta de Débito" (o cualquier otro método)
   - Los campos de monto y cambio deberían ocultarse
   - El botón "Imprimir y Terminar Venta" debería funcionar directamente

---

## 🎯 Comportamiento Esperado

### Cuando se selecciona "Efectivo":
- ✅ Se muestran: Monto Pago, Botón Calcular, Cambio
- ✅ Se valida que se ingrese el monto de pago
- ✅ Se calcula el cambio automáticamente
- ✅ `ImporteRecibido` = monto ingresado
- ✅ `ImporteCambio` = diferencia calculada

### Cuando se selecciona cualquier otro método:
- ✅ Se ocultan: Monto Pago, Botón Calcular, Cambio
- ✅ NO se valida el monto de pago
- ✅ NO se calcula cambio
- ✅ `ImporteRecibido` = total de la venta
- ✅ `ImporteCambio` = 0

---

## 📝 Notas Importantes

1. **Retrocompatibilidad:** Las ventas existentes se actualizarán automáticamente con método de pago "Efectivo"
2. **Validaciones:** El monto de pago solo es obligatorio para efectivo
3. **PDF de Venta:** El documento PDF puede necesitar actualizarse si deseas mostrar el método de pago
4. **Reportes:** Si tienes reportes de ventas, considera agregar el campo MetodoPago como filtro

---

## 🔧 Solución de Problemas

### Si los campos no se ocultan/muestran:
1. Limpia el caché del navegador (Ctrl + Shift + R)
2. Verifica que el archivo JavaScript se esté cargando correctamente
3. Abre la consola del navegador (F12) y verifica que no haya errores

### Si hay error al guardar la venta:
1. Verifica que ejecutaste ambos scripts SQL
2. Verifica que la columna `MetodoPago` existe en la tabla VENTA
3. Verifica que los stored procedures se actualizaron correctamente

### Si el método de pago no aparece en el detalle:
1. Verifica que ejecutaste el script de actualización de stored procedures
2. Recompila el proyecto
3. Reinicia la aplicación

---

## ✅ Checklist de Verificación

- [ ] Script `Agregar_MetodoPago_Venta.sql` ejecutado exitosamente
- [ ] Script `Actualizar_SP_Venta_MetodoPago.sql` ejecutado exitosamente
- [ ] Proyecto compilado sin errores
- [ ] Probado con método "Efectivo" - campos visibles ✓
- [ ] Probado con método "Tarjeta de Débito" - campos ocultos ✓
- [ ] Probado con método "Tarjeta de Crédito" - campos ocultos ✓
- [ ] Probado con método "Transferencia" - campos ocultos ✓
- [ ] Venta registrada correctamente con cada método ✓
- [ ] Detalle de venta muestra el método de pago correcto ✓

---

**Fecha de Implementación:** 31 de Octubre de 2025  
**Desarrollado por:** Asistente Cascade
