-- ============================================================
-- STORED PROCEDURES: Acceso a PDFs - winlabweb
-- Incluye: médico y paciente
-- Ejecutar en orden: primero los SP, luego los ejemplos de uso
-- ============================================================
--
-- Convención de flags (validada con DISTINCT en producción):
--   UtentiMedici / UtentiPazienti.FlgDisabilitato : 0 = activo | -1 = deshabilitado
--   Referti.FlgCanc                               : 0 = vigente | -1 = cancelado
--   Referti.FlgPubblicato                         : -1 = publicado (boolean estilo VB) | 0 = no publicado
--        (no usar = 1: en esta BD el valor 1 no aparece en FlgPubblicato)
--   Referti.FlgFirmato                            : en esta BD solo existe 0; no filtrar con = 1
--   Referti.FlgRiservato / FlgPreliminare         : 0 en el universo analizado; mantener = 0 si aplica
--
-- ============================================================

USE winlabweb;
GO

-- ============================================================
-- SP 1A: Listar informes disponibles para un MÉDICO
-- ============================================================
CREATE OR ALTER PROCEDURE sp_Medico_ListarPDFs
    @CPA_Medico     VARCHAR(16),
    @SoloNoLeidos   BIT         = 0,    -- 1 = solo pendientes de consultar
    @FechaDesde     VARCHAR(10) = NULL, -- formato: 'YYYY-MM-DD'
    @FechaHasta     VARCHAR(10) = NULL,
    @SoloFirmados   BIT         = 1     -- 1 = excluir FlgFirmato = -1 si existiera; en BD actual casi todo es 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que el médico existe y está activo
    -- Convención: FlgDisabilitato = 0 → activo | FlgDisabilitato = -1 → deshabilitado
    IF NOT EXISTS (
        SELECT 1 FROM UtentiMedici
        WHERE CPA = @CPA_Medico AND FlgDisabilitato <> -1
    )
    BEGIN
        RAISERROR('Médico no encontrado o deshabilitado: %s', 16, 1, @CPA_Medico);
        RETURN;
    END

    SELECT
        r.Id                            AS IdReferto,
        r.Codice                        AS CodigoReferto,
        r.Data                          AS FechaReferto,
        r.Ora                           AS HoraReferto,
        r.DataPrelievo                  AS FechaPrelievo,
        r.DataConsegna                  AS FechaEntrega,
        -- Paciente
        p.Id                            AS IdPaciente,
        p.Cognome + ' ' + p.Nome        AS NombrePaciente,
        p.CodiceFiscale                 AS CFPaciente,
        p.DataNascita                   AS NacimientoPaciente,
        -- Estado del informe
        r.FlgFirmato                    AS Firmado,
        r.FlgPubblicato                 AS Publicado,
        r.FlgPreliminare                AS Preliminar,
        r.FlgRiservato                  AS Reservado,
        -- Entidades
        r.CodiceEntitaErogante          AS UnidadErogante,
        r.CodiceEntitaRichiedente       AS UnidadSolicitante,
        r.CodiceServizio                AS Servicio,
        -- Acceso del médico
        rpm.FlgConsultato               AS MedicoYaConsulto,
        rpm.FlgStampato                 AS MedicoYaImprimio,
        -- Tamaño estimado del PDF (KB)
        DATALENGTH(rd.BlobReferto) / 1024 AS TamanoPDFkb
    FROM UtentiMedici um
        INNER JOIN RefertiPazientiMedici rpm ON rpm.CPA_Medico    = um.CPA
        INNER JOIN Referti r                 ON r.Id              = rpm.IdReferto
        INNER JOIN AnagraficaPazienti p      ON p.Id              = r.IdPaziente
        INNER JOIN RefertiDocumento rd       ON rd.IdReferto       = r.Id
    WHERE
        um.CPA      = @CPA_Medico
        AND r.FlgCanc   = 0
        AND (@SoloFirmados = 0 OR r.FlgFirmato <> -1)
        AND (@SoloNoLeidos  = 0 OR rpm.FlgConsultato = 0)
        AND (@FechaDesde IS NULL OR r.Data >= @FechaDesde)
        AND (@FechaHasta IS NULL OR r.Data <= @FechaHasta)
    ORDER BY
        r.Data DESC, r.Ora DESC;
