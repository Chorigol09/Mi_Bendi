# ❌ Solución: "No se pudieron cargar las listas de precios"

## Problema

Al entrar a **Ventas > Registrar Venta** aparece el error:
```
❌ "No se pudieron cargar las listas de precios"
```

Y el selector de listas de precios aparece vacío.

---

## ✅ Solución Paso a Paso

### PASO 1: Verificar que las tablas existan

Ejecuta esta consulta en SQL Server:

```sql
USE DBVENTAS_WEB
GO

-- Verificar tablas
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME IN ('LISTA_PRECIO', 'LISTA_PRECIO_DETALLE')
```

**Si NO aparecen las 2 tablas:**
- Ejecuta primero: `031_SISTEMA_LISTAS_PRECIOS.sql`
- Luego continúa con el PASO 2

**Si SÍ aparecen las 2 tablas:**
- Continúa con el PASO 2

---

### PASO 2: Ejecutar scripts en ORDEN

Ejecuta estos scripts **en SQL Server Management Studio** en este orden exacto:

#### 1️⃣ Crear sistema de listas (si no lo hiciste antes)
```sql
-- Archivo: 031_SISTEMA_LISTAS_PRECIOS.sql
-- Crea las tablas y stored procedures
```

#### 2️⃣ Agregar menú (si no lo hiciste antes)
```sql
-- Archivo: 032_AGREGAR_MENU_LISTAS_PRECIOS.sql
-- Agrega el menú en Administración
```

#### 3️⃣ **IMPORTANTE: Generar precios automáticos** ⭐
```sql
-- Archivo: 036_GENERAR_PRECIOS_AUTOMATICOS.sql
-- Este genera 3 listas con precios para TODOS tus productos
```

Este último script es **NUEVO** y hace lo siguiente:

✅ Crea 3 listas de precios:
- **Lista Minorista 2024** (precio regular)
- **Lista Mayorista 2024** (20-30% más barato que minorista)
- **Lista Promoción Black Friday** (15% más barato que minorista)

✅ Asigna precios automáticamente a **TODOS** tus productos

✅ Los precios son lógicos:
- Mayorista < Minorista
- Promoción < Minorista
- Precios entre $500 y $50.000 (ajustable)

---

### PASO 3: Actualizar base de datos para ventas

```sql
-- Archivo: 035_AGREGAR_LISTA_PRECIO_VENTA.sql
-- Agrega columnas a tabla VENTA y actualiza SP
```

---

### PASO 4: Recompilar proyecto

1. Abrir Visual Studio
2. **Compilar** > **Recompilar solución**
3. Ejecutar (F5)

---

## 🔍 Verificar que funcione

### En SQL Server:

```sql
-- Ver listas creadas
SELECT * FROM LISTA_PRECIO WHERE Activo = 1

-- Ver cantidad de productos con precio
SELECT 
    LP.Nombre,
    COUNT(LPD.IdListaPrecioDetalle) AS TotalProductos,
    MIN(LPD.PrecioVenta) AS PrecioMinimo,
    MAX(LPD.PrecioVenta) AS PrecioMaximo
FROM LISTA_PRECIO LP
LEFT JOIN LISTA_PRECIO_DETALLE LPD ON LP.IdListaPrecio = LPD.IdListaPrecio
WHERE LP.Activo = 1
GROUP BY LP.Nombre
```

**Deberías ver:**
```
Nombre                          TotalProductos  PrecioMinimo  PrecioMaximo
------------------------------- --------------- ------------- -------------
Lista Minorista 2024            X               $XXX          $XXXXX
Lista Mayorista 2024            X               $XXX          $XXXXX
Lista Promoción Black Friday    X               $XXX          $XXXXX
```

### En la aplicación:

1. Ir a **Ventas** > **Registrar Venta**
2. El selector debe mostrar:
   ```
   Lista Minorista 2024 (Minorista)
   Lista Mayorista 2024 (Mayorista)
   Lista Promoción Black Friday (Promocion)
   ```
3. Seleccionar una lista
4. Buscar un producto
5. El precio debe aparecer automáticamente

---

## ⚙️ Ajustar rangos de precios

Si quieres cambiar el rango de precios que se generan automáticamente:

**Edita el archivo:** `036_GENERAR_PRECIOS_AUTOMATICOS.sql`

**Busca esta línea:**
```sql
SET @PrecioBase = ROUND(RAND(CHECKSUM(NEWID())) * 49500 + 500, -1)
```

**Ajusta los valores:**
- `500` = Precio mínimo
- `49500` = Rango (500 + 49500 = 50000 precio máximo)

**Ejemplo para precios más bajos (100 a 10000):**
```sql
SET @PrecioBase = ROUND(RAND(CHECKSUM(NEWID())) * 9900 + 100, -1)
```

---

## 🎯 Ejemplo de Precios Generados

Para un producto cualquiera:

| Lista                    | Precio     | Diferencia vs Minorista |
|-------------------------|------------|-------------------------|
| **Minorista**           | $1.500,00  | Base                    |
| **Mayorista**           | $1.125,00  | -25% (ahorro $375)      |
| **Promoción**           | $1.275,00  | -15% (ahorro $225)      |

---

## 📝 Notas

- Los precios se generan **aleatoriamente** pero con lógica comercial
- Mayorista siempre será 20-30% más barato que minorista
- Promoción siempre será 15% más barato que minorista
- Todos los productos activos reciben precio
- Las vigencias se establecen automáticamente

---

## ❓ Si sigue sin funcionar

### Error en consola del navegador:

1. Presiona **F12** en el navegador
2. Ve a la pestaña **Console**
3. Busca errores en rojo
4. Copia el mensaje de error

### Verificar endpoint:

Abre esta URL en el navegador (cambia localhost por tu servidor):
```
http://localhost:64927/ListaPrecio/ObtenerListasPreciosActivas
```

Deberías ver un JSON con las listas:
```json
{
  "data": [
    {
      "IdListaPrecio": 1,
      "Nombre": "Lista Minorista 2024",
      "TipoLista": "Minorista",
      "Activo": true
    },
    ...
  ]
}
```

---

## 📧 Contacto

Si después de seguir todos los pasos sigue sin funcionar:
1. Copia los mensajes de error (SQL y navegador)
2. Verifica qué scripts ejecutaste
3. Revisa el log de compilación de Visual Studio

---

**Última actualización:** 12/11/2024  
**Versión:** 1.0
