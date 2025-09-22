import 'package:flutter/material.dart';

class FullScreenLoader extends StatelessWidget {
  final String message;

  const FullScreenLoader({
    super.key,
    this.message = 'Cargando...', // Texto por defecto
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 5,
          ),
          const SizedBox(height: 20), // Espaciado entre el indicador y el texto
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500, 
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}