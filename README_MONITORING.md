# Sistema de Monitoreo Automático para Obsidian Web

Este sistema proporciona monitoreo automático de archivos para la aplicación web Obsidian, detectando cambios, archivos nuevos y eliminados en tiempo real.

## 🎯 Características

- **Monitoreo en tiempo real** de cambios en archivos
- **Detección automática** de archivos nuevos y eliminados
- **Interfaz web similar a Obsidian** con árbol de archivos expandible
- **Sistema de notificaciones** para cambios detectados
- **Monitoreo programado** con cron (Linux) o tareas programadas (Windows)
- **Logs detallados** de todas las operaciones

## 📁 Estructura del Proyecto

```
WEB_OBSIDIAN/
├── index.html                 # Aplicación web principal
├── monitor_obsidian.sh        # Script de monitoreo (Linux)
├── install_monitoring.sh      # Script de instalación (Linux)
├── cron_obsidian_monitor      # Configuración de cron
├── run_scanner.bat           # Script de escaneo (Windows)
├── setup_scheduled_task.ps1  # Configuración de tareas (Windows)
└── obsidian/                 # Carpeta con archivos Obsidian
    ├── 01-notas/
    ├── 02-servidores/
    ├── 03-ia/
    └── ... (todas las carpetas y archivos)
```

## 🚀 Instalación Rápida

### Para Linux:

1. **Hacer ejecutable el script:**
   ```bash
   chmod +x install_monitoring.sh
   ```

2. **Ejecutar instalación:**
   ```bash
   ./install_monitoring.sh
   ```

3. **Seguir las instrucciones en pantalla**

### Para Windows:

1. **Ejecutar PowerShell como administrador:**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Ejecutar script de configuración:**
   ```powershell
   .\setup_scheduled_task.ps1
   ```

## ⚙️ Configuración Manual

### Configuración de Cron (Linux)

Agregar al crontab del usuario:
```bash
crontab -e
```

Agregar las siguientes líneas:
```
# Monitoreo automático de Obsidian
*/5 8-22 * * * /ruta/a/WEB_OBSIDIAN/monitor_obsidian.sh --check-changes >> /var/log/obsidian_monitor.log 2>&1
0 2 * * * /ruta/a/WEB_OBSIDIAN/monitor_obsidian.sh --full-scan >> /var/log/obsidian_monitor.log 2>&1
0 * * * * /ruta/a/WEB_OBSIDIAN/monitor_obsidian.sh --status >> /var/log/obsidian_monitor.log 2>&1
```

### Tareas Programadas (Windows)

1. Abrir "Programador de tareas"
2. Crear nueva tarea básica
3. Configurar para ejecutar `run_scanner.bat` periódicamente

## 🔧 Uso del Sistema

### Comandos del Script de Monitoreo

```bash
# Ver estado del sistema
./monitor_obsidian.sh --status

# Verificar cambios
./monitor_obsidian.sh --check-changes

# Escaneo completo
./monitor_obsidian.sh --full-scan

# Ejecutar como daemon
./monitor_obsidian.sh --daemon

# Ver logs
tail -f /var/log/obsidian_monitor.log
```

### Funcionalidades de la Web

- **Árbol de archivos expandible**: Haz clic en las carpetas para expandir/contraer
- **Búsqueda en tiempo real**: Escribe en la barra de búsqueda para filtrar archivos
- **Vista gráfica**: Visualiza las relaciones entre archivos y carpetas
- **Monitoreo automático**: La web detecta cambios automáticamente
- **Temas claro/oscuro**: Alterna entre modos de visualización

## 🐛 Solución de Problemas

### Las carpetas no se expanden
- Verificar que JavaScript esté habilitado
- Revisar la consola del navegador para errores
- Actualizar la página (F5)

### No se detectan cambios
- Verificar permisos de lectura en la carpeta obsidian
- Comprobar que el script de monitoreo esté ejecutándose
- Revisar el archivo de logs

### Error de permisos en Linux
```bash
# Dar permisos de ejecución
chmod +x *.sh

# Verificar permisos de la carpeta obsidian
ls -la obsidian/
```

## 📊 Logs y Monitoreo

### Archivos de Log
- **Linux**: `/var/log/obsidian_monitor.log` o `~/logs/obsidian_monitor.log`
- **Windows**: `%TEMP%\obsidian_monitor.log`

### Contenido de los Logs
- Cambios detectados en archivos
- Archivos nuevos/eliminados
- Errores y advertencias
- Estado del sistema

## 🔄 Actualización

Para actualizar el sistema:

1. **Detener el monitoreo:**
   ```bash
   ./monitor_obsidian.sh --stop
   ```

2. **Actualizar archivos**
3. **Reiniciar el monitoreo:**
   ```bash
   ./monitor_obsidian.sh --daemon
   ```

## 🗑️ Desinstalación

### Linux
```bash
# Remover de crontab
crontab -e
# Eliminar las líneas relacionadas con Obsidian

# O eliminar archivo de configuración del sistema
sudo rm /etc/cron.d/obsidian_monitor
```

### Windows
1. Abrir "Programador de tareas"
2. Eliminar la tarea "Obsidian File Monitor"
3. Eliminar archivos de scripts si es necesario

## 📞 Soporte

Si encuentras problemas:
1. Revisa los archivos de log
2. Verifica que todos los scripts sean ejecutables
3. Comprueba los permisos de la carpeta obsidian
4. Asegúrate de que la aplicación web esté funcionando correctamente

## 🎉 ¡Listo!

Tu sistema de monitoreo automático de Obsidian está configurado y funcionando. La aplicación web detectará automáticamente cualquier cambio en tus archivos y mantendrá el índice siempre actualizado.