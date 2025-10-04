# Obsidian Web

Una aplicación web moderna para leer y navegar por tus notas de Obsidian exportadas como HTML, con una interfaz similar a Obsidian pero optimizada para la web.

## 🚀 Características

- **Interfaz estilo Obsidian**: Árbol de archivos que se expande verticalmente
- **Responsive**: Se adapta a desktop, tablet y móvil
- **Vista gráfica**: Mapa de conocimiento con zoom y pan
- **Búsqueda en tiempo real**: Encuentra archivos rápidamente
- **Tema oscuro/claro**: Alterna entre temas visuales
- **Monitorización automática**: Detecta cambios en archivos externos
- **Extracción inteligente**: Procesa archivos HTML exportados de Obsidian
- **Pestañas múltiples**: Abre varios archivos simultáneamente

## 📁 Estructura del Proyecto

```
WEB_OBSIDIAN/
├── index.html              # Aplicación principal
├── generate_structure.py   # Script de escaneo de archivos
├── run_scanner.bat         # Ejecutable para Windows
├── setup_scheduled_task.ps1 # Configuración automática de tarea programada
├── obsidian/               # Carpeta con archivos HTML exportados
│   ├── 01-notas/
│   ├── 02-servidores/
│   ├── 03-ia/
│   └── ...
├── obsidian_structure.js   # Estructura generada automáticamente
└── obsidian_structure.json # Estructura en formato JSON
```

## 🛠️ Instalación y Configuración

### 1. Requisitos Previos

- **Python 3.6+** instalado y en el PATH
- **Servidor web** (Apache, Nginx, o servidor local)
- Archivos HTML exportados de Obsidian en la carpeta `obsidian/`

### 2. Configuración Inicial

1. **Exportar notas de Obsidian**:
   - En Obsidian: `Archivo → Exportar → Exportar a HTML`
   - Coloca los archivos en la carpeta `obsidian/`

2. **Generar estructura inicial**:
   ```bash
   python generate_structure.py
   ```

3. **Configurar tarea programada automática** (Windows):
   ```powershell
   # Ejecutar como Administrador
   .\setup_scheduled_task.ps1
   ```

### 3. Configuración Manual de Tarea Programada

Si prefieres configurar manualmente:

1. Abre **Programador de tareas** (`taskschd.msc`)
2. **Crear tarea básica**:
   - Nombre: `ObsidianStructureScanner`
   - Programa: `run_scanner.bat` (ruta completa)
   - Ejecutar cada: 60 minutos
   - Ejecutar con privilegios más altos

### 4. Ejecutar la Aplicación

#### Opción A: Servidor Local (Recomendado)
```bash
python -m http.server 3000
```
Luego abre: `http://localhost:3000`

#### Opción B: Archivo Local
Abre `index.html` directamente en el navegador (limitaciones de CORS)

## 🔧 Uso

### Navegación
- **Clic en carpetas**: Expande/colapsa el contenido
- **Clic en archivos**: Abre en nueva pestaña
- **Búsqueda**: Escribe en el campo de búsqueda para filtrar

### Atajos de Teclado
- `Ctrl+B`: Alternar sidebar
- `Ctrl+E`: Alternar modo edición
- `Ctrl+G`: Alternar vista gráfica
- `Ctrl+S`: Guardar archivo actual

### Vista Gráfica
- **Rueda del mouse**: Zoom in/out
- **Arrastrar**: Mover el mapa
- **Tooltips**: Pasa el mouse sobre nodos para ver nombres completos

## 🔄 Automatización

### Tarea Programada (Windows)

El script `setup_scheduled_task.ps1` configura automáticamente una tarea que:

- **Ejecuta cada hora** (configurable)
- **Escanea la carpeta obsidian/** en busca de cambios
- **Actualiza automáticamente** `obsidian_structure.js`
- **Se ejecuta en segundo plano** sin intervención

### Ejecución Manual

Para actualizar manualmente la estructura:
```bash
python generate_structure.py
```

O usando el batch:
```bash
run_scanner.bat
```

## 📊 Archivos Generados

### `obsidian_structure.js`
Código JavaScript que contiene la estructura completa de archivos. Este archivo se incluye automáticamente en `index.html`.

### `obsidian_structure.json`
Versión JSON de la estructura para uso programático o debugging.

## 🐛 Solución de Problemas

### La aplicación no carga
- Verifica que `obsidian_structure.js` existe y es válido
- Revisa la consola del navegador (F12)
- Asegúrate de que los archivos HTML están en `obsidian/`

### Carpetas no se expanden
- Verifica que `obsidian_structure.js` esté actualizado
- Recarga la página (Ctrl+F5)
- Ejecuta `python generate_structure.py` manualmente

### Tarea programada no funciona
- Ejecuta PowerShell como Administrador
- Verifica que Python esté en el PATH del sistema
- Revisa el Visor de eventos de Windows para errores

### Archivos no aparecen
- Ejecuta `python generate_structure.py` para regenerar
- Verifica que los archivos sean `.html`
- Comprueba permisos de lectura en la carpeta `obsidian/`

## 🔧 Personalización

### Cambiar intervalo de escaneo
```powershell
# Ejecutar cada 30 minutos
.\setup_scheduled_task.ps1 -IntervalMinutes 30
```

### Cambiar nombre de tarea
```powershell
.\setup_scheduled_task.ps1 -TaskName "MiEscaneoObsidian"
```

### Modificar estilos CSS
Edita la sección `<style>` en `index.html` para personalizar colores, fuentes, etc.

## 📈 Rendimiento

- **Escaneo optimizado**: Solo archivos `.html` son procesados
- **Caché inteligente**: Estructura se guarda localmente
- **Lazy loading**: Archivos se cargan solo cuando se abren
- **Monitorización eficiente**: Verificación cada 30 segundos sin impacto

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 🙏 Agradecimientos

- **Obsidian**: Por la inspiración y el formato de exportación
- **La comunidad**: Por el feedback y contribuciones
- **Tecnologías web**: HTML5, CSS3, JavaScript moderno

---

**Nota**: Esta aplicación es un complemento para Obsidian, no un reemplazo. Tus notas originales en Obsidian permanecen intactas.

