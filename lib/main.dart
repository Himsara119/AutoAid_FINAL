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
  // Makes sure Flutter bindings are ready before using platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase core using your platform config
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Firebase initialized: ${Firebase.app().name}');

  // Register background message handler (for Android background notifications)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Firestore with your secondary database (autoaid)
  FirestoreService.init(databaseId: 'autoaid');
  debugPrint('Firestore initialized for DB: autoaid');

  // Quick test to see if Firestore connects properly
  try {
    final snap = await FirestoreService.db.collection('vehicles').limit(1).get();
    debugPrint('vehicles sample docs: ${snap.docs.length}');
  } catch (e) {
    debugPrint('Firestore test failed: $e');
  }

  final user = FirebaseAuth.instance.currentUser ?? await FirebaseAuth.instance.authStateChanges().firstWhere((u) => u != null);
  debugPrint('Auth ready for uid=${user?.uid}');

  // Initialize notifications (local + push)
  await MessagingService.I.init(databaseId: 'autoaid');
  debugPrint('Messaging service initialized');

  // Register authentication repository for GetX dependency injection
  Get.put(AuthenticationRepository());

  // Run the main Flutter app
  runApp(const App());
}
