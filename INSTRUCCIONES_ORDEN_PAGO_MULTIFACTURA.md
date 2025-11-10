# Implementación: Órdenes de Pago con Múltiples Facturas

## Descripción
Se ha modificado el sistema de órdenes de pago para permitir seleccionar y pagar múltiples facturas del mismo proveedor en una sola orden de pago.

## Cambios Realizados

### 1. Base de Datos

#### Nueva Tabla: DETALLE_ORDEN_PAGO
- Tabla intermedia que relaciona una orden de pago con múltiples facturas
- Cada factura solo puede estar asociada a una orden de pago (constraint UNIQUE)
- Campos:
  - `IdDetalleOrdenPago` (PK)
  - `IdOrdenPago` (FK a ORDEN_PAGO)
  - `IdFactura` (FK a FACTURA, UNIQUE)
  - `MontoFactura` (monto individual de la factura)

#### Modificaciones en ORDEN_PAGO
- Campo `IdFactura` ahora es NULLABLE (mantener por compatibilidad)
- Se eliminó la FK directa a FACTURA
- El campo `MontoTotal` ahora suma todas las facturas asociadas

### 2. Stored Procedures Actualizados

#### SP_REGISTRAR_ORDEN_PAGO
- **Parámetro modificado**: `@IdsFacturas` (VARCHAR) - recibe IDs separados por comas
- **Cambio**: Ahora procesa múltiples facturas en una sola transacción
- Valida que todas las facturas:
  - Existan y estén en estado 'Pendiente'
  - Pertenezcan al mismo proveedor
  - No tengan una orden de pago previa
- Inserta registros en `DETALLE_ORDEN_PAGO`
- Actualiza todas las facturas a estado 'Pagado'

#### SP_OBTENER_ORDENES_PAGO
- **Nuevo campo**: `CantidadFacturas` - contador de facturas en la orden
- Concatena números de facturas en un solo string
- Agrupa productos de todas las facturas asociadas

#### SP_OBTENER_DETALLE_ORDEN_PAGO
- Devuelve productos de todas las facturas asociadas
- Incluye campo `NumeroFactura` en detalle de productos

#### SP_OBTENER_FACTURAS_ORDEN_PAGO (NUEVO)
- Obtiene lista de facturas asociadas a una orden de pago
- Retorna: IdFactura, NumeroFactura, FechaEmision, MontoFactura, Estado

### 3. Código Backend (C#)

#### CapaModelo/OrdenPago.cs
- **Nuevo campo**: `List<int> IdsFacturas` - lista de IDs de facturas a pagar
- **Nuevo campo**: `int CantidadFacturas` - contador para mostrar
- **Nuevo campo**: `List<FacturaOrdenPago> Facturas` - lista de facturas asociadas
- **Nueva clase**: `FacturaOrdenPago` - representa facturas en una orden

#### CapaDatos/CD_OrdenPago.cs
- **Método modificado**: `RegistrarOrdenPago()` - ahora envía IDs separados por comas
- **Método modificado**: `ObtenerOrdenesPago()` - maneja campo CantidadFacturas
- **Método nuevo**: `ObtenerFacturasOrdenPago()` - obtiene facturas de una orden

#### Controllers/OrdenPagoController.cs
- **Endpoint nuevo**: `ObtenerFacturasOrdenPago` - API para obtener facturas de orden

### 4. Frontend

#### Views/OrdenPago/Registrar.cshtml
- **Modificación**: Checkbox en lugar de botón "Seleccionar"
- **Alerta informativa**: Indica que se pueden seleccionar múltiples facturas
- **Resumen mejorado**: Muestra lista de facturas seleccionadas y total

#### Scripts/Views/OrdenPago_Registrar.js
- **Variable cambiada**: `facturasSeleccionadas` (array) en lugar de `facturaSeleccionada` (objeto)
- **Función nueva**: `actualizarFacturasSeleccionadas()` - calcula total y muestra resumen
- **Event handler**: Maneja cambios en checkboxes
- **Request modificado**: Envía array de IDs en lugar de un solo ID

#### Views/OrdenPago/Consultar.cshtml
- **Nueva columna**: "Cant. Facturas" - muestra badge con cantidad
- **Columna actualizada**: "Nro Factura(s)" - puede mostrar múltiples
- **Comprobante**: Incluye columna de factura en detalle de productos

#### Scripts/Views/OrdenPago_Consultar.js
- **Nueva columna**: `CantidadFacturas` con badges
- **Render mejorado**: Trunca números de facturas largos con tooltip
- **Comprobante actualizado**: Muestra número de factura por cada producto

## Instrucciones de Implementación

### Paso 1: Ejecutar Scripts SQL (EN ORDEN)
```sql
-- 1. Crear tabla y modificar estructura
-- Ejecutar: Utilidad/SQL Server/050_MODIFICAR_ORDEN_PAGO_MULTIFACTURA.sql

-- 2. Actualizar stored procedures
-- Ejecutar: Utilidad/SQL Server/051_SP_ORDEN_PAGO_MULTIFACTURA.sql
```

