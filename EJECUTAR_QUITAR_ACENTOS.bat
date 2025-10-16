@echo off
echo ========================================
echo   QUITAR ACENTOS DE INTERFAZ WEB
echo ========================================
echo.
echo Este script quitara todos los acentos de:
echo - Archivos .cshtml (vistas)
echo - Archivos .js (JavaScript)
echo.
echo IMPORTANTE: Este proceso modificara los archivos.
echo.
pause

echo.
echo Ejecutando script de PowerShell...
echo.

PowerShell.exe -ExecutionPolicy Bypass -File "%~dp0QUITAR_ACENTOS_INTERFAZ.ps1"

echo.
echo ========================================
echo   PROCESO COMPLETADO
echo ========================================
echo.
pause
