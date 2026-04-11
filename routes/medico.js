const express = require('express');
const { getPool, sql } = require('../config/db');
const verificarToken = require('../middleware/auth');

const router = express.Router();

// Todas las rutas de este archivo requieren token JWT válido
router.use(verificarToken);

/**
 * GET /api/medico/pdfs
 *
 * Lista los PDFs del médico autenticado.
 * Llama al stored procedure: sp_Medico_ListarPDFs @IdMedico
 * El IdMedico se obtiene automáticamente del token JWT.
 */
router.get('/pdfs', async (req, res) => {
  const idMedico = req.medico.idMedico;

  try {
    const pool = await getPool();

    const result = await pool.request()
      .input('IdMedico', sql.Int, idMedico)
      .execute('sp_Medico_ListarPDFs');

    return res.status(200).json({
      total: result.recordset.length,
      pdfs: result.recordset,
    });
  } catch (err) {
    console.error('Error al listar PDFs:', err.message);
    return res.status(500).json({ error: 'Error al obtener la lista de PDFs' });
  }
});

/**
 * GET /api/medico/pdf/:id
 *
 * Descarga un PDF específico por su ID (IdReferto).
 * Llama al stored procedure: sp_Medico_ObtenerPDF @IdReferto
 * Lee el campo BlobReferto (varbinary) y lo envía como application/pdf.
 *
 * Ejemplo de uso: GET /api/medico/pdf/42
 * El cliente recibe el archivo PDF directamente.
 */
router.get('/pdf/:id', async (req, res) => {
  const idReferto = parseInt(req.params.id, 10);

  if (isNaN(idReferto)) {
    return res.status(400).json({ error: 'El ID del PDF debe ser un número entero' });
  }

  try {
    const pool = await getPool();

    const result = await pool.request()
      .input('IdReferto', sql.Int, idReferto)
      .execute('sp_Medico_ObtenerPDF');

    if (!result.recordset || result.recordset.length === 0) {
      return res.status(404).json({ error: 'PDF no encontrado' });
    }

    const registro = result.recordset[0];
    const blobPDF = registro.BlobReferto;

    if (!blobPDF) {
      return res.status(404).json({ error: 'El PDF no tiene contenido (BlobReferto vacío)' });
    }

    // blobPDF es un Buffer de Node.js porque SQL devuelve varbinary(MAX) como Buffer
    const nombreArchivo = registro.NomeFile || `referto_${idReferto}.pdf`;

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${nombreArchivo}"`);
    res.setHeader('Content-Length', blobPDF.length);

    return res.status(200).end(blobPDF);
  } catch (err) {
    console.error('Error al obtener PDF:', err.message);
    return res.status(500).json({ error: 'Error al descargar el PDF' });
  }
});

module.exports = router;
