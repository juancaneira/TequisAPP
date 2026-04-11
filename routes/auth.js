const express = require('express');
const jwt = require('jsonwebtoken');
const { getPool, sql } = require('../config/db');
require('dotenv').config();

const router = express.Router();

/**
 * POST /api/auth/login
 *
 * Body esperado:
 *   { "usuario": "nombre_de_usuario", "contrasena": "password" }
 *
 * Busca el médico en la tabla UtentiMedici.
 * La comparación de contraseña asume texto plano (sistema legacy).
 * Si tu DB usa hash (MD5, bcrypt, etc.), ajusta la comparación debajo.
 */
router.post('/login', async (req, res) => {
  const { usuario, contrasena } = req.body;

  if (!usuario || !contrasena) {
    return res.status(400).json({ error: 'Usuario y contraseña son requeridos' });
  }

  try {
    const pool = await getPool();

    // Busca el médico por nombre de usuario en UtentiMedici
    // Ajusta los nombres de columna si difieren en tu tabla real
    const result = await pool.request()
      .input('usuario', sql.NVarChar, usuario)
      .query(`
        SELECT
          IdUtente,
          NomeUtente,
          Password,
          Nome,
          Cognome,
          Email,
          Attivo
        FROM UtentiMedici
        WHERE NomeUtente = @usuario
      `);

    if (result.recordset.length === 0) {
      return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });
    }

    const medico = result.recordset[0];

    // Verifica que la cuenta esté activa
    if (medico.Attivo === false || medico.Attivo === 0) {
      return res.status(403).json({ error: 'Cuenta desactivada. Contacte al administrador' });
    }

    // --- COMPARACIÓN DE CONTRASEÑA ---
    // Opción A (texto plano - sistemas legacy):
    const passwordValida = (contrasena === medico.Password);

    // Opción B (bcrypt - más seguro):
    // const bcrypt = require('bcryptjs');
    // const passwordValida = await bcrypt.compare(contrasena, medico.Password);

    if (!passwordValida) {
      return res.status(401).json({ error: 'Usuario o contraseña incorrectos' });
    }

    // Genera el token JWT válido por 8 horas
    const payload = {
      idMedico: medico.IdUtente,
      usuario: medico.NomeUtente,
      nombre: `${medico.Nome || ''} ${medico.Cognome || ''}`.trim(),
      email: medico.Email,
    };

    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '8h' });

    return res.status(200).json({
      token,
      medico: {
        id: medico.IdUtente,
        usuario: medico.NomeUtente,
        nombre: payload.nombre,
        email: medico.Email,
      },
    });
  } catch (err) {
    console.error('Error en login:', err.message);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
});

module.exports = router;
