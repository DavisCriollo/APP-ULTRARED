import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ultrared/config/menu/menu_item.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/home/presentation/widgets/item_menu.dart';
import 'package:ultrared/features/shared/provider/notification.dart';
// import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/shared/shared.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';
import 'package:ultrared/features/shared/widgets/ui/custom_app_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Aquí puedes ejecutar tu función al cargar el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).requestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      drawer: SideMenu(scaffoldKey: scaffoldKey),
      appBar: CustomAppBar(
        title: 'Home',
        userName: authState.user!.nombre,
        moduleName: 'Home',
        logoUrl: authState.user!.logo,
      ),
      body: _HomeView(),
    );
  }
}

class _HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authN = ref.watch(authProvider.notifier);

    final size = Responsive.of(context);
    return SizedBox(
      width: size.wScreen(100),
      height: size.hScreen(100),
      // color: Colors.red,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0), // Reducir el padding
            child: Center(
              // Centrar el contenido en la pantalla
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (authState.isAdmin || authState.isDemo) const SizedBox(),
                  Column(
                    children: [
                      // IconButton(
                      //     onPressed: () async {
                      //       final profile = await CapabilityProfile.load();
                      //       final printer =
                      //           NetworkPrinter(PaperSize.mm80, profile);

                      //       // Cambia la IP y puerto por los de tu impresora
                      //       final result = await printer.connect(
                      //         '192.168.1.91',
                      //         port: 9100,
                      //       );

                      //       if (result == PosPrintResult.success) {
                      //         printer.text('¡Hola desde Flutter!');
                      //         printer.cut();
                      //         printer.disconnect();
                      //       } else {
                      //         NotificationsService.show(
                      //             context,
                      //             'No se pudo conectar a la impresora',
                      //             SnackbarCategory.error);
                      //       }
                      //     },
                      //     icon: Icon(Icons.print)),

                      const SizedBox(height: 12),
                      Text(authState.user!.rol.join(', ')),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: size.iScreen(1.0),
                        runSpacing: size.iScreen(1.0),
                        children: appMenuItems.map((menuItem) {
                          if (authState.isAdmin) {
                            return ItemMenu(
                              size: size,
                              menuItem: menuItem,
                            );
                          }

                          if (!authN.isRol(rolesToFind: ['TECNICO']) &&
                              menuItem.title == 'Cuentas por Cobrar') {
                            return const SizedBox.shrink();
                          }
                          // if (authState.isDemo && menuItem.link == '/admin') {
                          //   return ItemMenu(
                          //       size: size,
                          //       menuItem: menuItem,
                          //       turnoActivo: true);
                          // }
                          return ItemMenu(
                            size: size,
                            menuItem: menuItem,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: size.iScreen(1.0), vertical: size.iScreen(1.0)),
                width: size.wScreen(100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ver: 0.7.0',
                      style: TextStyle(
                        fontSize: size.iScreen(1.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Image.asset(
                      'assets/images/logoNeitor.png',
                      height: size.iScreen(6.0),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
