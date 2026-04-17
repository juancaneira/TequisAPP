import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Descarga el PDF desde [url], lo guarda como archivo temporal
/// y lo abre con el visor del sistema (permite compartir el archivo).
/// Si [compartir] es true, muestra el diálogo de compartir directamente.
Future<void> abrirPDF(
  BuildContext context, {
  required String url,
  required String nombreArchivo,
  bool compartir = false,
}) async {
  // Diálogo de progreso
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: Color(0xFF4A6CF7)),
            SizedBox(width: 16),
            Expanded(child: Text('Descargando informe...')),
          ],
        ),
      ),
    ),
  );

  try {
    final response = await http.get(Uri.parse(url));

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // cierra el diálogo

    if (response.statusCode != 200) {
      _mostrarError(context, 'No se pudo descargar el informe (${response.statusCode}).');
      return;
    }

    // Guardar en directorio temporal
    final dir = await getTemporaryDirectory();
    final archivo = File('${dir.path}/$nombreArchivo.pdf');
    await archivo.writeAsBytes(response.bodyBytes);

    if (compartir) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(archivo.path, mimeType: 'application/pdf')],
          subject: nombreArchivo,
        ),
      );
    } else {
      final result = await OpenFilex.open(archivo.path, type: 'application/pdf');
      if (result.type != ResultType.done && context.mounted) {
        _mostrarError(context,
            'No se encontró un visor de PDF instalado. Instala Adobe Acrobat u otro visor.');
      }
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      _mostrarError(context, 'Error al descargar el informe. Verifica tu conexión.');
    }
  }
}

void _mostrarError(BuildContext context, String mensaje) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(children: [
        Icon(Icons.error_outline, color: Colors.red),
        SizedBox(width: 8),
        Text('Error'),
      ]),
      content: Text(mensaje),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Ok'))
      ],
    ),
  );
}
