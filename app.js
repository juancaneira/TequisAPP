require('dotenv').config();
const express = require('express');
const cors    = require('cors');
const sql     = require('mssql');
const bcrypt  = require('bcryptjs');
const crypto  = require('crypto');

// ─── DESCIFRADO DE BLOBS TESI (GenKeyNet.dll - clsCryptoTesi) ────────────────
// Clave maestra extraída del constructor de clsCryptoTesi en GenKeyNet.dll.
// Algoritmo: DES-CBC, IV = 8 bytes en cero.
// Formato del plaintext: bytes 4-7 = longitud real (UInt32LE), datos desde byte 12.
const TESI_KEY_NET = '9DDD6FF6F2534F29831255CDF0E0C673D6DDDF17A113626387218632BAA2EE86EA6FEC9F4F5B846D14DB9CD040170E60D1B2331298954F531E79E9B43F77915B';

function descifrarBlobTesi(bufferCifrado) {
  const claveDES = Buffer.from(TESI_KEY_NET.substring(0, 8), 'ascii');
  const iv       = Buffer.alloc(8, 0);

  const decipher = crypto.createDecipheriv('des-cbc', claveDES, iv);
  decipher.setAutoPadding(false);

  const descifrado = Buffer.concat([
    decipher.update(bufferCifrado),
    decipher.final()
  ]);

  if (descifrado.length <= 12) {
    throw new Error('Blob descifrado demasiado corto: ' + descifrado.length + ' bytes');
  }

  // Header del formato TesiWeb:
  //   bytes 0-7  : bloque inicial (firma/padding)
  //   bytes 8-11 : longitud real del PDF (UInt32 little-endian)
  //                CopyMemory(ref num6, 8, ByteArray, 4) → srcOffset=8
  //   bytes 12+  : datos reales del PDF
  const longitudDatos = descifrado.readUInt32LE(8);
  const padding = descifrado.length - longitudDatos;

  // Validar que el padding esté entre 12 y 19 (formato TesiWeb)
  if (padding < 12 || padding > 19) {
    throw new Error(`Formato de blob inválido: padding=${padding}, longitud=${longitudDatos}, total=${descifrado.length}. Header: ${descifrado.slice(0, 16).toString('hex')}`);
  }

  // Los datos reales (PDF) comienzan en byte 12
  return descifrado.slice(12, 12 + longitudDatos);
}

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
      .input('usuario', sql.VarChar, usuario)
      .query(`
        SELECT CPA, PasswordApp, Nome, Cognome, Titolo, Email, FlgDisabilitato
        FROM UtentiMedici
        WHERE CPA = @usuario
      `);

    if (resMedico.recordset.length > 0) {
      const medico = resMedico.recordset[0];

      if (medico.FlgDisabilitato === -1) {
        return res.status(403).json({ error: 'Cuenta desactivada. Contacte al administrador' });
      }

      if (!medico.PasswordApp) {
        return res.status(401).json({
          ok: false,
          necesita_setup: true,
          error: 'Contraseña de app no configurada. Usa POST /setup-password'
        });
      }

      const passwordValida = await bcrypt.compare(contrasena, medico.PasswordApp);
      if (!passwordValida) {
        return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });
      }

      return res.status(200).json({
        ok: true,
        rol: 'medico',
        cpa: medico.CPA,
        nombre: `${medico.Titolo || ''} ${medico.Nome || ''} ${medico.Cognome || ''}`.trim(),
        email: medico.Email || '',
      });
    }

    // 2) Buscar en UtentiPazienti
    const resPaciente = await db.request()
      .input('usuario', sql.VarChar, usuario)
      .query(`
        SELECT CPA, PasswordApp, Nome, Cognome, Email, FlgDisabilitato
        FROM UtentiPazienti
        WHERE CPA = @usuario
      `);

    if (resPaciente.recordset.length > 0) {
      const paciente = resPaciente.recordset[0];

      if (paciente.FlgDisabilitato === -1) {
        return res.status(403).json({ error: 'Cuenta desactivada. Contacte al administrador' });
      }

      if (!paciente.PasswordApp) {
        return res.status(401).json({
          ok: false,
          necesita_setup: true,
          error: 'Contraseña de app no configurada. Usa POST /setup-password'
        });
      }

      const passwordValida = await bcrypt.compare(contrasena, paciente.PasswordApp);
      if (!passwordValida) {
        return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });
      }

      return res.status(200).json({
        ok: true,
        rol: 'paciente',
        cpa: paciente.CPA,
        nombre: `${paciente.Nome || ''} ${paciente.Cognome || ''}`.trim(),
        email: paciente.Email || '',
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

    return res.status(200).json(result.recordset);

  } catch (err) {
    console.error('Error en /medico/informes:', err.message);
    return res.status(500).json({ error: 'Error al obtener los informes' });
  }
});

