@echo off
chcp 65001 > nul
echo ========================================
echo  ACTUALIZAR ICONO ORDEN DE PAGO
echo ========================================
echo.
echo Este script actualizará el icono del menú "Órdenes de Pago"
echo.
pause

echo.
echo Ejecutando script SQL...
echo.

sqlcmd -S . -E -i "Utilidad\SQL Server\038_ACTUALIZAR_ICONO_ORDEN_PAGO.sql"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  ACTUALIZACIÓN COMPLETADA
    echo ========================================
    echo.
    echo El icono ha sido actualizado correctamente.
    echo.
    echo IMPORTANTE:
    echo 1. Cierra sesión en la aplicación web
    echo 2. Vuelve a iniciar sesión
    echo 3. El icono debería aparecer ahora
    echo.
) else (
    echo.
    echo ========================================
    echo  ERROR
    echo ========================================
    echo.
    echo Hubo un error al ejecutar el script.
    echo Verifica que SQL Server esté en ejecución.
    echo.
)

pause
