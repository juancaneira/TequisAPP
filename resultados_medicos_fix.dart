// REEMPLAZAR el bloque FutureBuilder completo en resultados_medicos_widget.dart
// Desde: "child: FutureBuilder<ApiCallResponse>("
// Hasta: el cierre del Padding que lo contiene

Padding(
  padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
  child: FutureBuilder<ApiCallResponse>(
    future: TequisAPIGroup.listarInformesMedicoCall.call(
      cpaMedico: FFAppState().usuarioCPA,
    ),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          ),
        );
      }

      final response = snapshot.data!;
      final informes = getJsonField(response.jsonBody, r'$') as List? ?? [];

      if (informes.isEmpty) {
        return Center(
          child: Text(
            'No hay informes disponibles',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: informes.length,
        itemBuilder: (context, index) {
          final item = informes[index];

          return Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Color(0x1A000000),
                    offset: Offset(0, 2),
                  )
                ],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFFE8F0FE),
                              shape: BoxShape.circle,
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0, 0),
                              child: Icon(
                                Icons.person_outline,
                                color: Color(0xFF4A6CF7),
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paciente',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500),
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 11,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Text(
                                valueOrDefault<String>(
                                  getJsonField(item, r'$.NombrePaciente')
                                      ?.toString(),
                                  'Sin nombre',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600),
                                      color: Color(0xFF12151C),
                                      fontSize: 15,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Text(
                          'Disponible',
                          style: FlutterFlowTheme.of(context)
                              .labelSmall
                              .override(
                                font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600),
                                color: Color(0xFF388E3C),
                                fontSize: 11,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF0F0F0),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha de Reporte',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500),
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 11,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      color: Color(0xFF4A6CF7), size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    valueOrDefault<String>(
                                      getJsonField(item, r'$.FechaReferto')
                                          ?.toString(),
                                      '--',
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500),
                                          color: Color(0xFF12151C),
                                          fontSize: 13,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Código',
                                style: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .override(
                                      font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500),
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 11,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.tag,
                                      color: Color(0xFF4A6CF7), size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    valueOrDefault<String>(
                                      getJsonField(item, r'$.CodigoReferto')
                                          ?.toString(),
                                      '--',
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500),
                                          color: Color(0xFF12151C),
                                          fontSize: 13,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 14, 0, 0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          await launchURL(
                            'https://api.laboratoriotequis.com.mx/medico/descargar/${getJsonField(item, r'$.IdReferto').toString()}?CPA_Medico=${FFAppState().usuarioCPA}',
                          );
                        },
                        text: 'Ver PDF',
                        icon: Icon(Icons.picture_as_pdf, size: 16),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 42,
                          padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                          iconPadding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: Color(0xFF4A6CF7),
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600),
                                    color: Colors.white,
                                    fontSize: 13,
                                    letterSpacing: 0.0,
                                  ),
                          elevation: 0,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  ),
),
