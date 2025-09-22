import 'package:ultrared/features/auth/domain/domain.dart';

abstract class AuthRepository {
  Future<User> login(String empresa, String usuario, String password);
  Future<User> register(String email, String password, String fullName);
  Future<User> checkAuthStatus(String token);
}
