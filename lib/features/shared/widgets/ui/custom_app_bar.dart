import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultrared/config/provider/theme_provider.dart';
import 'package:ultrared/features/shared/provider/notification.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.userName,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;

        return AppBar(
          toolbarHeight: _toolbarHeight,
          title: Text(
            userName,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
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

  static const double _toolbarHeight = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);
}
