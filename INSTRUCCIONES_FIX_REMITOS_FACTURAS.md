# 🔧 FIX: Generación Automática de Remitos y Facturas

## 🔍 Problema Identificado

Al registrar una Orden de Compra, **NO se están generando automáticamente** los remitos y facturas asociados.

**Causa:** El stored procedure `usp_RegistrarCompra` no tiene la lógica para generar remitos y facturas automáticamente.

## ✅ Solución Implementada

Se ha modificado el SP `usp_RegistrarCompra` para que al crear una orden de compra:
- ✅ Genera automáticamente un **Remito** (Estado: "En Espera")
- ✅ Genera automáticamente una **Factura** (Estado: "Pendiente")
- ✅ Copia los productos y cantidades de la orden
- ✅ Números automáticos: `REM-20241016-1` y `FACT-20241016-1`

---

## 🚀 PASOS PARA APLICAR EL FIX

### **OPCIÓN A: Ejecutar desde Batch (Recomendado)**

1. **Doble clic** en el archivo:
   ```
   EJECUTAR_FIX_REMITOS_FACTURAS.bat
   ```

2. Presiona **Enter** cuando te lo pida

3. Espera a ver el mensaje: **"✅ FIX COMPLETADO"**

---

### **OPCIÓN B: Ejecutar desde SQL Server Management Studio**

1. **Abrir SQL Server Management Studio (SSMS)**

2. **File** → **Open** → **File...**

3. Seleccionar:
   ```
   scripts\FIX_GENERAR_REMITOS_FACTURAS_AUTO.sql
   ```

4. Presionar **F5** o click en **Execute**

5. Esperar a ver:
   ```
   ╔════════════════════════════════════════════════╗
   ║           ✅ FIX COMPLETADO                    ║
   ╚════════════════════════════════════════════════╝
   ```

---

## 🧪 VERIFICACIÓN

### **1. Verificar órdenes existentes**

Después de ejecutar el script, verifica en SSMS:

```sql
-- Ver cuántas órdenes tienen remito y factura
SELECT 
    'Órdenes' AS Tipo, COUNT(*) AS Total FROM ORDEN_COMPRA WHERE Activo = 1
UNION ALL
SELECT 'Remitos', COUNT(*) FROM REMITO WHERE Activo = 1
UNION ALL
SELECT 'Facturas', COUNT(*) FROM FACTURA WHERE Activo = 1
```

**Resultado esperado:** Las 3 cantidades deben ser **iguales**.

### **2. Ver remitos generados**

```sql
SELECT 
    r.NumeroRemito,
    r.IdOrdenCompra,
    p.RazonSocial,
    r.Estado,
    r.FechaRegistro
FROM REMITO r
INNER JOIN PROVEEDOR p ON r.IdProveedor = p.IdProveedor
ORDER BY r.FechaRegistro DESC
```

### **3. Ver facturas generadas**

```sql
SELECT 
    f.NumeroFactura,
    f.IdOrdenCompra,
    p.RazonSocial,
    f.Total,
    f.Estado,
    f.FechaEmision
FROM FACTURA f
INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
ORDER BY f.FechaEmision DESC
```

---

## 🎯 PROBAR LA FUNCIONALIDAD

### **1. Reiniciar la aplicación**

Cierra y vuelve a abrir el sistema (o ejecuta `RECOMPILAR_Y_EJECUTAR.bat`)

### **2. Crear una nueva Orden de Compra**

1. **Compras** → **Registrar Orden de Compra**
2. Selecciona un **proveedor**
3. Selecciona una **tienda**
4. Agrega **productos** con cantidades y precios
5. Click en **"Terminar y Guardar Compra"**

### **3. Verificar en Remitos**

1. **Compras** → **Remitos**
2. Deberías ver un **nuevo remito** con:
   - Número: `REM-20241016-X`
   - Estado: **"En Espera"** 🟡
   - Productos y cantidades de la orden

### **4. Verificar en Facturas**

1. **Compras** → **Facturas**
2. Deberías ver una **nueva factura** con:
   - Número: `FACT-20241016-X`
   - Estado: **"Pendiente"** 🟡
   - Total igual al total de la orden
   - Productos y cantidades de la orden

