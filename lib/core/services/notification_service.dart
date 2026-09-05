import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();

  static Future<void> initialize({void Function(String token)? onToken}) async {
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
          debugPrint('FCM Permission status: ${settings.authorizationStatus}');
        }

        // Get and optionally persist device registration token
        try {
          final token = await messaging.getToken();
          if (token != null && onToken != null) {
            onToken(token);
          }
        } catch (_) {
          // Token retrieval might be restricted on certain browsers without vapidKey
        }

        messaging.onTokenRefresh.listen((newToken) {
          if (onToken != null) onToken(newToken);
        });

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (kDebugMode) {
            debugPrint('Foreground push received: ${message.notification?.title}');
          }
        });
      } catch (e) {
        if (kDebugMode) {
          debugPrint('NotificationService initialization skipped/failed: $e');
        }
      }
    }
  }

  static Future<String?> getDeviceToken() async {
    try {
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        return await FirebaseMessaging.instance.getToken();
      }
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
    }
    return null;
  }
}
