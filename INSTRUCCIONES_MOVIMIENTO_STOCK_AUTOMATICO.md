# 🔧 Movimiento de Stock Automático al Recibir Remito

## 🎯 Funcionalidad Nueva

Cuando marcas un remito como **"Recibido"**, el sistema ahora:
1. ✅ Genera automáticamente movimientos de stock tipo **"Ingreso"**
2. ✅ Actualiza el stock en **PRODUCTO_TIENDA** 
3. ✅ Agrupa los movimientos con un **IdLote** único
4. ✅ Registra el usuario que recibió el remito
5. ✅ Asigna el motivo: "Recepción de Remito REM-XXXXX"

---

## 🚀 INSTALACIÓN (2 Pasos)

### **PASO 1: Ejecutar Script SQL**

#### **Opción A: Usar Batch (Recomendado)**

1. Doble clic en:
   ```
   EJECUTAR_FIX_MOVIMIENTO_STOCK.bat
   ```

2. Presiona **Enter** cuando te lo pida

3. Espera el mensaje: **"✅ CONFIGURACIÓN COMPLETADA"**

#### **Opción B: SQL Server Management Studio**

1. Abre **SQL Server Management Studio (SSMS)**
2. **File** → **Open** → **File...**
3. Selecciona: `scripts\FIX_REMITO_GENERA_MOVIMIENTO_STOCK.sql`
4. Presiona **F5** (Execute)

---

### **PASO 2: Recompilar la Aplicación**

1. Doble clic en:
   ```
   RECOMPILAR_Y_EJECUTAR.bat
   ```

2. Espera a que compile y ejecute

---

## 🧪 PROBAR LA FUNCIONALIDAD

### **1. Ir a Remitos**
- Menú: **Compras** → **Remitos**
- Verás los remitos con estado "En Espera" 🟡

### **2. Marcar como Recibido**
- Click en botón **"Marcar Recibido"** en un remito
- El estado cambia a **"Recibido"** ✅
- El sistema genera movimientos de stock automáticamente

### **3. Verificar Movimientos de Stock**
- Menú: **Reportes** → **Movimientos de Stock**
- Deberías ver nuevos movimientos con:
  - **Tipo:** Ingreso 🟢
  - **Motivo:** "Recepción de Remito REM-XXXXX"
  - **IdLote:** REMITO-X-YYYYMMDD
  - **Productos:** Los del remito con sus cantidades

### **4. Verificar Stock Actualizado**
- Menú: **Reportes** → **Productos por Tienda**
- Selecciona la tienda del remito
- El stock de los productos debe estar actualizado

---

## 📊 EJEMPLO DE FLUJO COMPLETO

```
1. CREAR ORDEN DE COMPRA
   ↓
   Usuario: Compras > Registrar Orden de Compra
   - Proveedor: BabyCare Distribuciones
   - Tienda: Tienda Principal
   - Productos: 
     * Conjunto pantalón (2 unidades)
     * Remera (3 unidades)
   ↓
   Se crean automáticamente:
   ✅ Orden de Compra #1
   ✅ Remito REM-20241016-1 (Estado: "En Espera")
   ✅ Factura FACT-20241016-1 (Estado: "Pendiente")

2. MARCAR REMITO COMO RECIBIDO
   ↓
   Usuario: Compras > Remitos
   - Click en "Marcar Recibido" en REM-20241016-1
   ↓
   Se generan automáticamente:
   ✅ Movimiento Stock: Conjunto pantalón (+2) - Ingreso
   ✅ Movimiento Stock: Remera (+3) - Ingreso
   ✅ IdLote: REMITO-1-20241016
   ✅ Motivo: "Recepción de Remito REM-20241016-1"

3. STOCK ACTUALIZADO
   ↓
   En PRODUCTO_TIENDA:
   ✅ Conjunto pantalón: Stock anterior + 2
   ✅ Remera: Stock anterior + 3
```

---

## 🔍 DETALLES TÉCNICOS

### **¿Qué hace el script SQL?**

1. **Modifica `usp_ActualizarEstadoRemito`:**
   - Detecta cuando el estado cambia a "Recibido"
   - Genera un IdLote único: `REMITO-{IdRemito}-{Fecha}`
   - Por cada producto del remito:
     - Verifica que esté asignado a la tienda
     - Si no existe, lo crea con stock 0
     - Llama a `usp_RegistrarMovimientoStock`
     - Registra ingreso y actualiza stock

2. **Usa el SP existente `usp_RegistrarMovimientoStock`:**
   - Valida stock disponible
   - Registra en tabla `MOVIMIENTO_STOCK`
   - Actualiza `PRODUCTO_TIENDA.Stock`

### **¿Qué hacen las modificaciones en C#?**

1. **`CD_Remito.cs`:**
   - Agrega parámetro `idUsuario` al método
   - Lo pasa al stored procedure

2. **`RemitoController.cs`:**
   - Obtiene usuario de la sesión
   - Valida que la sesión esté activa
   - Pasa el IdUsuario al método de capa de datos

---

## 📋 CAMPOS DE MOVIMIENTO DE STOCK

Cada movimiento generado contiene:

| Campo | Valor | Descripción |
|-------|-------|-------------|
| **IdTienda** | De la orden de compra | Tienda destino |
| **IdProducto** | Del detalle del remito | Producto recibido |
| **TipoMovimiento** | "Ingreso" | Siempre ingreso |
| **Cantidad** | Del detalle del remito | Unidades recibidas |
| **Motivo** | "Recepción de Remito REM-XXX" | Automático |
| **IdUsuario** | Usuario de la sesión | Quien marcó como recibido |
| **IdLote** | REMITO-{Id}-{Fecha} | Para agrupar |
| **FechaRegistro** | GETDATE() | Fecha/hora del registro |

