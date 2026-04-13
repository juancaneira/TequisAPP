const sql = require('mssql');
require('dotenv').config();

const config = {
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.DB_PORT) || 1433,
  options: {
    // Necesario si el servidor usa un certificado autofirmado (común en servidores locales)
    trustServerCertificate: true,
    encrypt: false,
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000,
  },
};

// Pool global compartido por toda la aplicación
let pool = null;

async function getPool() {
  if (pool) return pool;

  try {
    pool = await sql.connect(config);
    console.log(`Conectado a SQL Server: ${config.server} / ${config.database}`);
    return pool;
  } catch (err) {
    console.error('Error al conectar con SQL Server:', err.message);
    throw err;
  }
}

module.exports = { getPool, sql };
