import 'package:formz/formz.dart';

// Define input validation errors
enum GenericRequiredInputNumberError {
  empty,
  lessThanOrEqualToZero,
  conditionNotMet
}

class GenericRequiredInputNumber
    extends FormzInput<num, GenericRequiredInputNumberError> {
  final bool condition;

  const GenericRequiredInputNumber.dirty(num value, {required this.condition})
      : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == GenericRequiredInputNumberError.empty) {
      return 'El campo es requerido';
    }

    if (displayError == GenericRequiredInputNumberError.lessThanOrEqualToZero) {
      return 'El valor debe ser mayor a 0';
    }

    if (displayError == GenericRequiredInputNumberError.conditionNotMet) {
      return 'La condición no se cumple';
    }

    return null;
  }

  @override
  GenericRequiredInputNumberError? validator(num? value) {
    // Si condition es true, el campo es requerido y debe ser mayor a 0
    if (condition) {
      if (value == null) return GenericRequiredInputNumberError.empty;
      if (value <= 0) {
        return GenericRequiredInputNumberError.lessThanOrEqualToZero;
      }
    }
    // Si condition es false, no se valida (puede ser nulo o <= 0)
    return null;
  }
}
