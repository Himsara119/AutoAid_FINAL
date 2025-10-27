// lib/features/notifications/controllers/alerts_generator_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repositories/alerts_repository.dart';
import '../models/alert_model.dart';

/// Watches services+documents under a vehicle and mirrors due items into notifications.
/// Requires userId so streamAllForUser(...) can actually find them.
class AlertsGeneratorController extends GetxController {
  AlertsGeneratorController(
      this.vehicleId, {
        required this.userId,              // ← add
        this.dealershipId,                 // ← optional
        FirebaseFirestore? db,
      })  : _db = db ?? FirebaseFirestore.instance,
        _repo = AlertsRepository(db: db);

  final String vehicleId;
  final String userId;                 // ← add
  final String? dealershipId;          // ← add
  final FirebaseFirestore _db;
  final AlertsRepository _repo;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _svcSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _docSub;

  Query<Map<String, dynamic>> _servicesQuery() {
    final now = DateTime.now();
    final back = Timestamp.fromDate(now.subtract(const Duration(days: 365)));
    final ahead = Timestamp.fromDate(now.add(const Duration(days: 60)));
    return _db
        .collection('vehicles/$vehicleId/services')
        .where('next_service_date', isGreaterThanOrEqualTo: back)
        .where('next_service_date', isLessThanOrEqualTo: ahead);
  }

  Query<Map<String, dynamic>> _documentsQuery() {
    final now = DateTime.now();
    final back = Timestamp.fromDate(now.subtract(const Duration(days: 365)));
    final ahead = Timestamp.fromDate(now.add(const Duration(days: 90)));
    return _db
        .collection('vehicles/$vehicleId/documents')
        .where('no_expiry', isEqualTo: false)
        .where('expiry_date', isGreaterThanOrEqualTo: back)
        .where('expiry_date', isLessThanOrEqualTo: ahead);
  }

  @override
  void onInit() {
    super.onInit();
    _bind();
  }

  @override
  void onClose() {
    _svcSub?.cancel();
    _docSub?.cancel();
    super.onClose();
  }

  void _bind() {
    _svcSub = _servicesQuery().snapshots().listen((snap) async {
      for (final change in snap.docChanges) {
        final d = change.doc;
        if (change.type == DocumentChangeType.removed) {
          await _safeDelete('service_${d.id}');
          continue;
        }
        final base = AlertEntity.fromServiceRecord(doc: d, vehicleId: vehicleId);
        if (base != null) {
          final alert = base.copyWith(userId: userId, dealershipId: dealershipId);
          await _repo.upsert(vehicleId: vehicleId, alert: alert);
        } else {
          await _safeDelete('service_${d.id}');
        }
      }
    });

    _docSub = _documentsQuery().snapshots().listen((snap) async {
      for (final change in snap.docChanges) {
        final d = change.doc;
        if (change.type == DocumentChangeType.removed) {
          await _safeDelete('document_${d.id}');
          continue;
        }
        final base = AlertEntity.fromDocumentRecord(doc: d, vehicleId: vehicleId);
        if (base != null) {
          final alert = base.copyWith(userId: userId, dealershipId: dealershipId);
          await _repo.upsert(vehicleId: vehicleId, alert: alert);
        } else {
          await _safeDelete('document_${d.id}');
        }
      }
    });
  }

  Future<void> _safeDelete(String alertId) async {
    try {
      await _repo.delete(vehicleId: vehicleId, id: alertId);
    } catch (_) {}
  }
}
