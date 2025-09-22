import 'package:flutter/material.dart';

void mostrarAlerta(BuildContext context, String mensaje, bool error) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(error ? "Error" : "Información"),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cerrar"),
          ),
        ],
      );
    },
  );
}
