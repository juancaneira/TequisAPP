import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/pdf_helper.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'resultados_medicos_model.dart';
export 'resultados_medicos_model.dart';

/// Create a information display page for doctors with title "Mis Resultados"
/// and this schema
///  ├── Expanded
///   │     └── ListView (Dynamic)
///   │           └── Card (template de cada informe)
///   │                 ├── Text → NombrePaciente
///   │                 ├── Text → FechaReferto
///   │                 ├── Text → CodigoReferto
///   │                 └── Button → "Ver PDF"
class ResultadosMedicosWidget extends StatefulWidget {
  const ResultadosMedicosWidget({super.key});

  static String routeName = 'ResultadosMedicos';
  static String routePath = '/resultadosMedicos';

  @override
  State<ResultadosMedicosWidget> createState() =>
      _ResultadosMedicosWidgetState();
}

class _ResultadosMedicosWidgetState extends State<ResultadosMedicosWidget> {
  late ResultadosMedicosModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResultadosMedicosModel());
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
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 22.0,
            borderWidth: 1.0,
            buttonSize: 44.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF12151C),
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Mis Resultados',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.readexPro(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Color(0xFF12151C),
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
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
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Row(
                  children: [
                    Icon(Icons.medical_services_outlined, color: Color(0xFF4A6CF7), size: 18),
                    SizedBox(width: 6),
                    Text(
                      FFAppState().usuarioNombre,
                      style: TextStyle(
                        color: Color(0xFF12151C),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: TextField(
                  controller: _model.busquedaController,
                  focusNode: _model.busquedaFocus,
                  onChanged: (val) => setState(() => _model.filtroBusqueda = val.trim().toLowerCase()),
                  style: TextStyle(color: Color(0xFF12151C), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre de paciente...',
                    hintStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF4A6CF7), size: 20),
                    suffixIcon: _model.filtroBusqueda.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Color(0xFF9E9E9E), size: 18),
                            onPressed: () => setState(() {
                              _model.busquedaController?.clear();
                              _model.filtroBusqueda = '';
                            }),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF4A6CF7), width: 2),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
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
      final todosInformes = getJsonField(response.jsonBody, r'$') as List? ?? [];
      final informes = _model.filtroBusqueda.isEmpty
          ? todosInformes
          : todosInformes.where((item) {
              final nombre = (getJsonField(item, r'$.NombrePaciente')?.toString() ?? '').toLowerCase();
              return nombre.contains(_model.filtroBusqueda);
            }).toList();

      if (todosInformes.isEmpty) {
        return Center(
          child: Text(
            'No hay informes disponibles',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        );
      }

      if (informes.isEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, color: Color(0xFFBDBDBD), size: 48),
            SizedBox(height: 12),
            Text(
              'Sin resultados para "${_model.busquedaController?.text}"',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
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
                      child: Row(
                        children: [
                          Expanded(
                            child: FFButtonWidget(
                              onPressed: () async {
                                final id = getJsonField(item, r'$.IdReferto').toString();
                                final url = 'https://api.laboratoriotequis.com.mx/medico/descargar/$id?CPA_Medico=${FFAppState().usuarioCPA}';
                                await abrirPDF(context, url: url, nombreArchivo: 'informe_$id');
                              },
                              text: 'Ver PDF',
                              icon: Icon(Icons.picture_as_pdf, size: 16),
                              options: FFButtonOptions(
                                height: 42,
                                padding: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                                color: Color(0xFF4A6CF7),
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
                            color: Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () async {
                                final id = getJsonField(item, r'$.IdReferto').toString();
                                final url = 'https://api.laboratoriotequis.com.mx/medico/descargar/$id?CPA_Medico=${FFAppState().usuarioCPA}';
                                await abrirPDF(context, url: url, nombreArchivo: 'informe_$id', compartir: true);
                              },
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.share_rounded, color: Color(0xFF4A6CF7), size: 20),
                              ),
                            ),
                          ),
                        ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
