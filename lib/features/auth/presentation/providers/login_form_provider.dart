import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:ultrared/features/auth/infrastructure/inputs/input.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/shared/shared.dart';

import 'package:ultrared/features/shared/infrastructure/services/key_value_storage_impl.dart';
//! 3- StateNotifier - consume afuera

final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
  final loginUserCallback = ref.watch(authProvider.notifier).loginUser;
  final keyValueStorage = KeyValueStorageImpl();
  return LoginFormNotifier(
      loginUserCallback: loginUserCallback, keyValueStorage: keyValueStorage);
});

//! 2- Como implementamos un notifier
class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final KeyValueStorageImpl keyValueStorage;
  final Future<void> Function(String, String, String) loginUserCallback;
  LoginFormNotifier(
      {required this.loginUserCallback, required this.keyValueStorage})
      : super(LoginFormState()) {
    setvalues();
  }

  void setvalues() async {
    final rememberMe = await keyValueStorage.getValue<int>('rememberMe');
    state = state.copyWith(isLoadingData: true);
    final usuario = await keyValueStorage.getValue<String>('usuario');
    final password = await keyValueStorage.getValue<String>('password');
    final empresa = await keyValueStorage.getValue<String>('empresa');

    if (rememberMe == 1) {
      state = state.copyWith(
        usuario: Usuario.dirty(usuario ?? ""),
        password: Password.dirty(password ?? ""),
        empresa: Empresa.dirty(empresa ?? ""),
        rememberMe: rememberMe == 1,
      );
      await Future.delayed(const Duration(milliseconds: 100));
    }
    state = state.copyWith(isLoadingData: false);
  }

  void _updateState({
    Usuario? usuario,
    Password? password,
    Empresa? empresa,
    bool? rememberMe,
  }) {
    state = state.copyWith(
      usuario: usuario ?? state.usuario,
      password: password ?? state.password,
      empresa: empresa ?? state.empresa,
      rememberMe: rememberMe ?? state.rememberMe,
      isValid: Formz.validate([
        usuario ?? state.usuario,
        password ?? state.password,
        empresa ?? state.empresa,
      ]),
    );
  }

  void onEmpresaChange(String value) {
    final newEmpresa = Empresa.dirty(value);
    _updateState(empresa: newEmpresa);
  }

  void onUsuarioChange(String value) {
    final newUsuario = Usuario.dirty(value);
    _updateState(usuario: newUsuario);
  }

  void onPasswordChange(String value) {
    final newPassword = Password.dirty(value);
    _updateState(password: newPassword);
  }

  void onRememberMeChange(bool? value) {
    _updateState(rememberMe: value);
  }

  onFormSubmit() async {
    _touchEveryField();
    if (state.rememberMe) {
      await keyValueStorage.setKeyValue<String>('usuario', state.usuario.value);
      await keyValueStorage.setKeyValue<String>(
          'password', state.password.value);
      await keyValueStorage.setKeyValue<String>('empresa', state.empresa.value);
      await keyValueStorage.setKeyValue<int>(
          'rememberMe', state.rememberMe ? 1 : 0);
    } else {
      await keyValueStorage.removeKey(
        'token',
      );
      await keyValueStorage.removeKey(
        'token',
      );
      await keyValueStorage.removeKey(
        'token',
      );
      await keyValueStorage.removeKey(
        'rememberMe',
      );
    }
    if (!state.isValid) return;
    state = state.copyWith(isPosting: true);
    await loginUserCallback(
        state.empresa.value, state.usuario.value, state.password.value);
    state = state.copyWith(isPosting: false);
  }

  _touchEveryField() {
    final usuario = Usuario.dirty(state.usuario.value);
    final password = Password.dirty(state.password.value);
    state = state.copyWith(
      isFormPosted: true,
      usuario: usuario,
      password: password,
      isValid: Formz.validate([usuario, password]),
    );
  }
}

//! 1- State de este provider
class LoginFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final bool rememberMe;
  final Empresa empresa;
  final Usuario usuario;
  final Password password;
  final bool isLoadingData;

  LoginFormState(
      {this.isPosting = false,
      this.isFormPosted = false,
      this.isValid = false,
      this.empresa = const Empresa.pure(),
      this.usuario = const Usuario.pure(),
      this.password = const Password.pure(),
      this.rememberMe = false,
      this.isLoadingData = false});

  LoginFormState copyWith(
          {bool? isPosting,
          bool? isFormPosted,
          bool? isValid,
          Empresa? empresa,
          Usuario? usuario,
          Password? password,
          bool? rememberMe,
          bool? isLoadingData}) =>
      LoginFormState(
        isPosting: isPosting ?? this.isPosting,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isValid: isValid ?? this.isValid,
        empresa: empresa ?? this.empresa,
        usuario: usuario ?? this.usuario,
        password: password ?? this.password,
        rememberMe: rememberMe ?? this.rememberMe,
        isLoadingData: isLoadingData ?? this.isLoadingData,
      );

  @override
  String toString() {
    return '''
    isPosting: $isPosting,
    isFormPosted: $isFormPosted,
    isValid: $isValid,
    usuario: $usuario,
    password: $password
    ''';
  }
}
