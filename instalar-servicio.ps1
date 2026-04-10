# ==============================================================================
# instalar-servicio.ps1
# Instala WinlabwebAPI como servicio de Windows en Windows Server 2012 R2+
# Ejecutar como ADMINISTRADOR en el servidor de destino:
#   Right-click → "Ejecutar con PowerShell" (como administrador)
#   O desde consola: powershell -ExecutionPolicy Bypass -File instalar-servicio.ps1
# ==============================================================================

#Requires -RunAsAdministrator

$ErrorActionPreference = "Stop"

# ── Configuración ─────────────────────────────────────────────────────────────
$ServiceName    = "WinlabwebAPI"
$ServiceDisplay = "WinlabWeb API REST (Node.js)"
$ServiceDesc    = "API REST para acceso a informes PDF de medicos y pacientes - WinlabWeb"
$AppDir         = Split-Path -Parent $MyInvocation.MyCommand.Path
$NodeCmd        = Get-Command node -ErrorAction SilentlyContinue
$NodeExe        = if ($NodeCmd) { $NodeCmd.Source } else { $null }
$NssmDir        = "C:\tools\nssm"
$NssmExe        = "$NssmDir\nssm.exe"
$Port           = 3000

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  WinlabwebAPI - Instalador de servicio" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ── 1. Verificar Node.js ──────────────────────────────────────────────────────
Write-Host "[1/6] Verificando Node.js..." -ForegroundColor Yellow

if (-not $NodeExe) {
    Write-Host "  ERROR: Node.js no encontrado." -ForegroundColor Red
    Write-Host "  Descarga Node.js 18 LTS desde: https://nodejs.org/dist/v18.20.4/node-v18.20.4-x64.msi" -ForegroundColor Red
    Write-Host "  Importante: usa Node.js 18 (no 20 ni 22) para compatibilidad con Windows Server 2012 R2" -ForegroundColor Red
    exit 1
}

$nodeVersion = node --version
Write-Host "  OK: Node.js $nodeVersion encontrado en $NodeExe" -ForegroundColor Green

# ── 2. Verificar .env ────────────────────────────────────────────────────────
Write-Host "[2/6] Verificando archivo .env..." -ForegroundColor Yellow

if (-not (Test-Path "$AppDir\.env")) {
    Write-Host "  ERROR: No se encontro el archivo .env en $AppDir" -ForegroundColor Red
    Write-Host "  Copia el archivo .env con las credenciales correctas para este servidor." -ForegroundColor Red
    exit 1
}

Write-Host "  OK: .env encontrado." -ForegroundColor Green

# ── 3. Instalar dependencias npm ─────────────────────────────────────────────
Write-Host "[3/6] Instalando dependencias npm..." -ForegroundColor Yellow
Set-Location $AppDir

try {
    npm install --omit=dev 2>&1 | Out-Null
    Write-Host "  OK: dependencias instaladas." -ForegroundColor Green
} catch {
    Write-Host "  ERROR al ejecutar npm install: $_" -ForegroundColor Red
    exit 1
}

# ── 4. Descargar NSSM ────────────────────────────────────────────────────────
Write-Host "[4/6] Preparando NSSM (gestor de servicios)..." -ForegroundColor Yellow

if (-not (Test-Path $NssmExe)) {
    New-Item -ItemType Directory -Path $NssmDir -Force | Out-Null

    $nssmZip = "$env:TEMP\nssm.zip"
    Write-Host "  Descargando NSSM..." -ForegroundColor Gray

    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri "https://nssm.cc/release/nssm-2.24.zip" -OutFile $nssmZip -UseBasicParsing
        Expand-Archive -Path $nssmZip -DestinationPath "$env:TEMP\nssm_extract" -Force
        Copy-Item "$env:TEMP\nssm_extract\nssm-2.24\win64\nssm.exe" -Destination $NssmExe
        Remove-Item $nssmZip -Force
        Remove-Item "$env:TEMP\nssm_extract" -Recurse -Force
        Write-Host "  OK: NSSM descargado." -ForegroundColor Green
    } catch {
        Write-Host "  ERROR al descargar NSSM: $_" -ForegroundColor Red
        Write-Host "  Descarga manual: https://nssm.cc/release/nssm-2.24.zip" -ForegroundColor Red
        Write-Host "  Extrae nssm-2.24/win64/nssm.exe a $NssmDir\nssm.exe y vuelve a ejecutar." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  OK: NSSM ya existe en $NssmExe" -ForegroundColor Green
}