---

## 📊 ¿QUÉ HACE EL SCRIPT?

### **1. Modifica `usp_RegistrarCompra`**
- Agrega lógica para crear remito automáticamente
- Agrega lógica para crear factura automáticamente
- Copia los productos de la orden al remito y factura

### **2. Actualiza SPs de consulta**
- `usp_ObtenerRemitos` - Incluye fecha de orden, productos, cantidades
- `usp_ObtenerFacturas` - Incluye fecha de orden, productos, cantidades, total

### **3. Crea SPs de actualización**
- `usp_ActualizarEstadoRemito` - Cambiar estado (En Espera → Recibido)
- `usp_ActualizarEstadoFactura` - Cambiar estado (Pendiente → Pagado)

### **4. Recupera datos históricos**
- Genera remitos para todas las órdenes existentes que no tienen remito
- Genera facturas para todas las órdenes existentes que no tienen factura
- Copia los detalles de productos

---

## 🔄 FLUJO COMPLETO

```
Usuario crea Orden de Compra
          ↓
  ┌───────────────────┐
  │  usp_RegistrarCompra  │
  └───────────────────┘
          ↓
  ┌─────────────────────────────────────┐
  │  1. Crea ORDEN_COMPRA               │
  │  2. Crea DETALLE_ORDEN_COMPRA       │
  │  3. Crea REMITO (automático)        │
  │  4. Crea DETALLE_REMITO             │
  │  5. Crea FACTURA (automático)       │
  │  6. Crea DETALLE_FACTURA            │
  └─────────────────────────────────────┘
          ↓
  Usuario ve en Remitos y Facturas
```

---

## ⚠️ TROUBLESHOOTING

### **No se ejecuta el .bat**

Si al hacer doble clic en `EJECUTAR_FIX_REMITOS_FACTURAS.bat` no funciona:
- Usa la **OPCIÓN B** (SQL Server Management Studio)

### **Error: "sqlcmd no se reconoce..."**

Significa que `sqlcmd` no está en el PATH:
- Usa la **OPCIÓN B** (SQL Server Management Studio)

### **Script ejecutado pero no veo remitos/facturas**

1. Verifica en SSMS:
   ```sql
   SELECT * FROM REMITO
   SELECT * FROM FACTURA
   ```

2. Si no hay registros, verifica que existan órdenes:
   ```sql
   SELECT * FROM ORDEN_COMPRA
   ```

3. Ejecuta manualmente el paso 3 del script:
   ```sql
   -- Copiar del script: "3. Generando Remitos y Facturas..."
   ```

### **Al crear orden nueva no se genera remito/factura**

1. Verifica que el SP se actualizó:
   ```sql
   EXEC sp_helptext 'usp_RegistrarCompra'
   ```
   - Deberías ver las secciones `-- 3. GENERAR REMITO` y `-- 4. GENERAR FACTURA`

2. Si no están, vuelve a ejecutar el script completo

---

## ✅ CHECKLIST FINAL

Después de ejecutar el fix, verifica:

- [ ] Script ejecutado sin errores
- [ ] Cantidades de órdenes = remitos = facturas
- [ ] Remitos tienen número formato `REM-YYYYMMDD-X`
- [ ] Facturas tienen número formato `FACT-YYYYMMDD-X`
- [ ] Al crear orden nueva, aparece en Remitos
- [ ] Al crear orden nueva, aparece en Facturas
- [ ] Remito tiene productos y cantidades correctos
- [ ] Factura tiene productos, cantidades y total correcto

---

## 🎉 RESULTADO ESPERADO

Después de aplicar el fix:

✅ **Órdenes existentes** tienen remito y factura (recuperados automáticamente)
✅ **Nuevas órdenes** generan remito y factura automáticamente
✅ **Remitos** muestran productos, cantidades, fecha
✅ **Facturas** muestran productos, cantidades, total
✅ **Estados** se pueden cambiar (En Espera → Recibido, Pendiente → Pagado)
✅ **Trazabilidad completa** Orden → Remito + Factura

---

**¿Problemas? Revisa el troubleshooting o pregunta.** 🚀
