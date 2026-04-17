import '/flutter_flow/flutter_flow_util.dart';
import 'loginpaciente_widget.dart' show LoginpacienteWidget;
import 'package:flutter/material.dart';

class LoginpacienteModel extends FlutterFlowModel<LoginpacienteWidget> {
  final unfocusNode = FocusNode();
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;

  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  bool passwordVisibility = false;
  String? Function(BuildContext, String?)? textController2Validator;

  // Page state variables
  String? campoCPA;
  String? campoContrasena;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();
    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }
}
