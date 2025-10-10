import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ultrared/features/actividades/domain/entities/cargo.dart'; 
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/card/card_container.dart';
import 'package:ultrared/features/shared/widgets/card/card_mar_pad.dart';

class CargoCard extends ConsumerWidget {
  final Cargo equipoInstalado;
  final Responsive size;
  final void Function(Cargo equipoInstaladoToDelete)
      onDelete; // Función para eliminar con Future
  final void Function(Cargo equipoInstaladoToActive) loadActividad;
  const CargoCard({
    super.key,
    required this.equipoInstalado,
    required this.size,
    required this.onDelete, // Recibir la función de eliminación
    required this.loadActividad, // Recibir la función de eliminación
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return CardMarPad(
      size: size,
      child: Slidable(
        key: ValueKey(equipoInstalado.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                onDelete(
                    equipoInstalado); // Llamar a la función de eliminación con await
              },
              foregroundColor: Colors.black,
              icon: Icons.delete,
              label: 'Eliminar',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            loadActividad(equipoInstalado);
          },
          child: CardContainer(
            colors: colors,
            size: size,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Columna izquierda: identificación, ubicación, cliente y teléfonos
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Estado con color
                      Text(
                        'Item: ${equipoInstalado.item}',
                        style: TextStyle(
                          fontSize: size.iScreen(1.5),
                        ),
                      ),
                      Text(
                        'Costo: ${equipoInstalado.costoUnitario}',
                        style: TextStyle(
                          fontSize: size.iScreen(1.5),
                        ),
                      ),
                      Text(
                        'Cantidad: ${equipoInstalado.cantidad}',
                        style: TextStyle(
                          fontSize: size.iScreen(1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                // Columna derecha: tipo, opción, servicios, estado correo, usuario y fecha
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Tipo
                      Text(
                        'Valor: ${equipoInstalado.valor}',
                        style: TextStyle(
                          fontSize: size.iScreen(1.5),
                        ),
                      ),
                      Text(
                        'Descripción: ${equipoInstalado.descripcion}',
                        style: TextStyle(
                          fontSize: size.iScreen(1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
