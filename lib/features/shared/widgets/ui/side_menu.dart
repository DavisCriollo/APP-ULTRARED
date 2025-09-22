import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/config/menu/menu_item.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/main.dart';

class SideMenu extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SideMenu({super.key, required this.scaffoldKey});

  @override
  ConsumerState<SideMenu> createState() => SideMenuState();
}

class SideMenuState extends ConsumerState<SideMenu> {
  int navDrawerIndex = 0;
  bool cargando = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = Responsive.of(context);
    final colors = Theme.of(context).colorScheme;
    return Drawer(
      // backgroundColor: Color(Colors.red),
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              children: [
                CircleAvatar(
                  radius: size.hScreen(3),
                  child: ClipOval(
                    child: Image.network(
                      authState.user?.foto ?? "",
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/no-image.jpg',
                        );
                      },
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.hScreen(.5),
                ),
                Text(authState.user!.nombre
                    // style: TextStyle(color: Colors.white, fontSize: 18)
                    ),
                Text(authState.user!.rucempresa
                    // style: TextStyle(color: Colors.white70)
                    ),
              ],
            ),
          ),
          Expanded(
              child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ...[
                ...appMenuItems,
              ].map(
                (e) {
                  if (!authState.isAdmin && e.title == 'Gestión') {
                    return const SizedBox.shrink(); // Ocultar el elemento
                  }
                  return Column(
                    children: [
                      ListTile(
                        leading: Image.asset(
                          e.icon,
                          height: size.iScreen(4),
                          color: colors.secondary.lighten(
                              0.3), // Cambiar color del ícono si está deshabilitado
                        ),
                        title: Text(
                          e.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          e.subTitle,
                        ),
                        onTap: () {
                          context.push(e.link);
                        },
                        trailing: Icon(Icons.keyboard_arrow_right,
                            color: Colors.black),
                      ),
                      const Divider()
                    ],
                  );
                },
              )
            ],
          )),
          Column(
            children: [
              const Divider(),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Compartir'),
                onTap: () {},
              ),
              ListTile(
                leading: cargando
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.exit_to_app),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  if (cargando) {
                    return;
                  }

                  setState(() => cargando = true);

                  // Leer los proveedores al inicio
                  final auth = ref.read(authProvider);

                  if (auth.isAdmin) {
                    setState(() => cargando = false);

                    ref.read(authProvider.notifier).logout();
                  } else {
                    setState(() => cargando = false);

                    ref.read(authProvider.notifier).logout();
                  }
                },
              ),
              const SizedBox(
                height: 10,
              ), // Espacio para evitar que toque el borde inferior
            ],
          ),
        ],
      ),
    );
  }
}