END;
GO


-- ============================================================
-- SP 1B: Obtener el BLOB PDF para un médico (con validación)
-- ============================================================
CREATE OR ALTER PROCEDURE sp_Medico_ObtenerPDF
    @CPA_Medico  VARCHAR(16),
    @IdReferto   BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar que el médico tiene acceso a este referto
    IF NOT EXISTS (
        SELECT 1
        FROM RefertiPazientiMedici rpm
            INNER JOIN UtentiMedici um ON um.CPA = rpm.CPA_Medico
            INNER JOIN Referti r       ON r.Id   = rpm.IdReferto
        WHERE
            um.CPA          = @CPA_Medico
            AND rpm.IdReferto   = @IdReferto
            AND r.FlgCanc       = 0
            AND um.FlgDisabilitato <> -1  -- 0=activo, -1=deshabilitado
    )
    BEGIN
        RAISERROR('Acceso denegado: el médico %s no tiene permiso sobre el referto %d.', 16, 1, @CPA_Medico, @IdReferto);
        RETURN;
    END

    -- Devolver PDF + metadatos
    SELECT
        rd.IdReferto,
        rd.BlobReferto,
        r.Codice                        AS CodigoReferto,
        r.Data                          AS FechaReferto,
        r.CodiceServizio                AS Servicio,
        p.Cognome + ' ' + p.Nome        AS NombrePaciente,
        p.CodiceFiscale                 AS CFPaciente,
        um.Cognome + ' ' + um.Nome      AS NombreMedico,
        DATALENGTH(rd.BlobReferto) / 1024 AS TamanoPDFkb
    FROM RefertiDocumento rd
        INNER JOIN Referti r                 ON r.Id              = rd.IdReferto
        INNER JOIN AnagraficaPazienti p      ON p.Id              = r.IdPaziente
        INNER JOIN RefertiPazientiMedici rpm ON rpm.IdReferto      = r.Id
        INNER JOIN UtentiMedici um           ON um.CPA            = rpm.CPA_Medico
    WHERE
        rd.IdReferto = @IdReferto
        AND um.CPA   = @CPA_Medico;

    -- Marcar como consultado automáticamente
    UPDATE RefertiPazientiMedici
    SET FlgConsultato = 1
    WHERE
        CPA_Medico  = @CPA_Medico
        AND IdReferto   = @IdReferto
        AND FlgConsultato = 0;
END;
GO


-- ============================================================
-- SP 1C: Resumen de actividad del médico
-- ============================================================
CREATE OR ALTER PROCEDURE sp_Medico_Resumen
    @CPA_Medico VARCHAR(16)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        um.CPA,
        um.Titolo + ' ' + um.Cognome + ' ' + um.Nome AS NombreMedico,
        um.Email,
        COUNT(*)                                       AS TotalPDFs,
        SUM(CASE WHEN rpm.FlgConsultato = 0 THEN 1 ELSE 0 END) AS PendientesLeer,
        SUM(CASE WHEN rpm.FlgConsultato = 1 THEN 1 ELSE 0 END) AS YaLeidos,
        SUM(CASE WHEN rpm.FlgStampato   = 1 THEN 1 ELSE 0 END) AS Impresos,
        MAX(r.Data)                                    AS UltimoInforme,
        COUNT(DISTINCT r.IdPaziente)                   AS TotalPacientes
    FROM UtentiMedici um
        INNER JOIN RefertiPazientiMedici rpm ON rpm.CPA_Medico = um.CPA
        INNER JOIN Referti r               ON r.Id = rpm.IdReferto
        INNER JOIN RefertiDocumento rd     ON rd.IdReferto = r.Id
    WHERE
        um.CPA    = @CPA_Medico
        AND r.FlgCanc = 0
    GROUP BY
        um.CPA, um.Titolo, um.Cognome, um.Nome, um.Email;
END;
GO


