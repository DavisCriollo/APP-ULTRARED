import 'package:intl/intl.dart';

class CombustibleInfo {
  final String descripcion;
  final String codigo;

  CombustibleInfo({required this.descripcion, required this.codigo});
}

class Format {
  /// Formatea una fecha (String) a un formato local con el nombre del día (3 letras), día/mes/año (ejemplo: mié, 26/03/2025)
  static String formatFecha(String fecha) {
    try {
      final DateTime parsedDate = DateTime.parse(fecha).toLocal();
      return DateFormat('EEE, dd/MM/yyyy', 'es_ES').format(parsedDate);
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  /// Formatea una fecha (String) a un formato local con el nombre del día (3 letras), día/mes/año y hora (ejemplo: mié, 26/03/2025 14:30)
  static String formatFechaHora(String fecha) {
    try {
      final DateTime parsedDate = DateTime.parse(fecha).toLocal();
      return DateFormat('EEE, dd/MM/yyyy HH:mm', 'es_ES').format(parsedDate);
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  /// Aproxima un número a 2 decimales
  static double roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  /// Quita las dobles comillas al inicio y final de un string, si existen
  static String limpiarComillas(String valor) {
    // Quita todas las comillas dobles
    return valor.replaceAll('"', '');
  }
}
