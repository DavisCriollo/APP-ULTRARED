import 'package:flutter/material.dart';
import 'package:ultrared/main.dart';

class CustomBadge extends StatelessWidget {
  final Widget child;
  final String value;
  const CustomBadge({super.key, required this.child, required this.value});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              value, // ← Aquí va tu número dinámico
              style: TextStyle(
                color: colors.primary.contrastText,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
