import 'package:dio/dio.dart';

class ErrorApi {
  static String getErrorMessage(dynamic error, String nombreFuncion) { 
    const String defaultError = 'Cargando.....';
    print(nombreFuncion);
    if (error is DioException) {
      try {
        return error.response?.data['msg'] as String? ?? defaultError;
      } catch (e) {
        return defaultError;
      }
    }
    return defaultError;
  }
}
