import 'package:flutter/material.dart';
import 'package:ultrared/main.dart';

enum SnackbarCategory { success, warning, error }

class NotificationsService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show(
      BuildContext? context, String message, SnackbarCategory category) {
    if (context == null) {
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getSnackbarColor(category).contrastText),
      ),
      backgroundColor: _getSnackbarColor(category),

      // duration: const Duration(seconds: 2),
    ));
  }

  /// Muestra un error si `nextError` es distinto y no vacío, y luego ejecuta
  /// `clearErrorCallback` para limpiar el error en el provider.
  /// Uso típico desde `ref.listen`:
  /// ref.listen(sharedDataProvider, (previous, next) {
  ///   NotificationsService.showProviderErrorAndClear(
  ///     context: context,
  ///     prevError: previous?.responseGetCiudades.error ?? '',
  ///     nextError: next.responseGetCiudades.error,
  ///     clearErrorCallback: () => ref.read(sharedDataProvider.notifier).clearErrorCiudades(),
  ///   );
  /// });
  static void showProviderErrorAndClear({
    required BuildContext context,
    required String prevError,
    required String nextError,
    required VoidCallback clearErrorCallback,
    SnackbarCategory category = SnackbarCategory.error,
  }) {
    if (nextError.isNotEmpty && prevError != nextError) {
      show(context, nextError, category);
      try {
        clearErrorCallback();
      } catch (_) {
        // Silenciar errores del callback para no romper la UI.
      }
    }
  }

  static Color _getSnackbarColor(SnackbarCategory category) {
    switch (category) {
      case SnackbarCategory.success:
        return Colors.green.shade900;
      case SnackbarCategory.warning:
        return Colors.yellow;
      case SnackbarCategory.error:
        return Colors.red;
    }
  }
}