/**
 * GET /medico/descargar/:id?CPA_Medico=XXXX
 *
 * Parámetros:
 *   - id          : IdReferto numérico en la ruta
 *   - CPA_Medico  : CPA del médico como query param
 *
 * Ejemplo: GET /medico/descargar/1346552?CPA_Medico=JCNP
 *
 * Ejecuta: sp_Medico_ObtenerPDF @CPA_Medico, @IdReferto
 * Devuelve el campo BlobReferto (varbinary) como stream PDF.
 */
app.get('/medico/descargar/:id', async (req, res) => {
  const idReferto  = parseInt(req.params.id, 10);
  const cpaMedico  = req.query.CPA_Medico;

  if (isNaN(idReferto)) {
    return res.status(400).json({ error: 'El id debe ser un número entero' });
  }

  if (!cpaMedico) {
    return res.status(400).json({ error: 'El parámetro CPA_Medico es requerido' });
  }

  try {
    const db = await getPool();

    const result = await db.request()
      .input('CPA_Medico', sql.VarChar, cpaMedico)
      .input('IdReferto',  sql.BigInt,  idReferto)
      .execute('sp_Medico_ObtenerPDF');

    if (!result.recordset || result.recordset.length === 0) {
      return res.status(404).json({ error: 'Informe no encontrado' });
    }

    const registro = result.recordset[0];
    const blobCifrado = registro.BlobReferto;

    if (!blobCifrado || blobCifrado.length === 0) {
      return res.status(404).json({ error: 'El informe no tiene contenido (BlobReferto vacío)' });
    }

    // Descifrar el blob con el algoritmo DES-CBC de TesiWeb
    let pdfBuffer;
    try {
      pdfBuffer = descifrarBlobTesi(blobCifrado);
    } catch (errDescifrado) {
      console.error('Error al descifrar BlobReferto:', errDescifrado.message);
      return res.status(500).json({ error: 'No se pudo descifrar el informe: ' + errDescifrado.message });
    }

    const nombreArchivo = registro.NomeFile
      ? registro.NomeFile.replace(/[^a-zA-Z0-9._-]/g, '_')
      : `informe_${idReferto}.pdf`;

    // Headers para que el móvil abra el PDF inline
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `inline; filename="${nombreArchivo}"`);
    res.setHeader('Content-Length', pdfBuffer.length);
    res.setHeader('Cache-Control', 'no-cache');

    return res.end(pdfBuffer);

  } catch (err) {
    console.error('Error en /medico/descargar/:id:', err.message);
    return res.status(500).json({ error: 'Error al descargar el informe' });
  }
});

/**
 * GET /paciente/informes
 *
 * Query param requerido: CPA_Paciente
 * Ejemplo: GET /paciente/informes?CPA_Paciente=12345
 *
 * Ejecuta el SP: sp_Paciente_ListarPDFs @CPA_Paciente
 */
app.get('/paciente/informes', async (req, res) => {
  const { CPA_Paciente } = req.query;

  if (!CPA_Paciente) {
    return res.status(400).json({ error: 'El parámetro CPA_Paciente es requerido' });
  }

  try {
    const db = await getPool();

    const result = await db.request()
      .input('CPA_Paciente', sql.NVarChar, CPA_Paciente)
      .execute('sp_Paciente_ListarPDFs');

    return res.status(200).json(result.recordset);

  } catch (err) {
    console.error('Error en /paciente/informes:', err.message);
    return res.status(500).json({ error: 'Error al obtener los informes' });
  }
});

/**
 * GET /paciente/descargar/:id?CPA_Paciente=XXXX
 *
 * Parámetros:
 *   - id            : IdReferto numérico en la ruta
 *   - CPA_Paciente  : CPA del paciente como query param
 *
 * Ejecuta: sp_Paciente_ObtenerPDF @CPA_Paciente, @IdReferto
 * Devuelve el campo BlobReferto descifrado como stream PDF.
 */
