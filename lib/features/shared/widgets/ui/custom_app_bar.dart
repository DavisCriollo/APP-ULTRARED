import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultrared/config/provider/theme_provider.dart';
import 'package:ultrared/features/shared/provider/notification.dart';

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
                    onPressed: () async {
                      final res = await ref
                          .read(notificationsProvider.notifier)
                          .requestPermissions();
                      if (res == AuthorizationStatus.denied) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Permisos necesarios'),
                            content: const Text(
                              'Para recibir notificaciones importantes, activa los permisos en la configuración del sistema.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();

                                  openAppSettings(); // Requiere el paquete `app_settings`
                                },
                                child: const Text('Abrir configuración'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    icon: Icon(ref.watch(notificationsProvider).status ==
                            AuthorizationStatus.authorized
                        ? Icons.notifications_active
                        : Icons.notifications_off)),
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
