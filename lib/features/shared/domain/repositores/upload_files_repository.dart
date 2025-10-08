import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ultrared/features/shared/domain/entities/imagen.dart';
import 'package:ultrared/features/shared/errors/error_api.dart';

class ResponseUploadFiles {
  final List<Imagen> resultado;
  final String error;
  ResponseUploadFiles({required this.resultado, required this.error});
}

class ResponseDeleteFiles {
  final String error;
  ResponseDeleteFiles({required this.error});
}

class UploadFilesRepository {
  final Dio dio;
  UploadFilesRepository({required this.dio});

  /// Sube múltiples imágenes. `tipo` se envía como campo y cada archivo se
  /// envía en un campo "archivo" (múltiples entradas).
  /// Retorna la lista de Imagen (según lo que devuelva el backend) o error.
// ...existing code...
  /// `images` = lista de Imagen con url locales a subir.
  /// `tipo` = campo tipo.
  /// `fotosSubidas` = lista de urls ya subidas en el backend (se envía en `eliminar` -> JSON).
  /// `modificoImagenes` = fuerza el POST aunque no haya `images`.
  Future<ResponseUploadFiles> uploadFiles({
    required List<Imagen> imagenes,
    required String tipo,
    required List<String> urlToDelete,
  }) async {
    try {
      final imagenesToUpload =
          imagenes.where((img) => !img.url.startsWith('http')).toList();
      if (imagenesToUpload.isEmpty && urlToDelete.isEmpty) {
        return ResponseUploadFiles(resultado: [], error: '');
      }
      final formData = FormData.fromMap({
        "tipo": tipo,
      });

      // Si hay un archivo previo, eliminarlo

      for (var i = 0; i < imagenesToUpload.length; i++) {
        final img = imagenesToUpload[i];

        formData.files.add(MapEntry(
          'imagen${i + 1}',
          await MultipartFile.fromFile(img.url,
              filename: img.url.split(Platform.pathSeparator).last),
        ));
      }

      // Enviamos la lista de fotos ya subidas para que el backend la procese (campo 'eliminar')
      formData.fields.add(MapEntry('eliminar', jsonEncode(urlToDelete)));

      final resp = await dio.post(
        '/upload_delete_multiple_files/uploads',
        data: formData,
        options: Options(headers: {'Accept': 'application/json'}),
      );

      final data = resp.data?['pathUrls'] ?? [];
      List<Imagen> resultado = [];
      if (data != null) {
        if (data is List) {
          resultado = data.map<Imagen>((p) {
            final url = p is String ? p : (p['url'] ?? '');
            final nombre = (url is String && url.isNotEmpty)
                ? url.split('/').last
                : url.split(Platform.pathSeparator).last;
            return Imagen(nombre: nombre ?? '', url: url ?? '');
          }).toList();
        }
      }

      return ResponseUploadFiles(resultado: resultado, error: '');
    } on DioException catch (e) {
      return ResponseUploadFiles(
          resultado: [], error: ErrorApi.getErrorMessage(e, 'uploadFiles'));
    } catch (e) {
      return ResponseUploadFiles(resultado: [], error: e.toString());
    }
  }

// ...existing code...
  /// Elimina múltiples archivos recibiendo un arreglo de URLs.
  /// Retorna success = true si todo OK, o error.
  Future<ResponseDeleteFiles> deleteFiles({
    required List<String> urls,
  }) async {
    try {
      await dio.post(
        '/upload_delete_multiple_files/delete',
        data: {'urls': urls},
      );

      return ResponseDeleteFiles(error: '');
    } catch (e) {
      return ResponseDeleteFiles(
        error: ErrorApi.getErrorMessage(e, 'deleteFiles'),
      );
    }
  }
}
