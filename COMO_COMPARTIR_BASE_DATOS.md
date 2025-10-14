# 🗃️ CÓMO COMPARTIR LA BASE DE DATOS CON TUS COMPAÑEROS

## 📋 **OPCIONES DISPONIBLES**

Tienes **2 opciones** para compartir tu base de datos:

### ✅ **OPCIÓN 1: Script SQL (RECOMENDADO)**
- **Ventaja:** Se versiona en Git, portable, fácil de revisar
- **Archivo:** Script SQL completo con toda la estructura

### ✅ **OPCIÓN 2: Backup (.bak)**
- **Ventaja:** Copia exacta, rápido de restaurar
- **Archivo:** Archivo .bak de SQL Server

---

## 🎯 **OPCIÓN 1: GENERAR SCRIPT SQL COMPLETO**

### **PASO A: Generar Script desde SQL Server Management Studio**

1. **Abrir SSMS** y conectar al servidor
2. **Click derecho** en la base de datos `DBSISTEMA_VENTA`
3. Seleccionar: **Tasks** → **Generate Scripts...**
4. Click **Next** en la pantalla de bienvenida

### **Configuración del Script:**

5. **Choose Objects:**
   - Seleccionar: ☑️ **"Script entire database and all database objects"**
   - Click **Next**

6. **Set Scripting Options:**
   - Click en **"Advanced"**
   - Configurar estas opciones:

   ```
   ✅ Script DROP and CREATE:                      Script CREATE only
   ✅ Include Descriptive Headers:                 True
   ✅ Include If NOT EXISTS:                       True
   ✅ Script for Server Version:                   SQL Server 2019 (o tu versión)
   ✅ Script Indexes:                              True
   ✅ Script Primary Keys:                         True
   ✅ Script Foreign Keys:                         True
   ✅ Script Defaults:                             True
   ✅ Script Check Constraints:                    True
   ✅ Script Triggers:                             True
   
   📊 PARA INCLUIR DATOS:
   ✅ Types of data to script:                    Schema and data
   ```

7. **Save Location:**
   - Opción 1: **Save to file** → Seleccionar ubicación
   - Nombre sugerido: `DBSISTEMA_VENTA_COMPLETO.sql`
   - Guardar en: `Utilidad/SQL Server/`

8. Click **Next** → **Finish**

---

## 🗂️ **ESTRUCTURA DE SCRIPTS RECOMENDADA**

Organiza los scripts en este orden para tus compañeros:

### **📁 Utilidad/SQL Server/**
```
1️⃣ 000_LEEME_PRIMERO.txt           ← Instrucciones generales
2️⃣ 001_SETUP_COMPLETO.sql          ← Script completo generado (Opción A)
3️⃣ 002_DBSISTEMA_VENTA.sql         ← Estructura base (si existe)
4️⃣ 004_MEJORAS_SISTEMA_OC_REMITOS_FACTURAS.sql
5️⃣ 006_AGREGAR_MENUS_REMITO_FACTURA.sql
6️⃣ 016_GENERAR_REMITOS_FACTURAS_AUTO.sql
7️⃣ 017_DATOS_PRUEBA_OPCIONAL.sql   ← Datos de ejemplo (opcional)
```

---

## 💾 **OPCIÓN 2: CREAR BACKUP (.bak)**

### **PASO B: Generar Backup**

1. **Abrir SSMS** y conectar al servidor
2. **Click derecho** en `DBSISTEMA_VENTA`
3. Seleccionar: **Tasks** → **Back Up...**

### **Configuración del Backup:**

4. **General:**
   - Backup type: **Full**
   - Backup component: ☑️ **Database**
   
5. **Destination:**
   - Click **Remove** (si hay rutas anteriores)
   - Click **Add**
   - Ubicación sugerida: `C:\Backups\DBSISTEMA_VENTA_[FECHA].bak`
   - Ejemplo: `DBSISTEMA_VENTA_2025-10-14.bak`

6. **Options:**
   - ☑️ **Verify backup when finished**
   - Compression: **Compress backup** (para menor tamaño)

7. Click **OK**

### **Compartir el Backup:**

```bash
# Opción A: Subir a Google Drive / OneDrive
📦 DBSISTEMA_VENTA_2025-10-14.bak

# Opción B: Compartir por red local
\\red\compartida\DBSISTEMA_VENTA.bak
```

---

