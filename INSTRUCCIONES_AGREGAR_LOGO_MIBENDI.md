# Instrucciones para Agregar el Logo de Mi Bendi

## 📋 Pasos para Agregar el Logo

### **Paso 1: Guardar la Imagen del Logo**

1. **Guarda la imagen del logo** que te envié (el logo con el bebé en el carrito y el texto "Mi Bendi")

2. **Renombra el archivo** a: `mi-bendi-logo.png`

3. **Copia el archivo** a la siguiente carpeta:
   ```
   c:\Users\franc\source\repos\Mi_Bendi\VentasWeb\Imagenes\
   ```

### **Paso 2: Formato Recomendado**

- **Formato:** PNG (con fondo transparente preferiblemente)
- **Tamaño recomendado:** 400px x 200px aproximadamente
- **Nombre exacto:** `mi-bendi-logo.png`

---

## ✅ Verificación

Después de copiar el archivo:

1. Verifica que el archivo esté en la ruta correcta:
   ```
   VentasWeb\Imagenes\mi-bendi-logo.png
   ```

2. Ejecuta la aplicación

3. Ve a **Órdenes de Pago → Consultar Órdenes de Pago**

4. Haz clic en el botón "Ver" (ojo azul) de cualquier orden

5. Deberías ver el logo de "Mi Bendi" en la parte superior izquierda del comprobante

---

## 🎨 Cambios Realizados en el Código

**Archivo modificado:** `VentasWeb/Views/OrdenPago/Consultar.cshtml`

**Línea 89:** Se actualizó la referencia del logo:

**Antes:**
```html
<img src="~/Content/img/logo.png" alt="Logo" style="max-width: 150px;">
```

**Después:**
```html
<img src="@Url.Content("~/Imagenes/mi-bendi-logo.png")" alt="Mi Bendi Logo" style="max-width: 180px; height: auto;">
```

---

## 📂 Estructura de Carpetas

```
Mi_Bendi/
└── VentasWeb/
    └── Imagenes/
        ├── logo.png
        ├── tienda.png
        ├── mi-bendi-logo.png  ← AGREGAR ESTE ARCHIVO AQUÍ
        └── (otros archivos...)
```

---

## 🔧 Solución de Problemas

### **Si el logo no aparece:**

1. **Verifica el nombre del archivo:** Debe ser exactamente `mi-bendi-logo.png` (sin espacios, sin mayúsculas excepto donde se indica)

2. **Verifica la extensión:** Debe ser `.png` (no .jpg, no .jpeg)

3. **Verifica la ubicación:** Debe estar en `VentasWeb\Imagenes\`

4. **Limpia el caché del navegador:** 
   - Presiona `Ctrl + Shift + R` para recargar forzadamente
   - O usa `Ctrl + F5`

5. **Verifica los permisos:** El archivo debe tener permisos de lectura

---

## 💡 Nota Adicional

Si prefieres usar otro nombre para el archivo (por ejemplo, `logo-mi-bendi.png`), puedes cambiar la línea 89 del archivo `Consultar.cshtml` para reflejar el nuevo nombre:

```html
<img src="@Url.Content("~/Imagenes/NUEVO-NOMBRE.png")" alt="Mi Bendi Logo" style="max-width: 180px; height: auto;">
```

---

**Fecha:** 31 de Octubre de 2025  
**Archivo a agregar:** `mi-bendi-logo.png`  
**Ubicación:** `VentasWeb\Imagenes\`
