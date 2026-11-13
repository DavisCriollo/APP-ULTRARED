import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;
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
  static const int maxBytes = 4 * 1024 * 1024;

  UploadFilesRepository({required this.dio});

  /// Reduce el peso de una imagen para que no supere el límite de 4 MB.
  Future<File> _comprimirImagenSiEsNecesario(File file) async {
    final fileName =
        file.path.split(Platform.pathSeparator).last.toLowerCase();
    final esImagen =
        ['png', 'jpg', 'jpeg'].any((ext) => fileName.endsWith(ext));
    if (!esImagen) return file;

    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return file;

      final resized =
          decoded.width > 1280 ? img.copyResize(decoded, width: 1280) : decoded;
      final compressedBytes = img.encodeJpg(resized, quality: 80);

      final tempFile = File(
        '${Directory.systemTemp.path}/b2_${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );
      await tempFile.writeAsBytes(compressedBytes);
      return tempFile;
    } catch (_) {
      return file;
    }
  }

  /// Sube cada foto nueva en una petición a `POST /storage/upload`
  /// y borra las marcadas con `DELETE /storage/delete`.
  Future<ResponseUploadFiles> uploadFiles({
    required List<Imagen> imagenes,
    required String tipo,
    required List<String> urlToDelete,
  }) async {
    final imagenesToUpload =
        imagenes.where((item) => !item.url.startsWith('http')).toList();
    final imagenesUploaded =
        imagenes.where((item) => item.url.startsWith('http')).toList();

    try {
      if (imagenesToUpload.isEmpty && urlToDelete.isEmpty) {
        return ResponseUploadFiles(resultado: imagenesUploaded, error: '');
      }

      final urlsLimpias =
          urlToDelete.map((u) => u.trim()).where((u) => u.isNotEmpty).toList();
      if (urlsLimpias.isNotEmpty) {
        await deleteFiles(urls: urlsLimpias);
      }

      final List<Imagen> resultado = [];
      for (var i = 0; i < imagenesToUpload.length; i++) {
        final itemImg = imagenesToUpload[i];
        final originalFile = File(itemImg.url);
        final fileToUpload = await _comprimirImagenSiEsNecesario(originalFile);

        final fileSize = await fileToUpload.length();
        if (fileSize > maxBytes) {
          return ResponseUploadFiles(
            resultado: [...imagenesUploaded, ...resultado],
            error: 'El archivo supera el límite máximo permitido de 4 MB',
          );
        }

        final fileName = fileToUpload.path.split(Platform.pathSeparator).last;

        final formData = FormData.fromMap({
          'carpeta': tipo,
          'archivo': await MultipartFile.fromFile(
            fileToUpload.path,
            filename: fileName,
          ),
        });

        final resp = await dio.post(
          '/storage/upload',
          data: formData,
          options: Options(headers: {'Accept': 'application/json'}),
        );

        final String uploadedUrl =
            (resp.data?['url'] ?? resp.data?['nombre'] ?? '').toString();

        if (uploadedUrl.isNotEmpty) {
          final nombre = uploadedUrl.split('/').last;
          resultado.add(
            Imagen(
              nombre: nombre.isNotEmpty ? nombre : itemImg.nombre,
              url: uploadedUrl,
            ),
          );
        }
      }

      return ResponseUploadFiles(
        resultado: [...imagenesUploaded, ...resultado],
        error: '',
      );
    } on DioException catch (e) {
      return ResponseUploadFiles(
        resultado: imagenesUploaded,
        error: ErrorApi.getErrorMessage(e, 'uploadFiles'),
      );
    } catch (e) {
      return ResponseUploadFiles(
        resultado: imagenesUploaded,
        error: e.toString(),
      );
    }
  }

  /// Elimina archivos en Backblaze B2 con `DELETE /storage/delete`.
  Future<ResponseDeleteFiles> deleteFiles({
    required List<String> urls,
  }) async {
    try {
      final urlsLimpias =
          urls.map((u) => u.trim()).where((u) => u.isNotEmpty).toList();
      if (urlsLimpias.isEmpty) {
        return ResponseDeleteFiles(error: '');
      }

      await dio.delete(
        '/storage/delete',
        data: {'urls': urlsLimpias},
      );

      return ResponseDeleteFiles(error: '');
    } catch (e) {
      return ResponseDeleteFiles(
        error: ErrorApi.getErrorMessage(e, 'deleteFiles'),
      );
    }
  }
}
