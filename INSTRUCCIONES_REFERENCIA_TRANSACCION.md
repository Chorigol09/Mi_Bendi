# Implementacion: Campos de Referencia y Numero de Transaccion

## Fecha: 10 de Noviembre de 2025

---

## Descripcion

Se han agregado campos adicionales para las ordenes de pago cuando el metodo de pago **NO es Efectivo**:

### Campos Nuevos:

1. **Referencia**
   - Transferencia Bancaria / Cheque: Numero de comprobante
   - Tarjetas: Ultimos 4 digitos de la tarjeta

2. **Numero de Transaccion**
   - Identificador unico de la transaccion
   - Obligatorio para todos los metodos excepto Efectivo

---

## Cambios Realizados

### 1. Base de Datos

#### Script: `053_AGREGAR_REFERENCIA_TRANSACCION.sql`
- ✅ Columna `Referencia` (VARCHAR(100) NULL)
- ✅ Columna `NumeroTransaccion` (VARCHAR(100) NULL)

#### Script: `054_SP_ORDEN_PAGO_REFERENCIA.sql`
- ✅ `SP_REGISTRAR_ORDEN_PAGO` actualizado con nuevos parametros
- ✅ `SP_OBTENER_DETALLE_ORDEN_PAGO` actualizado para devolver campos

### 2. Backend (C#)

#### CapaModelo/OrdenPago.cs
- ✅ Propiedad `Referencia`
- ✅ Propiedad `NumeroTransaccion`

#### CapaDatos/CD_OrdenPago.cs
- ✅ Parametros agregados en `RegistrarOrdenPago()`
- ✅ Lectura de campos en `ObtenerDetalleOrdenPago()`

### 3. Frontend

#### Views/OrdenPago/Registrar.cshtml
- ✅ Seccion `divCamposAdicionales` (se muestra condicionalmente)
- ✅ Campo `txtReferencia` (cambia segun metodo)
- ✅ Campo `txtNumeroTransaccion`

#### Scripts/Views/OrdenPago_Registrar.js
- ✅ Logica para mostrar/ocultar campos segun metodo de pago
- ✅ Cambio dinamico de etiquetas y placeholders
- ✅ Validaciones especificas por metodo
- ✅ Envio de datos al backend

#### Views/OrdenPago/Consultar.cshtml
- ✅ Campos agregados en comprobante
- ✅ Fila de Numero Transaccion (se muestra condicionalmente)

#### Scripts/Views/OrdenPago_Consultar.js
- ✅ Muestra campos si no es Efectivo
- ✅ Cambia etiquetas segun metodo de pago

---

## Comportamiento por Metodo de Pago

### Efectivo
- ❌ NO solicita campos adicionales
- ❌ NO guarda Referencia ni NumeroTransaccion

### Transferencia Bancaria
- ✅ Solicita **Numero de Comprobante** (Referencia)
- ✅ Solicita **Numero de Transaccion**
- ✅ Guarda ambos campos

### Cheque
- ✅ Solicita **Numero de Comprobante** (Referencia)
- ✅ Solicita **Numero de Transaccion**
- ✅ Guarda ambos campos

### Tarjeta de Credito / Debito
- ✅ Solicita **Ultimos 4 Digitos** (Referencia)
  - Validacion: exactamente 4 digitos
  - maxlength="4"
- ✅ Solicita **Numero de Transaccion**
- ✅ Guarda ambos campos

---

## Validaciones Implementadas

### Frontend (JavaScript)

1. **Campos obligatorios** si metodo != Efectivo
   - Referencia no puede estar vacia
   - NumeroTransaccion no puede estar vacia

2. **Tarjetas**
   - Referencia debe tener exactamente 4 digitos
   - Mensaje: "Debe ingresar exactamente 4 digitos de la tarjeta"

3. **Habilitacion de boton**
   - Efectivo: Solo requiere facturas seleccionadas
   - Otros: Requiere facturas + Referencia + NumeroTransaccion

### Backend (SQL)

- Campos son NULL en base de datos (no obligatorios)
- Validacion en frontend segun metodo de pago

---

## Instrucciones de Instalacion

### Paso 1: Ejecutar Scripts SQL

**IMPORTANTE**: Ejecutar en este ORDEN:

