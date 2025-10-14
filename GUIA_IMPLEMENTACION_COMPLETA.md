# 🚀 GUÍA COMPLETA DE IMPLEMENTACIÓN
## Sistema de Orden de Compra, Remitos y Facturas

---

## ✅ ERRORES CORREGIDOS

### 1. **Error 500 - Actualización de Stock y Precio** ✓ RESUELTO
- **Ubicación**: `ProductoController.cs`
- **Solución**: Cambio de HttpStatusCodeResult a JsonResult con manejo de errores
- **Métodos corregidos**:
  - `AjustarStock()`
  - `ActualizarPrecioVenta()`

### 2. **Error "No se encuentra el Recurso" en Reporte/Ventas** ✓ RESUELTO
- **Ubicación**: `ReportesController.cs`
- **Solución**: Agregado método `Ventas()` y `ObtenerVenta()`

### 3. **Precio de Venta eliminado de Registro de Compras** ✓ COMPLETADO
- Vista y JavaScript actualizados para remover campo de precio de venta

---

## 📊 ARCHIVOS YA CREADOS

### Modelos (CapaModelo) ✓
- `Remito.cs`
- `DetalleRemito.cs`
- `Factura.cs`
- `DetalleFactura.cs`
- `Compra.cs` (actualizado con campo Estado)

### Capas de Datos (CapaDatos) ✓
- `CD_Remito.cs`
- `CD_Factura.cs`

### Scripts SQL ✓
- `004_MEJORAS_SISTEMA_OC_REMITOS_FACTURAS.sql`

---

## 📋 PASOS DE IMPLEMENTACIÓN RESTANTES

### **PASO 1: Ejecutar Script SQL**

```sql
-- Ejecutar en SQL Server Management Studio
USE DBVENTAS_WEB
GO

-- Ejecutar el archivo:
-- 004_MEJORAS_SISTEMA_OC_REMITOS_FACTURAS.sql
```

Este script:
- Renombra COMPRA a ORDEN_COMPRA
- Agrega campo Estado a ORDEN_COMPRA
- Crea tablas REMITO, DETALLE_REMITO, FACTURA, DETALLE_FACTURA
- Agrega campo PrecioVenta a PRODUCTO

---

### **PASO 2: Crear Stored Procedures**

Crear archivo: `005_STORED_PROCEDURES_REMITOS_FACTURAS.sql`

