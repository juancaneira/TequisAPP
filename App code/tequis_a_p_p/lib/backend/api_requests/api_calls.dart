import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start TequisAPI Group Code

class TequisAPIGroup {
  static String getBaseUrl() => 'https://api.laboratoriotequis.com.mx';
  static Map<String, String> headers = {};
  static ListarInformesMedicoCall listarInformesMedicoCall =
      ListarInformesMedicoCall();
  static ListarInformesPacienteCall listarInformesPacienteCall =
      ListarInformesPacienteCall();
  static ConfigurarContrasenaCall configurarContrasenaCall =
      ConfigurarContrasenaCall();
  static LoginCall loginCall = LoginCall();
}

class ListarInformesMedicoCall {
  Future<ApiCallResponse> call({
    String? cpaMedico = '',
  }) async {
    final baseUrl = TequisAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: ' ListarInformesMedico',
      apiUrl: '${baseUrl}/medico/informes',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {
        'CPA_Medico': cpaMedico,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List<String>? idReferto(dynamic response) => (getJsonField(
        response,
        r'''$[:].IdReferto''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? codigoReferto(dynamic response) => (getJsonField(
        response,
        r'''$[:].CodigoReferto''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? fechaReferto(dynamic response) => (getJsonField(
        response,
        r'''$[:].FechaReferto''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? nombrePaciente(dynamic response) => (getJsonField(
        response,
        r'''$[:].NombrePaciente''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<int>? tamanoPDFkb(dynamic response) => (getJsonField(
        response,
        r'''$[:].TamanoPDFkb''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<int>? publicado(dynamic response) => (getJsonField(
        response,
        r'''$[:].Publicado''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<String>? horaReferto(dynamic response) => (getJsonField(
        response,
        r'''$[:].HoraReferto''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class ListarInformesPacienteCall {
  Future<ApiCallResponse> call({
    String? cPAPaciente = '',
  }) async {
    final baseUrl = TequisAPIGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'ListarInformesPaciente',
      apiUrl: '${baseUrl}/paciente/informes',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'CPA_Paciente': cPAPaciente,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  List<String>? idReferto(dynamic response) => (getJsonField(
        response,
        r'''$[:].IdReferto''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? codigoReferto(dynamic response) => (getJsonField(
        response,
        r'''$[:].CodigoReferto''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? fechaReferto(dynamic response) => (getJsonField(
        response,
        r'''$[:].FechaReferto''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<String>? nombreMedico(dynamic response) => (getJsonField(
        response,
        r'''$[:].NombreMedico''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  List<int>? tamanoPDFkb(dynamic response) => (getJsonField(
        response,
        r'''$[:].TamanoPDFkb''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
}

class ConfigurarContrasenaCall {
  Future<ApiCallResponse> call({
    String? usuario = '',
    String? passwordApp = '',
    String? passwordActual,
  }) async {
    final baseUrl = TequisAPIGroup.getBaseUrl();

    final Map<String, dynamic> bodyMap = {
      'usuario': usuario,
      'passwordApp': passwordApp,
    };
    if (passwordActual != null && passwordActual.isNotEmpty) {
      bodyMap['passwordActual'] = passwordActual;
    }
    final ffApiRequestBody = jsonEncode(bodyMap);

    return ApiManager.instance.makeApiCall(
      callName: 'ConfigurarContrasena',
      apiUrl: '${baseUrl}/setup-password',
      callType: ApiCallType.POST,
      headers: {'Content-Type': 'application/json'},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  dynamic mensaje(dynamic response) => getJsonField(
        response,
        r'''$.mensaje''',
      );
  String? error(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.error''',
      ));
}

class LoginCall {
  Future<ApiCallResponse> call({
    String? usuario = '',
    String? contrasena = '',
  }) async {
    final baseUrl = TequisAPIGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "usuario": "${usuario}",
  "contrasena": "${contrasena}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'login',
      apiUrl: '${baseUrl}/login',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? error(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.error''',
      ));
  bool? ok(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.ok''',
      ));
  String? rol(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.rol''',
      ));
  String? cpa(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.cpa''',
      ));
  String? nombre(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.nombre''',
      ));
  String? email(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.email''',
      ));
}

/// End TequisAPI Group Code

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
