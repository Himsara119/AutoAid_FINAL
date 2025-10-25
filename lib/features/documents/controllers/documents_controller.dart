import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../data/repositories/document_repository.dart';
import '../models/document_model.dart';

/// DocumentController
/// - Streams the vehicle's documents as typed models
/// - Exposes counts (active / expired) for badges
/// - Single-record stream for detail pages
/// - Delete helper
///
/// Usage:
///   final c = Get.put(DocumentController(vehicleId));
///   StreamBuilder<List<DocumentRecord>>(stream: c.stream, ...)
class DocumentController extends GetxController {
  DocumentController(this.vehicleId, {DocumentRepository? repo})
      : _repo = repo ?? DocumentRepository();

  final String vehicleId;
  final DocumentRepository _repo;

  /// Internal subject if you ever want to cache the last value.
  final _docs = Rxn<List<DocumentRecord>>();

  /// Public stream of typed records.
  Stream<List<DocumentRecord>> get stream async* {
    // Map the repository stream of maps -> typed model once.
    yield* _repo.streamForVehicle(vehicleId).map(
          (rawList) {
        final list = rawList.map(_docFromMap).toList();

        // Sort by expiry date (nulls last), then by name (null-safe).
        list.sort((a, b) {
          final aTs = a.expiryDate?.millisecondsSinceEpoch ?? 0x7FFFFFFFFFFFFFFF;
          final bTs = b.expiryDate?.millisecondsSinceEpoch ?? 0x7FFFFFFFFFFFFFFF;
          final cmp = aTs.compareTo(bTs);
          if (cmp != 0) return cmp;
          final aName = (a.name ?? '').toLowerCase();
          final bName = (b.name ?? '').toLowerCase();
          return aName.compareTo(bName);
        });

        _docs.value = list;
        return list;
      },
    );
  }

  /// Cached latest value, if anyone subscribed at least once.
  List<DocumentRecord> get current => _docs.value ?? const [];

  /// Active vs expired counts for chips/badges on the tab header.
  Stream<({int active, int expired, int total})> get counts async* {
    yield* stream.map((list) {
      int active = 0, expired = 0;
      final now = DateTime.now();
      for (final d in list) {
        final isExpired = (d.noExpiry == false) &&
            d.expiryDate != null &&
            d.expiryDate!.isBefore(now);
        if (isExpired || d.status == 'expired') {
          expired++;
        } else {
          active++;
        }
      }
      return (active: active, expired: expired, total: list.length);
    });
  }

  /// Single record stream for detail pages.
  Stream<DocumentRecord?> streamOne(String documentId) async* {
    final db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),                 // required on newer firebase_core
      databaseId: _repo.databaseId,
    );
    yield* db
        .collection('vehicles')
        .doc(vehicleId)
        .collection('documents')
        .doc(documentId)
        .snapshots()
        .map((snap) => snap.exists ? DocumentRecord.fromSnap(snap) : null);
  }

  /// Delete record and best-effort delete the file.
  Future<void> delete({
    required String documentId,
    String? fileUrl,
  }) async {
    await _repo.delete(
      vehicleId: vehicleId,
      documentId: documentId,
      fileUrl: fileUrl,
    );
  }
}

/* ===================== Private map -> model adapter ===================== */

DocumentRecord _docFromMap(Map<String, dynamic> m) {
  final id = (m['id'] ?? '').toString();
  final x = Map<String, dynamic>.from(m)..remove('id');

  String status = (x['status'] ?? 'active') as String;
  final bool noExpiry = (x['no_expiry'] ?? false) as bool;
  final Timestamp? expTs = x['expiry_date'] as Timestamp?;
  final DateTime? expiry = expTs?.toDate();

  if (!noExpiry && expiry != null && expiry.isBefore(DateTime.now())) {
    status = 'expired';
  }

  return DocumentRecord(
    id: id,
    type: (x['type'] ?? 'other').toString(),
    name: (x['name'] as String?) ?? '',              // null-safe
    number: x['number'] as String?,
    issuer: x['issuer'] as String?,
    issueDate: (x['issue_date'] as Timestamp?)?.toDate(),
    expiryDate: expiry,
    noExpiry: noExpiry,
    notes: x['notes'] as String?,
    fileUrl: x['file_url'] as String?,
    fileName: x['file_name'] as String?,
    fileSize: x['file_size'] is int ? x['file_size'] as int : null,
    contentType: x['content_type'] as String?,
    status: status,
    createdAt: ((x['created_at'] as Timestamp?)?.toDate()) ?? DateTime.now(),
    updatedAt: ((x['updated_at'] as Timestamp?)?.toDate()) ?? DateTime.now(),
  );
}