---

## ⚠️ IMPORTANTE

### **Stock Inicial**
- Si un producto NO está en `PRODUCTO_TIENDA`, se crea automáticamente con stock 0
- Luego se hace el ingreso normalmente

### **Transacciones**
- Todo se maneja en una transacción
- Si falla un producto, se hace rollback completo
- Garantiza consistencia de datos

### **IdLote**
- Permite identificar qué movimientos corresponden al mismo remito
- Formato: `REMITO-{IdRemito}-{YYYYMMDD}`
- Ejemplo: `REMITO-1-20241016`

---

## ✅ VERIFICACIÓN

Después de aplicar el fix, verifica:

### **En Base de Datos:**

```sql
-- Ver movimientos generados por remitos
SELECT 
    m.IdLote,
    m.TipoMovimiento,
    p.Nombre AS Producto,
    m.Cantidad,
    m.Motivo,
    t.Nombre AS Tienda,
    u.Nombres AS Usuario,
    m.FechaRegistro
FROM MOVIMIENTO_STOCK m
INNER JOIN PRODUCTO p ON m.IdProducto = p.IdProducto
INNER JOIN TIENDA t ON m.IdTienda = t.IdTienda
INNER JOIN USUARIO u ON m.IdUsuario = u.IdUsuario
WHERE m.IdLote LIKE 'REMITO-%'
ORDER BY m.FechaRegistro DESC
```

### **En la Aplicación:**

- [ ] Remito se marca como "Recibido" ✅
- [ ] Aparecen movimientos en "Movimientos de Stock"
- [ ] Tipo de movimiento es "Ingreso" 🟢
- [ ] Motivo dice "Recepción de Remito REM-XXX"
- [ ] Todos los productos del remito están
- [ ] Cantidades coinciden con el remito
- [ ] Stock en "Productos por Tienda" actualizado
- [ ] IdLote agrupa los movimientos del mismo remito

---

## 🐛 TROUBLESHOOTING

### **No se generan movimientos al marcar recibido**

1. Verifica que el SP se actualizó:
   ```sql
   EXEC sp_helptext 'usp_ActualizarEstadoRemito'
   ```
   - Debe tener la sección de generación de movimientos

2. Verifica errores en SQL:
   - En SSMS, ejecuta manualmente el SP
   - Revisa mensajes de error

### **Error: "El producto no está asignado a esta tienda"**

- Esto NO debería pasar, el SP crea la asignación automáticamente
- Si pasa, verifica que exista `PRODUCTO_TIENDA`
- Ejecuta:
  ```sql
  SELECT * FROM PRODUCTO_TIENDA WHERE IdTienda = X
  ```

### **Stock no se actualiza**

1. Verifica en base de datos:
   ```sql
   SELECT * FROM PRODUCTO_TIENDA WHERE IdTienda = X
   ```

2. Verifica que `usp_RegistrarMovimientoStock` actualiza:
   ```sql
   EXEC sp_helptext 'usp_RegistrarMovimientoStock'
   ```

### **Error de sesión expirada**

- El usuario debe estar logueado
- Si pasa, vuelve a hacer login
- El sistema obtiene el usuario de `Session["Usuario"]`

---

## 🔄 FLUJO TÉCNICO COMPLETO

```
Usuario hace click en "Marcar Recibido"
          ↓
JavaScript llama AJAX al backend
          ↓
RemitoController.ActualizarEstado()
  - Obtiene usuario de sesión
  - Valida sesión activa
          ↓
CD_Remito.ActualizarEstadoRemito(idRemito, estado, idUsuario)
          ↓
SQL: usp_ActualizarEstadoRemito
  - BEGIN TRANSACTION
  - Obtiene datos del remito y orden
  - Actualiza estado → "Recibido"
  - Si es "Recibido":
    ┌─────────────────────────────────┐
    │ POR CADA PRODUCTO DEL REMITO:   │
    │ 1. Verificar PRODUCTO_TIENDA    │
    │ 2. Si no existe, crearlo        │
    │ 3. Llamar usp_RegistrarMovimientoStock │
    │    - Registra en MOVIMIENTO_STOCK │
    │    - Actualiza PRODUCTO_TIENDA.Stock │
    └─────────────────────────────────┘
  - COMMIT TRANSACTION
          ↓
JavaScript recibe respuesta
  - Actualiza UI (badge verde "Recibido")
  - Muestra mensaje de éxito
```

---

## 📝 ARCHIVOS MODIFICADOS

### **SQL:**
- 🆕 `scripts/FIX_REMITO_GENERA_MOVIMIENTO_STOCK.sql` - Script principal

### **C# Backend:**
- ✏️ `CapaDatos/CD_Remito.cs` - Agrega parámetro IdUsuario
- ✏️ `VentasWeb/Controllers/RemitoController.cs` - Obtiene usuario de sesión

### **Stored Procedures Afectados:**
- ✏️ `usp_ActualizarEstadoRemito` - Genera movimientos automáticamente
- ➡️ `usp_RegistrarMovimientoStock` - Usado por el SP anterior (sin cambios)

---

## 🎉 RESULTADO FINAL

Ahora tienes un sistema completamente automatizado:

✅ **Orden de Compra** → Genera automáticamente Remito + Factura
✅ **Marcar Remito Recibido** → Genera automáticamente Movimientos de Stock
✅ **Stock actualizado** → En tiempo real en PRODUCTO_TIENDA
✅ **Trazabilidad completa** → Orden → Remito → Movimientos → Stock
✅ **Auditoría** → Usuario y fecha de recepción registrados
✅ **Agrupación** → IdLote identifica movimientos del mismo remito

---

**¡Listo para usar!** 🚀

Si tienes problemas, revisa la sección de Troubleshooting o pregunta.
