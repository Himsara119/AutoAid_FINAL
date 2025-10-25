// lib/data/repositories/vehicle_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../firestore_service.dart';

class VehicleRepository {
  final CollectionReference<Map<String, dynamic>> _col =
  FirestoreService.db.collection('vehicles');

  /// Common scope:
  /// - exclude soft-deleted
  /// - optionally filter by dealership (path) OR buyer (RAW UID), not both
  Query<Map<String, dynamic>> _scoped({
    String? dealershipPath,
    String? buyerUserId,
  }) {
    Query<Map<String, dynamic>> q =
    _col.where('deleted', isEqualTo: false);

    if (dealershipPath != null && dealershipPath.isNotEmpty) {
      q = q.where('dealership_id', isEqualTo: dealershipPath);
    } else if (buyerUserId != null && buyerUserId.isNotEmpty) {
      // IMPORTANT: you store raw UID in current_owner_id, not 'users/uid'
      q = q.where('current_owner_id', isEqualTo: buyerUserId);
    }

    return q;
  }

  Future<int> countTotal({String? dealershipPath, String? buyerUserId}) async {
    try {
      final q = _scoped(
        dealershipPath: dealershipPath,
        buyerUserId: buyerUserId,
      ).where('status', whereIn: ['active', 'sold']);

      final res = await q.count().get();
      return res.count ?? 0;
    } catch (e) {
      debugPrint('countTotal error: $e');
      return 0;
    }
  }

  Future<int> countActive({String? dealershipPath, String? buyerUserId}) async {
    try {
      final q = _scoped(
        dealershipPath: dealershipPath,
        buyerUserId: buyerUserId,
      ).where('status', isEqualTo: 'active');

      final res = await q.count().get();
      return res.count ?? 0;
    } catch (e) {
      debugPrint('countActive error: $e');
      return 0;
    }
  }

  Future<int> countSold({String? dealershipPath, String? buyerUserId}) async {
    try {
      final q = _scoped(
        dealershipPath: dealershipPath,
        buyerUserId: buyerUserId,
      ).where('status', isEqualTo: 'sold');

      final res = await q.count().get();
      return res.count ?? 0;
    } catch (e) {
      debugPrint('countSold error: $e');
      return 0;
    }
  }
}
