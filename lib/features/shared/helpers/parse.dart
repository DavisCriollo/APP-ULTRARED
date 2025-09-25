import 'dart:convert';

class Parse {
  static String parseDynamicToString(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is num) {
      return value.toString();
    } else if (value is bool) {
      return value ? 'true' : 'false';
    } else {
      return '';
    }
  }

  static double parseDynamicToDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      return value.toDouble();
    } else {
      return 0.0;
    }
  }

  static int parseDynamicToInt(dynamic value) {
    if (value is String) {
      return int.tryParse(value) ?? 0;
    } else if (value is int) {
      return value;
    } else if (value is double) {
      return value.toInt();
    } else {
      return 0;
    }
  }

// ...existing code...

  static List<String> parseDynamicToListString(dynamic value) {
    if (value == null) return <String>[];

    // Si ya es una lista, convertir cada elemento a String y filtrar vacíos
    if (value is List) {
      return value
          .map((e) => e == null ? '' : e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Si es String, puede ser JSON array '["a","b"]' o CSV 'a, b' o elemento único
    if (value is String) {
      final s = value.trim();
      if (s.isEmpty) return <String>[];

      // Intentar decodificar JSON array
      if (s.startsWith('[') && s.endsWith(']')) {
        try {
          final decoded = jsonDecode(s);
          if (decoded is List) {
            return decoded
                .map((e) => e == null ? '' : e.toString().trim())
                .where((t) => t.isNotEmpty)
                .toList();
          }
        } catch (_) {
          // ignorar y continuar con CSV/único
        }
      }

      // CSV
      if (s.contains(',')) {
        return s
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      // Cadena única
      return <String>[s];
    }

    // Otros tipos (num, bool, etc.) -> convertir a String
    return <String>[value.toString()];
  }

// ...existing code...

  static List<int> parseDynamicToListInt(dynamic value) {
    if (value is int) {
      return [value];
    } else if (value is List) {
      return value.map((e) {
        if (e is int) {
          return e;
        } else if (e is String) {
          return int.tryParse(e) ?? 0;
        } else {
          return 0;
        }
      }).toList();
    } else {
      return [];
    }
  }

  static List<double> parseDynamicToListDouble(dynamic value) {
    if (value is double) {
      return [value];
    } else if (value is List) {
      return value.map((e) {
        if (e is double) {
          return e;
        } else if (e is int) {
          return e.toDouble();
        } else if (e is String) {
          return double.tryParse(e) ?? 0.0;
        } else {
          return 0.0;
        }
      }).toList();
    } else {
      return [];
    }
  }
}
