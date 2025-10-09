import 'package:flutter/material.dart';
import 'package:ultrared/features/actividades/domain/entities/equipo_instalado.dart';
import 'package:ultrared/features/shared/helpers/parse.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/form/custom_input_field.dart';

// ...existing code...
Future<EquipoInstalado?> showEquipoInstaladoDialog({
  required context,
  required Responsive size,
  EquipoInstalado? equipoInstaladoToEdit,
  bool editar = false,
}) async {
  EquipoInstalado equipoInstalado =
      equipoInstaladoToEdit ?? EquipoInstalado.defaultEquipoInstalado();
  final validacion = ValidacionEquipoInstalado();

  // crear controllers antes de showDialog

  final res = await showDialog<EquipoInstalado?>(
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
                      initialValue: equipoInstalado.material,
                      label: 'Material',
                      onChanged: (p0) {
                        equipoInstalado =
                            equipoInstalado.copyWith(material: p0);
                      },
                      errorMessage: validacion.material,
                    ),

                    CustomInputField(
                      onlyInt: true,
                      initialValue: equipoInstalado.cantidad.toString(),
                      label: 'Cantidad',
                      onChanged: (p0) {
                        equipoInstalado = equipoInstalado.copyWith(
                            cantidad: Parse.parseDynamicToInt(p0));
                      },
                      errorMessage: validacion.cantidad,
                    ),

                    CustomInputField(
                      initialValue: equipoInstalado.marca,
                      label: 'Marca',
                      onChanged: (p0) {
                        equipoInstalado = equipoInstalado.copyWith(marca: p0);
                      },
                    ),

                    CustomInputField(
                      initialValue: equipoInstalado.serie,
                      label: 'Serie',
                      onChanged: (p0) {
                        equipoInstalado = equipoInstalado.copyWith(serie: p0);
                      },
                    ),

                    CustomInputField(
                      initialValue: equipoInstalado.observaciones,
                      label: 'Observaciones',
                      onChanged: (p0) {
                        equipoInstalado =
                            equipoInstalado.copyWith(observaciones: p0);
                      },
                      lines: 3,
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
