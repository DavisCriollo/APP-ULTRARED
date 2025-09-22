import 'package:flutter/material.dart';

Future<String?> modalCampo({
  required BuildContext context,
  required String titulo,
  required String labelCampo,
  required String Function(String) validarCampo,
  TextInputType tipoTeclado =
      TextInputType.text, // ← nuevo parámetro con valor por defecto
}) async {
  final TextEditingController controller = TextEditingController();
  String? errorText;

  return await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            contentPadding: const EdgeInsets.all(16.0),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: controller,
                    keyboardType: tipoTeclado, // ← aquí se aplica
                    decoration: InputDecoration(
                      labelText: labelCampo,
                      errorText: errorText,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        errorText = null;
                      });
                    },
                    onSubmitted: (value) {
                      final error = validarCampo(value);
                      if (error.isEmpty) {
                        Navigator.of(context).pop(value);
                      } else {
                        setState(() {
                          errorText = error;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 32.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final error = validarCampo(controller.text);
                        if (error.isEmpty) {
                          Navigator.of(context).pop(controller.text);
                        } else {
                          setState(() {
                            errorText = error;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        "Aceptar",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cerrar"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