-- ============================================================
-- SP 2A: Listar informes disponibles para un PACIENTE
-- ============================================================
CREATE OR ALTER PROCEDURE sp_Paciente_ListarPDFs
    @CPA_Paciente   VARCHAR(16),
    @SoloNoLeidos   BIT         = 0,
    @FechaDesde     VARCHAR(10) = NULL,
    @FechaHasta     VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que el paciente existe y está activo
    -- Convención: FlgDisabilitato = 0 → activo | FlgDisabilitato = -1 → deshabilitado
    IF NOT EXISTS (
        SELECT 1 FROM UtentiPazienti
        WHERE CPA = @CPA_Paciente AND FlgDisabilitato <> -1
    )
    BEGIN
        RAISERROR('Paciente no encontrado o deshabilitado: %s', 16, 1, @CPA_Paciente);
        RETURN;
    END

    SELECT
        r.Id                            AS IdReferto,
        r.Codice                        AS CodigoReferto,
        r.Data                          AS FechaReferto,
        r.Ora                           AS HoraReferto,
        r.DataPrelievo                  AS FechaPrelievo,
        r.DataConsegna                  AS FechaEntrega,
        r.CodiceServizio                AS Servicio,
        r.CodiceEntitaErogante          AS UnidadLaboratorio,
        -- Médico asignado
        um.Titolo + ' ' + um.Cognome + ' ' + um.Nome AS NombreMedico,
        -- Estado de lectura del paciente
        rpm.FlgConsultato               AS PacienteYaConsulto,
        -- Tamaño estimado
        DATALENGTH(rd.BlobReferto) / 1024 AS TamanoPDFkb
    FROM UtentiPazienti up
        INNER JOIN RefertiPazientiMedici rpm ON rpm.CPA_Paziente = up.CPA
        INNER JOIN Referti r                 ON r.Id             = rpm.IdReferto
        INNER JOIN AnagraficaPazienti p      ON p.Id             = r.IdPaziente
        LEFT  JOIN UtentiMedici um           ON um.CPA           = rpm.CPA_Medico
        INNER JOIN RefertiDocumento rd       ON rd.IdReferto      = r.Id
    WHERE
        up.CPA              = @CPA_Paciente
        AND r.FlgCanc           = 0
        AND r.FlgPubblicato     = -1  -- publicado (convención típica Winlab/VB: -1 = true)
        AND r.FlgRiservato      = 0   -- excluir reservados
        AND (@SoloNoLeidos  = 0 OR rpm.FlgConsultato = 0)
        AND (@FechaDesde IS NULL OR r.Data >= @FechaDesde)
        AND (@FechaHasta IS NULL OR r.Data <= @FechaHasta)
    ORDER BY
        r.Data DESC, r.Ora DESC;
END;
GO


-- ============================================================
-- SP 2B: Obtener el BLOB PDF para un paciente (con validación)
-- ============================================================
CREATE OR ALTER PROCEDURE sp_Paciente_ObtenerPDF
    @CPA_Paciente VARCHAR(16),
    @IdReferto    BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    -- Paciente activo; referto vigente, publicado (FlgPubblicato=-1), no reservado
    IF NOT EXISTS (
        SELECT 1
        FROM RefertiPazientiMedici rpm
            INNER JOIN UtentiPazienti up ON up.CPA = rpm.CPA_Paziente
            INNER JOIN Referti r         ON r.Id   = rpm.IdReferto
        WHERE
            up.CPA              = @CPA_Paciente
            AND rpm.IdReferto       = @IdReferto
            AND r.FlgCanc           = 0
            AND r.FlgPubblicato     = -1
            AND r.FlgRiservato      = 0
            AND up.FlgDisabilitato  = 0
    )
    BEGIN
        RAISERROR('Acceso denegado: el paciente %s no tiene permiso sobre el referto %d.', 16, 1, @CPA_Paciente, @IdReferto);
        RETURN;
    END

    -- Devolver PDF + metadatos
    SELECT
        rd.IdReferto,
        rd.BlobReferto,
        r.Codice                            AS CodigoReferto,
        r.Data                              AS FechaReferto,
        r.CodiceServizio                    AS Servicio,
        r.CodiceEntitaErogante              AS Laboratorio,
        up.Cognome + ' ' + up.Nome          AS NombrePaciente,
        um.Titolo + ' ' + um.Cognome + ' ' + um.Nome AS NombreMedico,
        DATALENGTH(rd.BlobReferto) / 1024   AS TamanoPDFkb
    FROM RefertiDocumento rd
        INNER JOIN Referti r                 ON r.Id             = rd.IdReferto
        INNER JOIN RefertiPazientiMedici rpm ON rpm.IdReferto     = r.Id
        INNER JOIN UtentiPazienti up         ON up.CPA           = rpm.CPA_Paziente
        LEFT  JOIN UtentiMedici um           ON um.CPA           = rpm.CPA_Medico
    WHERE
        rd.IdReferto  = @IdReferto
        AND up.CPA    = @CPA_Paciente
        AND up.FlgDisabilitato = 0
        AND r.FlgCanc          = 0
        AND r.FlgPubblicato    = -1
        AND r.FlgRiservato     = 0;

    -- Marcar como consultado automáticamente
    UPDATE RefertiPazientiMedici
    SET FlgConsultato = 1
    WHERE
        CPA_Paziente    = @CPA_Paciente
        AND IdReferto       = @IdReferto
        AND FlgConsultato   = 0;
