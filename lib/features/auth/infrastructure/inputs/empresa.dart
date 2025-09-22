import 'package:formz/formz.dart';

// Define input validation errors
enum EmpresaError { empty }

// Extend FormzInput and provide the input type and error type.
class Empresa extends FormzInput<String, EmpresaError> {
  // Call super.pure to represent an unmodified form input.
  const Empresa.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Empresa.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == EmpresaError.empty) return 'El campo es requerido';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  EmpresaError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return EmpresaError.empty;

    return null;
  }
}
