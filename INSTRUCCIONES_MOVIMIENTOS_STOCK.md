# Sistema de Movimientos de Stock

## Descripción
Se ha implementado un sistema completo para gestionar movimientos de stock por tienda. El sistema permite:

- ✅ Registrar ingresos de stock (aumenta el inventario)
- ✅ Registrar egresos de stock (disminuye el inventario)
- ✅ Seleccionar la tienda donde se realiza el movimiento
- ✅ Validar que no se genere stock negativo
- ✅ Ver historial de movimientos filtrado por tienda
- ✅ Actualizar automáticamente el stock de la tienda y el stock general del producto

## Archivos Creados

### Backend (C#)
1. **CapaModelo/MovimientoStock.cs** - Modelo de datos
2. **CapaDatos/CD_MovimientoStock.cs** - Capa de acceso a datos
3. **VentasWeb/Controllers/MovimientoStockController.cs** - Controlador MVC

### Frontend
4. **VentasWeb/Views/MovimientoStock/Crear.cshtml** - Vista principal
5. **VentasWeb/Scripts/Views/MovimientoStock_Crear.js** - Lógica JavaScript

### Base de Datos
6. **scripts/Script_MovimientoStock.sql** - Script SQL para crear tabla y stored procedures

## Instalación

### Paso 1: Ejecutar el Script de Base de Datos

Abre SQL Server Management Studio y ejecuta el archivo:
```
scripts/Script_MovimientoStock.sql
```

Este script creará:
- Tabla `MOVIMIENTO_STOCK`
- Stored Procedure `usp_ObtenerMovimientosStock`
- Stored Procedure `usp_RegistrarMovimientoStock`

### Paso 2: Recompilar el Proyecto

1. Abre la solución en Visual Studio
2. Limpia la solución: `Build > Clean Solution`
3. Reconstruye: `Build > Rebuild Solution`

### Paso 3: Agregar al Menú (Opcional)

Si deseas agregar un enlace en el menú de navegación, edita el archivo de permisos/menús en la base de datos o en el código según tu estructura.

Para acceder directamente, navega a:
```
http://localhost:[puerto]/MovimientoStock/Crear
```

## Uso del Sistema

### Registrar un Movimiento

1. **Seleccionar Tienda**: Elige la sucursal donde se realiza el movimiento
2. **Tipo de Movimiento**: 
   - **Ingreso**: Aumenta el stock (ej: llegada de mercadería, devoluciones)
   - **Egreso**: Disminuye el stock (ej: ajuste de inventario, pérdidas, roturas)
3. **Seleccionar Producto**: Busca y selecciona el producto
4. **Cantidad**: Ingresa la cantidad del movimiento
5. **Motivo**: Describe el motivo del movimiento
6. Click en **Registrar Movimiento**

### Validaciones Automáticas

- ✅ No permite stock negativo en egresos
- ✅ Verifica que el producto esté asignado a la tienda
- ✅ Actualiza el stock de la tienda automáticamente
- ✅ Actualiza el stock general del producto (suma de todas las tiendas)
- ✅ Registra el usuario y fecha del movimiento

### Consultar Historial

El historial muestra:
- Fecha y hora del movimiento
- Tienda
- Producto (nombre y código)
- Tipo de movimiento (Ingreso/Egreso)
- Cantidad
- Motivo
- Usuario que realizó el movimiento

Puedes filtrar por tienda específica o ver todos los movimientos.

## Características Técnicas

### Seguridad
- Transacciones SQL para garantizar integridad de datos
- Validaciones en backend y frontend
- Control de usuario por sesión

### Performance
- Índices en claves foráneas
- Consultas optimizadas con INNER JOIN
- Paginación con DataTables

### UI/UX
- Diseño consistente con el resto de la aplicación
- Colores: badges verdes para Ingreso, rojos para Egreso
- Validación de formularios en tiempo real
- Mensajes de confirmación y error

## Estructura de Datos

### Tabla MOVIMIENTO_STOCK
```sql
- IdMovimiento (PK)
- IdTienda (FK)
- IdProducto (FK)
- TipoMovimiento (VARCHAR: 'Ingreso' o 'Egreso')
- Cantidad (INT)
- Motivo (VARCHAR)
- IdUsuario (FK)
- FechaRegistro (DATETIME)
```

## Mantenimiento

### Agregar Nuevos Tipos de Movimiento
Si necesitas agregar más tipos de movimientos (ej: "Transferencia"), modifica:
1. El enum en el frontend (Crear.cshtml, select de TipoMovimiento)
2. La validación en el stored procedure
3. La lógica de actualización de stock según corresponda

### Reportes
Los datos están disponibles para generar reportes de:
- Movimientos por período
- Movimientos por tienda
- Movimientos por producto
- Movimientos por usuario

## Soporte
Para cualquier problema o mejora, contacta al equipo de desarrollo.
