import 'package:flutter/material.dart';

class CustomExpansionTile extends StatelessWidget {
  final String label;
  final List<String> values;
  final String? errorMessage;
  final List<Widget> children;
  final Widget? suffixIcon;
  const CustomExpansionTile({
    super.key,
    required this.label,
    required this.values,
    this.errorMessage,
    required this.children,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ExpansionTile(
      dense: true,
      title: Row(
        children: [
          if (suffixIcon != null) suffixIcon!,
          Flexible(
            child: Text(
              '$label: ${values.join(' -- ')} ${errorMessage ?? ""}',
              style: TextStyle(
                color: errorMessage != null ? Colors.red : colors.primary,
                fontSize: 12,
              ),
              overflow: TextOverflow.clip, // ← corta con "..."
            ),
          ),
        ],
      ),
      children: children,
    );
  }
}
