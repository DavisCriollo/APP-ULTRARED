import 'package:formz/formz.dart';

// Define input validation errors
enum UsuarioError { empty }

// Extend FormzInput and provide the input type and error type.
class Usuario extends FormzInput<String, UsuarioError> {
  // Call super.pure to represent an unmodified form input.
  const Usuario.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Usuario.dirty(super.value) : super.dirty();
  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == UsuarioError.empty) return 'El campo es requerido';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  UsuarioError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return UsuarioError.empty;

    return null;
  }
}
