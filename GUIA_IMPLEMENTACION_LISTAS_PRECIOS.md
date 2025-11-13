# Sistema de Listas de Precios con Vigencia

## Descripción General

Este sistema permite gestionar múltiples listas de precios (Mayorista, Minorista, Distribuidores, etc.) con productos vinculados que tienen precios específicos y fechas de vigencia.

## Características Principales

1. **Listas de Precios**:
   - Crear listas personalizadas (Mayorista, Minorista, Promoción, etc.)
   - Asignar a tiendas específicas o aplicar globalmente
   - Estado activo/inactivo

2. **Productos en Listas**:
   - Vincular productos con precios específicos
   - Definir vigencia (fecha desde - fecha hasta)
   - Control de solapamiento de fechas (no permite precios duplicados en mismas fechas)
   - Consulta de productos vigentes

3. **Consultas**:
   - Ver todas las listas de precios
   - Filtrar por tienda
   - Ver detalle de productos por lista
   - Filtrar productos vigentes

## Pasos de Implementación

### 1. Base de Datos

Ejecutar el script SQL:
```sql
Utilidad/SQL Server/031_SISTEMA_LISTAS_PRECIOS.sql
```

Este script crea:
- **Tabla LISTA_PRECIO**: Almacena las listas de precios
- **Tabla LISTA_PRECIO_DETALLE**: Vincula productos con precios y vigencia
- **9 Stored Procedures**: Para todas las operaciones CRUD

### 2. Modelos C# (Ya creados)

Archivos creados en `CapaModelo/`:
- `ListaPrecio.cs`
- `ListaPrecioDetalle.cs`

### 3. Capa de Datos (Ya creada)

Archivo creado en `CapaDatos/`:
- `CD_ListaPrecio.cs`

Métodos disponibles:
- `ObtenerListasPrecios()`
- `RegistrarListaPrecio()`
- `ModificarListaPrecio()`
- `ObtenerProductosListaPrecio()`
- `AgregarProductoListaPrecio()`
- `ModificarProductoListaPrecio()`
- `EliminarProductoListaPrecio()`
- `ObtenerPrecioProductoVigente()`
- `ObtenerProductosDisponiblesParaLista()`

### 4. Controlador Web (Ya creado)

Archivo creado en `VentasWeb/Controllers/`:
- `ListaPrecioController.cs`

### 5. Vistas (Ya creadas)

Archivos creados en `VentasWeb/Views/ListaPrecio/`:
- `Index.cshtml` - Lista principal de listas de precios
- `Detalle.cshtml` - Detalle de productos en una lista

### 6. JavaScript (Ya creado)

Archivos creados en `VentasWeb/Scripts/Views/`:
- `ListaPrecio_Index.js`
- `ListaPrecio_Detalle.js`

### 7. Agregar al Menú del Sistema

Ejecutar en SQL Server para agregar las opciones al menú:

```sql
USE DBVENTAS_WEB
GO

-- Agregar menú de Listas de Precios
DECLARE @IdMenu INT

-- Buscar o crear el menú "Administración"
IF NOT EXISTS (SELECT 1 FROM MENU WHERE Nombre = 'Administracion')
BEGIN
    INSERT INTO MENU (Nombre, Icono, Activo) VALUES ('Administracion', 'fa fa-cogs', 1)
END

SELECT @IdMenu = IdMenu FROM MENU WHERE Nombre = 'Administracion'

-- Agregar submenú para Listas de Precios
IF NOT EXISTS (SELECT 1 FROM SUBMENU WHERE Nombre = 'Listas de Precios')
BEGIN
    INSERT INTO SUBMENU (IdMenu, Nombre, Controlador, Vista, Icono, Activo)
    VALUES (@IdMenu, 'Listas de Precios', 'ListaPrecio', 'Index', 'fa fa-list-alt', 1)
    
    PRINT 'Submenú "Listas de Precios" creado exitosamente'
END
ELSE
BEGIN
    PRINT 'El submenú "Listas de Precios" ya existe'
END
GO
```

### 8. Asignar Permisos

Ejecutar para asignar permisos al rol de Administrador:

```sql
USE DBVENTAS_WEB
GO

DECLARE @IdRolAdmin INT
DECLARE @IdSubMenu INT

-- Obtener el ID del rol de administrador
SELECT @IdRolAdmin = IdRol FROM ROL WHERE Descripcion = 'Administrador'

-- Obtener el ID del submenú
SELECT @IdSubMenu = IdSubMenu FROM SUBMENU WHERE Nombre = 'Listas de Precios'

-- Asignar permiso si no existe
IF NOT EXISTS (SELECT 1 FROM PERMISOS WHERE IdRol = @IdRolAdmin AND IdSubMenu = @IdSubMenu)
BEGIN
    INSERT INTO PERMISOS (IdRol, IdSubMenu, Activo)
    VALUES (@IdRolAdmin, @IdSubMenu, 1)
    
    PRINT 'Permiso asignado al rol de Administrador'
END
ELSE
BEGIN
    PRINT 'El permiso ya existe'
END
GO
```

## Uso del Sistema

### Crear una Lista de Precios

