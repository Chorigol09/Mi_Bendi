@echo off
echo ========================================
echo VIENDO ESTRUCTURA DE TABLAS
echo ========================================
echo.

sqlcmd -S localhost -d DBVENTAS_WEB -E -i "Utilidad\SQL Server\024_VER_ESTRUCTURA_FACTURA.sql"

echo.
echo ========================================
echo PRESIONA UNA TECLA PARA CERRAR
echo ========================================
pause
