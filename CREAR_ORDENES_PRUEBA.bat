@echo off
echo ========================================
echo CREANDO ORDENES DE COMPRA DE PRUEBA
echo ========================================
echo.

sqlcmd -S localhost -d DBVENTAS_WEB -E -i "Utilidad\SQL Server\021_CREAR_ORDENES_PRUEBA.sql"

echo.
echo ========================================
echo ORDENES CREADAS
echo ========================================
pause
