// lib/services/messaging_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class MessagingService {
  MessagingService._();
  static final MessagingService I = MessagingService._();

  late FirebaseFirestore _db;
  late FirebaseApp _app;
  static final _fln = FlutterLocalNotificationsPlugin();

  Future<void> init({String databaseId = 'autoaid'}) async {
    debugPrint('[MessagingService] init() called…');

    _app = Firebase.app();
    debugPrint('[MessagingService] Using Firebase app: ${_app.name}');

    _db = FirebaseFirestore.instanceFor(app: _app, databaseId: databaseId);
    debugPrint('[MessagingService] Firestore connected → project=${_app.options.projectId}, db=$databaseId');

    final fcm = FirebaseMessaging.instance;

    // Permissions
    debugPrint('[MessagingService] Requesting notification permissions…');
    final settings = await fcm.requestPermission(alert: true, badge: true, sound: true);
    debugPrint('[MessagingService] Permission status: ${settings.authorizationStatus}');

    await fcm.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    debugPrint('[MessagingService] Foreground presentation configured.');

    // Local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _fln.initialize(const InitializationSettings(android: androidInit, iOS: iosInit));
    debugPrint('[MessagingService] Local notifications initialized.');

    // Android channel
    const channel = AndroidNotificationChannel(
      'autoaid_general',
      'General',
      description: 'AutoAid alerts & updates',
      importance: Importance.high,
    );
    await _fln
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    debugPrint('[MessagingService] Notification channel created.');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((msg) async {
      debugPrint('[FCM] Foreground message id=${msg.messageId}');
      debugPrint('[FCM] notif.title=${msg.notification?.title}');
      debugPrint('[FCM] notif.body=${msg.notification?.body}');
      debugPrint('[FCM] data=${msg.data}');

      final n = msg.notification;
      if (n == null) {
        debugPrint('[LocalNotify] Skipped: no notification payload.');
        return;
      }

      await _fln.show(
        DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
        n.title ?? 'AutoAid',
        n.body ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails('autoaid_general', 'General', importance: Importance.high, priority: Priority.high),
          iOS: DarwinNotificationDetails(),
        ),
      );
      debugPrint('[LocalNotify] Shown: "${n.title}"');
    });

    // Initial token
    final token = await fcm.getToken();
    debugPrint('[MessagingService] Initial FCM token: $token');
    await _saveToken(token);

    // Token refresh
    fcm.onTokenRefresh.listen((newToken) async {
      debugPrint('[MessagingService] FCM token refreshed: $newToken'); // <-- was logging the wrong thing before
      await _saveToken(newToken);
    });

    debugPrint('[MessagingService] Initialization complete.');
  }

  Future<void> _saveToken(String? token) async {
    debugPrint('[MessagingService] _saveToken called. token=$token');
    if (token == null) {
      debugPrint('[MessagingService] No token to save.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('[MessagingService] No signed-in user. Deferring token save.');
      return;
    }

    try {
      final ref = _db.collection('users').doc(user.uid).collection('device_tokens').doc(token);
      debugPrint('[MessagingService] Writing token document: ${ref.path}');
      await ref.set({
        'platform': Platform.isIOS ? 'ios' : 'android',
        'last_seen_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('[MessagingService] Token saved OK for uid=${user.uid}');
    } on FirebaseException catch (e) {
      debugPrint('[MessagingService] Firestore write failed: code=${e.code} msg=${e.message}');
    } catch (e) {
      debugPrint('[MessagingService] Token save crashed: $e');
    }
  }
}
