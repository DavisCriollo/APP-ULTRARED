import 'package:ultrared/features/auth/domain/domain.dart';
import 'package:ultrared/features/auth/infrastructure/infrastructure.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl({AuthDatasource? datasource})
      : datasource = datasource ?? AuthDatasourceImpl();
  @override
  Future<User> checkAuthStatus(String token) {
    return datasource.checkAuthStatus(token);
  }

  @override
  Future<User> login(String empresa, String usuario, String password) {
    return datasource.login(empresa, usuario, password);
  }

  @override
  Future<User> register(String email, String password, String fullName) {
    return datasource.register(email, password, fullName);
  }
}
