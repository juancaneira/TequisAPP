import '/flutter_flow/flutter_flow_util.dart';
import 'configurar_contrasena_widget.dart' show ConfigurarContrasenaWidget;
import 'package:flutter/material.dart';

class ConfigurarContrasenaModel
    extends FlutterFlowModel<ConfigurarContrasenaWidget> {
  FocusNode? focusCPA;
  TextEditingController? controllerCPA;

  FocusNode? focusActual;
  TextEditingController? controllerActual;
  bool mostrarActual = false;

  FocusNode? focusNueva;
  TextEditingController? controllerNueva;
  bool mostrarNueva = false;

  FocusNode? focusConfirmar;
  TextEditingController? controllerConfirmar;
  bool mostrarConfirmar = false;

  bool cargando = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    focusCPA?.dispose();
    controllerCPA?.dispose();
    focusActual?.dispose();
    controllerActual?.dispose();
    focusNueva?.dispose();
    controllerNueva?.dispose();
    focusConfirmar?.dispose();
    controllerConfirmar?.dispose();
  }
}
