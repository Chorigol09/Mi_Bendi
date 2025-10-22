# Solución: Problema con Registro de Facturas

## Problema Identificado

1. **No se pueden registrar facturas**: El stored procedure no está actualizado en la base de datos
2. **Las facturas no aparecen en la lista**: El SP que obtiene las facturas no trae todos los campos necesarios

## Solución

### Paso 1: Ejecutar el Script de Corrección

1. Abre **SQL Server Management Studio** o **Azure Data Studio**
2. Conecta a tu base de datos `DBVENTAS_WEB`
3. Abre el archivo: `Utilidad\SQL Server\028_EJECUTAR_TODOS_LOS_FIXES.sql`
4. Ejecuta el script completo (F5 o botón Execute)

### Paso 2: Verificar que Funcionó

El script mostrará mensajes como:
```
✓ SP usp_RegistrarFacturaConDetalles creado
✓ SP usp_ObtenerFacturas creado
✓ usp_RegistrarFacturaConDetalles: OK
✓ usp_ObtenerFacturas: OK
```

Si ves estos mensajes con ✓, todo está correcto.

### Paso 3: Probar el Sistema

1. Ve a la aplicación web
2. Intenta registrar una nueva factura
3. Verifica que:
   - Se registre correctamente
   - Aparezca en la lista de facturas
   - Muestre el estado "PENDIENTE" en la columna "Pago"

## ¿Qué Hace el Script?

### Fix 1: Stored Procedure de Registro
- Crea/actualiza `usp_RegistrarFacturaConDetalles`
- Permite registrar facturas con sus detalles
- Establece el estado inicial como "Pendiente"

### Fix 2: Stored Procedure de Consulta
- Crea/actualiza `usp_ObtenerFacturas`
- Trae todos los campos necesarios para la vista:
  - Información básica de la factura
  - Cantidad de productos
  - Lista de productos
  - Fecha formateada
  - Estado de pago

## Si Sigue Sin Funcionar

1. **Verifica la conexión a la base de datos**:
   - Revisa el archivo `Web.config`
   - Asegúrate que apunta a `DBVENTAS_WEB`

2. **Verifica que los SPs existen**:
   ```sql
   SELECT name FROM sys.procedures 
   WHERE name IN ('usp_RegistrarFacturaConDetalles', 'usp_ObtenerFacturas')
   ```

3. **Revisa los logs del navegador**:
   - Presiona F12 en el navegador
   - Ve a la pestaña "Console"
   - Busca errores en rojo

## Compartir la Base de Datos con Compañeros

Una vez que todo funcione, para compartir con tus compañeros:

### Opción 1: Script SQL (Recomendado)
```sql
-- Ejecuta esto en SQL Server
BACKUP DATABASE [DBVENTAS_WEB] 
TO DISK = 'C:\Users\TuUsuario\Desktop\DBVENTAS_WEB.bak'
WITH FORMAT, INIT, NAME = 'Backup completo';
```

Luego comparte el archivo `.bak` y ellos lo restauran.

### Opción 2: Scripts de Creación
Comparte toda la carpeta `Utilidad\SQL Server\` con tus compañeros.
Ellos deben ejecutar los scripts en orden numérico.

## Notas Importantes

- ✅ El sistema ahora muestra la columna "Pago" con badges visuales
- ✅ No hay más signo "+" para expandir
- ✅ Las facturas nuevas aparecen automáticamente en la lista
- ✅ El estado por defecto es "Pendiente"
