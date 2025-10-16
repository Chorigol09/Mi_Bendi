# 📝 Lista de Acentos a Quitar de la Interfaz Web

## 🎯 Objetivo

Eliminar todos los acentos de las palabras que aparecen en la interfaz web para evitar problemas de codificación/encoding.

---

## 📋 Caracteres que se Reemplazarán

### **Vocales con acento:**
- `á` → `a`
- `é` → `e`
- `í` → `i`
- `ó` → `o`
- `ú` → `u`
- `ü` → `u`

### **Vocales mayúsculas con acento:**
- `Á` → `A`
- `É` → `E`
- `Í` → `I`
- `Ó` → `O`
- `Ú` → `U`
- `Ü` → `U`

### **Eñes:**
- `ñ` → `n`
- `Ñ` → `N`

---

## 📄 Archivos Afectados

El script procesará automáticamente:

### **Vistas (.cshtml):**
- `Views/Categoria/*.cshtml`
- `Views/Cliente/*.cshtml`
- `Views/Compra/*.cshtml`
- `Views/Factura/*.cshtml`
- `Views/Home/*.cshtml`
- `Views/Login/*.cshtml`
- `Views/MovimientoStock/*.cshtml`
- `Views/Permisos/*.cshtml`
- `Views/Producto/*.cshtml`
- `Views/Proveedor/*.cshtml`
- `Views/Remito/*.cshtml`
- `Views/Reporte/*.cshtml`
- `Views/Rol/*.cshtml`
- `Views/Shared/*.cshtml`
- `Views/Tienda/*.cshtml`
- `Views/Usuario/*.cshtml`
- `Views/Venta/*.cshtml`

### **JavaScript (.js):**
- `Scripts/Views/*.js` (todos los archivos)

---

## 📝 Ejemplos de Palabras que Cambiarán

### **Campos de Formulario:**
| Antes | Después |
|-------|---------|
| Descripción | Descripcion |
| Teléfono | Telefono |
| Dirección | Direccion |
| Razón Social | Razon Social |
| Contraseña | Contrasena |
| Número Remito | Numero Remito |
| Gestión de Remitos | Gestion de Remitos |
| Información | Informacion |

### **Días de la Semana:**
| Antes | Después |
|-------|---------|
| Miércoles | Miercoles |
| Sábado | Sabado |

### **Mensajes:**
| Antes | Después |
|-------|---------|
| ¿Está seguro? | ¿Esta seguro? |
| Sí, marcar recibido | Si, marcar recibido |
| Éxito | Exito |
| válido | valido |
| automáticamente | automaticamente |

### **Navegación:**
| Antes | Después |
|-------|---------|
| Toggler móvil | Toggler movil |
| Menús dinámicos | Menus dinamicos |
| español datatable | espanol datatable |
| Iniciales automáticas | Iniciales automaticas |

---

## 🚀 Cómo Ejecutar

### **Opción 1: Archivo Batch (Recomendado)**

1. Doble clic en:
   ```
   EJECUTAR_QUITAR_ACENTOS.bat
   ```

2. Lee el mensaje y presiona **Enter**

3. Espera a que termine el proceso

4. Verás un resumen con:
   - Archivos modificados
   - Total de reemplazos realizados

### **Opción 2: PowerShell Directo**

```powershell
PowerShell.exe -ExecutionPolicy Bypass -File "QUITAR_ACENTOS_INTERFAZ.ps1"
```

---

## ✅ Verificación

Después de ejecutar el script:

1. **Revisar algunos archivos modificados:**
   - Abre `Views/Remito/Index.cshtml`
   - Busca "Numero Remito" (antes "Número Remito")
   - Busca "Gestion" (antes "Gestión")

2. **Recompilar y ejecutar:**
   ```
   Doble clic en: RECOMPILAR_Y_EJECUTAR.bat
   ```

3. **Verificar en el navegador:**
   - Login al sistema
   - Navega por las diferentes secciones
   - Verifica que el texto se vea bien (sin símbolos raros)
   - Los acentos ya no deberían causar problemas de encoding

