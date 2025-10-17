import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:url_launcher/url_launcher.dart'; 

Future<void> launchWhatsApp(BuildContext context, String phoneNumber) async {
  final Uri whatsappUrl = Uri.parse("https://wa.me/$phoneNumber");

  try {
    await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
  } catch (e) {
    if (context.mounted) {
      NotificationsService.show(
        context,
        "No se puede abrir WhatsApp",
        SnackbarCategory.error,
      );
    }
  }
}