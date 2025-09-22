import 'package:dio/dio.dart';
import 'package:ultrared/config/config.dart';
import 'package:ultrared/features/auth/domain/domain.dart';
import 'package:ultrared/features/auth/infrastructure/infrastructure.dart';
import 'package:ultrared/features/shared/errors/error_api.dart';

class AuthDatasourceImpl extends AuthDatasource {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${Environment.apiUrl}api',
    ),
  );
  @override
  Future<User> checkAuthStatus(String token) async {
    try {
      final res = await dio.get('/auth',
          options: Options(headers: {'x-auth-token': token}));
      final user = UserMapper.userJsonToEntity(res.data);
      return user;
    } on DioException catch (e) {
      throw CustomError(ErrorApi.getErrorMessage(e, 'checkAuthStatus'));
    }
  }

  @override
  Future<User> login(String empresa, String usuario, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'empresa': empresa.trim(),
          'password': password.trim(),
          'usuario': usuario.trim(),
        },
      );
      final user = UserMapper.userJsonToEntity(response.data);
      return user;
    } on DioException catch (e) {
      throw CustomError(ErrorApi.getErrorMessage(e, 'login'));
    }
  }

  @override
  Future<User> register(String email, String password, String fullName) {
    throw UnimplementedError();
  }
}