1. Navegar a **Administración > Listas de Precios**
2. Clic en **"Nueva Lista de Precios"**
3. Completar el formulario:
   - **Nombre**: Ej. "Lista Mayorista 2025"
   - **Tipo**: Seleccionar (Mayorista, Minorista, etc.)
   - **Descripción**: Opcional
   - **Tienda**: Opcional (dejar vacío para aplicar a todas)
4. Guardar

### Agregar Productos a una Lista

1. En la tabla de listas, clic en el botón **"Ver Productos"** (icono de lista)
2. Clic en **"Agregar Producto"**
3. Seleccionar:
   - **Vigencia Desde/Hasta**: Fechas de validez del precio
   - **Producto**: De la lista desplegable (solo muestra productos disponibles)
   - **Precio de Venta**: Monto del precio
4. Guardar

### Consultar Precio Vigente

El sistema automáticamente:
- Valida que no existan precios duplicados en fechas solapadas
- Muestra badge "Vigente" para productos con precio actual
- Permite filtrar solo productos vigentes

### Editar Precios

1. En el detalle de la lista, clic en **"Editar"** (icono de lápiz)
2. Modificar precio, fechas o estado
3. Guardar

## Validaciones Implementadas

1. **No duplicidad de nombres**: No pueden existir dos listas con el mismo nombre para la misma tienda
2. **Fechas válidas**: La fecha de inicio debe ser menor o igual a la fecha de fin
3. **Precios positivos**: Los precios deben ser mayores a cero
4. **No solapamiento**: No pueden existir dos precios vigentes para el mismo producto en fechas que se solapen
5. **Productos activos**: Solo se pueden agregar productos activos a las listas

## API Endpoints

### Listas de Precios
- `GET /ListaPrecio/ObtenerListasPrecios` - Obtener todas las listas
- `POST /ListaPrecio/RegistrarListaPrecio` - Crear nueva lista
- `POST /ListaPrecio/ModificarListaPrecio` - Editar lista existente

### Productos en Listas
- `GET /ListaPrecio/ObtenerProductosListaPrecio` - Obtener productos de una lista
- `POST /ListaPrecio/AgregarProductoListaPrecio` - Agregar producto
- `POST /ListaPrecio/ModificarProductoListaPrecio` - Editar producto
- `POST /ListaPrecio/EliminarProductoListaPrecio` - Eliminar producto
- `GET /ListaPrecio/ObtenerPrecioProductoVigente` - Consultar precio vigente
- `GET /ListaPrecio/ObtenerProductosDisponibles` - Listar productos disponibles

## Estructura de Base de Datos

### LISTA_PRECIO
| Campo | Tipo | Descripción |
|-------|------|-------------|
| IdListaPrecio | INT | Primary Key |
| Nombre | VARCHAR(100) | Nombre de la lista |
| Descripcion | VARCHAR(500) | Descripción opcional |
| TipoLista | VARCHAR(50) | Tipo (Mayorista, Minorista, etc.) |
| IdTienda | INT | FK a TIENDA (nullable) |
| Activo | BIT | Estado |
| FechaRegistro | DATETIME | Fecha de creación |

### LISTA_PRECIO_DETALLE
| Campo | Tipo | Descripción |
|-------|------|-------------|
| IdListaPrecioDetalle | INT | Primary Key |
| IdListaPrecio | INT | FK a LISTA_PRECIO |
| IdProducto | INT | FK a PRODUCTO |
| PrecioVenta | DECIMAL(18,2) | Precio del producto |
| FechaVigenciaDesde | DATE | Inicio de vigencia |
| FechaVigenciaHasta | DATE | Fin de vigencia |
| Activo | BIT | Estado |
| FechaRegistro | DATETIME | Fecha de creación |

## Ejemplo de Uso Programático

### Obtener precio vigente de un producto

```csharp
using CapaDatos;

// Obtener precio vigente hoy
int idLista = 1; // Lista Mayorista
int idProducto = 10; // Producto específico
DateTime? fecha = DateTime.Now;

var detalle = CD_ListaPrecio.Instancia.ObtenerPrecioProductoVigente(idLista, idProducto, fecha);

if (detalle != null)
{
    decimal precioVigente = detalle.PrecioVenta;
    // Usar el precio...
}
```

### Crear una lista de precios desde código

```csharp
using CapaModelo;
using CapaDatos;

var nuevaLista = new ListaPrecio()
{
    Nombre = "Lista Mayorista 2025",
    Descripcion = "Lista de precios para clientes mayoristas",
    TipoLista = "Mayorista",
    IdTienda = null, // Aplica a todas las tiendas
    Activo = true
};

string mensaje;
bool resultado = CD_ListaPrecio.Instancia.RegistrarListaPrecio(nuevaLista, out mensaje);

if (resultado)
{
    // Lista creada exitosamente
}
```

## Soporte y Mantenimiento

Para cualquier consulta o mejora del sistema, revisar:
- Stored Procedures en SQL Server
- Logs de aplicación
- Validaciones en capa de datos

---

**Versión**: 1.0  
**Fecha**: 12/11/2024  
**Autor**: Sistema Mi_Bendi
