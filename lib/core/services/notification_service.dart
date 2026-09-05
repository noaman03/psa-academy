import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();

  static Future<void> initialize() async {
    // Only attempt on mobile / web where Firebase Messaging is supported
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        final messaging = FirebaseMessaging.instance;
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (kDebugMode) {
          print('FCM Permission status: ${settings.authorizationStatus}');
        }

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (kDebugMode) {
            print('Foreground push received: ${message.notification?.title}');
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print('NotificationService initialization skipped/failed: $e');
        }
      }
    }
  }
}
