# Changelog — WinlabwebAPI

Historial de cambios del proyecto. Formato basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/).

---

## [1.3.0] — 2026-04-10

### Corregido
- **Descifrado de PDF**: el offset de lectura de longitud en el blob era incorrecto.  
  `CopyMemory(ref num6, 8, ByteArray, 4)` en el .NET original significa "copia desde ByteArray[8]", por lo que la longitud real del PDF está en los bytes 8–11 (UInt32 little-endian), no en los bytes 4–7.
- Eliminados logs de diagnóstico del descifrado una vez confirmado el funcionamiento.

---

## [1.2.0] — 2026-04-10

### Añadido
- **Descifrado de blobs TesiWeb** (`BlobReferto`) en el endpoint `GET /medico/descargar/:id`.  
  Algoritmo obtenido por ingeniería inversa de `GenKeyNet.dll` (clase `clsDES` / `clsCryptoTesi`):
  - Cifrado: **DES-CBC**
  - IV: 8 bytes en cero
  - Clave: primeros 8 bytes ASCII de `KeyNet` → `9DDD6FF6`
  - Formato del plaintext: firma (bytes 0–7) · longitud real UInt32LE (bytes 8–11) · datos PDF (desde byte 12)
- El endpoint ahora devuelve el PDF descifrado con `Content-Type: application/pdf`, listo para abrir en móvil.

---

## [1.1.0] — 2026-04-10

### Añadido
- **Columna `PasswordApp`** (`VARCHAR(60) NULL`) en `dbo.UtentiMedici` y `dbo.UtentiPazienti` para autenticación móvil con bcrypt (independiente de la contraseña cifrada legacy de TesiWeb).
- **`POST /setup-password`**: permite a médicos y pacientes crear o cambiar su `PasswordApp`. Requiere `passwordActual` si ya existe una contraseña configurada.
- **`POST /login`** actualizado: detecta si `PasswordApp` es `NULL` (primera vez) e indica al cliente que llame a `/setup-password`.
- **`GET /`** (health check): devuelve estado de la API y versión de Node.js.

### Cambiado
- `POST /login`: usa `bcrypt.compare` contra `PasswordApp` en lugar de comparación directa con el campo `Password` (cifrado propietario de TesiWeb).
- `GET /medico/descargar/:id`: acepta `CPA_Medico` como query param y lo pasa a `sp_Medico_ObtenerPDF` junto con `IdReferto`.

### Corregido
- **`Invalid column name 'CPA_Medico'`**: las consultas de login usaban `CPA_Medico` en lugar de `CPA` al consultar `UtentiMedici` / `UtentiPazienti`.
- **Script de PowerShell** `instalar-servicio.ps1`: reemplazado el operador `?.` (requiere PowerShell 7.1+) por bloque `if/else` compatible con PowerShell 4.0 (Windows Server 2012 R2).

---

## [1.0.0] — 2026-04-10

### Añadido
- Proyecto Node.js/Express inicializado desde cero.
- **`app.js`** (archivo único consolidado):
  - Conexión a SQL Server con `mssql` y pool de conexiones.
  - `POST /login`: valida credenciales contra `UtentiMedici` o `UtentiPazienti` usando el campo `CPA` y `FlgDisabilitato`.
  - `GET /medico/informes`: ejecuta `sp_Medico_ListarPDFs` con `@CPA_Medico`.
  - `GET /medico/descargar/:id`: ejecuta `sp_Medico_ObtenerPDF` y devuelve el `BlobReferto` como stream PDF.
  - CORS habilitado para FlutterFlow y apps móviles.
  - Manejo de errores global.
- **`database.sql`**: definición de stored procedures:
  - `sp_Medico_ListarPDFs`
  - `sp_Medico_ObtenerPDF`
  - `sp_Paciente_ListarPDFs`
  - `sp_Paciente_ObtenerPDF`
  - Lógica de `FlgDisabilitato`: `0` = activo, `-1` = inactivo/deshabilitado (cláusulas usan `<> -1`).
  - `ALTER TABLE` para agregar columna `PasswordApp` en ambas tablas de usuarios.
- **`.env`**: credenciales de SQL Server, `JWT_SECRET` y `PORT` (excluido de git).
- **`.gitignore`**: excluye `.env`, `node_modules/`, `logs/`.
- **`package.json`**: dependencias (`express`, `mssql`, `bcryptjs`, `dotenv`, `cors`, `node-windows`).
- **`registrar-servicio.js`** / **`quitar-servicio.js`**: instalan y desinstalan la API como servicio de Windows usando `node-windows`.
- **`instalar-servicio.ps1`**: script PowerShell alternativo para registro del servicio con NSSM.
- **`.env.production`**: plantilla de variables de entorno para el servidor de producción.
- Despliegue en Windows Server 2012 R2 documentado y funcional.

---

## Endpoints disponibles

| Método | Ruta | Descripción |
|--------|------|-------------|
| `GET` | `/` | Health check |
| `POST` | `/login` | Autenticación de médico o paciente |
| `POST` | `/setup-password` | Crear o cambiar `PasswordApp` |
| `GET` | `/medico/informes?CPA_Medico=` | Listar informes del médico |
| `GET` | `/medico/descargar/:id?CPA_Medico=` | Descargar PDF descifrado |

## Tecnologías

- **Runtime**: Node.js ≥ 18
- **Framework**: Express 4
- **Base de datos**: SQL Server (mssql)
- **Autenticación**: bcryptjs
- **Descifrado de blobs**: crypto (DES-CBC, algoritmo TesiWeb)
- **Servicio Windows**: node-windows
