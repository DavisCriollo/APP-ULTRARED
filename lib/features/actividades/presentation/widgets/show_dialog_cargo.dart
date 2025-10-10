import 'package:flutter/material.dart';
import 'package:ultrared/features/actividades/domain/entities/cargo.dart';
import 'package:ultrared/features/shared/helpers/parse.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/form/custom_input_field.dart';

// ...existing code...
Future<Cargo?> showCargoDialog({
  required context,
  required Responsive size,
  Cargo? equipoInstaladoToEdit,
  bool editar = false,
}) async {
  Cargo equipoInstalado = equipoInstaladoToEdit ?? Cargo.defaultCargo();
  final validacion = ValidacionCargo();

  // crear controllers antes de showDialog

  final res = await showDialog<Cargo?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              '${editar ? 'Editar' : 'Crear'} Equipo Instalado',
              style: TextStyle(color: validacion.isValid ? null : Colors.red),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: size.hScreen(40),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomInputField(
                      initialValue: equipoInstalado.item,
                      label: 'Item',
                      onChanged: (p0) {
                        equipoInstalado = equipoInstalado.copyWith(item: p0);
                      },
                      errorMessage: validacion.item,
                    ),
                    CustomInputField(
                      initialValue: equipoInstalado.cantidad.toString(),
                      label: 'Cantidad',
                      onChanged: (p0) {
                        equipoInstalado = equipoInstalado.copyWith(
                            cantidad: Parse.parseDynamicToInt(p0));
                      },
                      errorMessage: validacion.cantidad,
                    ),
                    CustomInputField(
                      initialValue: equipoInstalado.costoUnitario.toString(),
                      label: 'Costo Unitario',
                      onChanged: (p0) {
                        equipoInstalado = equipoInstalado.copyWith(
                          costoUnitario: Parse.parseDynamicToDouble(p0),
                        );
                      },
                      errorMessage: validacion.costoUnitario,
                    ),
                    CustomInputField(
                      initialValue: equipoInstalado.valor.toString(),
                      label: 'Valor',
                      onChanged: (p0) {
                        equipoInstalado = equipoInstalado.copyWith(
                          valor: Parse.parseDynamicToDouble(p0),
                        );
                      },
                      errorMessage: validacion.valor,
                    ),
                    CustomInputField(
                      initialValue: equipoInstalado.descripcion,
                      label: 'Descripción',
                      onChanged: (p0) {
                        equipoInstalado =
                            equipoInstalado.copyWith(descripcion: p0);
                      },
                    ),

                    // ... otros campos usando cantidadC, marcaC, etc.
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final isInvalid = validacion.validacionHijo(equipoInstalado);
                  if (isInvalid) {
                    setState(() {}); // muestra errores
                    return;
                  }
                  Navigator.of(context).pop(equipoInstalado);
                },
                child: const Text('Crear'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );
    },
  );

  return res;
}
// ...existing code...
