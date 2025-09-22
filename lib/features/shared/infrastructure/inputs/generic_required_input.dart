import 'package:formz/formz.dart';

// Define input validation errors
enum GenericRequiredInputError { empty }

// Extend FormzInput and provide the input type and error type.
class GenericRequiredInput extends FormzInput<String, GenericRequiredInputError> {
  // Call super.pure to represent an unmodified form input.
  const GenericRequiredInput.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const GenericRequiredInput.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == GenericRequiredInputError.empty) return 'El campo es requerido';

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  GenericRequiredInputError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return GenericRequiredInputError.empty;

    return null;
  }
}
 