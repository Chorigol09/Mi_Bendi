# Guía de Integración - Listas de Precios en Ventas

## 📋 Descripción General

Se ha integrado el sistema de listas de precios en el módulo de ventas. Ahora, al registrar una venta:

1. **Se selecciona primero una lista de precios** (obligatorio)
2. **Los precios se obtienen automáticamente** de la lista seleccionada
3. **No se permite editar el precio manualmente** (solo lectura)
4. **Cada venta queda vinculada** a la lista de precios utilizada

---

## 🔧 Cambios Realizados

### 1. Base de Datos

**Archivo:** `035_AGREGAR_LISTA_PRECIO_VENTA.sql`

**Cambios en tabla VENTA:**
- ✅ Columna `IdListaPrecio` (INT, FK a LISTA_PRECIO)
- ✅ Columna `MetodoPago` (VARCHAR(50))
- ✅ Índice `IX_VENTA_IdListaPrecio` para optimizar consultas

**Stored Procedure actualizado:**
- ✅ `usp_RegistrarVenta` - Ahora recibe y guarda `IdListaPrecio`
- ✅ Valida que la lista de precios esté activa
- ✅ Maneja métodos de pago (Efectivo, Tarjeta, Transferencia)

### 2. Backend (C#)

#### Modelos (CapaModelo)

**Archivo:** `Venta.cs`
```csharp
public int IdListaPrecio { get; set; }
public ListaPrecio oListaPrecio { get; set; }
```

#### Controlador

**Archivo:** `ListaPrecioController.cs`

**Nuevos métodos:**

1. **ObtenerListasPreciosActivas()**
   - Retorna todas las listas de precios activas
   - URL: `/ListaPrecio/ObtenerListasPreciosActivas`

2. **ObtenerPrecioProductoVigente(int idListaPrecio, int idProducto)**
   - Retorna el precio vigente de un producto según la lista
   - URL: `/ListaPrecio/ObtenerPrecioProductoVigente?idListaPrecio=X&idProducto=Y`

### 3. Frontend

#### Vista

**Archivo:** `Views/Venta/Crear.cshtml`

**Cambios:**
- ✅ Agregado selector de lista de precios (primer campo)
- ✅ Campo `#cboListaPrecio` con opciones dinámicas

#### JavaScript

**Archivo:** `Scripts/Views/Venta_Crear.js`

**Nuevas funciones:**

1. **`cargarListasPrecios()`**
   - Carga las listas de precios activas al iniciar
   - Llena el combo `#cboListaPrecio`

2. **`obtenerPrecioProducto(idListaPrecio, idProducto)`**
   - Obtiene el precio vigente del producto
   - Actualiza el campo `#txtproductoprecio` automáticamente

**Validaciones agregadas:**
- ✅ Debe seleccionar lista de precios antes de agregar productos
- ✅ Al cambiar de lista, advierte si hay productos agregados
- ✅ Al buscar producto por código, valida lista seleccionada
- ✅ Al seleccionar producto del modal, valida lista seleccionada

**XML de venta actualizado:**
```xml
<VENTA>
    ...
    <IdListaPrecio>X</IdListaPrecio>
    ...
</VENTA>
```

---

## 🚀 Pasos de Instalación

### 1. Ejecutar Script SQL

```sql
-- En SQL Server Management Studio
-- Conectarse a la base de datos DBVENTAS_WEB

-- Ejecutar el script
USE DBVENTAS_WEB
GO

-- Ejecutar el archivo completo
-- Ruta: Utilidad\SQL Server\035_AGREGAR_LISTA_PRECIO_VENTA.sql
```

**Verificar que se ejecutó correctamente:**
```sql
-- Verificar columna agregada
SELECT TOP 1 IdListaPrecio, MetodoPago 
FROM VENTA

-- Verificar SP actualizado
EXEC sp_helptext 'usp_RegistrarVenta'
```

### 2. Recompilar Proyecto

1. Abrir Visual Studio
2. Abrir solución `Mi_Bendi.sln`
3. **Compilar** > **Recompilar solución** (Ctrl + Shift + B)
4. Verificar que no haya errores de compilación

### 3. Ejecutar y Probar

1. Ejecutar el proyecto (F5)
2. Navegar a **Ventas** > **Registrar Venta**
3. Verificar que aparece el selector de lista de precios

---

## ✅ Flujo de Uso

