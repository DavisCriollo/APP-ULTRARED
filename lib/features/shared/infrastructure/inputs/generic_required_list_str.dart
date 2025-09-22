import 'package:formz/formz.dart';

// Define input validation errors
enum GenericRequiredListStrError { empty }

// Extend FormzInput and provide the input type and error type.
class GenericRequiredListStr
    extends FormzInput<List<String>, GenericRequiredListStrError> {
  // Call super.pure to represent an unmodified form input.
   const GenericRequiredListStr.pure() : super.pure(const []);

  // Call super.dirty to represent a modified form input.
  const GenericRequiredListStr.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == GenericRequiredListStrError.empty) {
      return 'Por favor, ingrese al menos un valor.';
    }

    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  GenericRequiredListStrError? validator(List<String> value) {
    if (value.isEmpty) return GenericRequiredListStrError.empty;

    return null;
  }
}
