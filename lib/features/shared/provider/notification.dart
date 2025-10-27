import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ultrared/config/local_notifications/local_notifications.dart';
import 'package:ultrared/features/auth/domain/entities/user.dart';
import 'package:ultrared/features/auth/presentation/providers/auth_provider.dart';
import 'package:ultrared/features/shared/domain/entities/push_message.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ultrared/features/shared/infrastructure/services/key_value_storage_impl.dart';
import 'package:ultrared/firebase_options.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>(
  (ref) {
    final dio = ref.watch(authProvider.notifier).dio;
    final user = ref.watch(authProvider).user;
    return NotificationsNotifier(
      keyValueStorage: KeyValueStorageImpl(),
      dio: dio,
      user: user,
      requestLocalNotificationPermissions: () async {
        await LocalNotifications.requestPermisionLocalNotification();
      },
      showLocalNotification: ({
        required int id,
        String? title,
        String? body,
        String? data,
      }) {
        LocalNotifications.showLocalNotification(
          id: id,
          title: title,
          body: body,
          data: data,
        );
      },
    );
  },
);

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Dio dio;
  final User? user;
  final KeyValueStorageImpl keyValueStorage;
  int _pushNumberId = 0;

  final Future<void> Function()? requestLocalNotificationPermissions;
  final void Function({
    required int id,
    String? title,
    String? body,
    String? data,
  })? showLocalNotification;

  NotificationsNotifier({
    this.requestLocalNotificationPermissions,
    this.showLocalNotification,
    required this.dio,
    required this.keyValueStorage,
    required this.user,
  }) : super(const NotificationsState()) {
    _initialStatusCheck();
    _onForegroundMessage();
  }

  static Future<void> initializeFirebaseNotifications() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future<void> _initialStatusCheck() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    updateStatus(settings.authorizationStatus);
  }

  void updateStatus(AuthorizationStatus status) {
    state = state.copyWith(status: status);
    _getFCMToken();
  }

  void _saveToken(String tokenFToSave) async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    String dispositivo = 'Desconocido';
    String plataforma = Platform.operatingSystem;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      dispositivo = '${androidInfo.manufacturer} ${androidInfo.model}';
      plataforma = 'android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      dispositivo = '${iosInfo.name} ${iosInfo.model}';
      plataforma = 'ios ${iosInfo.systemVersion}';
    }
    try {
      final res = await dio.post('/push/register', data: {
        "perId": user?.id,
        "token": tokenFToSave,
        "dispositivo": dispositivo,
        "plataforma": plataforma,
      });
      print(res);
    } catch (e) {
      print(e);
    }
  }

  void _getFCMToken() async {
    if (state.status != AuthorizationStatus.authorized) return;
    final token2Save = await _firebaseMessaging.getToken();
    if (token2Save != null) {
      final tokenFSaved = await keyValueStorage.getValue<String>('tokenF');
      if (tokenFSaved == null) {
        await keyValueStorage.setKeyValue<String>('tokenF', token2Save);
        _saveToken(token2Save);
      } else {
        if (tokenFSaved != token2Save) {
          _saveToken(token2Save);
        }
      }
    }
    print('Token: $token2Save');
  }

  void addMessage(PushMessage message) {
    state = state.copyWith(notifications: [message, ...state.notifications]);
  }

  void handleRemoteMessage(RemoteMessage message) {
    if (message.notification == null) return;

    final notification = PushMessage(
      messageId:
          message.messageId?.replaceAll(';', '').replaceAll('%', '') ?? "",
      title: message.notification!.title ?? "",
      body: message.notification!.body ?? "",
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUlrl: Platform.isAndroid
          ? message.notification!.android?.imageUrl
          : message.notification!.apple?.imageUrl,
    );

    if (showLocalNotification != null) {
      showLocalNotification!(
        id: ++_pushNumberId,
        title: notification.title,
        body: notification.body,
        data: notification.messageId,
      );
    }

    // addMessage(notification);
  }

  void _onForegroundMessage() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  Future<AuthorizationStatus> requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (requestLocalNotificationPermissions != null) {
      await requestLocalNotificationPermissions!();
    }
    print('Authorization status: ${settings.authorizationStatus}');
    updateStatus(settings.authorizationStatus);
    return settings.authorizationStatus;
  }

  PushMessage? getPushMessage(String pushMessageId) {
    try {
      return state.notifications.firstWhere(
        (msg) => msg.messageId == pushMessageId,
      );
    } catch (_) {
      return null;
    }
  }
}

class NotificationsState {
  final AuthorizationStatus status;
  final List<PushMessage> notifications;

  const NotificationsState({
    this.status = AuthorizationStatus.notDetermined,
    this.notifications = const [],
  });

  NotificationsState copyWith({
    AuthorizationStatus? status,
    List<PushMessage>? notifications,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
    );
  }
}
