@echo off
echo ====================================
echo Compilando proyecto...
echo ====================================

REM Buscar MSBuild en diferentes ubicaciones
set MSBUILD_PATH=

if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe
)

if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe
)

if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    set MSBUILD_PATH=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe
)

if "%MSBUILD_PATH%"=="" (
    echo ERROR: No se encontro MSBuild
    echo Por favor, compila desde Visual Studio presionando Ctrl+Shift+B
    pause
    exit /b 1
)

echo MSBuild encontrado
echo Compilando...
echo.

"%MSBUILD_PATH%" VentasWeb.sln /t:Rebuild /p:Configuration=Debug /p:Platform="Any CPU" /nologo /verbosity:minimal

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: La compilacion fallo
    pause
    exit /b 1
)

echo.
echo ====================================
echo Compilacion exitosa!
echo ====================================
echo.
echo Ahora puedes reiniciar la aplicacion
pause