```sql
USE DBVENTAS_WEB
GO

-- ========== PROCEDIMIENTOS PARA REMITOS ==========

-- Obtener todos los remitos
CREATE OR ALTER PROCEDURE usp_ObtenerRemitos
AS
BEGIN
    SELECT 
        r.IdRemito,
        r.IdOrdenCompra,
        r.IdProveedor,
        p.RazonSocial,
        r.NumeroRemito,
        r.Estado,
        r.Observaciones,
        r.Activo,
        r.FechaRegistro,
        r.FechaRecepcion
    FROM REMITO r
    INNER JOIN PROVEEDOR p ON r.IdProveedor = p.IdProveedor
    WHERE r.Activo = 1
    ORDER BY r.FechaRegistro DESC
END
GO

-- Registrar remito
CREATE OR ALTER PROCEDURE usp_RegistrarRemito
    @IdOrdenCompra INT,
    @IdProveedor INT,
    @NumeroRemito VARCHAR(50),
    @Observaciones VARCHAR(500),
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    BEGIN TRY
        INSERT INTO REMITO (IdOrdenCompra, IdProveedor, NumeroRemito, Observaciones, Estado)
        VALUES (@IdOrdenCompra, @IdProveedor, @NumeroRemito, @Observaciones, 'En Espera')
        
        SET @Resultado = 1
    END TRY
    BEGIN CATCH
        SET @Resultado = 0
    END CATCH
END
GO

-- Actualizar estado de remito
CREATE OR ALTER PROCEDURE usp_ActualizarEstadoRemito
    @IdRemito INT,
    @Estado VARCHAR(20),
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    BEGIN TRY
        UPDATE REMITO 
        SET Estado = @Estado,
            FechaRecepcion = CASE WHEN @Estado = 'Recibido' THEN GETDATE() ELSE FechaRecepcion END
        WHERE IdRemito = @IdRemito
        
        SET @Resultado = 1
    END TRY
    BEGIN CATCH
        SET @Resultado = 0
    END CATCH
END
GO

-- ========== PROCEDIMIENTOS PARA FACTURAS ==========

-- Obtener todas las facturas
CREATE OR ALTER PROCEDURE usp_ObtenerFacturas
AS
BEGIN
    SELECT 
        f.IdFactura,
        f.IdOrdenCompra,
        f.IdProveedor,
        p.RazonSocial,
        f.NumeroFactura,
        f.Total,
        f.Estado,
        f.Observaciones,
        f.Activo,
        f.FechaEmision,
        f.FechaPago
    FROM FACTURA f
    INNER JOIN PROVEEDOR p ON f.IdProveedor = p.IdProveedor
    WHERE f.Activo = 1
    ORDER BY f.FechaEmision DESC
END
GO

-- Registrar factura
CREATE OR ALTER PROCEDURE usp_RegistrarFactura
    @IdOrdenCompra INT,
    @IdProveedor INT,
    @NumeroFactura VARCHAR(50),
    @Total DECIMAL(18,2),
    @Observaciones VARCHAR(500),
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    BEGIN TRY
        INSERT INTO FACTURA (IdOrdenCompra, IdProveedor, NumeroFactura, Total, Observaciones, Estado)
        VALUES (@IdOrdenCompra, @IdProveedor, @NumeroFactura, @Total, @Observaciones, 'Pendiente')
        
        SET @Resultado = 1
    END TRY
    BEGIN CATCH
        SET @Resultado = 0
    END CATCH
END
GO

-- Actualizar estado de factura
CREATE OR ALTER PROCEDURE usp_ActualizarEstadoFactura
    @IdFactura INT,
    @Estado VARCHAR(20),
    @Resultado BIT OUTPUT
AS
BEGIN
    SET @Resultado = 0
    BEGIN TRY
        UPDATE FACTURA 
        SET Estado = @Estado,
            FechaPago = CASE WHEN @Estado = 'Pagado' THEN GETDATE() ELSE FechaPago END
        WHERE IdFactura = @IdFactura
        
        SET @Resultado = 1
    END TRY
    BEGIN CATCH
        SET @Resultado = 0
    END CATCH
END
GO

-- ========== ACTUALIZAR PROCEDIMIENTO DE ORDEN DE COMPRA ==========

-- Modificar usp_RegistrarCompra para NO incrementar stock
CREATE OR ALTER PROCEDURE usp_RegistrarCompra
@Detalle [XML]
AS
BEGIN
    BEGIN TRY
        DECLARE @IdCompra INT = 0
        DECLARE @IdUsuario INT = 0
        DECLARE @IdProveedor INT = 0
        DECLARE @IdTienda INT = 0
        DECLARE @TotalCosto DECIMAL(18,2) = 0

        -- Extraer datos del XML
        DECLARE @datos TABLE(
            IdProducto INT,
            Cantidad INT,
            PrecioUnidadCompra DECIMAL(18,2),
            PrecioUnidadVenta DECIMAL(18,2),
            TotalCosto DECIMAL(18,2)
        )

        INSERT INTO @datos
        SELECT 
            T.Item.value('IdProducto[1]', 'INT'),
            T.Item.value('Cantidad[1]', 'INT'),
            T.Item.value('PrecioUnidadCompra[1]', 'DECIMAL(18,2)'),
            T.Item.value('PrecioUnidadVenta[1]', 'DECIMAL(18,2)'),
            T.Item.value('TotalCosto[1]', 'DECIMAL(18,2)')
        FROM @Detalle.nodes('DETALLE/DETALLE_COMPRA/DETALLE') AS T(Item)

        SELECT 
            @IdUsuario = T.Item.value('IdUsuario[1]', 'INT'),
            @IdProveedor = T.Item.value('IdProveedor[1]', 'INT'),
            @IdTienda = T.Item.value('IdTienda[1]', 'INT'),
            @TotalCosto = T.Item.value('TotalCosto[1]', 'DECIMAL(18,2)')
        FROM @Detalle.nodes('DETALLE/COMPRA') AS T(Item)

        BEGIN TRANSACTION REGISTRAR

        -- Insertar Orden de Compra (sin modificar stock)
        INSERT INTO ORDEN_COMPRA(IdUsuario, IdProveedor, IdTienda, TotalCosto, Estado)
        VALUES(@IdUsuario, @IdProveedor, @IdTienda, @TotalCosto, 'Abierta')

        SET @IdCompra = SCOPE_IDENTITY()

        -- Insertar Detalle
        INSERT INTO DETALLE_ORDEN_COMPRA(IdOrdenCompra, IdProducto, Cantidad, PrecioUnitarioCompra, PrecioUnitarioVenta, TotalCosto)
        SELECT @IdCompra, IdProducto, Cantidad, PrecioUnidadCompra, PrecioUnidadVenta, TotalCosto FROM @datos

        COMMIT TRANSACTION REGISTRAR

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION REGISTRAR
    END CATCH
END
GO

-- Actualizar lista de compras para mostrar Estado
CREATE OR ALTER PROCEDURE usp_ObtenerListaCompra
    @FechaInicio DATE,
    @FechaFin DATE,
    @IdProveedor INT,
    @IdTienda INT
AS
BEGIN
    SELECT 
        oc.IdCompra,
        CONVERT(VARCHAR(10), oc.FechaRegistro, 103) AS NumeroCompra,
        p.RazonSocial,
        t.Nombre,
        CONVERT(VARCHAR(10), oc.FechaRegistro, 103) AS FechaCompra,
        oc.TotalCosto,
        oc.Estado
    FROM ORDEN_COMPRA oc
    INNER JOIN PROVEEDOR p ON oc.IdProveedor = p.IdProveedor
    INNER JOIN TIENDA t ON oc.IdTienda = t.IdTienda
    WHERE 
        CONVERT(DATE, oc.FechaRegistro) BETWEEN @FechaInicio AND @FechaFin
        AND (@IdProveedor = 0 OR oc.IdProveedor = @IdProveedor)
        AND (@IdTienda = 0 OR oc.IdTienda = @IdTienda)
        AND oc.Activo = 1
    ORDER BY oc.FechaRegistro DESC
END
GO

PRINT 'Stored Procedures creados correctamente'
```

