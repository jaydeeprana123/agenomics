import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/repositories/consent_repository.dart';

/// Background FCM handler (must be a top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background: ${message.messageId}');
}

/// Firebase Cloud Messaging + local notifications for consent tablets.
class FcmService {
  FcmService(this._consentRepository);

  final ConsentRepository _consentRepository;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'consent_requests',
    'Consent Requests',
    description: 'New genomic consent requests from desktop',
    importance: Importance.high,
  );

  Future<void> init() async {
    if (kIsWeb) return;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );

    if (!kIsWeb && Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await messaging.getToken();
    if (token != null) {
      await _consentRepository.registerDeviceToken(
        token: token,
        platform: Platform.operatingSystem,
      );
    }

    messaging.onTokenRefresh.listen((token) {
      _consentRepository.registerDeviceToken(
        token: token,
        platform: Platform.operatingSystem,
      );
    });

    FirebaseMessaging.onMessage.listen(_showLocal);
  }

  Future<void> _showLocal(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _local.show(
      id: notification.hashCode,
      title: notification.title ?? 'Consent request',
      body: notification.body ?? 'A new consent request is waiting.',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Local alert when Firestore delivers a new pending request while listening.
  Future<void> notifyNewConsent({
    required String patientName,
    required String uhid,
  }) async {
    if (kIsWeb) return;
    await _local.show(
      id: patientName.hashCode,
      title: 'New consent request',
      body: '$patientName · $uhid',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
