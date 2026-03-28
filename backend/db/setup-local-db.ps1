param(
    [string]$MysqlExe = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
    [string]$DbUser = "root",
    [string]$DbPassword = "luckyadmin@123"
)

$ErrorActionPreference = "Stop"

$schemaPath = Join-Path $PSScriptRoot "schema.sql"

if (-not (Test-Path $MysqlExe)) {
    throw "mysql.exe not found at $MysqlExe"
}

if (-not (Test-Path $schemaPath)) {
    throw "schema.sql not found at $schemaPath"
}

Write-Host "Applying DANPSS schema using $MysqlExe"
Get-Content -Raw $schemaPath | & $MysqlExe -u $DbUser -p"$DbPassword"

if ($LASTEXITCODE -ne 0) {
    throw "Schema setup failed with exit code $LASTEXITCODE"
}

Write-Host "Database setup completed for danpss_db."
