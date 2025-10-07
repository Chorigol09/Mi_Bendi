@echo off
setlocal
REM Cambiá la instancia default si querés:
set SQLINSTANCE=.\SQLEXPRESS
set DBNAME=DBVENTAS_WEB
set INITSCRIPT=..\db\DBVENTAS_WEB_init.sql

powershell -ExecutionPolicy Bypass -File "%~dp0bootstrap.ps1" -SqlInstance "%SQLINSTANCE%" -DbName "%DBNAME%" -InitScript "%INITSCRIPT%"
endlocal
