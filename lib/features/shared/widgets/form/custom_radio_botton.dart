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
// ...existing code...
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded( 
          child: Text(
            questionText,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), 
          ),
        ),
        Expanded( 
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: options.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: e,
                    groupValue: selectedValue,
                    onChanged: (v) => onChanged?.call(v),
                  ),
                  Text(e),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
