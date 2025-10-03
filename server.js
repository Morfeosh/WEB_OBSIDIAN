const express = require('express');
const path = require('path');
const { exec } = require('child_process');
const fs = require('fs');
const app = express();
const port = 3012;

// Middleware para parsear JSON
app.use(express.json());

// Servir archivos estáticos desde el directorio actual
app.use(express.static(path.join(__dirname)));

// Ruta principal
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Endpoint para ejecutar el script de escaneo
app.post('/api/scan-files', (req, res) => {
    console.log('🔍 Ejecutando script de escaneo...');
    
    exec('py generate_structure.py', (error, stdout, stderr) => {
        if (error) {
            console.error('❌ Error ejecutando el script:', error);
            return res.status(500).json({
                success: false,
                error: error.message,
                stderr: stderr
            });
        }
        
        console.log('✅ Escaneo completado exitosamente');
        console.log('📊 Resultado:', stdout);
        
        res.json({
            success: true,
            message: 'Escaneo completado exitosamente',
            output: stdout
        });
    });
});

// Endpoint para obtener la estructura actual
app.get('/api/structure', (req, res) => {
    try {
        if (fs.existsSync('obsidian_structure.js')) {
            res.sendFile(path.join(__dirname, 'obsidian_structure.js'));
        } else {
            res.status(404).json({ error: 'Estructura no encontrada' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Endpoint para guardar archivos
app.post('/api/save-file', (req, res) => {
    try {
        const { path: filePath, content } = req.body;
        
        if (!filePath || !content) {
            return res.status(400).json({ error: 'Ruta y contenido son requeridos' });
        }
        
        // Asegurar que el archivo se guarde en la carpeta obsidian
        const fullPath = filePath.startsWith('obsidian/') ? filePath : `obsidian/${filePath}`;
        
        // Crear directorios si no existen
        const dir = path.dirname(fullPath);
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }
        
        // Guardar el archivo
        fs.writeFileSync(fullPath, content, 'utf8');
        
        console.log(`✅ Archivo guardado: ${fullPath}`);
        
        res.json({
            success: true,
            message: 'Archivo guardado correctamente',
            path: fullPath
        });
    } catch (error) {
        console.error('❌ Error guardando archivo:', error);
        res.status(500).json({ error: error.message });
    }
});

app.listen(port, () => {
    console.log(`🌐 Servidor web corriendo en http://localhost:${port}`);
    console.log(`📁 Archivos servidos desde: ${__dirname}`);
    console.log(`🔗 Abre tu navegador en: http://localhost:${port}`);
    console.log(`🔍 Endpoint de escaneo disponible en: POST http://localhost:${port}/api/scan-files`);
});
