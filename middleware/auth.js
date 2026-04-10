const jwt = require('jsonwebtoken');
require('dotenv').config();

function verificarToken(req, res, next) {
  // El cliente debe enviar el header: Authorization: Bearer <token>
  const authHeader = req.headers['authorization'];

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token de acceso requerido' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    // Adjunta los datos del médico al objeto request para uso en las rutas
    req.medico = decoded;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expirado, inicia sesión nuevamente' });
    }
    return res.status(403).json({ error: 'Token inválido' });
  }
}

module.exports = verificarToken;
