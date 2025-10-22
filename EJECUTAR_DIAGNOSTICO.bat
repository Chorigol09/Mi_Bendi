@echo off
echo ========================================
echo EJECUTANDO DIAGNOSTICO
echo ========================================
echo.

sqlcmd -S localhost -d DBVENTAS_WEB -E -i "Utilidad\SQL Server\020_DIAGNOSTICO_ORDENES_FACTURAS.sql"

echo.
echo ========================================
echo DIAGNOSTICO COMPLETADO
echo ========================================
pause
