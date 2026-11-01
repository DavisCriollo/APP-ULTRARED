import 'package:flutter/material.dart';
import 'package:ultrared/config/theme/app_theme.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

class CheckAuthStatusScreen extends StatelessWidget {
  const CheckAuthStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final logoWidth =
        responsive.isTablet ? responsive.w(300) : responsive.w(250);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.w(28)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logos/LetrasNegro.png',
                  width: logoWidth,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
                SizedBox(height: responsive.h(40)),
                SizedBox(
                  width: responsive.w(28),
                  height: responsive.w(28),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.basePrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