---

### **PASO 3: Crear Controladores**

#### `RemitoController.cs`
Ubicación: `VentasWeb/Controllers/RemitoController.cs`

```csharp
using CapaDatos;
using CapaModelo;
using System;
using System.Collections.Generic;
using System.Web.Mvc;

namespace VentasWeb.Controllers
{
    public class RemitoController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public JsonResult Obtener()
        {
            List<Remito> lista = CD_Remito.Instancia.ObtenerRemitos();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult Guardar(Remito objeto)
        {
            bool respuesta = CD_Remito.Instancia.RegistrarRemito(objeto);
            return Json(new { resultado = respuesta }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult ActualizarEstado(int idRemito, string estado)
        {
            bool respuesta = CD_Remito.Instancia.ActualizarEstadoRemito(idRemito, estado);
            return Json(new { resultado = respuesta }, JsonRequestBehavior.AllowGet);
        }
    }
}
```

#### `FacturaController.cs`
Ubicación: `VentasWeb/Controllers/FacturaController.cs`

```csharp
using CapaDatos;
using CapaModelo;
using System;
using System.Collections.Generic;
using System.Web.Mvc;

namespace VentasWeb.Controllers
{
    public class FacturaController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public JsonResult Obtener()
        {
            List<Factura> lista = CD_Factura.Instancia.ObtenerFacturas();
            return Json(new { data = lista }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult Guardar(Factura objeto)
        {
            bool respuesta = CD_Factura.Instancia.RegistrarFactura(objeto);
            return Json(new { resultado = respuesta }, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public JsonResult ActualizarEstado(int idFactura, string estado)
        {
            bool respuesta = CD_Factura.Instancia.ActualizarEstadoFactura(idFactura, estado);
            return Json(new { resultado = respuesta }, JsonRequestBehavior.AllowGet);
        }
    }
}
```

---

### **PASO 4: Actualizar _Layout.cshtml**

Agregar las URLs de Remito y Factura después de la línea 157:

```javascript
//CONTROLADOR REMITO
$.MisUrls.urls({ _ObtenerRemitos: '@Url.Action("Obtener", "Remito")' });
$.MisUrls.urls({ _GuardarRemito: '@Url.Action("Guardar", "Remito")' });
$.MisUrls.urls({ _ActualizarEstadoRemito: '@Url.Action("ActualizarEstado", "Remito")' });

//CONTROLADOR FACTURA
$.MisUrls.urls({ _ObtenerFacturas: '@Url.Action("Obtener", "Factura")' });
$.MisUrls.urls({ _GuardarFactura: '@Url.Action("Guardar", "Factura")' });
$.MisUrls.urls({ _ActualizarEstadoFactura: '@Url.Action("ActualizarEstado", "Factura")' });

//CONTROLADOR ORDEN DE COMPRA  
$.MisUrls.urls({ _ObtenerOrdenesCompra: '@Url.Action("Obtener", "Compra")' });
```

---

### **PASO 5: Actualizar Base de Datos con Menús**

