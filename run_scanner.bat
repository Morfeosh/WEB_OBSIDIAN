@echo off
echo ========================================
echo Ejecutando escaneo de estructura Obsidian
echo %DATE% %TIME%
echo ========================================

cd /d "%~dp0"

REM Verificar que Python esté disponible
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python no está instalado o no está en el PATH
    pause
    exit /b 1
)

REM Ejecutar el script de escaneo
echo Ejecutando generate_structure.py...
python generate_structure.py

REM Verificar si la ejecución fue exitosa
if errorlevel 1 (
    echo ERROR: El script falló con código de error %errorlevel%
    echo Reintentando en 5 segundos...
    timeout /t 5 /nobreak >nul
    python generate_structure.py
    if errorlevel 1 (
        echo ERROR: El script falló nuevamente
        pause
        exit /b 1
    )
)

echo ========================================
echo Escaneo completado exitosamente
echo ========================================
echo.

REM Mantener la ventana abierta por 10 segundos para ver los resultados
timeout /t 10 /nobreak >nul
exit /b 0
