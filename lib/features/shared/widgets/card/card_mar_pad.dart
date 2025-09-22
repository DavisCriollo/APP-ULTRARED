import 'package:flutter/material.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

class CardMarPad extends StatelessWidget {
  final Widget child;
  final Responsive size;
  const CardMarPad({super.key, required this.child, required this.size});

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: size.iScreen(1), vertical: size.iScreen(0.5)),
      child: child,
    );
  }
}
