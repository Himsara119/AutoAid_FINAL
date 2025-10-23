import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

Future<void> seedCurrentUserProfileOnce() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    debugPrint('seed: no user signed in, skipping');
    return;
  }

  final uid = user.uid;
  final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
  final snap = await docRef.get();

  if (snap.exists) {
    debugPrint('seed: user doc already exists for $uid');
    return;
  }

  const dealershipPath = 'dealerships/dealer_001'; // must match vehicles.dealership_id you want to see
  await docRef.set({
    'user_id': uid,
    'display_name': user.displayName ?? 'Unnamed',
    'email': user.email,
    'phone': '',
    'photo_url': '',
    'role': 'dealer_owner', // or 'customer'
    'dealership_id': dealershipPath,
    'settings': {'push_enabled': true, 'locale': 'en', 'theme': 'light'},
    'deleted': false,
  });

  debugPrint('seed: created user doc for $uid with dealership_id=$dealershipPath');
}
