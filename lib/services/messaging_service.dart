import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MessagingService {
  static final _fcm = FirebaseMessaging.instance;
  static final _fln = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (Platform.isAndroid) {
      await _fcm.requestPermission();
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _fln.initialize(const InitializationSettings(android: androidInit));

    FirebaseMessaging.onMessage.listen((msg) async {
      final n = msg.notification;
      if (n != null) {
        await _fln.show(
          n.hashCode,
          n.title,
          n.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'autoaid_default', 'AutoAid',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    final token = await _fcm.getToken();
    // TODO: save token in Firestore under users/{uid}/deviceTokens/{token}
  }
}