```sql
-- Insertar nuevos menús y submenús
USE DBVENTAS_WEB
GO

-- Verificar si existe el menú de Remitos
IF NOT EXISTS (SELECT * FROM SUBMENU WHERE Nombre = 'Remitos')
BEGIN
    -- Obtener el IdMenu de Compras o crear uno nuevo
    DECLARE @IdMenuCompras INT
    SELECT @IdMenuCompras = IdMenu FROM MENU WHERE Nombre = 'Compras'
    
    IF @IdMenuCompras IS NULL
    BEGIN
        INSERT INTO MENU (Nombre, Icono) VALUES ('Compras', 'fas fa-shopping-cart')
        SET @IdMenuCompras = SCOPE_IDENTITY()
    END

    -- Insertar submenú Remitos
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono)
    VALUES (@IdMenuCompras, 'Remitos', 'Remito', 'Index', 'fas fa-file-invoice')

    -- Insertar submenú Facturas
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono)
    VALUES (@IdMenuCompras, 'Facturas', 'Factura', 'Index', 'fas fa-file-invoice-dollar')
END
GO

-- Actualizar nombre de Compras a Orden de Compra
UPDATE SUBMENU SET Nombre = 'Registrar Orden de Compra' WHERE Nombre = 'Registrar Compra'
UPDATE SUBMENU SET Nombre = 'Consultar Ordenes de Compra' WHERE Nombre = 'Consultar Compras'
GO
```

---

### **PASO 6: Renombrar archivos de Compra**

1. **Renombrar vistas**:
   - `Views/Compra/Crear.cshtml` → Cambiar título a "Registrar Orden de Compra"
   - `Views/Compra/Consultar.cshtml` → Cambiar título a "Consultar Órdenes de Compra"

2. **Actualizar CD_Compra.cs**:
   - Agregar método para actualizar Estado de Orden de Compra

```csharp
// Agregar a CD_Compra.cs
public bool ActualizarEstadoOrdenCompra(int idCompra, string estado)
{
    bool respuesta = false;
    using (SqlConnection oConexion = new SqlConnection(Conexion.CN))
    {
        try
        {
            SqlCommand cmd = new SqlCommand("UPDATE ORDEN_COMPRA SET Estado = @Estado WHERE IdCompra = @Id", oConexion);
            cmd.Parameters.AddWithValue("@Estado", estado);
            cmd.Parameters.AddWithValue("@Id", idCompra);
            
            oConexion.Open();
            respuesta = cmd.ExecuteNonQuery() > 0;
        }
        catch
        {
            respuesta = false;
        }
    }
    return respuesta;
}
```

---

### **PASO 7: Actualizar Compra_Consultar.cshtml**

Agregar columna Estado y botón para cambiar estado:

```html
<!-- En la tabla, agregar columna -->
<th>Estado</th>

<!-- En el DataTable columns -->
{ 
    "data": "Estado",
    "render": function (data, type, row) {
        var badgeClass = data == 'Abierta' ? 'badge-warning' : 'badge-success';
        return '<span class="badge ' + badgeClass + '">' + data + '</span>';
    }
},
{
    "data": null,
    "render": function (data, type, row) {
        if (row.Estado == 'Abierta') {
            return '<button class="btn btn-sm btn-success btn-cerrar-oc" data-id="' + row.IdCompra + '">Cerrar OC</button>';
        }
        return '';
    },
    "orderable": false
}
```

---

## 📝 RESUMEN DE FLUJO DE TRABAJO

### **Flujo Completo del Sistema:**

1. **Registrar Orden de Compra** (NO incrementa stock)
   - Se crea con Estado = "Abierta"
   - Solo registra la intención de compra

2. **Crear Remito** (asociado a Orden de Compra)
   - Estado inicial: "En Espera"
   - Cambiar a "Recibido" cuando llega mercadería

3. **Crear Factura** (asociada a Orden de Compra)
   - Estado inicial: "Pendiente"
   - Cambiar a "Pagado" cuando se paga

4. **Actualizar Stock Manualmente**
   - Ir a Reportes > Productos por Tienda
   - Usar flechas ↑↓ para ajustar stock

5. **Cerrar Orden de Compra**
   - Una vez todo procesado, cambiar Estado a "Cerrada"

---

## ⚠️ IMPORTANTE

- **Ejecutar scripts SQL en orden**:
  1. `004_MEJORAS_SISTEMA_OC_REMITOS_FACTURAS.sql`
  2. `005_STORED_PROCEDURES_REMITOS_FACTURAS.sql`
  3. Script de actualización de menús

- **Recompilar el proyecto** después de agregar los nuevos archivos .cs

- **Las vistas completas de Remito y Factura** pueden basarse en las vistas de Compra existentes

---

## 🎯 ESTADO ACTUAL

✅ **COMPLETADO**:
- Error 500 corregido
- Error de Reporte/Ventas corregido
- Modelos creados
- Capas de datos creadas
- Script SQL principal creado
- Guía de implementación completa

⏳ **PENDIENTE (Usuario debe completar)**:
- Ejecutar scripts SQL
- Crear controladores Remito y Factura
- Crear vistas para Remito y Factura (pueden basarse en las vistas de Compra)
- Actualizar menús en base de datos
- Probar el flujo completo

---

**¡Sistema listo para implementación completa!**
