import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

class CardContainer extends StatelessWidget {
  final Responsive size;
  final Widget child;
  final ColorScheme colors;
  const CardContainer(
      {super.key,
      required this.size,
      required this.child,
      required this.colors});
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: size.iScreen(1.0), vertical: size.iScreen(1.0)),
        width: size.wScreen(100),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: colors.shadow
                  .withAlpha((0.2 * 255).toInt()), // Reduce la opacidad
              spreadRadius: 0,
              blurRadius: 4, // Reduce el desenfoque para una sombra más suave
              offset: const Offset(
                  0, 2), // Ajusta el desplazamiento para una sombra más sutil
            ),
          ],
        ),
        child: child);
  }
}
