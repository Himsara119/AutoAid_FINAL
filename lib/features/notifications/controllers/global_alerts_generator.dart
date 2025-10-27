// lib/features/notifications/controllers/global_alerts_generator.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'alerts_generator_controller.dart';

/// Binds AlertsGeneratorController for every vehicle owned by the user.
/// Mount this once after login or on dashboard init.
class GlobalAlertsGenerator extends GetxController {
  GlobalAlertsGenerator({required this.userId, this.dealershipId, FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final String userId;
  final String? dealershipId;
  final FirebaseFirestore _db;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _vehSub;
  final _active = <String, AlertsGeneratorController>{};

  @override
  void onInit() {
    super.onInit();

    // Adjust the vehicle query to your ownership schema.
    _vehSub = _db
        .collection('vehicles')
        .where('owner_user_id', isEqualTo: userId) // or currentOwnerId / dealershipId filter
        .snapshots()
        .listen((snap) {
      final seen = <String>{};
      for (final d in snap.docs) {
        final vid = d.id;
        seen.add(vid);
        if (!_active.containsKey(vid)) {
          final c = AlertsGeneratorController(
            vid,
            userId: userId,
            dealershipId: dealershipId,
            db: _db,
          );
          Get.put(c, tag: 'gen_$vid');
          _active[vid] = c;
        }
      }
      // Cleanup generators for vehicles no longer present
      final toRemove = _active.keys.where((k) => !seen.contains(k)).toList();
      for (final vid in toRemove) {
        final c = _active.remove(vid);
        if (c != null) {
          c.onClose();
          Get.delete<AlertsGeneratorController>(tag: 'gen_$vid', force: true);
        }
      }
    });
  }

  @override
  void onClose() {
    _vehSub?.cancel();
    for (final c in _active.values) {
      c.onClose();
    }
    _active.clear();
    super.onClose();
  }
}