### Proceso de Venta con Lista de Precios

1. **Seleccionar Lista de Precios** (primer paso, obligatorio)
   - Se muestran solo listas activas
   - Formato: "Nombre (Tipo)"
   - Ejemplo: "Lista Mayorista 2024 (Mayorista)"

2. **Seleccionar Producto**
   - Por código o búsqueda
   - El precio se obtiene automáticamente de la lista seleccionada

3. **Agregar Cantidad**
   - El campo precio está en modo solo lectura
   - Solo se puede editar la cantidad

4. **Agregar a la Venta**
   - El producto se agrega con el precio de la lista

5. **Finalizar Venta**
   - La venta queda vinculada a la lista de precios utilizada

### Validaciones

**Al intentar agregar producto SIN lista seleccionada:**
```
❌ "Debe seleccionar una lista de precios"
```

**Al cambiar lista CON productos en la venta:**
```
⚠️ "Al cambiar la lista de precios se borrarán los productos agregados. ¿Desea continuar?"
```

**Si el producto no tiene precio en la lista:**
```
⚠️ "El producto no tiene precio en la lista seleccionada"
Precio: $0,00
```

---

## 📊 Estructura de Datos

### Tabla VENTA (actualizada)

```sql
CREATE TABLE VENTA (
    IdVenta INT PRIMARY KEY IDENTITY(1,1),
    Codigo VARCHAR(100),
    ValorCodigo INT,
    IdTienda INT,
    IdUsuario INT,
    IdCliente INT,
    IdListaPrecio INT,          -- ⭐ NUEVO
    TipoDocumento VARCHAR(50),
    MetodoPago VARCHAR(50),      -- ⭐ NUEVO
    CantidadProducto INT,
    CantidadTotal INT,
    TotalCosto DECIMAL(18,2),
    ImporteRecibido DECIMAL(18,2),
    ImporteCambio DECIMAL(18,2),
    Activo BIT DEFAULT 1,
    FechaRegistro DATETIME DEFAULT GETDATE()
)
```

### Relación con Listas de Precios

```
VENTA (N) ──────► (1) LISTA_PRECIO
  │
  │ IdListaPrecio (FK)
  │
  └─► Cada venta usa UNA lista de precios
      Los productos se precian según esa lista
```

---

## 🔍 Consultas Útiles

### Ventas por Lista de Precios

```sql
-- Ver ventas agrupadas por lista de precios
SELECT 
    LP.Nombre AS ListaPrecio,
    LP.TipoLista,
    COUNT(V.IdVenta) AS TotalVentas,
    SUM(V.TotalCosto) AS MontoTotal,
    AVG(V.TotalCosto) AS PromedioVenta
FROM VENTA V
INNER JOIN LISTA_PRECIO LP ON V.IdListaPrecio = LP.IdListaPrecio
WHERE V.Activo = 1
    AND V.FechaRegistro >= DATEADD(MONTH, -1, GETDATE())
GROUP BY LP.Nombre, LP.TipoLista
ORDER BY MontoTotal DESC
```

### Detalle de una Venta con su Lista

```sql
-- Ver detalle completo de una venta
SELECT 
    V.Codigo,
    V.FechaRegistro,
    LP.Nombre AS ListaPrecio,
    LP.TipoLista,
    C.Nombre AS Cliente,
    V.TotalCosto,
    V.MetodoPago
FROM VENTA V
INNER JOIN LISTA_PRECIO LP ON V.IdListaPrecio = LP.IdListaPrecio
INNER JOIN CLIENTE C ON V.IdCliente = C.IdCliente
WHERE V.IdVenta = 123 -- Cambiar por ID de venta
```

### Productos más vendidos por Lista

```sql
-- Top 10 productos por lista de precios
SELECT 
    LP.Nombre AS ListaPrecio,
    P.Nombre AS Producto,
    COUNT(DV.IdDetalleVenta) AS CantidadVentas,
    SUM(DV.Cantidad) AS UnidadesVendidas,
    SUM(DV.ImporteTotal) AS MontoTotal
FROM DETALLE_VENTA DV
INNER JOIN VENTA V ON DV.IdVenta = V.IdVenta
INNER JOIN LISTA_PRECIO LP ON V.IdListaPrecio = LP.IdListaPrecio
INNER JOIN PRODUCTO P ON DV.IdProducto = P.IdProducto
WHERE V.Activo = 1
    AND V.FechaRegistro >= DATEADD(MONTH, -1, GETDATE())
GROUP BY LP.Nombre, P.Nombre
ORDER BY MontoTotal DESC
```

