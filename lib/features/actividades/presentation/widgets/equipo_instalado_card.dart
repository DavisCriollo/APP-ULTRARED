import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ultrared/features/actividades/domain/entities/equipo_instalado.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/card/card_container.dart';
import 'package:ultrared/features/shared/widgets/card/card_mar_pad.dart';

class EquipoInstaladoCard extends ConsumerWidget {
  final EquipoInstalado equipoInstalado;
  final Responsive size;
  final void Function(EquipoInstalado equipoInstaladoToDelete)
      onDelete; // Función para eliminar con Future
  final void Function(EquipoInstalado equipoInstaladoToActive) loadActividad;
  const EquipoInstaladoCard({
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
                        'Material: ${equipoInstalado.material}',
                        style: TextStyle(
                          fontSize: size.iScreen(1.5),
                        ),
                      ),
                      Text(
                        'Marca: ${equipoInstalado.marca}',
                        style: TextStyle(
                          fontSize: size.iScreen(1.5),
                        ),
                      ),
                      Text(
                        'Serie: ${equipoInstalado.serie}',
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
                        'Cantidad: ${equipoInstalado.cantidad}',
                        style: TextStyle(
                          fontSize: size.iScreen(1.5),
                        ),
                      ),
                      Text(
                        'Obv: ${equipoInstalado.observaciones}',
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
