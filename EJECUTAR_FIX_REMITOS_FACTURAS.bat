@echo off
echo ========================================
echo   EJECUTAR FIX REMITOS Y FACTURAS
echo ========================================
echo.
echo Este script ejecutara el fix para generar
echo automaticamente remitos y facturas.
echo.
pause

echo.
echo Ejecutando script SQL...
echo.

sqlcmd -S localhost -d DBVENTAS_WEB -E -i "%~dp0scripts\FIX_GENERAR_REMITOS_FACTURAS_AUTO.sql"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   SCRIPT EJECUTADO CORRECTAMENTE
    echo ========================================
    echo.
    echo Ahora debes:
    echo 1. Reiniciar la aplicacion
    echo 2. Crear una nueva orden de compra
    echo 3. Verificar en Remitos y Facturas
    echo.
) else (
    echo.
    echo ========================================
    echo   ERROR AL EJECUTAR EL SCRIPT
    echo ========================================
    echo.
    echo Si sqlcmd no esta disponible, ejecuta manualmente:
    echo.
    echo 1. Abre SQL Server Management Studio
    echo 2. File ^> Open ^> File
    echo 3. Selecciona: scripts\FIX_GENERAR_REMITOS_FACTURAS_AUTO.sql
    echo 4. Presiona F5
    echo.
)

pause