END;
GO


-- ============================================================
-- SP 2C: Resumen de actividad del paciente
-- ============================================================
CREATE OR ALTER PROCEDURE sp_Paciente_Resumen
    @CPA_Paciente VARCHAR(16)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        up.CPA,
        up.Cognome + ' ' + up.Nome             AS NombrePaciente,
        up.CodiceFiscale                       AS CFPaciente,
        up.Email,
        COUNT(*)                               AS TotalPDFsDisponibles,
        SUM(CASE WHEN rpm.FlgConsultato = 0
                 THEN 1 ELSE 0 END)            AS NuevosSinVer,
        SUM(CASE WHEN rpm.FlgConsultato = 1
                 THEN 1 ELSE 0 END)            AS YaVistos,
        MAX(r.Data)                            AS UltimoInforme
    FROM UtentiPazienti up
        INNER JOIN RefertiPazientiMedici rpm ON rpm.CPA_Paziente = up.CPA
        INNER JOIN Referti r               ON r.Id = rpm.IdReferto
        INNER JOIN RefertiDocumento rd     ON rd.IdReferto = r.Id
    WHERE
        up.CPA          = @CPA_Paciente
        AND r.FlgCanc       = 0
        AND r.FlgPubblicato = -1
        AND r.FlgRiservato  = 0
    GROUP BY
        up.CPA, up.Cognome, up.Nome, up.CodiceFiscale, up.Email;
END;
GO


-- ============================================================
-- EJEMPLOS DE USO
-- ============================================================

-- Médico: listar todos sus PDFs
EXEC sp_Medico_ListarPDFs @CPA_Medico = 'M001';

-- Médico: solo los pendientes de leer en un rango de fechas
EXEC sp_Medico_ListarPDFs
    @CPA_Medico   = 'M001',
    @SoloNoLeidos = 1,
    @FechaDesde   = '2025-01-01',
    @FechaHasta   = '2025-12-31';

-- Médico: obtener PDF específico (descarga el BLOB y lo marca como leído)
EXEC sp_Medico_ObtenerPDF @CPA_Medico = 'M001', @IdReferto = 123456;

-- Médico: ver resumen de actividad
EXEC sp_Medico_Resumen @CPA_Medico = 'M001';

-- Paciente: listar sus PDFs disponibles
EXEC sp_Paciente_ListarPDFs @CPA_Paciente = 'P001';

-- Paciente: solo los no leídos del último mes
EXEC sp_Paciente_ListarPDFs
    @CPA_Paciente = 'P001',
    @SoloNoLeidos = 1,
    @FechaDesde   = '2025-03-01';

-- Paciente: obtener PDF específico (descarga el BLOB y lo marca como leído)
EXEC sp_Paciente_ObtenerPDF @CPA_Paciente = 'P001', @IdReferto = 123456;

-- Paciente: ver resumen
EXEC sp_Paciente_Resumen @CPA_Paciente = 'P001';
