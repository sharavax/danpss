param(
    [string]$TomcatHome = "C:\Tomcat\apache-tomcat-9.0.116",
    [string]$AppName = "danpss",
    [int]$Port = 7070,
    [string]$JavaHome = "C:\Program Files\Java\jdk-17",
    [switch]$RebuildDatabase
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourcePath = $scriptRoot
$javaSourcePath = Join-Path $scriptRoot "backend\src\main\java"
$classesPath = Join-Path $scriptRoot "WEB-INF\classes"
$libPath = Join-Path $scriptRoot "WEB-INF\lib\mysql-connector-j-8.0.33.jar"
$targetPath = Join-Path (Join-Path $TomcatHome "webapps") $AppName
$startupScript = Join-Path (Join-Path $TomcatHome "bin") "startup.bat"
$javacExe = Join-Path (Join-Path $JavaHome "bin") "javac.exe"

$env:CATALINA_HOME = $TomcatHome
$env:CATALINA_BASE = $TomcatHome
$env:JAVA_HOME = $JavaHome
$env:JRE_HOME = ""

if (-not (Test-Path $TomcatHome)) {
    throw "Tomcat home not found: $TomcatHome"
}

if (-not (Test-Path $sourcePath)) {
    throw "Source app path not found: $sourcePath"
}
if (-not (Test-Path $javacExe)) {
    throw "javac.exe not found at $javacExe"
}
if (-not (Test-Path $libPath)) {
    throw "MySQL connector not found at $libPath"
}

if (-not (Test-Path (Join-Path $TomcatHome "webapps"))) {
    throw "Tomcat webapps directory not found."
}

if (-not (Test-Path $targetPath)) {
    New-Item -ItemType Directory -Path $targetPath | Out-Null
}

Write-Host "Compiling Java sources into WEB-INF\\classes"
if (Test-Path $classesPath) {
    Get-ChildItem -Path $classesPath -Recurse -Include *.class | Remove-Item -Force
}
$javaFiles = Get-ChildItem -Path $javaSourcePath -Recurse -Filter *.java | Select-Object -ExpandProperty FullName
if (-not $javaFiles) {
    throw "No Java source files found under $javaSourcePath"
}
& $javacExe -encoding UTF-8 -cp "$($TomcatHome)\lib\servlet-api.jar;$libPath" -d $classesPath $javaFiles
if ($LASTEXITCODE -ne 0) {
    throw "Java compilation failed with exit code $LASTEXITCODE"
}

if ($RebuildDatabase) {
    Write-Host "Rebuilding local MySQL schema"
    powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "backend\db\setup-local-db.ps1")
    if ($LASTEXITCODE -ne 0) {
        throw "Database rebuild failed with exit code $LASTEXITCODE"
    }
}

Write-Host "Deploying exploded app from $sourcePath to $targetPath"
robocopy $sourcePath $targetPath /MIR /XD backend .git .idea .vscode > $null

$robocopyCode = $LASTEXITCODE
if ($robocopyCode -ge 8) {
    throw "Deployment copy failed with robocopy exit code $robocopyCode"
}

$runningTomcat = Get-Process | Where-Object { $_.ProcessName -match "^tomcat9$" -or $_.Path -like "*apache-tomcat-9.0.116*" }
if (-not $runningTomcat) {
    Write-Host "Starting Tomcat 9"
    Start-Process -FilePath $startupScript -WorkingDirectory (Join-Path $TomcatHome "bin")
} else {
    Write-Host "Tomcat 9 is already running"
}

Write-Host "Done. Open http://localhost:$Port/$AppName/"
