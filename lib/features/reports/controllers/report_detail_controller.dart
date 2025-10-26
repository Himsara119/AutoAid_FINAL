// lib/features/reports/controllers/report_detail_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;

import '../models/report_entity.dart' as reports;

/// Controller that manages a single report document.
/// Keeps a live Firestore listener for the given reportId.
class ReportDetailController extends GetxController {
  final String vehicleId;
  final String reportId;

  ReportDetailController({
    required this.vehicleId,
    required this.reportId,
  });

  // Bind to the named database 'autoaid'
  final _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'autoaid',
  );

  final report = Rxn<reports.ReportModel>();
  final loading = true.obs;
  final deleting = false.obs;
  final error = RxnString();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  DocumentReference<Map<String, dynamic>> get _ref => _db
      .collection('vehicles')
      .doc(vehicleId)
      .collection('reports')
      .doc(reportId);

  @override
  void onInit() {
    super.onInit();
    _listenReport();
  }

  /// Watches a single Firestore report document in real time.
  void _listenReport() {
    loading.value = true;
    _sub = _ref.snapshots().listen((snapshot) {
      if (!snapshot.exists) {
        error.value = 'Report not found.';
        loading.value = false;
        report.value = null;
        return;
      }
      report.value = reports.ReportModel.fromDoc(snapshot);
      loading.value = false;
    }, onError: (e) {
      error.value = e.toString();
      loading.value = false;
    });
  }

  /// Manually refresh the report from Firestore.
  Future<void> refresh() async {
    try {
      final doc = await _ref.get();
      if (doc.exists) {
        report.value = reports.ReportModel.fromDoc(doc);
      } else {
        error.value = 'Report not found.';
      }
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// Deletes the report document and attempts to delete its storage file if URL is Firebase Storage.
  Future<void> deleteReport() async {
    if (deleting.value) return;
    deleting.value = true;
    try {
      final url = report.value?.fileUrl ?? '';

      // Best-effort: if it's a Firebase Storage URL, remove the file first.
      if (url.isNotEmpty) {
        try {
          final ref = storage.FirebaseStorage.instance.refFromURL(url);
          await ref.delete();
        } catch (_) {
          // Not a Firebase Storage URL or already deleted. Ignore.
        }
      }

      await _ref.delete();
    } catch (e) {
      error.value = 'Delete failed: $e';
      rethrow;
    } finally {
      deleting.value = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
