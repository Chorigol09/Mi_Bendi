# Modificaciones al Sistema de Movimientos de Stock

## Resumen
Se ha modificado el sistema de movimientos de stock para permitir diferentes tipos de movimientos utilizando una tabla **TIPO_MOV** en la base de datos. El tipo de movimiento ahora es fijo para todos los productos de un mismo registro (lote).

## Cambios Realizados

### 1. Base de Datos
- **Nueva tabla**: `TIPO_MOV` con los siguientes campos:
  - `IdTipoMov` (int, PK, Identity)
  - `Descripcion` (varchar(100)) - Nombre del tipo de movimiento
  - `TipoOperacion` (varchar(20)) - "Ingreso" o "Egreso"
  - `Activo` (bit)
  - `FechaRegistro` (datetime)

- **Modificación tabla MOVIMIENTO_STOCK**:
  - Se agregó el campo `IdTipoMov` (int) como Foreign Key a TIPO_MOV
  - Se mantiene `TipoMovimiento` para compatibilidad
  - Se mantiene `IdLote` para agrupar movimientos del mismo registro

### 2. Tipos de Movimiento Por Defecto
El script SQL inserta los siguientes tipos de movimiento:

**Ingresos:**
- Compra de mercadería
- Ajuste de inventario (suma)
- Devolución de cliente

**Egresos:**
- Venta de productos
- Ajuste de inventario (resta)
- Merma o pérdida
- Traslado a otra tienda

### 3. Modelos C#
- **Nuevo modelo**: `TipoMov.cs` en CapaModelo
- **Modificado**: `MovimientoStock.cs` - agregada propiedad `oTipoMov`

### 4. Capa de Datos
- **Nuevo**: `CD_TipoMov.cs` para obtener tipos de movimiento
- **Modificado**: `CD_MovimientoStock.cs` para:
  - Leer información de TipoMov al obtener movimientos
  - Registrar movimientos usando IdTipoMov

### 5. Controlador
- **Modificado**: `MovimientoStockController.cs`
  - Agregado método `ObtenerTiposMov()` para cargar tipos de movimiento
  - Modificada validación para usar `IdTipoMov` en lugar de `TipoMovimiento`

### 6. Vista y JavaScript
- **Vista**: El select de tipo de movimiento ahora carga desde la BD
- **JavaScript**: 
  - Carga tipos de movimiento al iniciar
  - El tipo de movimiento y la tienda se **deshabilitan** una vez que se agrega el primer producto
  - Valida que todos los productos del mismo registro tengan el mismo tipo de movimiento
  - Se vuelven a habilitar al eliminar todos los productos

## Instrucciones de Implementación

### Paso 1: Ejecutar Script SQL
```sql
-- Ejecutar el script en SQL Server Management Studio
-- Ubicación: scripts/Script_TIPO_MOV_Modificacion.sql
```

### Paso 2: Recompilar el Proyecto
1. Abrir la solución en Visual Studio
2. Limpiar solución (Build > Clean Solution)
3. Recompilar (Build > Rebuild Solution)

### Paso 3: Verificar las URLs en el archivo de rutas JavaScript
Asegúrate de que exista la URL para obtener tipos de movimiento en tu archivo de rutas:
```javascript
_ObtenerTiposMov: '@Url.Content("~/MovimientoStock/ObtenerTiposMov")'
```

## Funcionamiento

### Registrar Movimiento
1. Seleccionar **Tienda**
2. Seleccionar **Tipo de Movimiento** (cargado desde TIPO_MOV)
3. Ingresar **Motivo** (aplica a todos los productos)
4. Seleccionar **Producto** y agregar cantidad
5. Agregar más productos (mismo tipo de movimiento)
6. Registrar movimiento

**Importante**: 
- El tipo de movimiento se **fija** para todo el lote al agregar el primer producto
- No se puede cambiar hasta eliminar todos los productos
- Todos los productos del mismo registro compartirán:
  - Mismo IdLote
  - Mismo Tipo de Movimiento
  - Mismo Motivo

### Agregar Nuevos Tipos de Movimiento
Para agregar nuevos tipos de movimiento, ejecutar en la base de datos:
```sql
INSERT INTO TIPO_MOV (Descripcion, TipoOperacion, Activo)
VALUES ('Nuevo Tipo', 'Ingreso', 1) -- o 'Egreso'
```

## Beneficios
1. ✅ **Flexibilidad**: Agregar nuevos tipos de movimiento sin modificar código
2. ✅ **Consistencia**: Un solo tipo de movimiento por registro/lote
3. ✅ **Trazabilidad**: Mejor descripción de los movimientos
4. ✅ **Escalabilidad**: Fácil administración de tipos de movimiento
5. ✅ **Reportes**: Posibilidad de generar reportes por tipo específico de movimiento

## Archivos Modificados

### Scripts SQL
- `scripts/Script_TIPO_MOV_Modificacion.sql` ⭐ NUEVO

### Modelos (CapaModelo)
- `TipoMov.cs` ⭐ NUEVO
- `MovimientoStock.cs` (modificado)

### Capa de Datos (CapaDatos)
- `CD_TipoMov.cs` ⭐ NUEVO
- `CD_MovimientoStock.cs` (modificado)

### Controladores
- `MovimientoStockController.cs` (modificado)

### Vistas
- `Views/MovimientoStock/Crear.cshtml` (modificado)

### JavaScript
- `Scripts/Views/MovimientoStock_Crear.js` (modificado)

## Notas Importantes
- La columna `TipoMovimiento` se mantiene en la tabla por compatibilidad
- Los datos existentes se migran automáticamente al ejecutar el script
- El campo `IdLote` agrupa todos los movimientos registrados juntos
- El motivo es compartido por todos los productos del mismo lote

## Soporte
Si encuentras algún problema:
1. Verificar que el script SQL se ejecutó correctamente
2. Verificar que la solución se recompiló
3. Limpiar caché del navegador (Ctrl+F5)
4. Revisar la consola del navegador para errores JavaScript
