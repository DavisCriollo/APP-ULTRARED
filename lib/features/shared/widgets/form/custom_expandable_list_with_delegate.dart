import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/widgets/form/custom_badge.dart';
import 'package:ultrared/features/shared/widgets/form/custom_expansion_tile.dart';

class CustomExpandableListWithDelegate extends StatelessWidget {
  final String label;
  final String? errorMessage;
  final void Function(List<String>) onDeleteValue;
  final List<String> values;
  final void Function() onTap;

  const CustomExpandableListWithDelegate({
    super.key,
    required this.label,
    this.errorMessage,
    required this.onDeleteValue,
    required this.values,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomExpansionTile(
      errorMessage: errorMessage,
      label: label,
      values: values,
      suffixIcon: CustomBadge(
        value: '${values.length}',
        child: IconButton(
          icon: const Icon(Icons.add_circle),
          onPressed: onTap,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: values.map((value) {
                  return ListTile(
                    title: Text(
                      value,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon:
                          const Icon(Icons.delete, size: 16, color: Colors.red),
                      onPressed: () {
                        List<String> updatedValues = List.from(values);
                        updatedValues
                            .remove(value); // Elimina el valor del arreglo
                        onDeleteValue(
                            updatedValues); // Llama a la función de eliminación con el arreglo actualizado
                      },
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ],
    );
  }
}
