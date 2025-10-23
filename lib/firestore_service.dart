import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  static late FirebaseFirestore db;

  static void init({String? databaseId}) {
    final app = Firebase.app(); // your main Firebase app instance

    if (databaseId == null || databaseId.isEmpty || databaseId == '(default)') {
      db = FirebaseFirestore.instance;
    } else {
      db = FirebaseFirestore.instanceFor(app: app, databaseId: databaseId);
    }

    debugPrint(
      'Firestore connected → project=${db.app.options.projectId}, databaseId=${db.databaseId}',
    );
  }
}
