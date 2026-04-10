require('dotenv').config();
const express = require('express');
const cors = require('cors');
const sql = require('mssql');

const app = express();
const PORT = process.env.PORT || 3000;

// ─── CORS ────────────────────────────────────────────────────────────────────
// Permite llamadas desde FlutterFlow y cualquier app móvil/web.
// En producción puedes reemplazar origin:'*' por tu dominio específico.
app.use(cors({ origin: '*' }));
app.use(express.json());

// ─── CONEXIÓN A SQL SERVER ───────────────────────────────────────────────────
const dbConfig = {
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.DB_PORT) || 1433,
  options: {
    trustServerCertificate: true, // necesario para servidores locales con certificado autofirmado
    encrypt: false,
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
};

// Pool global reutilizable (se crea una sola vez al arrancar)
let pool;

async function getPool() {
  if (!pool) {
    pool = await sql.connect(dbConfig);
    console.log(`Conectado a SQL Server: ${dbConfig.server} / ${dbConfig.database}`);
  }
  return pool;
}

// ─── ENDPOINTS ───────────────────────────────────────────────────────────────

// Ruta de salud: confirma que la API está en línea
app.get('/', function(req, res) {
  res.json({
    servicio: 'WinlabwebAPI',
    version: '1.0.0',
    estado: 'en linea',
    timestamp: new Date().toISOString()
  });
});

/**
 * POST /login
 *
 * Body: { "usuario": "...", "contrasena": "..." }
 *
 * Busca primero en UtentiMedici; si no encuentra, busca en UtentiPazienti.
 * Devuelve los datos del usuario y el rol encontrado ("medico" o "paciente").
 *
 * NOTA: La comparación de contraseña asume texto plano (sistema legacy).
 * Si tu DB usa hash (MD5, bcrypt...) ajusta la condición WHERE o la comparación
 * en JavaScript según corresponda.
 */
app.post('/login', async (req, res) => {
  const { usuario, contrasena } = req.body;

  if (!usuario || !contrasena) {
    return res.status(400).json({ error: 'Los campos usuario y contrasena son requeridos' });
  }

  try {
    const db = await getPool();

    // 1) Buscar en UtentiMedici
    const resMedico = await db.request()
      .input('usuario', sql.NVarChar, usuario)
      .query(`
        SELECT IdUtente, NomeUtente, Password, Nome, Cognome, Email, FlgDisabilitato, CPA_Medico
        FROM UtentiMedici
        WHERE NomeUtente = @usuario
      `);

    if (resMedico.recordset.length > 0) {
      const medico = resMedico.recordset[0];

      // FlgDisabilitato: 0 = activo, -1 = deshabilitado
      if (medico.FlgDisabilitato === -1) {
        return res.status(403).json({ error: 'Cuenta desactivada. Contacte al administrador' });
      }

      // Comparación de contraseña en texto plano
      // Para bcrypt: const ok = await require('bcryptjs').compare(contrasena, medico.Password);
      if (contrasena !== medico.Password) {
        return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });
      }

      return res.status(200).json({
        rol: 'medico',
        usuario: {
          id: medico.IdUtente,
          nombre: `${medico.Nome || ''} ${medico.Cognome || ''}`.trim(),
          email: medico.Email,
          CPA_Medico: medico.CPA_Medico,
        },
      });
    }

    // 2) Si no es médico, buscar en UtentiPazienti
    const resPaciente = await db.request()
      .input('usuario', sql.NVarChar, usuario)
      .query(`
        SELECT IdUtente, NomeUtente, Password, Nome, Cognome, Email, FlgDisabilitato
        FROM UtentiPazienti
        WHERE NomeUtente = @usuario
      `);

    if (resPaciente.recordset.length > 0) {
      const paciente = resPaciente.recordset[0];

      // FlgDisabilitato: 0 = activo, -1 = deshabilitado
      if (paciente.FlgDisabilitato === -1) {
        return res.status(403).json({ error: 'Cuenta desactivada. Contacte al administrador' });
      }

      if (contrasena !== paciente.Password) {
        return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });
      }

      return res.status(200).json({
        rol: 'paciente',
        usuario: {
          id: paciente.IdUtente,
          nombre: `${paciente.Nome || ''} ${paciente.Cognome || ''}`.trim(),
          email: paciente.Email,
        },
      });
    }

    // Usuario no encontrado en ninguna tabla
    return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });

  } catch (err) {
    console.error('Error en /login:', err.message);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
});

