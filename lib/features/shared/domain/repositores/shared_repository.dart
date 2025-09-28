import 'package:dio/dio.dart';
import 'package:ultrared/features/shared/domain/entities/ciudad.dart';
import 'package:ultrared/features/shared/errors/error_api.dart';

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

class SharedRepository {
  final Dio dio;
  SharedRepository({
    required this.dio,
  });

  Future<ResponseGetCiudades> getCiudades() async {
    try {
      final response = await dio.get(
        '/ciudades/filtro/0',
      );
      final List<Ciudad> resCiudades =
          response.data['data'].map<Ciudad>((e) => Ciudad.fromJson(e)).toList();

      return ResponseGetCiudades(
        resultado: resCiudades,
        error: '',
      );
    } on DioException catch (e) {
      return ResponseGetCiudades(
          resultado: [], error: ErrorApi.getErrorMessage(e, 'getCiudades'));
    }
  }
}
