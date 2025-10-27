// lib/data/repositories/report_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;

import '../../features/profile/models/profile_entity.dart';
import '../../features/reports/models/report_entity.dart';

/// Firestore repository for vehicle reports:
/// Path: vehicles/{vehicleId}/reports/{reportId}
class ReportRepo {
  ReportRepo({
    FirebaseFirestore? db,
  }) : _db = db ??
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'autoaid',
      );

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String vehicleId) =>
      _db.collection('vehicles').doc(vehicleId).collection('reports');

  /* ----------------------------- Reads ----------------------------- */

  /// Live list of reports under a vehicle, newest first.
  Stream<List<ReportModel>> watchReports(String vehicleId) {
    return _col(vehicleId)
        .orderBy('uploaded_at', descending: true)
        .snapshots()
        .map((q) => q.docs.map((d) => ReportModel.fromDoc(d)).toList());
  }

  /// Optional filtered stream by category (e.g., "condition", "inspection").
  Stream<List<ReportModel>> watchReportsByCategory(
      String vehicleId, {
        required String category,
      }) {
    return _col(vehicleId)
        .where('category', isEqualTo: category)
        .orderBy('uploaded_at', descending: true)
        .snapshots()
        .map((q) => q.docs.map((d) => ReportModel.fromDoc(d)).toList());
  }

  /// One-shot fetch of a single report; returns null if it doesn't exist.
  Future<ReportModel?> fetch(String vehicleId, String reportId) async {
    final d = await _col(vehicleId).doc(reportId).get();
    if (!d.exists) return null;
    return ReportModel.fromDoc(d);
  }

  /// Paged read (for when dealerships hoard PDFs like dragons).
  Future<
      ({
      List<ReportModel> items,
      DocumentSnapshot<Map<String, dynamic>>? next,
      })> fetchPage(
      String vehicleId, {
        int limit = 20,
        DocumentSnapshot<Map<String, dynamic>>? startAfter,
      }) async {
    Query<Map<String, dynamic>> q =
    _col(vehicleId).orderBy('uploaded_at', descending: true).limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);

    final snap = await q.get();
    final items = snap.docs.map((d) => ReportModel.fromDoc(d)).toList();
    final next = snap.docs.isEmpty ? null : snap.docs.last;
    return (items: items, next: next);
  }

  /* ---------------------------- Writes ----------------------------- */

  /// Creates a new report document. Returns the generated reportId.
  ///
  /// If you already have a `ReportModel`, use [createFromModel] instead.
  Future<String> create(String vehicleId, Map<String, dynamic> data) async {
    // Ensure server timestamps exist
    data['uploaded_at'] ??= FieldValue.serverTimestamp();
    data['updated_at'] = FieldValue.serverTimestamp();

    final ref = _col(vehicleId).doc();
    await ref.set(data, SetOptions(merge: true));
    return ref.id;
  }

  /// Creates from a model. Uses model.toJson() and returns the new id.
  Future<String> createFromModel(String vehicleId, ReportModel model) {
    return create(vehicleId, model.toJson());
  }

  /// Partial update. Only fields present in [patch] are modified.
  Future<void> update(
      String vehicleId,
      String reportId,
      Map<String, dynamic> patch,
      ) async {
    patch['updated_at'] = FieldValue.serverTimestamp();
    await _col(vehicleId).doc(reportId).update(patch);
  }

  /// Replace the entire doc. You almost never need this.
  Future<void> replace(
      String vehicleId,
      String reportId,
      Map<String, dynamic> data,
      ) async {
    data['uploaded_at'] ??= FieldValue.serverTimestamp();
    data['updated_at'] = FieldValue.serverTimestamp();
    await _col(vehicleId).doc(reportId).set(data);
  }

  /// Delete a report. Try not to do this live in front of a client.
  Future<void> delete(String vehicleId, String reportId) {
    return _col(vehicleId).doc(reportId).delete();
  }

  /* ------------------------ Utility Helpers ------------------------ */

  /// Generate a new document id (useful for naming files, etc.).
  String newReportId(String vehicleId) => _col(vehicleId).doc().id;
}
