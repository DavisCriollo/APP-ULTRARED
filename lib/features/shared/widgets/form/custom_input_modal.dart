import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/shared.dart';

Future<void> showCustomInputModal({
  required BuildContext context,
  required String label,
  required CustomInputField field,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(label),
        content: field,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      );
    },
  );
}
