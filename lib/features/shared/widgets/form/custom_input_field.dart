import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatelessWidget {
  final bool isTopField; // La idea es que tenga bordes redondeados arriba
  final bool isBottomField; // La idea es que tenga bordes redondeados abajo
  final String? label;
  final TextAlign? textAlign;
  final String? hint;
  final String? errorMessage;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? lines; // Nuevo parámetro opcional para definir las líneas
  final String initialValue;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool readOnly;
  final IconButton? suffixIcon;
  final bool autofocus;
  final bool toUpperCase; // Nuevo parámetro para convertir a mayúsculas
  final bool isLoading; // Nuevo parámetro para mostrar el indicador de progreso
  final bool onlyInt; // Nuevo parámetro para restringir a números enteros
  final int? maxDigits; // Nuevo parámetro para limitar el número máximo de dígitos

  const CustomInputField({
    super.key,
    this.isTopField = false,
    this.isBottomField = false,
    this.label,
    this.hint,
    this.errorMessage,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.lines, // Inicializando el nuevo parámetro
    this.initialValue = '',
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.textAlign = TextAlign.start,
    this.controller,
    this.readOnly = false,
    this.autofocus = false,
    this.suffixIcon,
    this.toUpperCase = false, // Inicializando el nuevo parámetro
    this.isLoading = false, // Inicializando el nuevo parámetro
    this.onlyInt = false, // Inicializando el nuevo parámetro
    this.maxDigits, // Inicializando el nuevo parámetro
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        TextFormField(
          autofocus: autofocus,
          readOnly: readOnly,
          controller: controller,
          onChanged: onChanged,
          inputFormatters: [
            if (toUpperCase) _UpperCaseTextFormatter(),
            if (onlyInt) FilteringTextInputFormatter.digitsOnly, // Restringe a números enteros
            if (maxDigits != null) LengthLimitingTextInputFormatter(maxDigits), // Limita el número máximo de dígitos
          ],
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          obscureText: obscureText,
          keyboardType: onlyInt ? TextInputType.number : keyboardType, // Cambia el teclado si es solo números

          style: const TextStyle(
            fontSize: 15,
          ),
          maxLines: lines ?? 1, // Usar el valor de lines si se proporciona, de lo contrario 1
          initialValue: controller == null ? initialValue : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                vertical: 4, // Reducir el padding horizontal
                horizontal: 4),
            floatingLabelBehavior: (lines ?? 1) > 1
                ? FloatingLabelBehavior.always
                : FloatingLabelBehavior.auto,
            floatingLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            enabledBorder: lines != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: colors.onSurface),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(color: colors.onSurface),
                  ),
            focusedBorder: lines != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: colors.primary),
                  )
                : UnderlineInputBorder(
                    borderSide: BorderSide(color: colors.primary),
                  ),
            errorBorder: lines != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.red),
                  )
                : const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
            focusedErrorBorder: lines != null
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.red),
                  )
                : const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
            isDense: true,
            label: label != null ? Text(label!) : null,
            hintText: hint,
            errorText: errorMessage,
            suffixIcon: suffixIcon,
          ),
          textAlign: textAlign!,
        ),
        if (isLoading)
          const LinearProgressIndicator(), // Mostrar indicador de progreso si isLoading es true
      ],
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