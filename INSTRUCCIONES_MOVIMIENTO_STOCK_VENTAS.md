# Registro de Movimientos de Stock en Ventas

## Descripción General

Se ha implementado una funcionalidad para que cada vez que se realice una nueva venta, esta quede registrada automáticamente como movimiento de stock en el sistema.

## Cambios Realizados

### 1. Modificación del Procedimiento `usp_RegistrarVenta`

El procedimiento almacenado `usp_RegistrarVenta` ha sido actualizado para incluir el registro automático de movimientos de stock.

**Ubicación del script:** `scripts/Agregar_MovimientoStock_a_Ventas.sql`

### 2. Funcionalidad Implementada

Cuando se registra una venta, el sistema ahora:

1. **Registra la venta** en la tabla `VENTA` y `DETALLE_VENTA` (comportamiento existente)
2. **Crea movimientos de stock** para cada producto vendido en la tabla `MOVIMIENTO_STOCK`
3. **Actualiza el stock** restando las cantidades vendidas en la tabla `PRODUCTO_TIENDA`
4. **Valida el stock disponible** antes de completar la venta

### 3. Características del Movimiento de Stock

Cada producto vendido genera un movimiento con las siguientes características:

- **Tipo de Movimiento:** "Venta de productos" (IdTipoMov = 4)
- **Tipo de Operación:** Egreso (resta del stock)
- **Lote:** Se agrupa con formato `VENTA-xxxxxx` donde xxxxxx es el código de la venta
- **Motivo:** "Venta de producto - Código de venta: xxxxxx"
- **Usuario:** El usuario que realizó la venta
- **Tienda:** La tienda donde se realizó la venta
- **Fecha:** Fecha y hora del registro de la venta

### 4. Validaciones

El sistema valida que:
- Exista stock suficiente de cada producto antes de completar la venta
- Si algún producto no tiene stock suficiente, la venta completa se cancela (rollback)
- El producto esté asignado a la tienda

## Instalación

### Paso 1: Ejecutar el Script SQL

Ejecutar el script `scripts/Agregar_MovimientoStock_a_Ventas.sql` en la base de datos:

```sql
-- Ejecutar en SQL Server Management Studio o herramienta similar
USE [DBVENTAS_WEB]
GO

-- Luego ejecutar todo el contenido del archivo
-- Agregar_MovimientoStock_a_Ventas.sql
```

### Paso 2: Verificar la Actualización

Verificar que el procedimiento se haya actualizado correctamente:

```sql
-- Verificar que el procedimiento existe
SELECT * FROM sys.objects 
WHERE type = 'P' AND name = 'usp_RegistrarVenta'
```

## Ejemplo de Uso

El registro de movimientos de stock es **automático** y no requiere cambios en el código de la aplicación. 

Cuando se realiza una venta desde la interfaz web (Vista `Venta_Crear`), el sistema:

1. Registra la venta normalmente
2. Automáticamente crea los movimientos de stock
3. Actualiza los niveles de inventario

## Consultar Movimientos de Stock

Para ver los movimientos de stock generados por ventas:

```sql
-- Ver movimientos de tipo "Venta de productos"
SELECT 
    m.IdMovimiento,
    m.FechaRegistro,
    t.Nombre AS Tienda,
    p.Nombre AS Producto,
    m.Cantidad,
    m.Motivo,
    m.IdLote,
    u.Nombres AS Usuario
FROM MOVIMIENTO_STOCK m
INNER JOIN TIENDA t ON m.IdTienda = t.IdTienda
INNER JOIN PRODUCTO p ON m.IdProducto = p.IdProducto
INNER JOIN USUARIO u ON m.IdUsuario = u.IdUsuario
WHERE m.IdTipoMov = 4  -- Venta de productos
ORDER BY m.FechaRegistro DESC
```

Para ver todos los movimientos de una venta específica:

```sql
-- Reemplazar 'VENTA-000001' con el código de la venta
SELECT 
    m.*,
    p.Nombre AS NombreProducto
FROM MOVIMIENTO_STOCK m
INNER JOIN PRODUCTO p ON m.IdProducto = p.IdProducto
WHERE m.IdLote = 'VENTA-000001'
```

## Impacto en la Aplicación

### Sin Cambios Requeridos en:
- ✅ VentasWeb/Controllers/VentaController.cs
- ✅ VentasWeb/Scripts/Views/Venta_Crear.js
- ✅ CapaDatos/CD_Venta.cs
- ✅ Cualquier otra parte del código de la aplicación

### Beneficios:
- ✅ Trazabilidad completa de las ventas en el stock
- ✅ Historial detallado de movimientos por venta
- ✅ Validación automática de stock disponible
- ✅ Agrupación de movimientos por lote de venta
- ✅ Sincronización automática entre ventas y stock

## Notas Importantes

1. **Transaccional:** Todo el proceso (venta + movimientos + actualización de stock) se ejecuta dentro de una transacción. Si algo falla, todo se revierte.

2. **Stock Insuficiente:** Si al momento de registrar la venta no hay stock suficiente de algún producto, la venta completa se cancela.

3. **Compatibilidad:** Esta implementación es compatible con el sistema existente de movimientos de stock y no afecta otras funcionalidades.

4. **Tipo de Movimiento:** Utiliza el tipo de movimiento "Venta de productos" (IdTipoMov = 4) que ya existe en la tabla TIPO_MOV.

## Soporte

Si encuentras algún problema o necesitas realizar ajustes, revisa:
- El procedimiento `usp_RegistrarVenta` en la base de datos
- Los logs de errores en la aplicación
- La tabla `MOVIMIENTO_STOCK` para verificar los registros

---

**Fecha de implementación:** Noviembre 2024  
**Versión:** 1.0
