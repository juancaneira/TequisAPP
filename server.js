require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { getPool } = require('./config/db');

const authRoutes = require('./routes/auth');
const medicoRoutes = require('./routes/medico');

const app = express();
const PORT = process.env.PORT || 3000;

// Permite llamadas desde apps móviles y navegadores de cualquier origen
// En producción, reemplaza '*' por la URL específica de tu frontend
app.use(cors({ origin: '*' }));

// Interpreta el body de las peticiones como JSON
app.use(express.json());

// Ruta de salud: confirma que el servidor está corriendo
app.get('/', (req, res) => {
  res.json({
    servicio: 'WinlabwebAPI',
    version: '1.0.0',
    estado: 'en línea',
    timestamp: new Date().toISOString(),
  });
});

// Rutas de la API
app.use('/api/auth', authRoutes);
app.use('/api/medico', medicoRoutes);

// Manejador de rutas no encontradas (404)
app.use((req, res) => {
  res.status(404).json({ error: `Ruta no encontrada: ${req.method} ${req.originalUrl}` });
});

// Manejador global de errores (500)
app.use((err, req, res, next) => {
  console.error('Error no manejado:', err.stack);
  res.status(500).json({ error: 'Error interno del servidor' });
});

// Inicia el servidor y la conexión a la DB al mismo tiempo
async function iniciarServidor() {
  try {
    await getPool(); // Establece el pool de conexiones antes de aceptar peticiones
    app.listen(PORT, () => {
      console.log(`\nWinlabwebAPI corriendo en http://localhost:${PORT}`);
      console.log('Endpoints disponibles:');
      console.log(`  POST http://localhost:${PORT}/api/auth/login`);
      console.log(`  GET  http://localhost:${PORT}/api/medico/pdfs   (requiere token)`);
      console.log(`  GET  http://localhost:${PORT}/api/medico/pdf/:id (requiere token)\n`);
    });
  } catch (err) {
    console.error('No se pudo iniciar el servidor:', err.message);
    process.exit(1);
  }
}

iniciarServidor();
