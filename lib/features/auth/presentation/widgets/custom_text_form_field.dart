import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorMessage;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final bool toUpperCase;
  final String initialValue; // Nuevo parámetro para el valor inicial

  const CustomTextFormField({
    super.key,
    this.label,
    this.hint,
    this.errorMessage,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.onFieldSubmitted,
    this.toUpperCase = false,
    this.initialValue = '', // Inicializando el nuevo parámetro
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
        borderSide: BorderSide(color: colors.onSurface),
        borderRadius: BorderRadius.circular(8));

    const borderRadius = Radius.circular(8);

    return Container(
      // padding: const EdgeInsets.only(bottom: 0, top: 15),
      decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.only(
              topLeft: borderRadius,
              bottomLeft: borderRadius,
              bottomRight: borderRadius),
          boxShadow: [
            BoxShadow(
                color: colors.shadow.withAlpha((0.06 * 255).toInt()),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ]),
      child: TextFormField(
        onChanged: onChanged,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onFieldSubmitted: onFieldSubmitted,
        inputFormatters: toUpperCase ? [_UpperCaseTextFormatter()] : [],
        initialValue: initialValue, // Asignando el valor inicial
        style: const TextStyle(
          fontSize: 20,
        ),
        decoration: InputDecoration(
          floatingLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          enabledBorder: border,
          focusedBorder: border,
          errorBorder:
              border.copyWith(borderSide: BorderSide(color: colors.onSurface)),
          focusedErrorBorder:
              border.copyWith(borderSide: BorderSide(color: colors.onSurface)),
          isDense: true,
          label: label != null ? Text(label!) : null,
          hintText: hint,
          errorText: errorMessage,
          focusColor: colors.primary,
          // icon: Icon( Icons.supervised_user_circle_outlined, color: colors.primary, )
        ),
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
