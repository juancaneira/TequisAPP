import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'configurar_contrasena_model.dart';
export 'configurar_contrasena_model.dart';

class ConfigurarContrasenaWidget extends StatefulWidget {
  const ConfigurarContrasenaWidget({super.key, this.cpaInicial});

  /// CPA prellenado si viene desde el login
  final String? cpaInicial;

  static String routeName = 'configurarContrasena';
  static String routePath = '/configurarContrasena';

  @override
  State<ConfigurarContrasenaWidget> createState() =>
      _ConfigurarContrasenaWidgetState();
}

class _ConfigurarContrasenaWidgetState
    extends State<ConfigurarContrasenaWidget> {
  late ConfigurarContrasenaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ConfigurarContrasenaModel());
    _model.controllerCPA = TextEditingController(text: widget.cpaInicial ?? '');
    _model.focusCPA = FocusNode();
    _model.controllerActual = TextEditingController();
    _model.focusActual = FocusNode();
    _model.controllerNueva = TextEditingController();
    _model.focusNueva = FocusNode();
    _model.controllerConfirmar = TextEditingController();
    _model.focusConfirmar = FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _passwordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool visible,
    required VoidCallback onToggle,
    String? helperText,
  }) {
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Color(0xFF424242),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: !visible,
          style: TextStyle(color: Color(0xFF12151C), fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
            helperText: helperText,
            helperStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF4A6CF7)),
            suffixIcon: IconButton(
              icon: Icon(
                visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Color(0xFF9E9E9E),
              ),
              onPressed: onToggle,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Color(0xFFF5F6FA),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Color(0xFF12151C), size: 24),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Configurar Contraseña',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.readexPro(fontWeight: FontWeight.bold),
                  color: Color(0xFF12151C),
                  fontSize: 20,
                  letterSpacing: 0,
                ),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado informativo
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF4A6CF7), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF4A6CF7), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Si es la primera vez que configuras tu contraseña, deja el campo "Contraseña actual" vacío.\n\nSi ya tienes una y quieres cambiarla, ingrésala en el campo correspondiente.',
                          style: TextStyle(
                              color: Color(0xFF1565C0), fontSize: 13, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Card con formulario
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 8,
                          color: Color(0x1A000000),
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campo CPA
                        Text('CPA / Código de usuario',
                            style: TextStyle(
                                color: Color(0xFF424242),
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 6),
                        TextFormField(
                          controller: _model.controllerCPA,
                          focusNode: _model.focusCPA,
                          style: TextStyle(color: Color(0xFF12151C), fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Ej: JCNP o 00000192',
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
                            fillColor: widget.cpaInicial != null
                                ? Color(0xFFF0F0F0)
                                : Color(0xFFF8F9FA),
                          ),
                          readOnly: widget.cpaInicial != null,
                        ),
                        SizedBox(height: 16),

                        // Contraseña actual (opcional)
                        _passwordField(
                          label: 'Contraseña actual (opcional)',
                          hint: 'Dejar vacío si no tienes contraseña',
                          controller: _model.controllerActual!,
                          focusNode: _model.focusActual!,
                          visible: _model.mostrarActual,
                          onToggle: () => setState(
                              () => _model.mostrarActual = !_model.mostrarActual),
                          helperText: 'Solo si ya configuraste una contraseña antes',
                        ),
                        SizedBox(height: 16),

                        // Nueva contraseña
                        _passwordField(
                          label: 'Nueva contraseña',
                          hint: 'Mínimo 6 caracteres',
                          controller: _model.controllerNueva!,
                          focusNode: _model.focusNueva!,
                          visible: _model.mostrarNueva,
                          onToggle: () => setState(
                              () => _model.mostrarNueva = !_model.mostrarNueva),
                        ),
                        SizedBox(height: 16),

                        // Confirmar contraseña
                        _passwordField(
                          label: 'Confirmar nueva contraseña',
                          hint: 'Repite la nueva contraseña',
                          controller: _model.controllerConfirmar!,
                          focusNode: _model.focusConfirmar!,
                          visible: _model.mostrarConfirmar,
                          onToggle: () => setState(() =>
                              _model.mostrarConfirmar = !_model.mostrarConfirmar),
                        ),
                        SizedBox(height: 24),

                        // Botón guardar
                        FFButtonWidget(
                          onPressed: _model.cargando
                              ? null
                              : () async {
                                  final cpa =
                                      _model.controllerCPA!.text.trim();
                                  final actual =
                                      _model.controllerActual!.text.trim();
                                  final nueva =
                                      _model.controllerNueva!.text.trim();
                                  final confirmar =
                                      _model.controllerConfirmar!.text.trim();

                                  if (cpa.isEmpty || nueva.isEmpty || confirmar.isEmpty) {
                                    _showError(context,
                                        'Por favor completa todos los campos requeridos.');
                                    return;
                                  }
                                  if (nueva.length < 6) {
                                    _showError(context,
                                        'La contraseña debe tener al menos 6 caracteres.');
                                    return;
                                  }
                                  if (nueva != confirmar) {
                                    _showError(context,
                                        'Las contraseñas no coinciden. Verifica e intenta de nuevo.');
                                    return;
                                  }

                                  setState(() => _model.cargando = true);

                                  final response =
                                      await TequisAPIGroup.configurarContrasenaCall.call(
                                    usuario: cpa,
                                    passwordApp: nueva,
                                    passwordActual: actual.isEmpty ? null : actual,
                                  );

                                  setState(() => _model.cargando = false);

                                  if (response.succeeded ?? false) {
                                    await showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Row(children: [
                                          Icon(Icons.check_circle,
                                              color: Color(0xFF388E3C)),
                                          SizedBox(width: 8),
                                          Text('¡Listo!'),
                                        ]),
                                        content: Text(
                                            'Contraseña configurada correctamente. Ya puedes iniciar sesión.'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                context.pop();
                                              },
                                              child: Text('Ir al login'))
                                        ],
                                      ),
                                    );
                                  } else {
                                    final errorMsg = response.statusCode == 401
                                        ? 'La contraseña actual es incorrecta.'
                                        : response.statusCode == 404
                                            ? 'El CPA ingresado no existe en el sistema.'
                                            : 'Error al configurar la contraseña. Intenta de nuevo.';
                                    _showError(context, errorMsg);
                                  }
                                },
                          text: _model.cargando ? 'Guardando...' : 'Guardar Contraseña',
                          icon: Icon(
                            _model.cargando
                                ? Icons.hourglass_empty
                                : Icons.save_rounded,
                            size: 18,
                          ),
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 52,
                            color: Color(0xFF4A6CF7),
                            disabledColor: Color(0xFFBDBDBD),
                            textStyle:
                                FlutterFlowTheme.of(context).titleSmall.override(
                                      font: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 8),
          Text('Error'),
        ]),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Ok'))
        ],
      ),
    );
  }
}
