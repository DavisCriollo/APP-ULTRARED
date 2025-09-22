import 'package:flutter/material.dart';

class ResumenButton extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final String label;
  final String value;
  final VoidCallback? onPressed;

  const ResumenButton({
    super.key,
    required this.backgroundColor,
    required this.textColor,
    required this.label,
    required this.value,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      onPressed: onPressed,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}