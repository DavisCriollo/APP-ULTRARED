import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/shared.dart';
import 'package:ultrared/features/shared/widgets/form/custom_expansion_tile.dart';

class CustomExpandableEmailList extends StatefulWidget {
  final String label;
  final String? errorMessage;
  final void Function(String) onAddValue;
  final void Function(List<String>) onDeleteValue;
  final List<String> values;

  const CustomExpandableEmailList({
    super.key,
    required this.label,
    this.errorMessage,
    required this.onAddValue,
    required this.onDeleteValue,
    required this.values,
  });

  @override
  CustomExpandableEmailListState createState() =>
      CustomExpandableEmailListState();
}

class CustomExpandableEmailListState extends State<CustomExpandableEmailList> {
  final TextEditingController inputController = TextEditingController();
  Email nuevoEmail = const Email.pure();

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomExpansionTile(
      errorMessage: widget.errorMessage,
      label: widget.label,
      values: widget.values,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputField(
                label: 'Agregar',
                controller: inputController,
                errorMessage: nuevoEmail.errorMessage,
                onFieldSubmitted: (p0) {
                  if (nuevoEmail.isNotValid) {
                    return;
                  }
                  setState(() {
                    inputController.text = '';
                    widget.onAddValue(nuevoEmail.value);
                    nuevoEmail = const Email
                        .pure(); // Reinicia nuevoEmail a su estado inicial
                  });
                },
                onChanged: (p0) {
                  setState(() {
                    nuevoEmail = Email.dirty(
                        p0); // Actualiza nuevoEmail cada vez que cambia el valor
                  });
                },
                suffixIcon: IconButton(
                  onPressed: () {
                    if (nuevoEmail.isNotValid) {
                      return;
                    }
                    setState(() {
                      inputController.text = '';
                      widget.onAddValue(nuevoEmail.value);
                      nuevoEmail = const Email
                          .pure(); // Reinicia nuevoEmail a su estado inicial
                    });
                  },
                  icon: const Icon(Icons.add_circle),
                ),
              ),
              Wrap(
                spacing: 1.0, // Espacio horizontal entre elementos
                runSpacing: 1.0, // Espacio vertical entre líneas de elementos
                children: widget.values.map((value) {
                  return Chip(
                    label: Text(
                      value,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onDeleted: () {
                      setState(() {
                        List<String> updatedValues = List.from(widget.values);
                        updatedValues
                            .remove(value); // Elimina el valor del arreglo
                        widget.onDeleteValue(
                            updatedValues); // Llama a la función de eliminación con el arreglo actualizado
                      });
                    },
                    deleteIcon: const Icon(
                      Icons.delete,
                      size: 16,
                      color: Colors.red,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
