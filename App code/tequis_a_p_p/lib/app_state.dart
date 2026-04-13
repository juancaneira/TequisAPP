import 'package:flutter/material.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _usuarioRol = prefs.getString('ff_usuarioRol') ?? _usuarioRol;
    });
    _safeInit(() {
      _usuarioCPA = prefs.getString('ff_usuarioCPA') ?? _usuarioCPA;
    });
    _safeInit(() {
      _usuarioNombre = prefs.getString('ff_usuarioNombre') ?? _usuarioNombre;
    });
    _safeInit(() {
      _usuarioEmail = prefs.getString('ff_usuarioEmail') ?? _usuarioEmail;
    });
    _safeInit(() {
      _estaLogueado = prefs.getBool('ff_estaLogueado') ?? _estaLogueado;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _usuarioRol = '';
  String get usuarioRol => _usuarioRol;
  set usuarioRol(String value) {
    _usuarioRol = value;
    prefs.setString('ff_usuarioRol', value);
  }

  String _usuarioCPA = '';
  String get usuarioCPA => _usuarioCPA;
  set usuarioCPA(String value) {
    _usuarioCPA = value;
    prefs.setString('ff_usuarioCPA', value);
  }

  String _usuarioNombre = '';
  String get usuarioNombre => _usuarioNombre;
  set usuarioNombre(String value) {
    _usuarioNombre = value;
    prefs.setString('ff_usuarioNombre', value);
  }

  String _usuarioEmail = '';
  String get usuarioEmail => _usuarioEmail;
  set usuarioEmail(String value) {
    _usuarioEmail = value;
    prefs.setString('ff_usuarioEmail', value);
  }

  bool _estaLogueado = false;
  bool get estaLogueado => _estaLogueado;
  set estaLogueado(bool value) {
    _estaLogueado = value;
    prefs.setBool('ff_estaLogueado', value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
