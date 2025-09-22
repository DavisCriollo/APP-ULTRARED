import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

class CustomButtonModal extends StatelessWidget {
  final Responsive size;
  final IconData icon;
  final VoidCallback onPressed;
  final bool disabled;

  const CustomButtonModal({
    super.key,
    required this.size,
    required this.icon,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: size.iScreen(0.5),
        vertical: size.iScreen(0.0),
      ),
      height: size.iScreen(4.5),
      width: size.iScreen(4.5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(size.iScreen(1)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: disabled ? null : onPressed,
        child: Icon(
          icon,
          size: size.iScreen(2.5),
        ),
      ),
    );
  }
}
