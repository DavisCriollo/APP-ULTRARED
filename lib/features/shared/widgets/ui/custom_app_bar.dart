import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/config/provider/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String userName;
  final String moduleName;
  final String logoUrl;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.userName,
    required this.moduleName,
    required this.logoUrl,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

        return AppBar(
          title: Row(
            children: [
              Image.network(
                logoUrl,
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/no-image.jpg',
                    height: 30,
                  );
                },
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moduleName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ],
          ),
          actions: actions ??
              [
                IconButton(
                  onPressed: () {
                    ref.read(themeNotifierProvider.notifier).toggleDarkMode();
                  },
                  icon: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                ),
              ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}