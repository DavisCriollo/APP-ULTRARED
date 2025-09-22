import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

Future<String?> cupertinoModal(
  BuildContext context,
  Responsive size,
  String title,
  List<String> options, {
  bool warning = false, // Nuevo parámetro para controlar el color del texto
}) async {
  return await showCupertinoModalPopup<String>(
    context: context,
    builder: (BuildContext builder) {
      return CupertinoActionSheet(
        title: Text(
          title,
          style: TextStyle(
            fontSize: size.iScreen(2.0),
            fontWeight: FontWeight.bold,
            color: warning ? Colors.red : null, // Cambiar color según warning
          ),
        ),
        actions: options.map<CupertinoActionSheetAction>((String option) {
          return CupertinoActionSheetAction(
            child: Text(option),
            onPressed: () {
              Navigator.pop(context, option);
            },
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
    },
  );
}