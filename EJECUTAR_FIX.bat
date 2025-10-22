@echo off
echo ========================================
echo EJECUTANDO CORRECCION DE STORED PROCEDURES
echo ========================================
echo.

sqlcmd -S localhost -d DBVENTAS_WEB -E -i "Utilidad\SQL Server\019_FIX_PARAMETRO_RESULTADO.sql"

echo.
echo ========================================
echo CORRECCION COMPLETADA
echo ========================================
pause
