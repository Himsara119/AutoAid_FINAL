import 'dart:async';
import 'package:finalapp/utils/helpers/firebase_bg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app.dart';
import 'data/repositories/auth_repository.dart';
import 'firebase_options.dart';
import 'firestore_service.dart';
import 'services/messaging_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Timebox Firebase init so bad networks don’t freeze the UI.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
    debugPrint('Firebase initialized: ${Firebase.app().name}');
  } catch (e) {
    debugPrint('Firebase init timed out or failed: $e');
  }

  // 2) Register background handler (cheap, keep as-is).
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 3) DO NOT block on auth here. Read whatever is available and move on.
  final user = FirebaseAuth.instance.currentUser;
  debugPrint('Auth (non-blocking) current uid=${user?.uid}');

  // 4) Don’t block UI on Firestore/messaging. Kick off bootstrap in background.
  //    If your app needs Firestore instantly, we still init it here, but guarded.
  unawaited(_bootstrapServices());

  // 5) Spin up the app immediately so splash can transition.
  Get.put(AuthenticationRepository());
  runApp(const App());
}

/// Background bootstrap that used to block the splash.
Future<void> _bootstrapServices() async {
  // Firestore secondary DB init (guarded).
  try {
    FirestoreService.init(databaseId: 'autoaid');
    debugPrint('Firestore initialized for DB: autoaid');
  } catch (e) {
    debugPrint('Firestore init failed: $e');
  }

  // Optional sanity ping. Never throw.
  unawaited(Future(() async {
    try {
      final snap = await FirestoreService.db.collection('vehicles').limit(1).get();
      debugPrint('vehicles sample docs: ${snap.docs.length}');
    } catch (e) {
      debugPrint('Firestore test failed: $e');
    }
  }));

  // Messaging init (guarded + timeboxed).
  try {
    await MessagingService.I
        .init(databaseId: 'autoaid')
        .timeout(const Duration(seconds: 5));
    debugPrint('Messaging service initialized');
  } catch (e) {
    debugPrint('Messaging init skipped/failed: $e');
  }
}
