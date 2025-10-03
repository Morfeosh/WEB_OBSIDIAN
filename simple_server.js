const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const port = 3000;

// Función para servir archivos estáticos
function serveStaticFile(res, filePath, contentType) {
    fs.readFile(filePath, (err, data) => {
        if (err) {
            res.writeHead(404, { 'Content-Type': 'text/plain' });
            res.end('Archivo no encontrado');
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(data);
        }
    });
}

// Función para ejecutar el script de Python
function executeScanScript(res) {
    const { exec } = require('child_process');
    
    console.log('🔍 Ejecutando script de escaneo...');
    
    exec('py generate_structure.py', (error, stdout, stderr) => {
        if (error) {
            console.error('❌ Error ejecutando el script:', error);
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
                success: false,
                error: error.message,
                stderr: stderr
            }));
            return;
        }
        
        console.log('✅ Escaneo completado exitosamente');
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            success: true,
            message: 'Escaneo completado exitosamente',
            output: stdout
        }));
    });
}

// Función para guardar archivos
function saveFile(req, res) {
    let body = '';
    
    req.on('data', chunk => {
        body += chunk.toString();
    });
    
    req.on('end', () => {
        try {
            const { path: filePath, content } = JSON.parse(body);
            
            if (!filePath || !content) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'Ruta y contenido son requeridos' }));
                return;
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
            
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({
                success: true,
                message: 'Archivo guardado correctamente',
                path: fullPath
            }));
        } catch (error) {
            console.error('❌ Error guardando archivo:', error);
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: error.message }));
        }
    });
}

// Función para eliminar archivos
function deleteFile(req, res) {
    let body = '';
    
    req.on('data', chunk => {
        body += chunk.toString();
    });
    
    req.on('end', () => {
        try {
            const { path: filePath } = JSON.parse(body);
            
            if (!filePath) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'Ruta del archivo es requerida' }));
                return;
            }
            
            // Asegurar que el archivo está en la carpeta obsidian
            const fullPath = filePath.startsWith('obsidian/') ? filePath : `obsidian/${filePath}`;
            
            if (fs.existsSync(fullPath)) {
                fs.unlinkSync(fullPath);
                console.log(`🗑️ Archivo eliminado: ${fullPath}`);
                
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    success: true,
                    message: 'Archivo eliminado correctamente'
                }));
            } else {
                res.writeHead(404, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    success: false,
                    message: 'Archivo no encontrado'
                }));
            }
        } catch (error) {
            console.error('❌ Error eliminando archivo:', error);
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: error.message }));
        }
    });
}

// Crear servidor
const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    const pathname = parsedUrl.pathname;
    
    // Configurar CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }
    
    // Manejar rutas de API
    if (req.method === 'POST' && pathname === '/api/scan-files') {
        executeScanScript(res);
        return;
    }
    
    if (req.method === 'POST' && pathname === '/api/save-file') {
        saveFile(req, res);
        return;
    }
    
    if (req.method === 'POST' && pathname === '/api/delete-file') {
        deleteFile(req, res);
        return;
    }
    
    if (req.method === 'GET' && pathname === '/api/structure') {
        if (fs.existsSync('obsidian_structure.js')) {
            serveStaticFile(res, 'obsidian_structure.js', 'application/javascript');
        } else {
            res.writeHead(404, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: 'Estructura no encontrada' }));
        }
        return;
    }
    
    // Servir archivos estáticos
    if (pathname === '/') {
        serveStaticFile(res, 'index.html', 'text/html');
    } else if (pathname.endsWith('.js')) {
        serveStaticFile(res, pathname.slice(1), 'application/javascript');
    } else if (pathname.endsWith('.css')) {
        serveStaticFile(res, pathname.slice(1), 'text/css');
    } else if (pathname.endsWith('.html')) {
        serveStaticFile(res, pathname.slice(1), 'text/html');
    } else if (pathname.endsWith('.png')) {
        serveStaticFile(res, pathname.slice(1), 'image/png');
    } else if (pathname.endsWith('.jpg') || pathname.endsWith('.jpeg')) {
        serveStaticFile(res, pathname.slice(1), 'image/jpeg');
    } else if (pathname.endsWith('.pdf')) {
        serveStaticFile(res, pathname.slice(1), 'application/pdf');
    } else {
        // Intentar servir el archivo como está
        const filePath = pathname.slice(1);
        if (fs.existsSync(filePath)) {
            const ext = path.extname(filePath).toLowerCase();
            const contentType = {
                '.html': 'text/html',
                '.css': 'text/css',
                '.js': 'application/javascript',
                '.json': 'application/json',
                '.png': 'image/png',
                '.jpg': 'image/jpeg',
                '.jpeg': 'image/jpeg',
                '.gif': 'image/gif',
                '.pdf': 'application/pdf'
            }[ext] || 'text/plain';
            
            serveStaticFile(res, filePath, contentType);
        } else {
            res.writeHead(404, { 'Content-Type': 'text/plain' });
            res.end('Archivo no encontrado');
        }
    }
});

server.listen(port, () => {
    console.log(`🌐 Servidor web simple corriendo en http://localhost:${port}`);
    console.log(`📁 Archivos servidos desde: ${__dirname}`);
    console.log(`🔗 Abre tu navegador en: http://localhost:${port}`);
    console.log(`🔍 Endpoint de escaneo disponible en: POST http://localhost:${port}/api/scan-files`);
    console.log(`💾 Endpoint de guardado disponible en: POST http://localhost:${port}/api/save-file`);
    console.log(`🗑️ Endpoint de eliminación disponible en: POST http://localhost:${port}/api/delete-file`);
});