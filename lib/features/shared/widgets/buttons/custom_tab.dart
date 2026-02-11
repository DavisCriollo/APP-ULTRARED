import 'package:flutter/material.dart';
import 'package:ultrared/main.dart';

class CustomTab extends StatelessWidget {
  const CustomTab({
    super.key,
    required this.isSelected,
    required this.color,
    required this.colorSelected,
    required this.funcion,
    required this.texto,
  });

  final bool isSelected;
  final Color color;
  final Color colorSelected;
  final Function(String param) funcion;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 10, // Reducir el padding horizontal
        ),
        backgroundColor: isSelected ? colorSelected : color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
      ),
      onPressed: () {
        funcion(texto);
      },
      child: Text(
        texto,
        style: TextStyle(
          color: isSelected ? color.contrastText : colorSelected.contrastText,
        ),
      ),
    );
  }
}