/**
 * GET /medico/informes
 *
 * Query param requerido: CPA_Medico
 * Ejemplo: GET /medico/informes?CPA_Medico=12345
 *
 * Ejecuta el SP: sp_Medico_ListarPDFs @CPA_Medico
 * Devuelve la lista de informes PDF del médico.
 */
app.get('/medico/informes', async (req, res) => {
  const { CPA_Medico } = req.query;

  if (!CPA_Medico) {
    return res.status(400).json({ error: 'El parámetro CPA_Medico es requerido' });
  }

  try {
    const db = await getPool();

    const result = await db.request()
      .input('CPA_Medico', sql.NVarChar, CPA_Medico)
      .execute('sp_Medico_ListarPDFs');

    return res.status(200).json({
      total: result.recordset.length,
      informes: result.recordset,
    });

  } catch (err) {
    console.error('Error en /medico/informes:', err.message);
    return res.status(500).json({ error: 'Error al obtener los informes' });
  }
});

/**
 * GET /medico/descargar/:id
 *
 * Parámetro de ruta: id (IdReferto numérico)
 * Ejemplo: GET /medico/descargar/42
 *
 * Ejecuta el SP: sp_Medico_ObtenerPDF @IdReferto
 * Lee el campo BlobReferto (varbinary → Buffer en Node.js).
 * Responde con el binario del PDF como stream para que la app móvil pueda abrirlo.
 */
app.get('/medico/descargar/:id', async (req, res) => {
  const idReferto = parseInt(req.params.id, 10);

  if (isNaN(idReferto)) {
    return res.status(400).json({ error: 'El id debe ser un número entero' });
  }

  try {
    const db = await getPool();

    const result = await db.request()
      .input('IdReferto', sql.Int, idReferto)
      .execute('sp_Medico_ObtenerPDF');

    if (!result.recordset || result.recordset.length === 0) {
      return res.status(404).json({ error: 'Informe no encontrado' });
    }

    const registro = result.recordset[0];
    const blobPDF = registro.BlobReferto; // Buffer (varbinary MAX → Buffer de Node.js)

    if (!blobPDF || blobPDF.length === 0) {
      return res.status(404).json({ error: 'El informe no tiene contenido PDF (BlobReferto vacío)' });
    }

    const nombreArchivo = registro.NomeFile
      ? registro.NomeFile.replace(/[^a-zA-Z0-9._-]/g, '_') // sanitiza el nombre
      : `informe_${idReferto}.pdf`;

    // Headers que permiten al móvil (Flutter/iOS/Android) abrir el PDF inline
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `inline; filename="${nombreArchivo}"`);
    res.setHeader('Content-Length', blobPDF.length);
    res.setHeader('Cache-Control', 'no-cache');

    // Envía el buffer como stream de respuesta
    return res.end(blobPDF);

  } catch (err) {
    console.error('Error en /medico/descargar/:id:', err.message);
    return res.status(500).json({ error: 'Error al descargar el informe' });
  }
});

// ─── INICIO DEL SERVIDOR ─────────────────────────────────────────────────────
async function iniciar() {
  try {
    await getPool(); // conecta a DB antes de aceptar peticiones
    app.listen(PORT, () => {
      console.log(`\nAPI WinlabWeb escuchando en http://localhost:${PORT}`);
      console.log('Endpoints disponibles:');
      console.log(`  POST http://localhost:${PORT}/login`);
      console.log(`  GET  http://localhost:${PORT}/medico/informes?CPA_Medico=XXXX`);
      console.log(`  GET  http://localhost:${PORT}/medico/descargar/:id\n`);
    });
  } catch (err) {
    console.error('No se pudo iniciar la API:', err.message);
    process.exit(1);
  }
}

iniciar();
