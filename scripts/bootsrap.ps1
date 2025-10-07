param(
  # Cambiá el default a tu instancia si querés forzarla.
  [string]$SqlInstance = ".\SQLEXPRESS",     # tu caso: SANTIAGO\SQLEXPRESS
  [string]$DbName = "DBVENTAS_WEB",
  [string]$InitScript = "..\db\DBVENTAS_WEB_init.sql",
  [switch]$Rebuild    # si se pasa: DROP + CREATE DB
)

function Exec-SqlCmd {
  param([string]$Query, [string]$Db = $null)
  if ($Db) {
    sqlcmd -S $SqlInstance -d $Db -Q $Query -b
  } else {
    sqlcmd -S $SqlInstance -Q $Query -b
  }
  if ($LASTEXITCODE -ne 0) { throw "Falló: $Query" }
}

Write-Host "==> Instancia: $SqlInstance"
Write-Host "==> DB: $DbName"
Write-Host "==> Script: $InitScript"

# ¿Existe la DB?
$existsQuery = "SELECT 1 FROM sys.databases WHERE name = N'$DbName';"
$exists = sqlcmd -S $SqlInstance -h -1 -Q $existsQuery | Out-String
$exists = $exists.Trim() -eq "1"

if ($Rebuild -and $exists) {
  Write-Host "==> Rebuild: poniendo SINGLE_USER y DROPEANDO $DbName"
  Exec-SqlCmd -Query "ALTER DATABASE [$DbName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;"
  Exec-SqlCmd -Query "DROP DATABASE [$DbName];"
  $exists = $false
}

if (-not $exists) {
  Write-Host "==> Creando DB $DbName"
  Exec-SqlCmd -Query "CREATE DATABASE [$DbName];"
} else {
  Write-Host "==> La DB $DbName ya existe. No se recrea (a menos que uses -Rebuild)."
}

# Ejecutar el script (trae DROP+CREATE de objetos y datos semilla)
Write-Host "==> Aplicando $InitScript sobre $DbName"
sqlcmd -S $SqlInstance -d $DbName -i $InitScript -b
if ($LASTEXITCODE -ne 0) { throw "Falló al ejecutar $InitScript" }

Write-Host "✅ Listo. $DbName disponible en $SqlInstance"
