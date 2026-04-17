import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/pdf_helper.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'resultados_paciente_model.dart';
export 'resultados_paciente_model.dart';

class ResultadosPacienteWidget extends StatefulWidget {
  const ResultadosPacienteWidget({super.key});

  static String routeName = 'resultadosPaciente';
  static String routePath = '/resultadosPaciente';

  @override
  State<ResultadosPacienteWidget> createState() => _ResultadosPacienteWidgetState();
}

class _ResultadosPacienteWidgetState extends State<ResultadosPacienteWidget> {
  late ResultadosPacienteModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResultadosPacienteModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Color(0xFFF5F6FA),
          automaticallyImplyLeading: false,
          title: Text(
            'Mis Resultados',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.readexPro(fontWeight: FontWeight.bold),
                  color: Color(0xFF12151C),
                  fontSize: 22,
                  letterSpacing: 0,
                ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.logout_rounded, color: Color(0xFF12151C), size: 24),
              tooltip: 'Cerrar sesión',
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('session_cpa');
                await prefs.remove('session_nombre');
                await prefs.remove('session_rol');
                FFAppState().usuarioCPA = '';
                FFAppState().usuarioNombre = '';
                FFAppState().usuarioRol = '';
                FFAppState().estaLogueado = false;
                context.goNamed(InicioWidget.routeName);
              },
            ),
          ],
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Icon(Icons.person_rounded, color: Color(0xFF4A6CF7), size: 18),
                    SizedBox(width: 6),
                    Text(
                      FFAppState().usuarioNombre,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            color: Color(0xFF424242),
                            letterSpacing: 0,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
                  child: FutureBuilder<ApiCallResponse>(
                    future: TequisAPIGroup.listarInformesPacienteCall.call(
                      cPAPaciente: FFAppState().usuarioCPA,
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, size: 64, color: Color(0xFFBDBDBD)),
                              SizedBox(height: 16),
                              Text(
                                'No hay resultados disponibles',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.inter(),
                                      color: Color(0xFF9E9E9E),
                                      letterSpacing: 0,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: false,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Badge disponible
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text('Disponible',
                                            style: TextStyle(
                                                color: Color(0xFF388E3C),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    Divider(height: 14, thickness: 1, color: Color(0xFFF0F0F0)),
                                    // Fecha y Código
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Fecha de Reporte',
                                                style: TextStyle(
                                                    color: Color(0xFF9E9E9E),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500)),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today_outlined,
                                                    color: Color(0xFF4A6CF7), size: 14),
                                                SizedBox(width: 4),
                                                Text(
                                                  valueOrDefault<String>(
                                                    getJsonField(item, r'$.FechaReferto')?.toString(),
                                                    '--',
                                                  ),
                                                  style: TextStyle(
                                                      color: Color(0xFF12151C),
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Código',
                                                style: TextStyle(
                                                    color: Color(0xFF9E9E9E),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500)),
                                            Row(
                                              children: [
                                                Icon(Icons.tag, color: Color(0xFF4A6CF7), size: 14),
                                                SizedBox(width: 4),
                                                Text(
                                                  valueOrDefault<String>(
                                                    getJsonField(item, r'$.CodigoReferto')?.toString(),
                                                    '--',
                                                  ),
                                                  style: TextStyle(
                                                      color: Color(0xFF12151C),
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 14),
                                    // Botón Ver PDF + Compartir
                                    Row(
                                      children: [
                                        Expanded(
                                          child: FFButtonWidget(
                                            onPressed: () async {
                                              final id = getJsonField(item, r'$.IdReferto').toString();
                                              final url = 'https://api.laboratoriotequis.com.mx/paciente/descargar/$id?CPA_Paciente=${FFAppState().usuarioCPA}';
                                              await abrirPDF(context, url: url, nombreArchivo: 'informe_$id');
                                            },
                                            text: 'Ver PDF',
                                            icon: Icon(Icons.picture_as_pdf, size: 16),
                                            options: FFButtonOptions(
                                              height: 42,
                                              padding: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                                              color: Color(0xFF388E3C),
                                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                    font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    letterSpacing: 0,
                                                  ),
                                              elevation: 0,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Material(
                                          color: Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(10),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(10),
                                            onTap: () async {
                                              final id = getJsonField(item, r'$.IdReferto').toString();
                                              final url = 'https://api.laboratoriotequis.com.mx/paciente/descargar/$id?CPA_Paciente=${FFAppState().usuarioCPA}';
                                              await abrirPDF(context, url: url, nombreArchivo: 'informe_$id', compartir: true);
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Icon(Icons.share_rounded, color: Color(0xFF388E3C), size: 20),
                                            ),
                                          ),
                                        ),
                                      ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
