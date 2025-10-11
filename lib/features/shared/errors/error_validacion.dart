class Validacion {
  // Mensajes estáticos
  static const String requerido = "El campo es requerido";
  static const String requeridoList = "Al menos un ítem requerido";

  // Método para valores numéricos mínimos
  static String numMin({num valor = 0}) {
    return "Debe ser mayor a \$$valor";
  }

  // Validación de campo de texto requerido
  static String? campoRequerido(String valor) {
    return valor.trim().isEmpty ? requerido : null;
  }

  // Validación de lista de texto requerida
  static String? listaRequerida(List<String> lista) {
    return lista.isEmpty || lista.any((item) => item.trim().isEmpty)
        ? requeridoList
        : null;
  }

  // Validación de longitud mínima
  static String? longitudMin(String valor, int min) {
    return valor.trim().length < min
        ? "Debe tener al menos $min caracteres"
        : null;
  }

  // Validación de longitud máxima
  static String? longitudMax(String valor, int max) {
    return valor.trim().length > max
        ? "Debe tener máximo $max caracteres"
        : null;
  }
}
