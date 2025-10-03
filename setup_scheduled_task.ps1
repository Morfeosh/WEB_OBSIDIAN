# Script de PowerShell para configurar tarea programada automática
# Ejecutar como Administrador para configurar la tarea programada

param(
    [int]$IntervalMinutes = 60,  # Ejecutar cada hora por defecto
    [string]$TaskName = "ObsidianStructureScanner",
    [string]$ScriptPath = $PSScriptRoot
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "CONFIGURACIÓN DE TAREA PROGRAMADA" -ForegroundColor Cyan
Write-Host "Escaneo automático de estructura Obsidian" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar permisos de administrador
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: Este script debe ejecutarse como Administrador" -ForegroundColor Red
    Write-Host "Haz clic derecho en PowerShell y selecciona 'Ejecutar como administrador'" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar que el archivo batch existe
$batchFile = Join-Path $ScriptPath "run_scanner.bat"
if (-not (Test-Path $batchFile)) {
    Write-Host "ERROR: No se encuentra el archivo run_scanner.bat en $ScriptPath" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar que Python esté disponible
try {
    $pythonVersion = python --version 2>$null
    Write-Host "✓ Python encontrado: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Python no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "Instala Python desde https://python.org" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Eliminar tarea existente si existe
Write-Host "Eliminando tarea programada existente (si existe)..." -ForegroundColor Yellow
schtasks /delete /tn "$TaskName" /f 2>$null | Out-Null

# Crear la nueva tarea programada
Write-Host "Creando nueva tarea programada..." -ForegroundColor Yellow
Write-Host "  Nombre: $TaskName" -ForegroundColor White
Write-Host "  Intervalo: Cada $IntervalMinutes minutos" -ForegroundColor White
Write-Host "  Script: $batchFile" -ForegroundColor White
Write-Host ""

$taskCommand = "schtasks /create /tn `"$TaskName`" /tr `"$batchFile`" /sc minute /mo $IntervalMinutes /rl highest /f"

# Ejecutar el comando
Invoke-Expression $taskCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host "" -ForegroundColor Green
    Write-Host "✓ TAREA PROGRAMADA CREADA EXITOSAMENTE" -ForegroundColor Green
    Write-Host "" -ForegroundColor Green
    Write-Host "Detalles de la tarea:" -ForegroundColor White
    Write-Host "  • Nombre: $TaskName" -ForegroundColor White
    Write-Host "  • Ejecuta: Cada $IntervalMinutes minutos" -ForegroundColor White
    Write-Host "  • Comando: $batchFile" -ForegroundColor White
    Write-Host "  • Ejecuta con permisos elevados" -ForegroundColor White
    Write-Host ""

    # Mostrar información adicional
    Write-Host "Para gestionar la tarea:" -ForegroundColor Cyan
    Write-Host "  • Programador de tareas → Biblioteca → $TaskName" -ForegroundColor White
    Write-Host "  • Para ejecutar manualmente: schtasks /run /tn `"$TaskName`"" -ForegroundColor White
    Write-Host "  • Para eliminar: schtasks /delete /tn `"$TaskName`"" -ForegroundColor White
    Write-Host ""

    # Probar la tarea inmediatamente
    Write-Host "¿Quieres probar la tarea ahora? (s/n): " -ForegroundColor Yellow -NoNewline
    $testResponse = Read-Host

    if ($testResponse -eq 's' -or $testResponse -eq 'S') {
        Write-Host "Ejecutando tarea de prueba..." -ForegroundColor Yellow
        schtasks /run /tn "$TaskName"
        Start-Sleep -Seconds 2

        # Verificar estado
        $taskInfo = schtasks /query /tn "$TaskName" /fo list /v 2>$null | Select-String "Status:"
        Write-Host "Estado de la tarea: $taskInfo" -ForegroundColor White
    }

} else {
    Write-Host "ERROR: No se pudo crear la tarea programada" -ForegroundColor Red
    Write-Host "Código de error: $LASTEXITCODE" -ForegroundColor Red
    Write-Host ""
    Write-Host "Solución alternativa:" -ForegroundColor Yellow
    Write-Host "  1. Abre el Programador de tareas (taskschd.msc)" -ForegroundColor White
    Write-Host "  2. Crea una nueva tarea básica" -ForegroundColor White
    Write-Host "  3. Nombre: $TaskName" -ForegroundColor White
    Write-Host "  4. Programa: $batchFile" -ForegroundColor White
    Write-Host "  5. Ejecutar cada $IntervalMinutes minutos" -ForegroundColor White
    Write-Host "  6. Ejecutar con los privilegios más altos" -ForegroundColor White
}

Write-Host ""
Write-Host "Presiona Enter para finalizar..." -ForegroundColor Gray
Read-Host
