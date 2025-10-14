# Script para ejecutar la aplicación desde WindSurf/PowerShell
# Uso: .\ejecutar.ps1

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "   SISTEMA DE VENTAS - Mi Bendi" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si existe el archivo de solución
$solutionFile = ".\VentasWeb.sln"
if (-not (Test-Path $solutionFile)) {
    Write-Host "❌ ERROR: No se encontró VentasWeb.sln" -ForegroundColor Red
    Write-Host "   Ejecuta este script desde la raíz del proyecto" -ForegroundColor Yellow
    exit 1
}

Write-Host "📁 Proyecto encontrado: VentasWeb.sln" -ForegroundColor Green
Write-Host ""

# Buscar MSBuild
Write-Host "🔍 Buscando MSBuild..." -ForegroundColor Yellow
$msbuildPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"

if (-not (Test-Path $msbuildPath)) {
    # Intentar con Professional
    $msbuildPath = "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
}

if (-not (Test-Path $msbuildPath)) {
    # Intentar con Enterprise
    $msbuildPath = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
}

if (-not (Test-Path $msbuildPath)) {
    Write-Host "❌ ERROR: No se encontró MSBuild" -ForegroundColor Red
    Write-Host "   Por favor, instala Visual Studio 2022" -ForegroundColor Yellow
    Write-Host "   O ejecuta desde Visual Studio: F5" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ MSBuild encontrado" -ForegroundColor Green
Write-Host ""

# Compilar el proyecto
Write-Host "🔨 Compilando proyecto..." -ForegroundColor Yellow
& $msbuildPath $solutionFile /p:Configuration=Debug /p:Platform="Any CPU" /nologo /verbosity:minimal

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ ERROR: La compilación falló" -ForegroundColor Red
    Write-Host "   Revisa los errores arriba" -ForegroundColor Yellow
    Write-Host "   Tip: Abre el proyecto en Visual Studio para más detalles" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "✅ Compilación exitosa!" -ForegroundColor Green
Write-Host ""

# Buscar IIS Express
Write-Host "🌐 Buscando IIS Express..." -ForegroundColor Yellow
$iisExpressPath = "C:\Program Files\IIS Express\iisexpress.exe"

if (-not (Test-Path $iisExpressPath)) {
    $iisExpressPath = "C:\Program Files (x86)\IIS Express\iisexpress.exe"
}

if (-not (Test-Path $iisExpressPath)) {
    Write-Host "⚠️  IIS Express no encontrado" -ForegroundColor Yellow
    Write-Host "   Por favor, ejecuta desde Visual Studio: F5" -ForegroundColor Yellow
    Write-Host "   O instala IIS Express" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ IIS Express encontrado" -ForegroundColor Green
Write-Host ""

# Ejecutar la aplicación
$projectPath = Resolve-Path ".\VentasWeb"
$port = 8080

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "🚀 INICIANDO APLICACIÓN" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 URL: http://localhost:$port" -ForegroundColor Cyan
Write-Host "📁 Path: $projectPath" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️  Presiona Ctrl+C para detener el servidor" -ForegroundColor Yellow
Write-Host ""

# Esperar 2 segundos y abrir navegador
Start-Sleep -Seconds 2
Start-Process "http://localhost:$port"

# Ejecutar IIS Express
& $iisExpressPath /path:$projectPath /port:$port
