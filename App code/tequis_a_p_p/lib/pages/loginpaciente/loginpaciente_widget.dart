import '/backend/api_requests/api_calls.dart';
import '/pages/configurar_contrasena/configurar_contrasena_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'loginpaciente_model.dart';
export 'loginpaciente_model.dart';

class LoginpacienteWidget extends StatefulWidget {
  const LoginpacienteWidget({super.key});

  static String routeName = 'loginpaciente';
  static String routePath = '/loginpaciente';

  @override
  State<LoginpacienteWidget> createState() => _LoginpacienteWidgetState();
}

class _LoginpacienteWidgetState extends State<LoginpacienteWidget> {
  late LoginpacienteModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginpacienteModel());
    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
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
        backgroundColor: Color(0xFF0A1628),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.fromSTEB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/Variantes-logo-RGB_(2)-01.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Laboratorio Tequis',
                      style: FlutterFlowTheme.of(context).headlineMedium.override(
                            font: GoogleFonts.readexPro(fontWeight: FontWeight.bold),
                            color: Colors.white,
                            fontSize: 22,
                            letterSpacing: 0,
                          ),
                    ),
                    Text(
                      'Portal del Paciente',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: Color(0xCCFFFFFF),
                            fontSize: 14,
                            letterSpacing: 0,
                          ),
                    ),
                    SizedBox(height: 32),
                    // Card de login
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Iniciar Sesión',
                              style: FlutterFlowTheme.of(context).headlineSmall.override(
                                    font: GoogleFonts.readexPro(fontWeight: FontWeight.bold),
                                    color: Color(0xFF12151C),
                                    fontSize: 20,
                                    letterSpacing: 0,
                                  ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Accede con tu Código de Paciente (8 dígitos)',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.inter(),
                                    color: Color(0xFF9E9E9E),
                                    fontSize: 12,
                                    letterSpacing: 0,
                                  ),
                            ),
                            SizedBox(height: 20),
                            // Campo CPA
                            Text('Código de Paciente',
                                style: FlutterFlowTheme.of(context).labelMedium.override(
                                      font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                      color: Color(0xFF424242),
                                      letterSpacing: 0,
                                    )),
                            SizedBox(height: 6),
                            TextFormField(
                              controller: _model.textController1,
                              focusNode: _model.textFieldFocusNode1,
                              onChanged: (value) => _model.campoCPA = value,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: TextStyle(color: Color(0xFF12151C), fontSize: 16),
                              decoration: InputDecoration(
                                hintText: '00000000',
                                hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                prefixIcon: Icon(Icons.badge_outlined, color: Color(0xFF4A6CF7)),
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
                                filled: true,
                                fillColor: Color(0xFFF8F9FA),
                              ),
                            ),
                            SizedBox(height: 16),
                            // Campo Contraseña
                            Text('Contraseña',
                                style: FlutterFlowTheme.of(context).labelMedium.override(
                                      font: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                      color: Color(0xFF424242),
                                      letterSpacing: 0,
                                    )),
                            SizedBox(height: 6),
                            TextFormField(
                              controller: _model.textController2,
                              focusNode: _model.textFieldFocusNode2,
                              onChanged: (value) => _model.campoContrasena = value,
                              obscureText: !_model.passwordVisibility,
                              style: TextStyle(color: Color(0xFF12151C), fontSize: 16),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF4A6CF7)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _model.passwordVisibility
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                  onPressed: () => setState(
                                      () => _model.passwordVisibility = !_model.passwordVisibility),
                                ),
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
                                filled: true,
                                fillColor: Color(0xFFF8F9FA),
                              ),
                            ),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () => context.pushNamed(
                                  ConfigurarContrasenaWidget.routeName,
                                  queryParameters: {
                                    'cpaInicial': serializeParam(
                                      _model.textController1?.text.trim() ?? '',
                                      ParamType.String,
                                    ),
                                  },
                                ),
                                child: Text(
                                  '¿No tienes contraseña? Configúrala aquí',
                                  style: TextStyle(
                                    color: Color(0xFF1565C0),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            // Botón login
                            FFButtonWidget(
                              onPressed: () async {
                                final cpa = _model.campoCPA ?? '';
                                final contrasena = _model.campoContrasena ?? '';
                                if (cpa.isEmpty || contrasena.isEmpty) {
                                  await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Campos requeridos'),
                                      content: Text('Ingresa tu código de paciente y contraseña.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: Text('Ok'))
                                      ],
                                    ),
                                  );
                                  return;
                                }
                                final response = await TequisAPIGroup.loginCall.call(
                                  usuario: cpa,
                                  contrasena: contrasena,
                                );
                                if ((response.succeeded ?? false)) {
                                  final rol = TequisAPIGroup.loginCall.rol(response.jsonBody) ?? '';
                                  FFAppState().usuarioCPA =
                                      TequisAPIGroup.loginCall.cpa(response.jsonBody) ?? '';
                                  FFAppState().usuarioNombre =
                                      TequisAPIGroup.loginCall.nombre(response.jsonBody) ?? '';
                                  FFAppState().usuarioRol = rol;
                                  FFAppState().estaLogueado = true;
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('session_cpa', FFAppState().usuarioCPA);
                                  await prefs.setString('session_nombre', FFAppState().usuarioNombre);
                                  await prefs.setString('session_rol', rol);
                                  if (Navigator.of(context).canPop()) context.pop();
                                  context.pushNamed(ResultadosPacienteWidget.routeName);
                                } else {
                                  await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Error de acceso'),
                                      content: Text('Código de paciente o contraseña incorrectos.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: Text('Ok'))
                                      ],
                                    ),
                                  );
                                }
                              },
                              text: 'Ingresar al Portal',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 52,
                                color: Color(0xFF1565C0),
                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                      color: Colors.white,
                                      fontSize: 15,
                                      letterSpacing: 0,
                                    ),
                                elevation: 0,
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        '← Volver al inicio',
                        style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 14),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
