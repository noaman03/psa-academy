import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotification {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> myRequestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    String? token = await getFCMToken();
    print('User granted permission: ${settings.authorizationStatus}');
    print('FCM Token: $token');
  }

  Future<String?> getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("For web device token: $token");
    return token;
  }

  void showPushNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }
}
