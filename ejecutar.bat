@echo off
echo =====================================
echo    SISTEMA DE VENTAS - Mi Bendi
echo =====================================
echo.

REM Verificar si existe Visual Studio 2022
if not exist "C:\Program Files\Microsoft Visual Studio\2022\" (
    echo ERROR: Visual Studio 2022 no encontrado
    echo Por favor, abre VentasWeb.sln con Visual Studio y presiona F5
    pause
    exit /b 1
)

echo Abriendo Visual Studio...
echo.
echo INSTRUCCIONES:
echo 1. Visual Studio se abrira
echo 2. Espera a que cargue el proyecto
echo 3. Presiona F5 para ejecutar
echo.

start "" "VentasWeb.sln"

pause
