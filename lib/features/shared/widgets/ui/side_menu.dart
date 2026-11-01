import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/config/menu/menu_item.dart';
import 'package:ultrared/config/theme/app_theme.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/shared/utils/responsive.dart';

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
    const brand = AppTheme.basePrimaryColor;

    return Drawer(
      backgroundColor: colors.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: brand,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  size.w(20),
                  size.h(18),
                  size.w(20),
                  size.h(22),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(size.w(3)),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: size.w(34),
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.network(
                            authState.user?.foto ?? '',
                            width: size.w(68),
                            height: size.w(68),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/no-image.jpg',
                                width: size.w(68),
                                height: size.w(68),
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.h(12)),
                    Text(
                      authState.user!.nombre,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.sp(16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: size.h(2)),
                    Text(
                      authState.user!.rucempresa,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: size.sp(13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: size.h(8)),
              children: [
                ...appMenuItems.map((e) {
                  if (!authState.isAdmin && e.title == 'Gestión') {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.w(10),
                      vertical: size.h(2),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size.w(12)),
                      ),
                      leading: Image.asset(
                        e.icon,
                        height: size.iScreen(4),
                        color: brand,
                      ),
                      title: Text(
                        e.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: size.sp(15),
                        ),
                      ),
                      subtitle: e.subTitle.isEmpty
                          ? null
                          : Text(
                              e.subTitle,
                              style: TextStyle(fontSize: size.sp(12)),
                            ),
                      trailing: Icon(
                        Icons.keyboard_arrow_right,
                        color: brand.withValues(alpha: 0.7),
                      ),
                      onTap: () {
                        context.push(e.link);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Compartir'),
            onTap: () {},
          ),
          ListTile(
            leading: cargando
                ? SizedBox(
                    width: size.w(22),
                    height: size.w(22),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.exit_to_app, color: brand),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(
                color: brand,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              if (cargando) {
                return;
              }

              setState(() => cargando = true);

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
          SizedBox(height: size.h(10)),
        ],
      ),
    );
  }
}
