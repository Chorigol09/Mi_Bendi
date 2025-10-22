@echo off
echo ========================================
echo CREANDO STORED PROCEDURE DE FACTURA
echo ========================================
echo.

sqlcmd -S localhost -d DBVENTAS_WEB -E -i "Utilidad\SQL Server\025_SP_FACTURA_CORREGIDO.sql"

echo.
echo ========================================
echo PRESIONA UNA TECLA PARA CERRAR
echo ========================================
pause
