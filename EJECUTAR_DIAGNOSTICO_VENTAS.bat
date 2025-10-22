@echo off
echo ========================================
echo DIAGNOSTICO DE VENTAS
echo ========================================
echo.
echo Ejecutando diagnostico en la base de datos...
echo.

sqlcmd -S FRANCO_LPT\SQLEXPRESS -E -d DBVENTAS_WEB -i "DIAGNOSTICO_VENTAS.sql" -o "RESULTADO_DIAGNOSTICO_VENTAS.txt"

echo.
echo ========================================
echo DIAGNOSTICO COMPLETADO
echo ========================================
echo.
echo El resultado se guardo en: RESULTADO_DIAGNOSTICO_VENTAS.txt
echo.
pause

notepad RESULTADO_DIAGNOSTICO_VENTAS.txt
