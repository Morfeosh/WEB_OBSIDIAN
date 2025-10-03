#!/bin/bash

# Script de instalación para el sistema de monitoreo automático de Obsidian
# Este script configura el monitoreo automático de archivos en Linux

set -e

echo "=== Instalación del Sistema de Monitoreo Obsidian ==="
echo

# Verificar que estamos en el directorio correcto
if [ ! -f "monitor_obsidian.sh" ]; then
    echo "Error: Este script debe ejecutarse desde el directorio WEB_OBSIDIAN"
    exit 1
fi

# Hacer el script de monitoreo ejecutable
chmod +x monitor_obsidian.sh

echo "✅ Script monitor_obsidian.sh hecho ejecutable"

# Crear directorio de logs si no existe
LOG_DIR="/var/log"
USER_LOG_DIR="$HOME/logs"

# Intentar crear en /var/log (requiere sudo)
if [ -w "$LOG_DIR" ]; then
    LOG_FILE="$LOG_DIR/obsidian_monitor.log"
    echo "✅ Usando directorio de logs del sistema: $LOG_FILE"
else
    # Crear directorio de logs en el home del usuario
    mkdir -p "$USER_LOG_DIR"
    LOG_FILE="$USER_LOG_DIR/obsidian_monitor.log"
    echo "✅ Usando directorio de logs del usuario: $LOG_FILE"
fi

touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

echo "✅ Archivo de log creado: $LOG_FILE"

# Mostrar opciones de instalación
echo
echo "=== OPCIONES DE INSTALACIÓN ==="
echo "1. Instalar en crontab del usuario actual (recomendado)"
echo "2. Instalar en /etc/cron.d/ (requiere sudo)"
echo "3. Solo crear archivos de configuración"
echo

read -p "Selecciona una opción (1-3): " choice

case $choice in
    1)
        # Instalar en crontab del usuario
        echo
        echo "Instalando en crontab del usuario..."
        
        # Verificar si ya existe la configuración
        if crontab -l 2>/dev/null | grep -q "monitor_obsidian.sh"; then
            echo "⚠️  Ya existe configuración de cron para Obsidian. Actualizando..."
            # Remover configuraciones existentes
            crontab -l 2>/dev/null | grep -v "monitor_obsidian.sh" | crontab -
        fi
        
        # Agregar nuevas configuraciones
        (crontab -l 2>/dev/null; echo "# Monitoreo automático de Obsidian") | crontab -
        (crontab -l; echo "*/5 8-22 * * * $PWD/monitor_obsidian.sh --check-changes >> $LOG_FILE 2>&1") | crontab -
        (crontab -l; echo "0 2 * * * $PWD/monitor_obsidian.sh --full-scan >> $LOG_FILE 2>&1") | crontab -
        (crontab -l; echo "0 * * * * $PWD/monitor_obsidian.sh --status >> $LOG_FILE 2>&1") | crontab -
        
        echo "✅ Configuración de cron instalada en crontab del usuario"
        ;;
        
    2)
        # Instalar en /etc/cron.d/
        echo
        echo "Instalando en /etc/cron.d/..."
        
        if [ "$EUID" -ne 0 ]; then
            echo "⚠️  Esta opción requiere permisos de superusuario"
            echo "Ejecutando con sudo..."
            sudo bash -c "
                cat > /etc/cron.d/obsidian_monitor << 'EOF'
# Monitoreo automático de archivos Obsidian
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Ejecutar cada 5 minutos durante horario activo
*/5 8-22 * * * $USER $PWD/monitor_obsidian.sh --check-changes >> $LOG_FILE 2>&1

# Escaneo completo diario
0 2 * * * $USER $PWD/monitor_obsidian.sh --full-scan >> $LOG_FILE 2>&1

# Verificación de estado cada hora
0 * * * * $USER $PWD/monitor_obsidian.sh --status >> $LOG_FILE 2>&1
EOF
                chmod 644 /etc/cron.d/obsidian_monitor
            "
        else
            cat > /etc/cron.d/obsidian_monitor << EOF
# Monitoreo automático de archivos Obsidian
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Ejecutar cada 5 minutos durante horario activo
*/5 8-22 * * * $USER $PWD/monitor_obsidian.sh --check-changes >> $LOG_FILE 2>&1

# Escaneo completo diario
0 2 * * * $USER $PWD/monitor_obsidian.sh --full-scan >> $LOG_FILE 2>&1

# Verificación de estado cada hora
0 * * * * $USER $PWD/monitor_obsidian.sh --status >> $LOG_FILE 2>&1
EOF
            chmod 644 /etc/cron.d/obsidian_monitor
        fi
        
        echo "✅ Configuración de cron instalada en /etc/cron.d/obsidian_monitor"
        ;;
        
    3)
        echo
        echo "✅ Archivos de configuración creados:"
        echo "   - monitor_obsidian.sh (ejecutable)"
        echo "   - cron_obsidian_monitor (configuración de cron)"
        echo "   - $LOG_FILE (archivo de log)"
        echo
        echo "Para instalar manualmente, ejecuta:"
        echo "crontab -e"
        echo "Y agrega las líneas del archivo cron_obsidian_monitor"
        ;;
        
    *)
        echo "❌ Opción no válida"
        exit 1
        ;;
esac

# Probar el script de monitoreo
echo
echo "=== Probando el script de monitoreo ==="
if ./monitor_obsidian.sh --status; then
    echo "✅ Script de monitoreo funciona correctamente"
else
    echo "⚠️  El script de monitoreo encontró algunos problemas"
fi

# Mostrar información de instalación
echo
echo "=== INSTALACIÓN COMPLETADA ==="
echo
echo "📊 Configuración del monitoreo:"
echo "   - Verificación de cambios: Cada 5 minutos (8 AM - 10 PM)"
echo "   - Escaneo completo: Diario a las 2 AM"
echo "   - Verificación de estado: Cada hora"
echo
echo "📝 Archivo de log: $LOG_FILE"
echo
echo "🔧 Comandos útiles:"
echo "   - Ver estado: ./monitor_obsidian.sh --status"
echo "   - Ver logs: tail -f $LOG_FILE"
echo "   - Ejecutar manualmente: ./monitor_obsidian.sh --check-changes"
echo
echo "🔄 Para desinstalar:"
echo "   - crontab -e (y eliminar las líneas de Obsidian)"
echo "   - O: sudo rm /etc/cron.d/obsidian_monitor"
echo

# Iniciar el daemon de monitoreo
echo "¿Deseas iniciar el daemon de monitoreo ahora? (s/N)"
read -p "> " start_daemon

if [[ $start_daemon =~ ^[Ss]$ ]]; then
    echo "Iniciando daemon de monitoreo..."
    if ./monitor_obsidian.sh --daemon; then
        echo "✅ Daemon de monitoreo iniciado"
        echo "PID: $(cat /tmp/obsidian_monitor.pid 2>/dev/null || echo 'No disponible')"
    else
        echo "❌ Error al iniciar el daemon"
    fi
fi

echo
echo "🎉 ¡Instalación completada! El sistema monitoreará automáticamente los cambios en tus archivos Obsidian."