## 👥 **INSTRUCCIONES PARA TUS COMPAÑEROS**

### **📄 Si usan el SCRIPT SQL:**

```sql
-- 1. Abrir SQL Server Management Studio
-- 2. Conectar al servidor local
-- 3. Abrir el script: File → Open → File
-- 4. Seleccionar: DBSISTEMA_VENTA_COMPLETO.sql
-- 5. Presionar F5 o click en "Execute"
-- 6. ¡Listo! Base de datos creada
```

**Ventajas:**
- ✅ Portable
- ✅ Versionable en Git
- ✅ Fácil de revisar diferencias
- ✅ No depende de versiones de SQL Server

---

### **💾 Si usan el BACKUP (.bak):**

```sql
-- 1. Copiar el archivo .bak al servidor
-- 2. Abrir SQL Server Management Studio
-- 3. Click derecho en "Databases"
-- 4. Seleccionar: "Restore Database..."
-- 5. Seleccionar: "Device" → Buscar el .bak
-- 6. Verificar nombre de BD: DBSISTEMA_VENTA
-- 7. Click "OK"
-- 8. ¡Listo! Base de datos restaurada
```

**Ventajas:**
- ✅ Rápido de restaurar
- ✅ Copia exacta con datos
- ✅ Incluye permisos y configuraciones

---

## 🔗 **CONFIGURAR CONNECTION STRING**

Después de crear la base de datos, deben configurar el `Web.config`:

```xml
<connectionStrings>
  <add name="cadena_conexion" 
       connectionString="Data Source=localhost;Initial Catalog=DBSISTEMA_VENTA;Integrated Security=True" 
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

**Variaciones comunes:**

```xml
<!-- SQL Server Express -->
connectionString="Data Source=localhost\SQLEXPRESS;Initial Catalog=DBSISTEMA_VENTA;Integrated Security=True"

<!-- Con usuario y contraseña -->
connectionString="Data Source=localhost;Initial Catalog=DBSISTEMA_VENTA;User ID=sa;Password=tuPassword"

<!-- Servidor remoto -->
connectionString="Data Source=192.168.1.100;Initial Catalog=DBSISTEMA_VENTA;User ID=usuario;Password=password"
```

---

## 📦 **RECOMENDACIÓN FINAL**

### **Para compartir en Git (repositorio):**
```
✅ Usar SCRIPT SQL (Opción 1)
✅ Commit y push a develop
✅ Tus compañeros ejecutan el script
```

### **Para compartir internamente (equipo local):**
```
✅ Compartir BACKUP (.bak) por Drive/OneDrive
✅ Más rápido de restaurar
✅ Incluye todos los datos actuales
```

### **IDEAL: Ambas opciones**
```
📄 Script SQL → Para nuevos desarrolladores
💾 Backup → Para copias rápidas del equipo
```

---

## ✅ **CHECKLIST PARA TUS COMPAÑEROS**

```
☐ 1. Clonar repositorio: git clone https://github.com/Chorigol09/Mi_Bendi.git
☐ 2. Checkout a develop: git checkout develop
☐ 3. Instalar SQL Server (si no lo tienen)
☐ 4. Ejecutar script SQL O restaurar backup
☐ 5. Configurar Web.config con su connection string
☐ 6. Abrir solución en Visual Studio
☐ 7. Build > Rebuild Solution
☐ 8. Presionar F5
☐ 9. Login: admin@mibendi.com / admin123
☐ 10. ¡A trabajar! 🚀
```

---

## 🆘 **SOLUCIÓN DE PROBLEMAS COMUNES**

### **"Cannot open database DBSISTEMA_VENTA"**
```sql
-- Verificar que existe
SELECT name FROM sys.databases WHERE name = 'DBSISTEMA_VENTA'

-- Si no existe, ejecutar el script de creación
```

### **"Login failed for user"**
```
→ Verificar connection string en Web.config
→ Verificar que SQL Server permite autenticación Windows/SQL
→ Verificar permisos del usuario
```

### **"Invalid column name"**
```
→ Ejecutar el script 016_GENERAR_REMITOS_FACTURAS_AUTO.sql
→ Verificar que todas las tablas existen
```

---

## 📞 **CONTACTO**

Si tus compañeros tienen problemas, pueden:
1. Revisar este documento
2. Consultar los archivos .md en el repositorio
3. Contactarte directamente

---

**¡Éxito con la configuración! 🎉**
