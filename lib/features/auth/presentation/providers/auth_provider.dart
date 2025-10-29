import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/config/config.dart';
import 'package:ultrared/features/auth/domain/domain.dart';
import 'package:ultrared/features/auth/infrastructure/infrastructure.dart';
import 'package:ultrared/features/shared/errors/error_api.dart';
import 'package:ultrared/features/shared/infrastructure/services/key_value_storage_impl.dart';

enum AuthStatus { checking, authenticated, noAuthenticated }

class UsuarioNombreResponse {
  final String nombre;
  final String error;
  UsuarioNombreResponse({
    required this.nombre,
    required this.error,
  });
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final keyValueStorage = KeyValueStorageImpl();
  return AuthNotifier(
      authRepository: authRepository, keyValueStorage: keyValueStorage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageImpl keyValueStorage;
  final Dio dio;

  AuthNotifier({required this.authRepository, required this.keyValueStorage})
      : dio = Dio(BaseOptions(
          baseUrl: '${Environment.apiUrl}api',
        )),
        super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> loginUser(
      String empresa, String usuario, String password) async {
    try {
      final user = await authRepository.login(empresa, usuario, password);
      _setLoggedUser(user);
    } on CustomError catch (e) {
      logout(errorMessage: e.message);
    } catch (e) {
      logout(errorMessage: 'Hubo un error');
    }
  }

  void registerUser(String email, String password) async {}

  void checkAuthStatus() async {
    final token = await keyValueStorage.getValue<String>('token');

    if (token == null) logout();
    try {
      final user = await authRepository.checkAuthStatus(token!);
      _setLoggedUser(user);
    } catch (e) {
      logout();
    }
  }

  void _setLoggedUser(User user) async {
    await keyValueStorage.setKeyValue<String>('token', user.token);
    dio.options.headers['x-auth-token'] = user.token;
    state = state.copywith(
      user: user,
      authStatus: AuthStatus.authenticated,
      errorMessage: '',
      isAdmin: user.rol.any((role) =>
          role == 'ADMIN' || role == 'SUPERADMIN' || role == 'ADMINISTRADOR'),
      isDemo: user.nombre == 'DEMO',
    );
  }

  Future<UsuarioNombreResponse> getUsuarioNombre(String documento) async {
    try {
      final res = await dio.get(
        '/proveedores/usuario/$documento',
      );
      return UsuarioNombreResponse(
          nombre: res.data["data"]["nombre"], error: '');
    } catch (e) {
      return UsuarioNombreResponse(
          nombre: '', error: ErrorApi.getErrorMessage(e, 'getUsuarioNombre'));
    }
  }

  Future<void> logout({String? errorMessage}) async {
    await keyValueStorage.removeKey('token');
    dio.options.headers.remove('x-auth-token');
    state = state.copywith(
        authStatus: AuthStatus.noAuthenticated,
        user: null,
        errorMessage: errorMessage);
  }

  Map<String, dynamic> dataDefaultMap(
      {String userProperty = 'user', String empresaPropery = 'rucempresa'}) {
    return {
      "rucempresa": state.user?.rucempresa,
      "rol": state.user?.rol,
      userProperty: state.user?.usuario,
      empresaPropery: state.user?.rucempresa,
    };
  }

  bool isRol({required List<String> rolesToFind}) {
    return state.user!.rol.toSet().intersection(rolesToFind.toSet()).isNotEmpty;
  }
}

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String? errorMessage;
  final bool isAdmin;
  final bool isDemo;

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessage = '',
    this.isAdmin = false,
    this.isDemo = false,
  });

  AuthState copywith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
    bool? isAdmin,
    bool? isDemo,
  }) =>
      AuthState(
        authStatus: authStatus ?? this.authStatus,
        user: user ?? this.user,
        errorMessage: errorMessage ?? this.errorMessage,
        isAdmin: isAdmin ?? this.isAdmin,
        isDemo: isDemo ?? this.isDemo,
      );
}