---

## 🐛 Solución de Problemas

### Problema 1: No aparecen listas de precios

**Síntoma:** El selector está vacío

**Solución:**
```sql
-- Verificar que existan listas activas
SELECT * FROM LISTA_PRECIO WHERE Activo = 1

-- Si no hay, ejecutar script de datos de prueba
-- 033_DATOS_PRUEBA_LISTAS_PRECIOS.sql
```

### Problema 2: Producto sin precio

**Síntoma:** Precio aparece en $0,00

**Solución:**
```sql
-- Verificar que el producto esté en la lista
SELECT * 
FROM LISTA_PRECIO_DETALLE LPD
WHERE LPD.IdListaPrecio = X  -- ID de lista
  AND LPD.IdProducto = Y      -- ID de producto
  AND LPD.Activo = 1
  AND GETDATE() BETWEEN LPD.FechaDesde AND LPD.FechaHasta

-- Si no existe, agregar el producto a la lista desde
-- Administración > Listas de Precios > Detalle
```

### Problema 3: Error al guardar venta

**Síntoma:** "No se pudo registrar la venta"

**Verificaciones:**
```sql
-- 1. Verificar que la columna exista
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'VENTA' AND COLUMN_NAME = 'IdListaPrecio'

-- 2. Verificar que el SP esté actualizado
EXEC sp_helptext 'usp_RegistrarVenta'

-- 3. Verificar log de errores (si aplica)
```

---

## 📝 Notas Importantes

### Compatibilidad

- ✅ **Ventas antiguas:** Las ventas existentes tendrán `IdListaPrecio = NULL`
- ✅ **Reportes:** Los reportes existentes seguirán funcionando
- ⚠️ **Obligatoriedad:** Las nuevas ventas DEBEN tener una lista de precios

### Migración de Datos

Si deseas asociar ventas antiguas a una lista:

```sql
-- Crear una lista "Precios Históricos" para ventas antiguas
INSERT INTO LISTA_PRECIO (Nombre, Descripcion, TipoLista, Activo)
VALUES ('Precios Históricos', 'Lista para ventas realizadas antes del sistema de listas', 'General', 1)

DECLARE @IdListaHistorica INT = SCOPE_IDENTITY()

-- Asociar ventas antiguas
UPDATE VENTA 
SET IdListaPrecio = @IdListaHistorica
WHERE IdListaPrecio IS NULL
```

### Mantenimiento

- 📅 **Revisar listas activas** mensualmente
- 🔄 **Actualizar precios** según vigencias
- 📊 **Analizar ventas por lista** para decisiones comerciales

---

## 📚 Archivos Modificados

### SQL
- ✅ `035_AGREGAR_LISTA_PRECIO_VENTA.sql` (NUEVO)

### Backend
- ✅ `CapaModelo/Venta.cs` (Modificado)
- ✅ `VentasWeb/Controllers/ListaPrecioController.cs` (Modificado)

### Frontend
- ✅ `VentasWeb/Views/Venta/Crear.cshtml` (Modificado)
- ✅ `VentasWeb/Scripts/Views/Venta_Crear.js` (Modificado)

---

## ✨ Características Implementadas

- [x] Selector de lista de precios en ventas
- [x] Carga dinámica de listas activas
- [x] Obtención automática de precios
- [x] Validación de lista obligatoria
- [x] Campo precio en solo lectura
- [x] Vinculación venta-lista en BD
- [x] Validación de lista activa
- [x] Manejo de productos sin precio
- [x] Advertencia al cambiar lista
- [x] Actualización de stored procedure
- [x] Índice de optimización
- [x] Documentación completa

---

## 🎯 Próximos Pasos Sugeridos

1. **Reportes:**
   - Crear reporte de ventas por lista de precios
   - Análisis de margen por lista

2. **Dashboard:**
   - Gráfico de ventas por tipo de lista
   - Top productos por lista

3. **Auditoría:**
   - Log de cambios de precio en listas
   - Historial de precios por producto

---

**Fecha de implementación:** 12/11/2024  
**Versión:** 1.0  
**Estado:** ✅ Implementado y listo para producción
