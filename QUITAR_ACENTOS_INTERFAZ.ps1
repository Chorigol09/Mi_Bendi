# Script para quitar acentos de archivos de interfaz web
# Busca en vistas .cshtml y archivos .js

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  QUITAR ACENTOS DE INTERFAZ WEB" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$rootPath = "C:\Users\franc\source\repos\Mi_Bendi\VentasWeb"

# Mapeo de caracteres con acento a sin acento
$replacements = @{
    'á' = 'a'; 'é' = 'e'; 'í' = 'i'; 'ó' = 'o'; 'ú' = 'u'; 'ü' = 'u'
    'Á' = 'A'; 'É' = 'E'; 'Í' = 'I'; 'Ó' = 'O'; 'Ú' = 'U'; 'Ü' = 'U'
    'ñ' = 'n'; 'Ñ' = 'N'
}

# Contador de archivos y cambios
$filesModified = 0
$totalReplacements = 0

# Función para procesar un archivo
function Process-File {
    param($file)
    
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $fileReplacements = 0
    
    # Aplicar cada reemplazo
    foreach ($key in $replacements.Keys) {
        $before = $content
        $content = $content.Replace($key, $replacements[$key])
        if ($before -ne $content) {
            $count = ([regex]::Matches($before, [regex]::Escape($key))).Count
            $fileReplacements += $count
        }
    }
    
    # Si hubo cambios, guardar el archivo
    if ($originalContent -ne $content) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "  ✓ $($file.Name): $fileReplacements reemplazos" -ForegroundColor Green
        return $fileReplacements
    }
    
    return 0
}

# Procesar archivos .cshtml
Write-Host "Procesando archivos .cshtml..." -ForegroundColor Yellow
$cshtmlFiles = Get-ChildItem -Path "$rootPath\Views" -Filter "*.cshtml" -Recurse
foreach ($file in $cshtmlFiles) {
    $changes = Process-File $file
    if ($changes -gt 0) {
        $filesModified++
        $totalReplacements += $changes
    }
}

# Procesar archivos .js
Write-Host ""
Write-Host "Procesando archivos .js..." -ForegroundColor Yellow
$jsFiles = Get-ChildItem -Path "$rootPath\Scripts\Views" -Filter "*.js" -Recurse
foreach ($file in $jsFiles) {
    $changes = Process-File $file
    if ($changes -gt 0) {
        $filesModified++
        $totalReplacements += $changes
    }
}

# Resumen
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUMEN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Archivos modificados: $filesModified" -ForegroundColor Green
Write-Host "Total de reemplazos: $totalReplacements" -ForegroundColor Green
Write-Host ""

if ($filesModified -gt 0) {
    Write-Host "✓ Proceso completado exitosamente" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos pasos:" -ForegroundColor Yellow
    Write-Host "1. Revisar los cambios en los archivos"
    Write-Host "2. Ejecutar RECOMPILAR_Y_EJECUTAR.bat"
    Write-Host "3. Verificar que la interfaz se vea correctamente"
} else {
    Write-Host "✓ No se encontraron acentos para reemplazar" -ForegroundColor Green
}

Write-Host ""
Write-Host "Presiona cualquier tecla para continuar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
