import 'package:formz/formz.dart';

// Define input validation errors
enum PlacaError { empty, format }

// Extend FormzInput and provide the input type and error type.
class Placa extends FormzInput<String, PlacaError> {
  static final RegExp placaRegExp = RegExp(
    r'^[A-Z]{3}[0-9]{4}$',
  );

  // Call super.pure to represent an unmodified form input.
  const Placa.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Placa.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == PlacaError.empty) return 'El campo es requerido';
    if (displayError == PlacaError.format) {
      return 'No tiene el formato de placa EJEMPLO: ZZZ9999';
    }

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  PlacaError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return PlacaError.empty;

    // Si el valor tiene exactamente 6 caracteres, pasa la validación
    if (value.length == 6) return null;

    // Validar el formato de la placa
    if (!placaRegExp.hasMatch(value)) return PlacaError.format;

    return null;
  }
}