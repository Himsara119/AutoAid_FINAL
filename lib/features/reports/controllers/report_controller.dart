import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../profile/models/profile_entity.dart';

/// Manages reports under a specific vehicle. Supports:
/// 1) Bound mode: construct with vehicleId -> auto-listen
/// 2) Unbound mode: construct empty -> call setVehicle(id) later
class ReportListController extends GetxController {
  String? _vehicleId;
  String? get vehicleId => _vehicleId;

  /// Firestore (named DB: autoaid)
  final _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'autoaid',
  );

  /// Backward-compatible: you can still do ReportListController(vehicleId)
  /// or start unbound with ReportListController().
  ReportListController([String? vehicleId]) {
    if (vehicleId != null && vehicleId.isNotEmpty) {
      _vehicleId = vehicleId;
    }
  }

  final items = <ReportModel>[].obs;
  final loading = true.obs;
  final error = RxnString();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    if (_vehicleId != null && _vehicleId!.isNotEmpty) {
      _listenReports(_vehicleId!);
    } else {
      loading.value = false; // nothing to load until a vehicle is set
    }
  }

  /// If you constructed unbound, call this once the user picked a car.
  Future<void> setVehicle(String vehicleId) async {
    if (vehicleId.isEmpty) return;
    if (_vehicleId == vehicleId) return;
    _vehicleId = vehicleId;
    await _sub?.cancel();
    _listenReports(vehicleId);
  }

  void _listenReports(String vehicleId) {
    loading.value = true;
    error.value = null;

    _sub = _db
        .collection('vehicles')
        .doc(vehicleId)
        .collection('reports')
        .orderBy('uploaded_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) => ReportModel.fromDoc(doc)).toList();
      items.assignAll(list);
      loading.value = false;
    }, onError: (e) {
      error.value = e.toString();
      loading.value = false;
    });
  }

  Future<void> refreshList() async {
    final id = _vehicleId;
    if (id == null || id.isEmpty) return;
    await _sub?.cancel();
    _listenReports(id);
  }

  Future<void> delete(String reportId) async {
    final id = _vehicleId;
    if (id == null || id.isEmpty) return;

    try {
      await _db
          .collection('vehicles')
          .doc(id)
          .collection('reports')
          .doc(reportId)
          .delete();

      items.removeWhere((r) => r.id == reportId);
    } catch (e) {
      error.value = e.toString();
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