1. `050_MODIFICAR_ORDEN_PAGO_MULTIFACTURA.sql` (si no esta ejecutado)
2. `051_SP_ORDEN_PAGO_MULTIFACTURA.sql` (si no esta ejecutado)
3. `052_OPTIMIZAR_SP_ORDEN_PAGO.sql` (si no esta ejecutado)
4. **`053_AGREGAR_REFERENCIA_TRANSACCION.sql`** ⭐ NUEVO
5. **`054_SP_ORDEN_PAGO_REFERENCIA.sql`** ⭐ NUEVO

### Paso 2: Recompilar Proyecto

1. Visual Studio → Clean Solution
2. Visual Studio → Rebuild Solution
3. Verificar sin errores de compilacion

### Paso 3: Limpiar Cache

- Navegador: Ctrl + Shift + Delete
- O usar modo incognito

---

## Casos de Prueba

### Test 1: Pago con Efectivo
1. Seleccionar proveedor con facturas pendientes
2. Marcar una o mas facturas
3. Seleccionar "Efectivo" como metodo
4. ✅ NO debe mostrar campos adicionales
5. ✅ Boton debe habilitarse inmediatamente
6. Registrar orden de pago
7. ✅ Debe registrar exitosamente

### Test 2: Pago con Transferencia
1. Seleccionar proveedor con facturas pendientes
2. Marcar una o mas facturas
3. Seleccionar "Transferencia Bancaria"
4. ✅ Debe mostrar campos adicionales
5. ✅ Etiqueta debe decir "Numero de Comprobante"
6. Llenar numero de comprobante y numero de transaccion
7. ✅ Boton debe habilitarse
8. Registrar orden de pago
9. ✅ Debe registrar exitosamente

### Test 3: Pago con Tarjeta
1. Seleccionar proveedor con facturas pendientes
2. Marcar una o mas facturas
3. Seleccionar "Tarjeta de Credito"
4. ✅ Debe mostrar campos adicionales
5. ✅ Etiqueta debe decir "Ultimos 4 Digitos"
6. ✅ Campo debe tener maxlength="4"
7. Intentar ingresar 3 digitos
8. ✅ Debe mostrar error al registrar
9. Ingresar 4 digitos y numero de transaccion
10. ✅ Debe registrar exitosamente

### Test 4: Visualizar Comprobante
1. Ir a Consultar Ordenes de Pago
2. Buscar ordenes
3. Click en boton "Ver" (ojo)
4. ✅ Si es Efectivo: NO mostrar Referencia ni NumeroTransaccion
5. ✅ Si NO es Efectivo: Mostrar ambos campos
6. ✅ Etiqueta correcta segun metodo de pago

---

## Validacion de Campos

### Referencia
```javascript
// Transferencia / Cheque
- Cualquier valor alfanumerico
- Ejemplo: "COMP-2025-001", "CHQ-123456"

// Tarjetas
- Exactamente 4 digitos
- Ejemplo: "1234", "5678"
- maxlength="4"
```

### Numero Transaccion
```javascript
- Cualquier valor alfanumerico
- Ejemplo: "TXN-20251110-001", "AUTH-789456"
- Sin restricciones de formato
```

---

## Archivos Modificados

### SQL
1. ✅ `053_AGREGAR_REFERENCIA_TRANSACCION.sql` (NUEVO)
2. ✅ `054_SP_ORDEN_PAGO_REFERENCIA.sql` (NUEVO)

### Backend
3. ✅ `CapaModelo/OrdenPago.cs`
4. ✅ `CapaDatos/CD_OrdenPago.cs`

### Frontend
5. ✅ `Views/OrdenPago/Registrar.cshtml`
6. ✅ `Scripts/Views/OrdenPago_Registrar.js`
7. ✅ `Views/OrdenPago/Consultar.cshtml`
8. ✅ `Scripts/Views/OrdenPago_Consultar.js`

---

## Compatibilidad

### Ordenes de Pago Existentes
- ✅ Ordenes antiguas no tienen estos campos (NULL)
- ✅ Comprobante muestra "-" si no hay datos
- ✅ No se requiere migracion de datos

### Efectivo
- ✅ Sigue funcionando sin cambios
- ✅ Campos permanecen NULL

---

## Notas Importantes

- ⚠️ **Ejecutar scripts SQL en orden correcto**
- ⚠️ **Limpiar cache del navegador**
- ⚠️ **Validar que maxlength funcione en tarjetas**
- ⚠️ **Probar todos los metodos de pago**

---

**Estado:** ✅ Completado y listo para implementar  
**Fecha:** 10 de Noviembre de 2025