app.get('/paciente/descargar/:id', async (req, res) => {
  const idReferto   = parseInt(req.params.id, 10);
  const cpaPaciente = req.query.CPA_Paciente;

  if (isNaN(idReferto)) {
    return res.status(400).json({ error: 'El id debe ser un número entero' });
  }

  if (!cpaPaciente) {
    return res.status(400).json({ error: 'El parámetro CPA_Paciente es requerido' });
  }

  try {
    const db = await getPool();

    const result = await db.request()
      .input('CPA_Paciente', sql.VarChar, cpaPaciente)
      .input('IdReferto',    sql.BigInt,  idReferto)
      .execute('sp_Paciente_ObtenerPDF');

    if (!result.recordset || result.recordset.length === 0) {
      return res.status(404).json({ error: 'Informe no encontrado' });
    }

    const registro   = result.recordset[0];
    const blobCifrado = registro.BlobReferto;

    if (!blobCifrado || blobCifrado.length === 0) {
      return res.status(404).json({ error: 'El informe no tiene contenido (BlobReferto vacío)' });
    }

    let pdfBuffer;
    try {
      pdfBuffer = descifrarBlobTesi(blobCifrado);
    } catch (errDescifrado) {
      console.error('Error al descifrar BlobReferto:', errDescifrado.message);
      return res.status(500).json({ error: 'No se pudo descifrar el informe: ' + errDescifrado.message });
    }

    const nombreArchivo = registro.NomeFile
      ? registro.NomeFile.replace(/[^a-zA-Z0-9._-]/g, '_')
      : `informe_${idReferto}.pdf`;

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `inline; filename="${nombreArchivo}"`);
    res.setHeader('Content-Length', pdfBuffer.length);
    res.setHeader('Cache-Control', 'no-cache');

    return res.end(pdfBuffer);

  } catch (err) {
    console.error('Error en /paciente/descargar/:id:', err.message);
    return res.status(500).json({ error: 'Error al descargar el informe' });
  }
});

/**
 * POST /setup-password
 *
 * Permite a un médico o paciente crear su contraseña de acceso a la app
 * por primera vez, o cambiarla si ya la tiene.
 *
 * Body: { "usuario": "CPA", "passwordApp": "nueva_clave" }
 *
 * Si el usuario ya tiene PasswordApp configurada, debe enviar también
 * la contraseña actual para poder cambiarla:
 * Body: { "usuario": "CPA", "passwordApp": "nueva_clave", "passwordActual": "clave_vieja" }
 */
app.post('/setup-password', async (req, res) => {
  const { usuario, passwordApp, passwordActual } = req.body;

  if (!usuario || !passwordApp) {
    return res.status(400).json({ error: 'Los campos usuario y passwordApp son requeridos' });
  }

  if (passwordApp.length < 6) {
    return res.status(400).json({ error: 'La contraseña debe tener al menos 6 caracteres' });
  }

  try {
    const db = await getPool();

    // Buscar en médicos primero, luego pacientes
    let tabla = null;
    let registro = null;

    const resMedico = await db.request()
      .input('usuario', sql.VarChar, usuario)
      .query(`SELECT CPA, PasswordApp, FlgDisabilitato FROM UtentiMedici WHERE CPA = @usuario`);

    if (resMedico.recordset.length > 0) {
      tabla = 'UtentiMedici';
      registro = resMedico.recordset[0];
    } else {
      const resPaciente = await db.request()
        .input('usuario', sql.VarChar, usuario)
        .query(`SELECT CPA, PasswordApp, FlgDisabilitato FROM UtentiPazienti WHERE CPA = @usuario`);

      if (resPaciente.recordset.length > 0) {
        tabla = 'UtentiPazienti';
        registro = resPaciente.recordset[0];
      }
    }

    if (!registro) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    if (registro.FlgDisabilitato === -1) {
      return res.status(403).json({ error: 'Cuenta desactivada. Contacte al administrador' });
    }

    // Si ya tiene contraseña, verificar la actual antes de cambiar
    if (registro.PasswordApp) {
      if (!passwordActual) {
        return res.status(400).json({
          error: 'Este usuario ya tiene contraseña configurada',
          accion: 'Envía también el campo passwordActual para cambiarla'
        });
      }
      const actualValida = await bcrypt.compare(passwordActual, registro.PasswordApp);
      if (!actualValida) {
        return res.status(401).json({ error: 'La contraseña actual es incorrecta' });
      }
    }

    // Cifrar la nueva contraseña con bcrypt (10 rondas)
    const hash = await bcrypt.hash(passwordApp, 10);

    await db.request()
      .input('hash', sql.VarChar(60), hash)
      .input('usuario', sql.VarChar, usuario)
      .query(`UPDATE ${tabla} SET PasswordApp = @hash WHERE CPA = @usuario`);

    return res.status(200).json({
      mensaje: registro.PasswordApp
        ? 'Contraseña actualizada correctamente'
        : 'Contraseña de app configurada correctamente'
    });

  } catch (err) {
    console.error('Error en /setup-password:', err.message);
    return res.status(500).json({ error: 'Error interno del servidor' });
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
      console.log(`  POST http://localhost:${PORT}/setup-password`);
      console.log(`  GET  http://localhost:${PORT}/medico/informes?CPA_Medico=XXXX`);
      console.log(`  GET  http://localhost:${PORT}/medico/descargar/:id?CPA_Medico=XXXX`);
      console.log(`  GET  http://localhost:${PORT}/paciente/informes?CPA_Paciente=XXXX`);
      console.log(`  GET  http://localhost:${PORT}/paciente/descargar/:id?CPA_Paciente=XXXX\n`);
    });
  } catch (err) {
    console.error('No se pudo iniciar la API:', err.message);
    process.exit(1);
  }
}

iniciar();
