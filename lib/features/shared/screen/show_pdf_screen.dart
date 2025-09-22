import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultrared/config/local_notifications/local_notifications.dart';

class ShowPdfScreen extends StatefulWidget {
  final String infoPdf;
  final String labelPdf;

  const ShowPdfScreen(
      {super.key, required this.infoPdf, required this.labelPdf});

  @override
  ShowPdfScreenState createState() => ShowPdfScreenState();
}

class ShowPdfScreenState extends State<ShowPdfScreen> {
  bool _isDownloading = false;
  double _progress = 0.0;

  Future<void> downloadPDF(BuildContext context) async {
    Dio dio = Dio();
    try {
      setState(() {
        _isDownloading = true;
        _progress = 0.0;
      });

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

        String filePath = '${dir.path}/documento.pdf';
        await dio.download(
          widget.infoPdf,
          filePath,
          onReceiveProgress: (rec, total) {
            setState(() {
              _progress = (rec / total);
            });
          },
        );

        // Mostrar notificación
        LocalNotifications.showLocalNotification(
          id: 0,
          title: 'Descarga completada',
          body: 'Toca para abrir el archivo',
          data: filePath,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Descarga completada: $filePath')),
          );
        }
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de almacenamiento denegado')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al descargar el archivo')),
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    LocalNotifications.initializeLocalNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final Responsive size = Responsive.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        appBar: AppBar(
          title: const Text('Factura'),
          actions: [
            IconButton(
              icon: Icon(
                Icons.download_outlined,
                size: size.iScreen(3.5),
              ),
              onPressed: () {
                downloadPDF(context);
              },
            ),
          ],
        ),
        body: _isDownloading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(value: _progress),
                    const SizedBox(height: 20),
                    Text('${(_progress * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              )
            : Container(
                width: size.wScreen(100),
                height: size.hScreen(100),
                padding: EdgeInsets.symmetric(
                    horizontal: size.iScreen(1.0), vertical: size.iScreen(1.0)),
                color: Colors.grey[300],
                child: const PDF().cachedFromUrl(widget.infoPdf),
              ),
      ),
    );
  }
}