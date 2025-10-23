import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final data = Rxn<Map<String, dynamic>>();

  Future<void> loadUserByUid(String uid) async {
    debugPrint('Loading user by uid: $uid');
    final d = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!d.exists) throw Exception('User profile not found for $uid');
    data.value = d.data();

    if (d.exists) {
      data.value = d.data();
      debugPrint('User loaded: ${d.data()}');
    } else {
      debugPrint('No user found for UID: $uid');
    }
  }

  String get role => (data.value?['role'] ?? 'customer').toString();
  String? get dealershipPath => data.value?['dealership_id'];         // e.g. "dealerships/dealer_001"
  String? get userId => data.value?['user_id'];                       // your field, not doc id
}
