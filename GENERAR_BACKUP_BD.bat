@echo off
chcp 65001 >nul
title Generar Backup de Base de Datos - Mi Bendi

echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║                                                           ║
echo ║      🗃️  GENERAR BACKUP DE BASE DE DATOS                 ║
echo ║                                                           ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo Este script generará un backup de tu base de datos
echo para compartir con tus compañeros.
echo.

:: Obtener fecha actual
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set FECHA=%datetime:~0,8%
set HORA=%datetime:~8,6%

:: Configurar rutas
set BACKUP_DIR=%~dp0Backups
set BACKUP_FILE=%BACKUP_DIR%\DBSISTEMA_VENTA_%FECHA%_%HORA%.bak

:: Crear carpeta de backups si no existe
if not exist "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%"
    echo ✓ Carpeta Backups creada
)

echo.
echo 📦 Generando backup...
echo    Ubicación: %BACKUP_FILE%
echo.

:: Generar script SQL para backup
(
echo USE master;
echo GO
echo BACKUP DATABASE [DBSISTEMA_VENTA]
echo TO DISK = N'%BACKUP_FILE%'
echo WITH NOFORMAT, NOINIT,
echo NAME = N'DBSISTEMA_VENTA-Full Database Backup',
echo SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
echo GO
echo PRINT '✓ Backup completado exitosamente'
echo PRINT 'Ubicación: %BACKUP_FILE%'
echo GO
) > "%TEMP%\backup_script.sql"

:: Ejecutar backup usando sqlcmd
:: Cambia "localhost" si tu servidor tiene otro nombre
sqlcmd -S localhost -E -i "%TEMP%\backup_script.sql"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ╔═══════════════════════════════════════════════════════════╗
    echo ║                ✅ BACKUP COMPLETADO                       ║
    echo ╚═══════════════════════════════════════════════════════════╝
    echo.
    echo 📄 Archivo generado:
    echo    %BACKUP_FILE%
    echo.
    echo 📤 Ahora puedes:
    echo    1. Compartir este archivo con tus compañeros
    echo    2. Subirlo a Google Drive / OneDrive
    echo    3. Copiarlo a una red compartida
    echo.
    echo 💡 Tamaño del archivo:
    dir "%BACKUP_FILE%" | find ".bak"
    echo.
) else (
    echo.
    echo ❌ ERROR: No se pudo generar el backup
    echo.
    echo Verifica:
    echo   • SQL Server está corriendo
    echo   • Tienes permisos para hacer backup
    echo   • La base de datos DBSISTEMA_VENTA existe
    echo   • El nombre del servidor es correcto (localhost)
    echo.
    echo Si tu servidor tiene otro nombre, edita este archivo:
    echo   • Busca la línea: sqlcmd -S localhost
    echo   • Cambia "localhost" por tu servidor
    echo     Ejemplos: .\SQLEXPRESS, MIPC\SQLEXPRESS, etc.
    echo.
)

:: Limpiar archivo temporal
del "%TEMP%\backup_script.sql" >nul 2>&1

echo.
echo Presiona cualquier tecla para salir...
pause >nul
