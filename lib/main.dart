import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultrared/config/config.dart';
import 'package:ultrared/config/local_notifications/local_notifications.dart';
import 'package:ultrared/config/provider/device_type_provider.dart';
import 'package:ultrared/config/provider/theme_provider.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/shared/infrastructure/services/key_value_storage_impl.dart';
import 'package:ultrared/features/shared/msg/show_snackbar.dart';
import 'package:ultrared/features/shared/provider/notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  final container = ProviderContainer();
  await NotificationsNotifier
      .initializeFirebaseNotifications(); // ✅ Usas tu provider
  await container.read(notificationsProvider.notifier).requestPermissions();
  await LocalNotifications.initializeLocalNotifications();

  final storage = KeyValueStorageImpl();
  final isDarkMode = await ThemeNotifier.loadPersistedDarkMode(storage);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: ProviderScope(
        overrides: [
          themeNotifierProvider.overrideWith((ref) {
            final user = ref.watch(authProvider).user;
            final colorPrimario = user?.colorSecundario ?? '#6200EE';
            final colorSecundario = user?.colorPrimario ?? '#03DAC6';

            return ThemeNotifier(
              colorPrimario: colorPrimario,
              colorSecundario: colorSecundario,
              isDarkMode: isDarkMode,
              storage: storage,
            );
          }),
        ],
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contextProvider.notifier).state = context;
    });
    final appRouter = ref.watch(goRouterProvider);
    final AppTheme appTheme = ref.watch(themeNotifierProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // Inglés
        Locale('es'), // Español
      ],
      scaffoldMessengerKey: NotificationsService.messengerKey,
      routerConfig: appRouter,
      theme: appTheme.getTheme(),
      builder: (context, child) {
        return HandleNotificationInteraction(child: child!);
      },
    );
  }
}

class HandleNotificationInteraction extends ConsumerStatefulWidget {
  final Widget child;
  const HandleNotificationInteraction({super.key, required this.child});

  @override
  ConsumerState<HandleNotificationInteraction> createState() =>
      _HandleNotificationInteractionState();
}

class _HandleNotificationInteractionState
    extends ConsumerState<HandleNotificationInteraction> {
  Future<void> setupInteractedMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    ref.read(notificationsProvider.notifier).handleRemoteMessage(message);

    // final messageId =
    //     message.messageId?.replaceAll(';', '').replaceAll('%', '') ?? "";
    // appRouter.push('/push-details/$messageId');
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// * COLORS

extension ColorUtils on Color {
  /// Aclara el color en [amount], que va de 0.0 a 1.0 (por defecto 0.1 = 10%).
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lighter = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return lighter.toColor();
  }

  /// Oscurece el color en [amount], que va de 0.0 a 1.0 (por defecto 0.1 = 10%).
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darker.toColor();
  }

  /// Devuelve el color de texto con mejor contraste (blanco o negro).
  Color get contrastText {
    final brightness = ThemeData.estimateBrightnessForColor(this);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}
