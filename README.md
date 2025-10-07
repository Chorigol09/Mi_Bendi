# 💻 Proyecto "Mi Bendi" — Guía de instalación y colaboración

Este proyecto está desarrollado en **ASP.NET** con una base de datos SQL Server llamada **DBVENTAS_WEB**.  
El objetivo de este documento es que cualquier integrante del equipo pueda clonar el proyecto, levantar su entorno local y contribuir correctamente al repositorio.

---

## 🧩 1) Clonar el repositorio

### 🔹 Requisitos previos
- Tener instalado **Visual Studio 2022** o **.NET SDK 7/8**
- Tener instalado **SQL Server Express** o **SQL LocalDB**
- Tener instalado **sqlcmd** (viene con las SQL Server Tools o Visual Studio)
- Contar con acceso al repositorio remoto (GitHub)

### 🔹 Clonar el proyecto
Abrir PowerShell o Git Bash en una carpeta de trabajo y ejecutar:

-DESDE EL BASH
git clone <URL-del-repo>
cd mi-bendi

## 2) Crear y restaurar la base de datos
Desde PowerShell (en la raíz del proyecto):

 Opción 1: usando SQL Express (recomendado)
.\scripts\bootstrap.ps1 -SqlInstance ".\SQLEXPRESS"

 Opción 2: si usás LocalDB
.\scripts\bootstrap.ps1 -SqlInstance "(localdb)\MSSQLLocalDB"

## 3) Configurar la conexión a la base de datos

El proyecto usa web.config (ASP.NET Framework):
<connectionStrings>
  <add name="miconexion"
       connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=DBVENTAS_WEB;Integrated Security=True;MultipleActiveResultSets=True;TrustServerCertificate=True"
       providerName="System.Data.SqlClient" />
</connectionStrings>
Si tu instancia SQL es distinta (por ejemplo, tunombre\SQLEXPRESS), solo cambiá el valor de Data Source.

## 4) Ejecutar el proyecto

En Visual Studio:

Presioná F5 o Ctrl + F5 para iniciar

## 5) Flujo de trabajo en equipo (GitHub + Base de datos)
🧍‍♂️ Cada desarrollador debe:

1. Tener su propia base local (DBVENTAS_WEB creada con el bootstrap).

2. Crear una nueva rama antes de modificar código o base de datos:

EN POWERSHELL:
    git checkout -b feature/nombre-de-tu-tarea

3. Trabajar normalmente (código, vistas, controladores, etc.).

4. Si realiza cambios en la base de datos (tablas, vistas, procedimientos, etc.):

    Generar un archivo SQL de parche en la carpeta /db/patches/.

Ejemplo de nombre del parche del archivo:
    db/patches/2025-10-08_agregar_campo_direccion_cliente.sql
    ⚠️ No edites directamente DBVENTAS_WEB_init.sql, salvo que quieras actualizar la “foto base” de todo el proyecto.
    (PORQUE SE SUPONE QUE DBBENTAS_WEB_init.sql es como la base de datos que yo tengo ahora que esta andando perfecto, por lo que si algo sale mal, tenemos esa de backup)

## 6) 🧩 Aplicar los parches de base de datos

Cuando otro compañero agregue un parche, cada desarrollador debe aplicarlo en su base local con:

DESDE POWERSHELL
sqlcmd -S .\SQLEXPRESS -d DBVENTAS_WEB -i .\db\patches\2025-10-08_agregar_campo_direccion_cliente.sql -b

## 7) Subir cambios y generar un Pull Request

Cuando termines tu trabajo:

1. Verificá que todo compile correctamente.

2. Confirmá tus cambios:  
    git add .
    git commit -m "Agregada nueva funcionalidad + parche SQL"

3) Sincronizá con la rama principal (por ejemplo develop):
    git fetch origin
    git rebase origin/develop

4) Subi tu rama al repo
    git push origin feature/nombre-de-tu-tarea

5) Entrá a GitHub → vas a ver un botón “Compare & Pull Request”.

6) Escribí una breve descripción de tus cambios (qué agregaste, qué tablas tocaste).

7) Enviá el Pull Request para revisión.

💡 yo reviso el código y los parches SQL antes de hacer merge a la rama principal.

## 8) Actualizar tu entorno después de un merge

Cuando se aprueba un Pull Request y se integran cambios:

1) Volvé a la rama develop:
    git checkout develop

2)Actualizá el repo local:
    git pull origin develop

3)Aplicá los nuevos parches SQL que aparezcan en /db/patches/:
    sqlcmd -S .\SQLEXPRESS -d DBVENTAS_WEB -i .\db\patches\<nombre-del-parche>.sql -b


🧭 Buenas prácticas del equipo
-Cada desarrollador trabaja con su propia base local.
- cambio de estructura se documenta en /db/patches/.
-Las ramas siempre parten de develop.
-Los Pull Requests deben incluir una descripción clara de lo que se cambió.
-DBVENTAS_WEB_init.sql solo se actualiza cuando hay una versión estable completa de la base.

💬 Soporte interno
Si algo falla al crear la base:
POWERSHELL

    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

    .\scripts\bootstrap.ps1 -SqlInstance ".\SQLEXPRESS" -Rebuild

Si el proyecto no se conecta correctamente:
    Revisar el Data Source en la cadena de conexión.
    Confirmar que la base DBVENTAS_WEB aparece en SSMS.
    Probar conexión con:
(POWERSHELL)

    sqlcmd -S .\SQLEXPRESS -d DBVENTAS_WEB -Q "SELECT GETDATE();"