# ── 5. Crear/actualizar el servicio de Windows ───────────────────────────────
Write-Host "[5/6] Registrando servicio de Windows..." -ForegroundColor Yellow

# Si el servicio ya existe, detenerlo y eliminarlo antes de recrear
$existingService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Host "  Servicio existente encontrado, actualizando..." -ForegroundColor Gray
    & $NssmExe stop $ServiceName confirm 2>&1 | Out-Null
    & $NssmExe remove $ServiceName confirm 2>&1 | Out-Null
    Start-Sleep -Seconds 2
}

# Registrar el nuevo servicio
& $NssmExe install $ServiceName $NodeExe
& $NssmExe set $ServiceName AppDirectory     $AppDir
& $NssmExe set $ServiceName AppParameters    "app.js"
& $NssmExe set $ServiceName DisplayName      $ServiceDisplay
& $NssmExe set $ServiceName Description      $ServiceDesc
& $NssmExe set $ServiceName Start            SERVICE_AUTO_START

# Logs del servicio (stdout y stderr a archivos)
$logDir = "$AppDir\logs"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
& $NssmExe set $ServiceName AppStdout        "$logDir\api-stdout.log"
& $NssmExe set $ServiceName AppStderr        "$logDir\api-stderr.log"
& $NssmExe set $ServiceName AppRotateFiles   1
& $NssmExe set $ServiceName AppRotateBytes   10485760   # 10 MB por archivo

# Reinicio automático si el proceso muere
& $NssmExe set $ServiceName AppExit Default Restart
& $NssmExe set $ServiceName AppRestartDelay 5000       # espera 5s antes de reiniciar

Write-Host "  OK: servicio '$ServiceName' registrado." -ForegroundColor Green

# ── 6. Regla de firewall ──────────────────────────────────────────────────────
Write-Host "[6/6] Abriendo puerto $Port en el firewall de Windows..." -ForegroundColor Yellow

$fwRuleName = "WinlabwebAPI Puerto $Port"
$existingRule = Get-NetFirewallRule -DisplayName $fwRuleName -ErrorAction SilentlyContinue
if (-not $existingRule) {
    New-NetFirewallRule `
        -DisplayName $fwRuleName `
        -Direction   Inbound `
        -Protocol    TCP `
        -LocalPort   $Port `
        -Action      Allow `
        -Profile     Any | Out-Null
    Write-Host "  OK: regla de firewall creada para puerto $Port." -ForegroundColor Green
} else {
    Write-Host "  OK: regla de firewall ya existia." -ForegroundColor Green
}

# ── Iniciar el servicio ───────────────────────────────────────────────────────
Write-Host ""
Write-Host "Iniciando el servicio..." -ForegroundColor Cyan
& $NssmExe start $ServiceName

Start-Sleep -Seconds 3
$svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($svc -and $svc.Status -eq "Running") {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "  Servicio iniciado correctamente!" -ForegroundColor Green
    Write-Host "  API disponible en: http://localhost:$Port" -ForegroundColor Green
    Write-Host "  Logs en: $logDir" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "  ADVERTENCIA: El servicio no arranco automaticamente." -ForegroundColor Yellow
    Write-Host "  Revisa los logs en: $logDir\api-stderr.log" -ForegroundColor Yellow
    Write-Host "  O inicia manualmente: net start $ServiceName" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Comandos utiles:" -ForegroundColor Cyan
Write-Host "  Iniciar:   net start $ServiceName"
Write-Host "  Detener:   net stop  $ServiceName"
Write-Host "  Estado:    Get-Service $ServiceName"
Write-Host "  Ver logs:  Get-Content '$logDir\api-stdout.log' -Tail 50"
Write-Host ""
