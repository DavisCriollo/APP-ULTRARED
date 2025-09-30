import 'package:ultrared/features/clientes/domain/entities/cliente.dart';
import 'package:ultrared/features/shared/domain/entities/ciudad.dart';
import 'package:ultrared/features/shared/domain/entities/plan.dart';
import 'package:ultrared/features/shared/domain/entities/servicio.dart';

class ResponseGetCiudades {
  final List<Ciudad> resultado;
  final String error;

  ResponseGetCiudades({
    required this.resultado,
    required this.error,
  });

  /// Devuelve una nueva instancia con el mismo `resultado` y `error` vacío.
  ResponseGetCiudades clearError() {
    return ResponseGetCiudades(resultado: resultado, error: '');
  }
}

class ResponseGetVendedores {
  final List<Persona> resultado;
  final String error;

  ResponseGetVendedores({
    required this.resultado,
    required this.error,
  });

  /// Devuelve una nueva instancia con el mismo `resultado` y `error` vacío.
  ResponseGetVendedores clearError() {
    return ResponseGetVendedores(resultado: resultado, error: '');
  }
}

class ResponseGetPlanes {
  final List<Plan> resultado;
  final String error;

  ResponseGetPlanes({
    required this.resultado,
    required this.error,
  });

  /// Devuelve una nueva instancia con el mismo `resultado` y `error` vacío.
  ResponseGetPlanes clearError() {
    return ResponseGetPlanes(resultado: resultado, error: '');
  }
}

class ResponseGetServicios {
  final List<Servicio> resultado;
  final String error;

  ResponseGetServicios({
    required this.resultado,
    required this.error,
  });

  /// Devuelve una nueva instancia con el mismo `resultado` y `error` vacío.
  ResponseGetServicios clearError() {
    return ResponseGetServicios(resultado: resultado, error: '');
  }
}
