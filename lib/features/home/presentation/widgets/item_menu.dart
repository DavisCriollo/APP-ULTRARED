import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/config/menu/menu_item.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/main.dart';

class ItemMenu extends StatelessWidget {
  final MenuItem menuItem;
  final bool turnoActivo;
  const ItemMenu({
    super.key,
    required this.size,
    required this.menuItem,
    this.turnoActivo = false,
  });

  final Responsive size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: size.iScreen(14.0), // Ajustar el ancho de los elementos
      height: size.iScreen(14.0), // Ajustar el ancho de los elementos
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 4.0), // Espacio entre los elementos
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(10.0), // Reducir el radio de los bordes
          child: Material(
            color: Colors.transparent, // Color de fondo transparente
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  10.0), // Radio de los bordes redondeados
            ),
            child: InkWell(
              onTap: turnoActivo
                  ? () {
                      // Acción al presionar el botón
                      context.push(menuItem.link);
                    }
                  : null,
              splashColor: colors.secondary
                  .withAlpha((0.7 * 255).toInt()), // Color del splash
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                      color: turnoActivo
                          ? colors.secondary.lighten(0.2)
                          : colors.secondary
                              .lighten(0.2)
                              .withAlpha((0.6 * 255).toInt()),
                      width: 2.0), // Borde gris
                ),
                child: Center(
                  // Centrar el contenido
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        menuItem.icon,
                        height: size.iScreen(7.0),
                        color: turnoActivo
                            ? colors.secondary.lighten(0.2)
                            : colors.secondary.lighten(0.2).withAlpha(
                                (0.6 * 255)
                                    .toInt()), // Reducir el tamaño de la imagen
                      ),
                      const SizedBox(height: 4), // Reducir el espacio
                      Text(
                        menuItem.title,
                        style: TextStyle(
                          fontSize:
                              size.iScreen(1.8), // Reducir el tamaño del texto
                          fontWeight: FontWeight.bold,
                          color: turnoActivo
                              ? colors.secondary.lighten(0.2)
                              : colors.secondary
                                  .lighten(0.2)
                                  .withAlpha((0.6 * 255).toInt()),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2), // Reducir el espacio
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
