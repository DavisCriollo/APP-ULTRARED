import 'package:flutter/material.dart';

class TitleDivider extends StatelessWidget {
  final String title;
  final double fontSize;
  final Widget? action;

  const TitleDivider({
    super.key,
    required this.title,
    this.fontSize = 16,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (action != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
          ),
        const Expanded(
          child: Divider(thickness: 1),
        ),
        if (action == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
          ),
        const Expanded(
          child: Divider(thickness: 1),
        ),
        if (action != null) ...[
          const SizedBox(width: 8),
          action!,
        ],
      ],
    );
  }
}
