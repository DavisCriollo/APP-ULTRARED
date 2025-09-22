import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

class CustomRadioBotton extends StatelessWidget {
  final Responsive size;
  final String? selectedValue; // Valor seleccionado
  final List<String> options;
  final Function(String?)?
      onChanged; // Función de callback para el cambio de valor
  final String questionText;

  // Constructor
  const CustomRadioBotton({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    required this.questionText,
    required this.size,
    this.options = const ['SI', 'NO'],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          questionText,
          style: const TextStyle(fontSize: 18),
        ),
        ...options.map((e) {
          return Row(
            children: [
              Radio<String>(
                value: e,
                groupValue: selectedValue,
                onChanged: onChanged,
              ),
              Text(e),
            ],
          );
        }),
      ],
    );
  }
}
