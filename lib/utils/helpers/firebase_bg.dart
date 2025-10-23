// lib/utils/helpers/firebase_bg.dart
import 'dart:developer' as dev;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// If you have firebase_options.dart, pull it in for safety.
// import 'package:finalapp/firebase_options.dart';

@pragma('vm:entry-point') // required so Android can find this in background isolate
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Be defensive: initialize Firebase in the background isolate.
  try {
    // If you have options, use them; else the default app is fine on Android.
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp();
  } catch (_) {
    // Already initialized or not required. No need to crash the isolate.
  }

  // Log everything so you can debug payloads from the console
  dev.log('[BG FCM] id=${message.messageId}');
  dev.log('[BG FCM] notif.title=${message.notification?.title}');
  dev.log('[BG FCM] notif.body=${message.notification?.body}');
  dev.log('[BG FCM] data=${message.data}');

  // Show a notification even for data-only messages
  final title = message.notification?.title ?? message.data['title'] ?? 'AutoAid';
  final body  = message.notification?.body  ?? message.data['body']  ?? '';

  // Init a fresh plugin instance in the background isolate
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  ));

  // Reuse the channel you created in foreground init (autoaid_general)
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'autoaid_general',
      'General',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
  await plugin.show(
    id,
    title,
    body,
    details,
    payload: message.data['deeplink'] ?? '',
  );

  dev.log('[BG FCM] local-notification shown id=$id title="$title"');
}
