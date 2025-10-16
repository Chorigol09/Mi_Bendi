@echo off
echo ========================================
echo   CONFIGURAR MOVIMIENTO DE STOCK
echo   AL RECIBIR REMITOS
echo ========================================
echo.
echo Este script configurara el sistema para
echo generar automaticamente movimientos de stock
echo cuando se marca un remito como "Recibido"
echo.
pause

echo.
echo Ejecutando script SQL...
echo.

sqlcmd -S localhost -d DBVENTAS_WEB -E -i "%~dp0scripts\FIX_REMITO_GENERA_MOVIMIENTO_STOCK.sql"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   SCRIPT EJECUTADO CORRECTAMENTE
    echo ========================================
    echo.
    echo Ahora debes:
    echo 1. Ejecutar RECOMPILAR_Y_EJECUTAR.bat
    echo 2. Ir a Compras ^> Remitos
    echo 3. Marcar un remito como "Recibido"
    echo 4. Verificar en Reportes ^> Movimientos de Stock
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
    echo 3. Selecciona: scripts\FIX_REMITO_GENERA_MOVIMIENTO_STOCK.sql
    echo 4. Presiona F5
    echo.
)

pause
