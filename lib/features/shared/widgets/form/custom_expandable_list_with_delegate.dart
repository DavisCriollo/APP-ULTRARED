import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/widgets/form/custom_badge.dart';
import 'package:ultrared/features/shared/widgets/form/custom_expansion_tile.dart';

class CustomExpandableListWithDelagate extends StatefulWidget {
  final String label;
  final String? errorMessage;
  final void Function(List<String>) onDeleteValue;
  final List<String> values;
  final void Function() onTap;

  const CustomExpandableListWithDelagate({
    super.key,
    required this.label,
    this.errorMessage,
    required this.onDeleteValue,
    required this.values,
    required this.onTap,
  });

  @override
  CustomExpandablePlacaListState createState() =>
      CustomExpandablePlacaListState();
}

class CustomExpandablePlacaListState
    extends State<CustomExpandableListWithDelagate> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomExpansionTile(
      errorMessage: widget.errorMessage,
      label: widget.label,
      values: widget.values,
      suffixIcon: CustomBadge(
        value: '${widget.values.length}',
        child: IconButton(
          icon: const Icon(Icons.add_circle),
          onPressed: widget.onTap,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CustomInputField(
              //   onTap: widget.onTap,
              //   readOnly: true,
              //   toUpperCase: true,
              //   label: 'Agregar',
              //   controller: inputController,
              //   errorMessage: nuevaPlaca.errorMessage,
              //   onChanged: (p0) {
              //     setState(() {
              //       nuevaPlaca = Placa.dirty(
              //           p0); // Actualiza nuevaPlaca cada vez que cambia el valor
              //     });
              //   },
              //   suffixIcon: IconButton(
              //     icon: const Icon(Icons.add_circle),
              //     onPressed: () {
              //       widget.onTap();
              //     },
              //   ),
              // ),
              Column(
                children: widget.values.map((value) {
                  return ListTile(
                    title: Text(
                      value,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon:
                          const Icon(Icons.delete, size: 16, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          List<String> updatedValues = List.from(widget.values);
                          updatedValues
                              .remove(value); // Elimina el valor del arreglo
                          widget.onDeleteValue(
                              updatedValues); // Llama a la función de eliminación con el arreglo actualizado
                        });
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
