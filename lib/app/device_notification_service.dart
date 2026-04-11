import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';

import 'models.dart';

const _firebaseWebVapidKey = String.fromEnvironment('FIREBASE_WEB_VAPID_KEY');

class DeviceNotificationService {
  DeviceNotificationService._();

  static final DeviceNotificationService instance = DeviceNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<AppNotification> _remoteNotificationsController =
      StreamController<AppNotification>.broadcast();
  final List<AppNotification> _pendingRemoteNotifications = <AppNotification>[];
  final Set<String> _processedRemoteMessageIds = <String>{};

  bool _isInitialized = false;
  FirebaseMessaging? _messaging;

  Stream<AppNotification> get remoteNotifications =>
      _remoteNotificationsController.stream;

  String get platformLabel {
    if (kIsWeb) {
      return 'web';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'unknown';
    }
  }

  Stream<String> get tokenRefreshStream =>
      _messaging?.onTokenRefresh ?? const Stream<String>.empty();

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(defaultActionName: 'Abrir'),
    );

    await _plugin.initialize(initializationSettings);
    await _requestPermissions();
    await _initializeFirebaseMessaging();
    _isInitialized = true;
  }

  Future<String?> getPushToken() async {
    if (_messaging == null) {
      return null;
    }

    try {
      if (kIsWeb && _firebaseWebVapidKey.trim().isNotEmpty) {
        return await _messaging!.getToken(vapidKey: _firebaseWebVapidKey);
      }
      return await _messaging!.getToken();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[Notifications] unable to obtain FCM token: $error');
      }
      return null;
    }
  }

  List<AppNotification> drainPendingRemoteNotifications() {
    final pending = List<AppNotification>.from(_pendingRemoteNotifications);
    _pendingRemoteNotifications.clear();
    return pending;
  }

  Future<void> show(AppNotification notification) async {
    if (!_isInitialized) {
      return;
    }

    await _plugin.show(
      notification.createdAt.millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.message,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'urku_live_channel',
          'URKU Live',
          channelDescription: 'Alertas de pedidos, social y restaurantes.',
          importance: Importance.max,
          priority: Priority.high,
          ticker: notification.title,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        linux: const LinuxNotificationDetails(),
      ),
    );
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    final macPlugin = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    await macPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    if (kDebugMode) {
      debugPrint('[Notifications] permission request completed');
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    if (!_supportsFirebaseMessaging) {
      if (kDebugMode) {
        debugPrint('[Notifications] FCM skipped: unsupported platform');
      }
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        if (kDebugMode) {
          debugPrint('[Notifications] FCM skipped: Firebase.initializeApp has not run');
        }
        return;
      }

      _messaging = FirebaseMessaging.instance;
      await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      await _messaging!.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);

      final initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        _emitRemoteNotification(initialMessage);
      }
    } on MissingPluginException catch (error) {
      if (kDebugMode) {
        debugPrint('[Notifications] FCM plugin unavailable on this platform: $error');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[Notifications] FCM init failed: $error');
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _emitRemoteNotification(message);
  }

  void _handleOpenedMessage(RemoteMessage message) {
    _emitRemoteNotification(message);
  }

  void _emitRemoteNotification(RemoteMessage message) {
    final dedupeId = _dedupeIdForMessage(message);
    if (!_processedRemoteMessageIds.add(dedupeId)) {
      return;
    }

    final notification = _notificationFromRemoteMessage(message);
    if (notification == null) {
      return;
    }

    _pendingRemoteNotifications.add(notification);
    _remoteNotificationsController.add(notification);
  }

  AppNotification? _notificationFromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final title =
        data['title']?.trim().isNotEmpty == true
            ? data['title']!.trim()
            : message.notification?.title?.trim() ?? 'URKU';
    final body =
        data['body']?.trim().isNotEmpty == true
            ? data['body']!.trim()
            : message.notification?.body?.trim() ?? '';
    if (body.isEmpty) {
      return null;
    }

    return AppNotification(
      id: message.messageId ?? '${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      message: body,
      type: _notificationTypeFromRaw(data['type']),
      createdAt: DateTime.now(),
    );
  }

  AppNotificationType _notificationTypeFromRaw(String? rawType) {
    switch ((rawType ?? '').trim().toLowerCase()) {
      case 'order':
        return AppNotificationType.order;
      case 'social':
        return AppNotificationType.social;
      case 'restaurant':
        return AppNotificationType.restaurant;
      default:
        return AppNotificationType.system;
    }
  }

  String _dedupeIdForMessage(RemoteMessage message) {
    return message.messageId ??
        '${message.data['type']}-${message.data['orderId']}-${message.data['postId']}-${message.sentTime?.millisecondsSinceEpoch ?? 0}';
  }

  bool get _supportsFirebaseMessaging {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }
}