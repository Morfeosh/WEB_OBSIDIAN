#!/bin/bash

# Script de monitoreo para Obsidian Web en Linux
# Este script monitorea cambios en la carpeta obsidian y actualiza la aplicación

# Configuración
OBSIDIAN_DIR="./obsidian"
LOG_FILE="./monitor.log"
CHECK_INTERVAL=30  # Segundos entre verificaciones

# Función para registrar logs
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$1"
}

# Función para verificar cambios en archivos
check_file_changes() {
    local current_files=$(find "$OBSIDIAN_DIR" -name "*.html" -type f | sort)
    local last_files=""
    
    # Si existe archivo de estado anterior, cargarlo
    if [ -f "./last_files.txt" ]; then
        last_files=$(cat "./last_files.txt")
    fi
    
    # Comparar archivos actuales con los anteriores
    if [ "$current_files" != "$last_files" ]; then
        log_message "Cambios detectados en la estructura de archivos"
        
        # Guardar estado actual
        echo "$current_files" > "./last_files.txt"
        
        # Aquí podrías agregar acciones adicionales como:
        # - Reiniciar el servidor web
        # - Actualizar índices de búsqueda
        # - Enviar notificaciones
        log_message "Estructura actualizada - Archivos encontrados: $(echo "$current_files" | wc -l)"
    fi
}

# Función para verificar archivos modificados
check_modified_files() {
    local modified_files=$(find "$OBSIDIAN_DIR" -name "*.html" -type f -mmin -1)
    
    if [ -n "$modified_files" ]; then
        log_message "Archivos modificados recientemente:"
        echo "$modified_files" | while read -r file; do
            log_message "  - $file"
        done
    fi
}

# Función principal de monitoreo
start_monitoring() {
    log_message "Iniciando monitoreo de carpeta obsidian..."
    log_message "Directorio: $OBSIDIAN_DIR"
    log_message "Intervalo de verificación: $CHECK_INTERVAL segundos"
    
    # Crear archivo de estado inicial si no existe
    if [ ! -f "./last_files.txt" ]; then
        find "$OBSIDIAN_DIR" -name "*.html" -type f | sort > "./last_files.txt"
        log_message "Estado inicial guardado"
    fi
    
    # Bucle principal de monitoreo
    while true; do
        check_file_changes
        check_modified_files
        sleep $CHECK_INTERVAL
    done
}

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  start     Iniciar monitoreo en primer plano"
    echo "  daemon    Iniciar monitoreo en segundo plano"
    echo "  stop      Detener monitoreo en segundo plano"
    echo "  status    Ver estado del monitoreo"
    echo "  logs      Mostrar logs recientes"
    echo "  help      Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 start          # Monitoreo en primer plano"
    echo "  $0 daemon         # Monitoreo en segundo plano"
    echo "  $0 status         # Ver estado"
    echo "  $0 logs           # Ver logs"
}

# Función para iniciar como daemon
start_daemon() {
    if [ -f "./monitor.pid" ]; then
        local pid=$(cat "./monitor.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo "El monitoreo ya está ejecutándose (PID: $pid)"
            return 1
        else
            rm -f "./monitor.pid"
        fi
    fi
    
    nohup "$0" start > /dev/null 2>&1 &
    local daemon_pid=$!
    echo $daemon_pid > "./monitor.pid"
    echo "Monitoreo iniciado en segundo plano (PID: $daemon_pid)"
    log_message "Monitoreo iniciado como daemon (PID: $daemon_pid)"
}

# Función para detener daemon
stop_daemon() {
    if [ -f "./monitor.pid" ]; then
        local pid=$(cat "./monitor.pid")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            echo "Monitoreo detenido (PID: $pid)"
            log_message "Monitoreo detenido (PID: $pid)"
        else
            echo "El monitoreo no está ejecutándose"
        fi
        rm -f "./monitor.pid"
    else
        echo "No hay monitoreo ejecutándose"
    fi
}

# Función para ver estado
show_status() {
    if [ -f "./monitor.pid" ]; then
        local pid=$(cat "./monitor.pid")
        if kill -0 "$pid" 2>/dev/null; then
            echo "✅ Monitoreo ejecutándose (PID: $pid)"
            echo "📊 Última verificación: $(stat -c %y "./last_files.txt" 2>/dev/null || echo "Nunca")"
            echo "📝 Archivos monitoreados: $(find "$OBSIDIAN_DIR" -name "*.html" -type f 2>/dev/null | wc -l || echo 0)"
        else
            echo "❌ Monitoreo no está ejecutándose (PID obsoleto: $pid)"
            rm -f "./monitor.pid"
        fi
    else
        echo "❌ Monitoreo no está ejecutándose"
    fi
}

# Función para mostrar logs
show_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo "=== Últimas 20 líneas del log ==="
        tail -20 "$LOG_FILE"
    else
        echo "No hay archivo de log disponible"
    fi
}

# Verificar que el directorio obsidian existe
if [ ! -d "$OBSIDIAN_DIR" ]; then
    echo "Error: El directorio $OBSIDIAN_DIR no existe"
    exit 1
fi

# Procesar argumentos
case "${1:-help}" in
    start)
        start_monitoring
        ;;
    daemon)
        start_daemon
        ;;
    stop)
        stop_daemon
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Opción no válida: $1"
        show_help
        exit 1
        ;;
esac