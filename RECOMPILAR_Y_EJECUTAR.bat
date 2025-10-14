@echo off
chcp 65001 >nul
echo ========================================
echo    RECOMPILAR Y EJECUTAR SISTEMA
echo ========================================
echo.

REM Verificar si existe Visual Studio 2022
set MSBUILD="C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"

if not exist %MSBUILD% (
    set MSBUILD="C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
)

if not exist %MSBUILD% (
    set MSBUILD="C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
)

if not exist %MSBUILD% (
    echo ❌ ERROR: No se encontró MSBuild
    echo.
    echo Por favor, abre Visual Studio manualmente:
    echo 1. Doble clic en VentasWeb.sln
    echo 2. Build ^> Rebuild Solution
    echo 3. Presiona F5
    echo.
    pause
    exit /b 1
)

echo ✓ MSBuild encontrado
echo.

echo ========================================
echo    PASO 1/3: LIMPIAR PROYECTO
echo ========================================
echo.
%MSBUILD% VentasWeb.sln /t:Clean /p:Configuration=Release /nologo /verbosity:minimal

if errorlevel 1 (
    echo.
    echo ❌ ERROR al limpiar el proyecto
    pause
    exit /b 1
)

echo ✓ Proyecto limpiado
echo.

echo ========================================
echo    PASO 2/3: RECOMPILAR PROYECTO
echo ========================================
echo.
%MSBUILD% VentasWeb.sln /t:Rebuild /p:Configuration=Release /nologo /verbosity:minimal

if errorlevel 1 (
    echo.
    echo ❌ ERROR al compilar
    echo.
    echo Abre Visual Studio y revisa los errores:
    echo    doble clic en VentasWeb.sln
    echo.
    pause
    exit /b 1
)

echo.
echo ✓ Proyecto compilado exitosamente
echo.

echo ========================================
echo    PASO 3/3: VERIFICAR ARCHIVOS
echo ========================================
echo.

REM Verificar que existen los controladores
if exist "VentasWeb\Controllers\RemitoController.cs" (
    echo ✓ RemitoController.cs existe
) else (
    echo ❌ ERROR: RemitoController.cs NO existe
)

if exist "VentasWeb\Controllers\FacturaController.cs" (
    echo ✓ FacturaController.cs existe
) else (
    echo ❌ ERROR: FacturaController.cs NO existe
)

if exist "VentasWeb\Views\Remito\Index.cshtml" (
    echo ✓ Views\Remito\Index.cshtml existe
) else (
    echo ❌ ERROR: Views\Remito\Index.cshtml NO existe
)

if exist "VentasWeb\Views\Factura\Index.cshtml" (
    echo ✓ Views\Factura\Index.cshtml existe
) else (
    echo ❌ ERROR: Views\Factura\Index.cshtml NO existe
)

echo.
echo ========================================
echo    ✅ COMPILACIÓN COMPLETADA
echo ========================================
echo.
echo AHORA PUEDES:
echo.
echo   Opción 1: Ejecutar desde aquí
echo             Presiona cualquier tecla...
echo.
echo   Opción 2: Ejecutar desde Visual Studio
echo             Doble clic en VentasWeb.sln
echo             Presiona F5
echo.
pause

REM Buscar IIS Express
set IISEXPRESS="C:\Program Files\IIS Express\iisexpress.exe"
if not exist %IISEXPRESS% (
    set IISEXPRESS="C:\Program Files (x86)\IIS Express\iisexpress.exe"
)

if not exist %IISEXPRESS% (
    echo.
    echo IIS Express no encontrado.
    echo Por favor, ejecuta desde Visual Studio: F5
    pause
    exit /b 0
)

echo.
echo ========================================
echo    🚀 EJECUTANDO APLICACIÓN
echo ========================================
echo.
echo URL: http://localhost:8080
echo.
echo Usuario: admin@mibendi.com
echo Clave: admin123
echo.
echo Presiona Ctrl+C para detener el servidor
echo.

REM Esperar y abrir navegador
timeout /t 2 /nobreak >nul
start http://localhost:8080

REM Ejecutar IIS Express
%IISEXPRESS% /path:"%CD%\VentasWeb" /port:8080
