// lib/data/repositories/vehicle_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../firestore_service.dart';

class VehicleRepository {
  final CollectionReference<Map<String, dynamic>> _col =
  FirestoreService.db.collection('vehicles');

  Future<int> countTotal({String? dealershipPath, String? buyerUserId}) async {
    Query<Map<String, dynamic>> q = _col.where('deleted', isEqualTo: false);
    q = q.where('status', whereIn: ['active', 'sold']);
    if (dealershipPath != null && dealershipPath.isNotEmpty) {
      q = q.where('dealership_id', isEqualTo: dealershipPath);
    } else if (buyerUserId != null && buyerUserId.isNotEmpty) {
      q = q.where('current_owner_id', isEqualTo: 'users/$buyerUserId');
    }
    try {
      final res = await q.count().get();
      return res.count ?? 0;
    } catch (e) {
      debugPrint('countTotal error: $e');
      return 0;
    }
  }

  Future<int> countActive({String? dealershipPath, String? buyerUserId}) async {
    Query<Map<String, dynamic>> q =
    _col.where('deleted', isEqualTo: false).where('status', isEqualTo: 'active');
    if (dealershipPath != null && dealershipPath.isNotEmpty) {
      q = q.where('dealership_id', isEqualTo: dealershipPath);
    } else if (buyerUserId != null && buyerUserId.isNotEmpty) {
      q = q.where('current_owner_id', isEqualTo: 'users/$buyerUserId');
    }
    try {
      final res = await q.count().get();
      return res.count ?? 0;
    } catch (e) {
      debugPrint('countActive error: $e');
      return 0;
    }
  }

  Future<int> countSold({String? dealershipPath, String? buyerUserId}) async {
    Query<Map<String, dynamic>> q =
    _col.where('deleted', isEqualTo: false).where('status', isEqualTo: 'sold');
    if (dealershipPath != null && dealershipPath.isNotEmpty) {
      q = q.where('dealership_id', isEqualTo: dealershipPath);
    } else if (buyerUserId != null && buyerUserId.isNotEmpty) {
      q = q.where('current_owner_id', isEqualTo: 'users/$buyerUserId');
    }
    try {
      final res = await q.count().get();
      return res.count ?? 0;
    } catch (e) {
      debugPrint('countSold error: $e');
      return 0;
    }
  }
}