---

## 📊 Archivos con Mayor Cantidad de Acentos

Basado en el análisis inicial, estos archivos tienen más palabras con acentos:

1. **`Shared/_Layout.cshtml`** - Menú principal y navegación
2. **`Compra/Crear.cshtml`** - Formulario de orden de compra
3. **`Remito/Index.cshtml`** - Gestión de remitos
4. **`Venta/Documento.cshtml`** - Documento de venta
5. **`Scripts/Views/Compra_Consultar.js`** - Datepicker en español
6. **`Scripts/Views/Venta_Consultar.js`** - Datepicker en español
7. **`Scripts/Views/Reporte_Venta.js`** - Datepicker en español

---

## ⚠️ Importante

### **Backup Automático:**
- El script NO crea backups automáticos
- Si usas Git, asegúrate de commitear antes
- Puedes hacer backup manual copiando la carpeta `VentasWeb`

### **Encoding UTF-8:**
- Los archivos se guardan con encoding UTF-8
- Esto asegura compatibilidad
- No deberías tener problemas de caracteres raros

### **Reversión:**
- Si necesitas revertir, usa Git:
  ```bash
  git checkout .
  ```
- O restaura desde un backup manual

---

## 🔍 Qué NO se Modifica

El script solo procesa:
- ✅ Archivos `.cshtml` en `Views/`
- ✅ Archivos `.js` en `Scripts/Views/`

NO modifica:
- ❌ Archivos `.cs` (C# backend)
- ❌ Archivos `.sql` (base de datos)
- ❌ Otros archivos JavaScript fuera de `Scripts/Views/`
- ❌ Contenido de base de datos

---

## 📈 Beneficios

Después de quitar los acentos:

✅ **Sin problemas de encoding** - No más caracteres raros (�)
✅ **Compatibilidad** - Funciona en cualquier navegador
✅ **Sin configuración UTF-8** - No necesitas meta tags especiales
✅ **Más simple** - Menos problemas de codificación
✅ **Portable** - Funciona en diferentes servidores

---

## 🐛 Troubleshooting

### **Error: No se puede ejecutar scripts en este sistema**

Ejecuta en PowerShell como administrador:
```powershell
Set-ExecutionPolicy RemoteSigned
```

Luego ejecuta el batch nuevamente.

### **Los cambios no se reflejan**

1. Asegúrate de recompilar:
   ```
   RECOMPILAR_Y_EJECUTAR.bat
   ```

2. Limpia caché del navegador:
   - `Ctrl + Shift + Delete`
   - Borra caché y cookies

3. Recarga la página:
   - `Ctrl + F5` (recarga forzada)

### **Algunos archivos no se modificaron**

- Verifica que los archivos no estén abiertos en Visual Studio
- Cierra Visual Studio antes de ejecutar el script
- Vuelve a ejecutar el script

---

## 📝 Log de Cambios

El script mostrará en consola:
- ✓ Nombre de cada archivo modificado
- ✓ Cantidad de reemplazos por archivo
- ✓ Total de archivos modificados
- ✓ Total de reemplazos realizados

Ejemplo de salida:
```
Procesando archivos .cshtml...
  ✓ Index.cshtml: 15 reemplazos
  ✓ Crear.cshtml: 8 reemplazos
  
Procesando archivos .js...
  ✓ Compra_Consultar.js: 12 reemplazos
  
========================================
  RESUMEN
========================================
Archivos modificados: 23
Total de reemplazos: 187
```

---

## ✅ Checklist Final

Después de ejecutar:

- [ ] Script ejecutado sin errores
- [ ] Revisar archivos modificados
- [ ] Recompilar aplicación
- [ ] Login al sistema
- [ ] Navegar por todas las secciones
- [ ] Verificar que no hay caracteres raros
- [ ] Verificar formularios
- [ ] Verificar mensajes de error/éxito
- [ ] Verificar datepickers (fechas)
- [ ] Todo funciona correctamente ✅

---

**¡Listo para ejecutar!** 🚀

Si tienes dudas o problemas, revisa el Troubleshooting.
