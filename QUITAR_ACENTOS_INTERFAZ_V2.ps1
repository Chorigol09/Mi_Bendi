# Script para quitar acentos de archivos de interfaz web
# Busca en vistas .cshtml y archivos .js

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  QUITAR ACENTOS DE INTERFAZ WEB" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$rootPath = "C:\Users\franc\source\repos\Mi_Bendi\VentasWeb"

# Contador de archivos y cambios
$filesModified = 0
$totalReplacements = 0

# Función para quitar acentos de un texto
function Remove-Accents {
    param([string]$text)
    
    # Minúsculas
    $text = $text.Replace('á', 'a')
    $text = $text.Replace('é', 'e')
    $text = $text.Replace('í', 'i')
    $text = $text.Replace('ó', 'o')
    $text = $text.Replace('ú', 'u')
    $text = $text.Replace('ü', 'u')
    
    # Mayúsculas
    $text = $text.Replace('Á', 'A')
    $text = $text.Replace('É', 'E')
    $text = $text.Replace('Í', 'I')
    $text = $text.Replace('Ó', 'O')
    $text = $text.Replace('Ú', 'U')
    $text = $text.Replace('Ü', 'U')
    
    # Eñes
    $text = $text.Replace('ñ', 'n')
    $text = $text.Replace('Ñ', 'N')
    
    return $text
}

# Función para contar acentos en un texto
function Count-Accents {
    param([string]$text)
    
    $count = 0
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'á' }).Count
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'é' }).Count
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'í' }).Count
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'ó' }).Count
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'ú' }).Count
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'ü' }).Count
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'Á' }).Count
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'É' }).Count
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'Í' }).Count
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'Ó' }).Count
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'Ú' }).Count
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'Ü' }).Count
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'ñ' }).Count
    $count += ($text.ToCharArray() | Where-Object { $_ -eq 'Ñ' }).Count
    
    return $count
}

# Función para procesar un archivo
function Process-File {
    param($file)
    
    try {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $originalContent = $content
        
        # Contar acentos antes
        $accentsBefore = Count-Accents $content
        
        if ($accentsBefore -eq 0) {
            return 0
        }
        
        # Quitar acentos
        $content = Remove-Accents $content
        
        # Guardar el archivo
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        
        Write-Host "  [OK] $($file.Name): $accentsBefore reemplazos" -ForegroundColor Green
        return $accentsBefore
    }
    catch {
        Write-Host "  [ERROR] $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
        return 0
    }
}

# Procesar archivos .cshtml
Write-Host "Procesando archivos .cshtml..." -ForegroundColor Yellow
$cshtmlFiles = Get-ChildItem -Path "$rootPath\Views" -Filter "*.cshtml" -Recurse -ErrorAction SilentlyContinue

if ($cshtmlFiles) {
    foreach ($file in $cshtmlFiles) {
        $changes = Process-File $file
        if ($changes -gt 0) {
            $filesModified++
            $totalReplacements += $changes
        }
    }
} else {
    Write-Host "  No se encontraron archivos .cshtml" -ForegroundColor Yellow
}

# Procesar archivos .js
Write-Host ""
Write-Host "Procesando archivos .js..." -ForegroundColor Yellow
$jsFiles = Get-ChildItem -Path "$rootPath\Scripts\Views" -Filter "*.js" -Recurse -ErrorAction SilentlyContinue

if ($jsFiles) {
    foreach ($file in $jsFiles) {
        $changes = Process-File $file
        if ($changes -gt 0) {
            $filesModified++
            $totalReplacements += $changes
        }
    }
} else {
    Write-Host "  No se encontraron archivos .js" -ForegroundColor Yellow
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
    Write-Host "[OK] Proceso completado exitosamente" -ForegroundColor Green
    Write-Host ""
    Write-Host "Proximos pasos:" -ForegroundColor Yellow
    Write-Host "1. Revisar los cambios en los archivos"
    Write-Host "2. Ejecutar RECOMPILAR_Y_EJECUTAR.bat"
    Write-Host "3. Verificar que la interfaz se vea correctamente"
} else {
    Write-Host "[OK] No se encontraron acentos para reemplazar" -ForegroundColor Green
}

Write-Host ""
Write-Host "Presiona cualquier tecla para continuar..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
