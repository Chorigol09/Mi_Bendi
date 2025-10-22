# Instrucciones para Implementar Carga Manual de Facturas

## Resumen
Se ha implementado la funcionalidad de carga manual de facturas que permite:
- Seleccionar proveedor
- Ingresar número de factura
- Seleccionar tienda destino
- Agregar productos con cantidad y precio unitario
- Cálculo automático del total de producto y total de factura
- Registro de factura con estado "Pendiente de Pago"

## Pasos para Implementar

### 1. Ejecutar Scripts SQL (EN ORDEN)
**IMPORTANTE:** Debes ejecutar los siguientes scripts SQL en este orden:

#### Script 1: Habilitar carga manual de facturas
```
Utilidad\SQL Server\017_SP_REGISTRAR_FACTURA_CON_DETALLES.sql
```

Este script:
- Agrega la columna `IdTienda` a la tabla `FACTURA`
- Crea el stored procedure `usp_RegistrarFacturaConDetalles`
- Actualiza el stored procedure `usp_ObtenerFacturas`

#### Script 2: Deshabilitar generación automática
```
Utilidad\SQL Server\018_DESHABILITAR_FACTURAS_AUTOMATICAS.sql
```

Este script:
- Modifica `usp_RegistrarCompra` para que NO genere facturas automáticamente
- Las facturas ahora se deben cargar manualmente

**Cómo ejecutar:**
1. Abre SQL Server Management Studio
2. Conéctate a tu base de datos
3. Ejecuta PRIMERO el archivo `017_SP_REGISTRAR_FACTURA_CON_DETALLES.sql` (F5)
4. Ejecuta DESPUÉS el archivo `018_DESHABILITAR_FACTURAS_AUTOMATICAS.sql` (F5)
5. Verifica que no haya errores en los mensajes

### 2. Compilar el Proyecto
1. Abre la solución en Visual Studio
2. Compila el proyecto (Build > Build Solution)
3. Verifica que no haya errores de compilación

### 3. Acceder a la Nueva Funcionalidad
La nueva funcionalidad estará disponible en:
- **URL:** `/Factura/Crear`
- **Menú:** Compras > Registrar Factura (si está configurado en el menú)

## Funcionalidades Implementadas

### Archivos Creados/Modificados

#### Backend (C#)
1. **CapaModelo/Factura.cs** - Agregada propiedad `oTienda`
2. **CapaDatos/CD_Factura.cs** - Agregado método `RegistrarFacturaConDetalles`
3. **VentasWeb/Controllers/FacturaController.cs** - Agregadas acciones:
   - `Crear()` - Vista de creación
   - `GuardarConDetalles(string xml)` - Guardar factura con detalles

#### Frontend
1. **VentasWeb/Views/Factura/Crear.cshtml** - Vista de carga manual de facturas
2. **VentasWeb/Scripts/Views/Factura_Crear.js** - Lógica JavaScript
3. **VentasWeb/Views/Shared/_Layout.cshtml** - Agregada URL `_GuardarFacturaConDetalles`

#### Base de Datos
1. **Utilidad/SQL Server/017_SP_REGISTRAR_FACTURA_CON_DETALLES.sql** - Script SQL

## Uso de la Funcionalidad

### Pasos para Registrar una Factura

1. **Seleccionar Proveedor:**
   - Click en "Buscar Proveedor"
   - Seleccionar proveedor de la lista

2. **Ingresar Número de Factura:**
   - Escribir el número de factura (ej: 001-001-00000123)

3. **Seleccionar Tienda Destino:**
   - Click en "Buscar Tienda"
   - Seleccionar tienda de la lista

4. **Agregar Productos:**
   - Buscar producto por código o usando el botón "Buscar"
   - Ingresar cantidad
   - Ingresar precio unitario (formato: $1.200,00)
   - Click en "Agregar"
   - Repetir para cada producto

5. **Revisar Totales:**
   - El sistema calcula automáticamente:
     - Total por producto (cantidad × precio unitario)
     - Total general de la factura

6. **Registrar Factura:**
   - Click en "Registrar Factura"
   - La factura se guardará con estado "Pendiente de Pago"

## Características Técnicas

### Formato de Precios
- Formato argentino: `$1.200,00`
- Punto (.) para separador de miles
- Coma (,) para separador de decimales
- Conversión automática al ingresar

### Validaciones
- Todos los campos son obligatorios
- No se pueden agregar productos duplicados
- El número de factura no puede repetirse para el mismo proveedor
- Debe haber al menos un producto en la factura

### Estado de la Factura
- Al registrar: **Pendiente de Pago**
- Puede cambiarse a "Pagado" desde la lista de facturas

## Estructura XML Enviada al Backend

```xml
<DETALLE>
  <FACTURA>
    <IdProveedor>1</IdProveedor>
    <IdTienda>1</IdTienda>
    <NumeroFactura>001-001-00000123</NumeroFactura>
    <Total>15000.00</Total>
  </FACTURA>
  <DETALLE_FACTURA>
    <DETALLE>
      <IdFactura>0</IdFactura>
      <IdProducto>5</IdProducto>
      <Cantidad>10</Cantidad>
      <PrecioUnitario>1500.00</PrecioUnitario>
      <Subtotal>15000.00</Subtotal>
    </DETALLE>
  </DETALLE_FACTURA>
</DETALLE>
```

## Notas Importantes

1. **Independiente de Orden de Compra:** Esta funcionalidad permite registrar facturas sin necesidad de una orden de compra previa
2. **No afecta stock:** El registro de la factura NO modifica el stock de productos
3. **Validación de duplicados:** El sistema valida que no exista una factura con el mismo número para el mismo proveedor
4. **Formato de precios:** Asegúrate de usar el formato correcto ($1.200,00)

## Solución de Problemas

### Error: "No se pudo registrar la factura"
- Verifica que ejecutaste el script SQL `017_SP_REGISTRAR_FACTURA_CON_DETALLES.sql`
- Verifica que la base de datos tenga la columna `IdTienda` en la tabla `FACTURA`
- Revisa los logs de SQL Server para más detalles

### Error: "Ya existe una factura con este número"
- El número de factura ya está registrado para ese proveedor
- Usa un número de factura diferente

### Los productos no se muestran
- Verifica que hayas seleccionado una tienda primero
- Verifica que existan productos activos en el sistema

## Próximos Pasos Sugeridos

1. Agregar menú en la navegación para acceder a "Registrar Factura"
2. Agregar validación de formato de número de factura
3. Agregar opción para adjuntar imagen de la factura
4. Agregar reporte de facturas pendientes de pago
