import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ultrared/config/router/app_router.notifier.dart';
import 'package:ultrared/features/actividades/presentation/screens/actividad.dart';
import 'package:ultrared/features/actividades/presentation/screens/actividades.dart';
import 'package:ultrared/features/auth/auth.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/cuentas_por_cobrar/presentation/screens/cuenta_por_cobrar.dart';
import 'package:ultrared/features/cuentas_por_cobrar/presentation/screens/cuentas_por_cobrar.dart';
import 'package:ultrared/features/cuentas_por_cobrar/presentation/screens/pago_screen.dart';
import 'package:ultrared/features/shared/screen/show_pdf_screen.dart';

import 'package:ultrared/features/home/home.dart';

final goRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.read(goRouterNotifierProvider);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: goRouterNotifier,
    routes: [
      //* Primera Pantalla
      GoRoute(
        path: '/splash',
        builder: (context, state) => const CheckAuthStatusScreen(),
      ),

      ///* Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      ///* Home Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      //* ACTIVIDADES
      GoRoute(
        path: '/actividades',
        builder: (context, state) => const ActividadesScreen(),
      ),
      GoRoute(
        path: '/actividad/:id',
        builder: (context, state) => const ActividadScreen(),
      ),
//* CUENTAS POR COBRAR
      GoRoute(
        path: '/cuenta_cobrar',
        builder: (context, state) => CuentasPorCobrarScreen(
          search: state.queryParams['search'] ?? '',
        ),
      ),
      GoRoute(
        path: '/cuenta_cobrar/:id',
        builder: (context, state) => CuentaPorCobrar(
          ccId: int.tryParse(state.params['id'].toString()) ?? 0,
        ),
      ),

      GoRoute(
        path: '/pago/:id',
        builder: (context, state) => PagoScreen(
          ccId: int.tryParse(state.params['id'].toString()) ?? 0,
        ),
      ),

      GoRoute(
        path: '/PDF/:label/:url',
        builder: (context, state) {
          final String label = state.params['label'] ?? '';
          final String encodedUrl = state.params['url'] ?? '';
          final String url =
              Uri.decodeComponent(encodedUrl); // Decodifica la URL para usarla
          return ShowPdfScreen(
            labelPdf: label,
            infoPdf: url,
          );
        },
      ),

      // GoRoute(
      //   path: '/product/:id',
      //   builder: (context, state) {
      //     return ProductScreen(productId: state.params['id'] ?? "no-id");
      //   },
      // ),
    ],
    redirect: (context, state) {
      final isGoingTo = state.subloc;
      final authStatus = goRouterNotifier.authStatus;

      if (isGoingTo == '/splash' && authStatus == AuthStatus.checking) {
        return null;
      }

      if (authStatus == AuthStatus.noAuthenticated) {
        if (isGoingTo == '/login' || isGoingTo == '/register') {
          return null;
        } else {
          return '/login';
        }
      }
      if (authStatus == AuthStatus.authenticated) {
        if (isGoingTo == '/login' ||
            isGoingTo == '/register' ||
            isGoingTo == '/splash') {
          return '/';
        }
      }

      return null;
    },
  );
});
