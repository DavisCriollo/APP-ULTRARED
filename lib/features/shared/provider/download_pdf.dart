import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultrared/config/local_notifications/local_notifications.dart';

final downloadPdfProvider =
    StateNotifierProvider<PdfDownloadNotifier, PdfDownloadState>((ref) {
  return PdfDownloadNotifier();
});

class PdfDownloadState {
  final bool isDownloading;
  final double progress;

  PdfDownloadState({required this.isDownloading, required this.progress});
}

class PdfDownloadNotifier extends StateNotifier<PdfDownloadState> {
  PdfDownloadNotifier()
      : super(PdfDownloadState(isDownloading: false, progress: 0.0));

  Future<void> downloadPDF(BuildContext? context, String infoPdf) async {
    Dio dio = Dio();
    try {
      state = PdfDownloadState(isDownloading: true, progress: 0.0);

      // Solicitar permisos de almacenamiento
      var status = await Permission.storage.request();
      if (status.isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        var dir = await getExternalStorageDirectory();
        String newPath = "";
        List<String> paths = dir!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/$folder";
          } else {
            break;
          }
        }
        newPath = "$newPath/Download";
        dir = Directory(newPath);
 
        String fileName = infoPdf.split('/').last.split('?').first;
        // if (fileName.isEmpty) fileName = 'archivo_descargado';
        String filePath = '${dir.path}/$fileName'; 
        await dio.download(
          infoPdf,
          filePath,
          onReceiveProgress: (rec, total) {
            state =
                PdfDownloadState(isDownloading: true, progress: (rec / total));
          },
        );

        // Mostrar notificación
        LocalNotifications.showLocalNotification(
          id: 0,
          title: 'Descarga completada',
          body: 'Toca para abrir el archivo',
          data: filePath,
        );
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Descarga completada: $filePath')),
          );
        }
        OpenFile.open(filePath);
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      } else {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de almacenamiento denegado')),
          );
        }
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al descargar el archivo')),
        );
      }
    } finally {
      state = PdfDownloadState(isDownloading: false, progress: 0.0);
    }
  }
}