### Paso 2: Compilar Proyecto
1. Abrir solución en Visual Studio
2. Limpiar solución (Clean Solution)
3. Recompilar solución (Rebuild Solution)
4. Verificar que no hay errores de compilación

### Paso 3: Verificar Archivos Modificados
Asegurarse que los siguientes archivos estén actualizados:
- ✅ `CapaModelo/OrdenPago.cs`
- ✅ `CapaDatos/CD_OrdenPago.cs`
- ✅ `VentasWeb/Controllers/OrdenPagoController.cs`
- ✅ `VentasWeb/Views/OrdenPago/Registrar.cshtml`
- ✅ `VentasWeb/Scripts/Views/OrdenPago_Registrar.js`
- ✅ `VentasWeb/Views/OrdenPago/Consultar.cshtml`
- ✅ `VentasWeb/Scripts/Views/OrdenPago_Consultar.js`

### Paso 4: Limpiar Caché del Navegador
Importante para que los cambios en JavaScript se reflejen:
- Ctrl + Shift + Delete (Chrome/Edge)
- O usar modo incógnito para pruebas

### Paso 5: Probar Funcionalidad

#### Prueba 1: Registrar Orden con Una Factura
1. Ir a "Órdenes de Pago" → "Registrar"
2. Seleccionar un proveedor que tenga facturas pendientes
3. Marcar checkbox de UNA factura
4. Verificar que muestra el número y monto correcto
5. Seleccionar método de pago
6. Registrar orden de pago
7. Verificar mensaje de éxito

#### Prueba 2: Registrar Orden con Múltiples Facturas
1. Seleccionar un proveedor con varias facturas pendientes
2. Marcar checkboxes de DOS O MÁS facturas
3. Verificar que el resumen muestra:
   - Lista de números de facturas separados por coma
   - Suma total de los montos
4. Seleccionar método de pago
5. Registrar orden de pago
6. Verificar mensaje indicando cantidad de facturas procesadas

#### Prueba 3: Consultar Órdenes de Pago
1. Ir a "Órdenes de Pago" → "Consultar"
2. Filtrar por proveedor (o ver todas)
3. Buscar
4. Verificar columna "Cant. Facturas":
   - Badge azul para múltiples facturas
   - Badge gris para una factura
5. Click en botón "Ver" (ojo)
6. Verificar comprobante muestra:
   - Todos los números de facturas
   - Productos de todas las facturas
   - Columna indicando de qué factura viene cada producto
   - Total correcto sumando todas las facturas

#### Prueba 4: Validaciones
1. Intentar registrar sin seleccionar facturas → debe mostrar error
2. Seleccionar facturas, luego desmarcar todas → debe ocultar sección de pago
3. Verificar que facturas ya pagadas no aparecen en lista de pendientes
4. Verificar que no se puede pagar la misma factura dos veces

## Compatibilidad con Datos Existentes

El sistema mantiene compatibilidad con órdenes de pago existentes:
- El script de migración (`050_MODIFICAR_ORDEN_PAGO_MULTIFACTURA.sql`) copia automáticamente órdenes existentes a la tabla `DETALLE_ORDEN_PAGO`
- Órdenes antiguas se mostrarán con "1 factura"
- No se requiere modificar datos existentes manualmente

## Beneficios de la Implementación

1. **Eficiencia**: Pagar múltiples facturas en una sola transacción
2. **Reducción de comprobantes**: Menos órdenes de pago para gestionar
3. **Mejor control**: Suma total de facturas por proveedor
4. **Flexibilidad**: Sigue permitiendo pagar facturas individuales
5. **Trazabilidad**: Se mantiene el detalle de qué facturas componen cada orden

## Notas Importantes

- ⚠️ **BACKUP**: Hacer backup de la base de datos antes de ejecutar scripts
- ⚠️ **Orden de ejecución**: Los scripts SQL deben ejecutarse en el orden indicado
- ⚠️ **Validación**: Una factura solo puede estar en una orden de pago
- ⚠️ **Proveedor**: Solo se pueden seleccionar facturas del mismo proveedor
- ⚠️ **Estado**: Solo facturas en estado "Pendiente" son seleccionables

## Soporte y Resolución de Problemas

### Error: "Una o más facturas ya tienen una orden de pago asociada"
- **Causa**: Factura ya fue pagada previamente
- **Solución**: Verificar en consulta de órdenes de pago, desmarcar esa factura

### Error: "La factura no existe o ya fue pagada"
- **Causa**: Estado de factura no es "Pendiente"
- **Solución**: Verificar estado en módulo de facturas

### No aparecen facturas para seleccionar
- **Causa**: No hay facturas pendientes para ese proveedor
- **Solución**: Verificar que existan facturas en estado "Pendiente"

### No se refleja cambio en el frontend
- **Causa**: Caché del navegador
- **Solución**: Limpiar caché o usar modo incógnito

---

**Fecha de Implementación**: 10 de Noviembre de 2025  
**Versión**: 1.0  
**Estado**: ✅ Completado - Listo para implementar
