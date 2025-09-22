import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/provider/download_pdf.dart';

import 'package:image/image.dart' as img; // Agrega esta importación

class UploadInput extends ConsumerStatefulWidget {
  final bool disabled;
  final bool disabledDelete;
  final Function(String) onChanged;
  final Function(bool) setLoading;
  final bool isLoading;
  final String? errorMessage;
  final String label;
  final String? extension; // "IMAGEN", "PDF", "all"
  final String value; // URL o nombre del archivo actual

  const UploadInput({
    super.key,
    required this.label,
    this.disabled = false,
    this.disabledDelete = false,
    this.errorMessage,
    this.extension = 'all',
    required this.onChanged,
    required this.value,
    required this.setLoading,
    required this.isLoading,
  });

  @override
  ConsumerState<UploadInput> createState() => _UploadInputState();
}

class _UploadInputState extends ConsumerState<UploadInput> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    FileType fileType;
    List<String>? allowedExtensions;

    if (widget.extension == "IMAGEN") {
      fileType = FileType.custom;
      allowedExtensions = ["png", "jpg", "jpeg"];
    } else if (widget.extension == "PDF") {
      fileType = FileType.custom;
      allowedExtensions = ["pdf"];
    } else if (widget.extension == "all") {
      fileType = FileType.custom;
      allowedExtensions = ["png", "jpg", "jpeg", "pdf"];
    } else {
      fileType = FileType.any;
      allowedExtensions = null;
    }

    final result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowedExtensions: allowedExtensions,
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() => _selectedFile = file);
      await _uploadFile(file);
    }
  }

  Future<void> _uploadFile(File file) async {
    widget.setLoading(true);
    final dio = ref.read(authProvider.notifier).dio;
    try {
      final fileName = file.path.split('/').last;

      // Si es imagen, reducir tamaño/resolución
      final isImage = ['png', 'jpg', 'jpeg']
          .any((ext) => fileName.toLowerCase().endsWith(ext));
      File fileToUpload = file;
      if (isImage) {
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image != null) {
          // Redimensionar (por ejemplo, ancho máximo 1024px)
          final resized = img.copyResize(image, width: 1024);
          final resizedBytes =
              img.encodeJpg(resized, quality: 80); // Puedes ajustar la calidad
          final tempDir = Directory.systemTemp;
          final tempFile = await File('${tempDir.path}/resized_$fileName')
              .writeAsBytes(resizedBytes);
          fileToUpload = tempFile;
        }
      }

      final formData = FormData.fromMap({
        "tipo": widget.label,
        "archivo":
            await MultipartFile.fromFile(fileToUpload.path, filename: fileName),
      });

      // Si hay un archivo previo, eliminarlo
      if (widget.value.isNotEmpty) {
        await dio.post("/upload_delete_multiple_files/delete", data: {
          "urls": [widget.value]
        });
      }

      final response = await dio.post(
        "/upload_delete_multiple_files/upload",
        data: formData,
      );

      widget.onChanged(response.data["nombre"]);
    } catch (e) {
      NotificationsService.show(context.mounted ? context : null,
          'Hubo un error al subir el archivo', SnackbarCategory.error);
    }
    widget.setLoading(false);
  }

  Future<void> _deleteFile() async {
    final dio = ref.read(authProvider.notifier).dio;

    widget.setLoading(true);
    try {
      if (widget.value.isNotEmpty) {
        await dio.post("/upload_delete_multiple_files/delete", data: {
          "urls": [widget.value]
        });
        widget.onChanged('');
        setState(() => _selectedFile = null);
      }
    } catch (e) {
      NotificationsService.show(context.mounted ? context : null,
          'Hubo un error al eliminar el archivo', SnackbarCategory.error);
    }

    widget.setLoading(false);
  }

  Future<void> _downloadFile() async {
    final url = widget.value;
    final downloadPDF = ref.read(downloadPdfProvider.notifier).downloadPDF;
    if (url.isNotEmpty) {
      downloadPDF(context, url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = _selectedFile != null
        ? _selectedFile!.path.split('/').last
        : (widget.value.isNotEmpty)
            ? widget.value.split('/').last
            : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ...existing code...
        TextFormField(
          readOnly: true,
          controller: TextEditingController(text: fileName),
          onChanged: null,
          decoration: InputDecoration(
            errorText: widget.errorMessage,
            labelText: widget.label,
            suffixIcon: SizedBox(
              width: 250, // Ajusta el ancho según la cantidad de iconos
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message: "Subir Archivo",
                    child: IconButton(
                      icon: const Icon(Icons.cloud_upload),
                      color: widget.disabled ? Colors.grey : Colors.blue,
                      onPressed: widget.disabled || widget.isLoading
                          ? null
                          : () {
                              if (widget.value.isEmpty) {
                                _pickFile();
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Reemplazar archivo"),
                                    content: const Text(
                                        "¿Estás seguro de que deseas reemplazar el archivo actual?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Cancelar"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _pickFile();
                                        },
                                        child: const Text("Reemplazar"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                    ),
                  ),
                  if (widget.value.isNotEmpty)
                    Tooltip(
                      message: "Descargar Archivo",
                      child: IconButton(
                        icon: const Icon(Icons.download),
                        color: Colors.green,
                        onPressed: widget.isLoading ? null : _downloadFile,
                      ),
                    ),
                  if (widget.value.isNotEmpty && !widget.disabledDelete)
                    Tooltip(
                      message: "Eliminar Archivo",
                      child: IconButton(
                        icon: const Icon(Icons.delete_forever),
                        color: Colors.red,
                        onPressed: widget.disabledDelete || widget.isLoading
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Eliminar archivo"),
                                    content: const Text(
                                        "¿Estás seguro de que deseas eliminar el archivo?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text("Cancelar"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _deleteFile();
                                        },
                                        child: const Text("Eliminar"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
// ...existing code...
        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}
