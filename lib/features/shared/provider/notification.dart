import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ultrared/config/local_notifications/local_notifications.dart';
import 'package:ultrared/features/shared/domain/entities/push_message.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ultrared/firebase_options.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>(
  (ref) => NotificationsNotifier(
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
  ),
);

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
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

  void _getFCMToken() async {
    if (state.status != AuthorizationStatus.authorized) return;
    final token = await _firebaseMessaging.getToken();
    print('Token: $token');
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

  Future<void> requestPermissions() async {
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
