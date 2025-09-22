import 'package:flutter/material.dart';

class CustomExpansionTile extends StatelessWidget {
  final String label;
  final List<String> values;
  final String? errorMessage;
  final List<Widget> children;
  const CustomExpansionTile(
      {super.key,
      required this.label,
      required this.values,
      required this.errorMessage,
      required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ExpansionTile(
      dense: true,
      title: Text(
        '$label: ${values.join(', ')} ${errorMessage ?? ""}',
        style: TextStyle(
          color: errorMessage != null ? Colors.red : colors.primary,
          fontSize: 12,
        ),
      ),
      children: children,
    );
  }
}
