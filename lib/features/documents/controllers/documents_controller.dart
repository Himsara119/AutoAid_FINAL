// lib/features/vehicles/controllers/document_controller.dart
import 'dart:async';
import 'dart:developer' as dev;

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../data/repositories/document_repository.dart';
import '../models/document_model.dart';

// Notifications
import '../../notifications/models/alert_model.dart';
import '../../../data/repositories/alerts_repository.dart';

/// Streams vehicle documents and mirrors expiry notifications into
/// vehicles/{vehicleId}/notifications.
class DocumentController extends GetxController {
  DocumentController(
      this.vehicleId, {
        DocumentRepository? repo,
        AlertsRepository? alerts,
      })  : _repo = repo ?? DocumentRepository(),
        _alerts = alerts ?? AlertsRepository();

  final String vehicleId;
  final DocumentRepository _repo;
  final AlertsRepository _alerts;

  // cache of last emission (handy for UI)
  final _docs = Rxn<List<DocumentRecord>>();

  /// Public stream of typed records + side-effect to keep notifications in sync.
  Stream<List<DocumentRecord>> get stream async* {
    yield* _repo.streamForVehicle(vehicleId).asyncMap((rawList) async {
      final list = rawList.map(_docFromMap).toList(growable: false);

      // Sort by expiry first (nulls last), then by name.
      list.sort((a, b) {
        final aTs = a.expiryDate?.millisecondsSinceEpoch ?? 0x7fffffffffffffff;
        final bTs = b.expiryDate?.millisecondsSinceEpoch ?? 0x7fffffffffffffff;
        final cmp = aTs.compareTo(bTs);
        if (cmp != 0) return cmp;
        return (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase());
      });

      _docs.value = list;

      try {
        await _mirrorNotifications(list);
      } catch (e, st) {
        dev.log('Mirror notifications failed',
            name: 'DocumentController', error: e, stackTrace: st);
      }

      dev.log(
        'Documents tick for $vehicleId → ${list.length} docs',
        name: 'DocumentController',
      );

      return list;
    });
  }

  List<DocumentRecord> get current => _docs.value ?? const [];

  /// Active vs expired counts for chips/badges.
  Stream<({int active, int expired, int total})> get counts async* {
    yield* stream.map((list) {
      int active = 0, expired = 0;
      final now = DateTime.now();
      for (final d in list) {
        final isExpired =
            (d.noExpiry == false) && d.expiryDate != null && d.expiryDate!.isBefore(now);
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
      app: Firebase.app(),
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

  /// Delete record and best-effort delete the file and its notification.
  Future<void> delete({
    required String documentId,
    String? fileUrl,
  }) async {
    await _repo.delete(
      vehicleId: vehicleId,
      documentId: documentId,
      fileUrl: fileUrl,
    );

    // Remove corresponding notification (deterministic id via source tuple)
    try {
      await _alerts.deleteBySource(
        vehicleId: vehicleId,
        source: 'document',
        sourceId: documentId,
        type: AlertType.documentExpiry,
      );
      dev.log('Deleted document alert for $documentId', name: 'DocumentController');
    } catch (e, st) {
      dev.log('Failed to delete document alert $documentId',
          name: 'DocumentController', error: e, stackTrace: st);
    }
  }

  // ====================== Notification mirroring ======================

  Future<void> _mirrorNotifications(List<DocumentRecord> docs) async {
    final futures = <Future<void>>[];

    for (final d in docs) {
      if (d.id.isEmpty) {
        dev.log('Skipping doc with empty id', name: 'DocumentController');
        continue;
      }

      // No expiry -> ensure alert is gone
      if (d.noExpiry == true) {
        futures.add(_deleteBySourceIfExists(d.id));
        continue;
      }

      final expiry = d.expiryDate;
      if (expiry == null) {
        futures.add(_deleteBySourceIfExists(d.id));
        continue;
      }

      final days = _daysUntil(expiry);

      // Severity: overdue < 0, urgent ≤ 2, upcoming ≤ 45, else none
      String? severity;
      if (days < 0) {
        severity = AlertSeverity.overdue;
      } else if (days <= 2) {
        severity = AlertSeverity.urgent;
      } else if (days <= 45) {
        severity = AlertSeverity.upcoming;
      } else {
        severity = null;
      }

      if (severity == null) {
        futures.add(_deleteBySourceIfExists(d.id));
        continue;
      }

      final title = days < 0
          ? 'Document expired ${-days} day${-days == 1 ? '' : 's'} ago'
          : (severity == AlertSeverity.urgent
          ? 'Document expires in $days day${days == 1 ? '' : 's'}'
          : 'Document due in $days day${days == 1 ? '' : 's'}');

      final message = 'Expiry date: ${_fmt(expiry)}';

      futures.add(_alerts
          .upsertBySource(
        vehicleId: vehicleId,
        source: 'document',
        sourceId: d.id,
        type: AlertType.documentExpiry,
        title: title,
        message: message,
        severity: severity,
        dueAt: Timestamp.fromDate(expiry),
      )
          .then((_) {
        dev.log(
          'Synced document alert: ${d.id} → $severity (in $days days)',
          name: 'DocumentController',
        );
      }).catchError((e, st) {
        dev.log('Upsert doc alert failed',
            name: 'DocumentController', error: e, stackTrace: st);
      }));
    }

    await Future.wait(futures);
  }

  Future<void> _deleteBySourceIfExists(String documentId) async {
    try {
      await _alerts.deleteBySource(
        vehicleId: vehicleId,
        source: 'document',
        sourceId: documentId,
        type: AlertType.documentExpiry,
      );
      dev.log('Removed document alert: $documentId (out of window or no expiry)',
          name: 'DocumentController');
    } catch (_) {
      // fine if it didn’t exist
    }
  }

  // ============================ Helpers ============================

  int _daysUntil(DateTime due) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(due.year, due.month, due.day);
    return d.difference(today).inDays;
  }

  /// ISO-like yyyy-MM-dd for UI strings
  String _fmt(DateTime d) => d.toIso8601String().split('T').first;
}

/* ===================== Private map -> model adapter ===================== */

DocumentRecord _docFromMap(Map<String, dynamic> m) {
  final id = (m['id'] ?? '').toString();
  final x = Map<String, dynamic>.from(m)..remove('id');

  String status = (x['status'] ?? 'active') as String;
  final bool noExpiry = (x['no_expiry'] ?? false) as bool;

  // Be tolerant with Firestore types
  Timestamp? expTs;
  final raw = x['expiry_date'];
  if (raw is Timestamp) expTs = raw;
  if (raw is DateTime) expTs = Timestamp.fromDate(raw);
  if (raw is String) {
    final d = DateTime.tryParse(raw);
    if (d != null) expTs = Timestamp.fromDate(d);
  }
  final DateTime? expiry = expTs?.toDate();

  if (!noExpiry && expiry != null && expiry.isBefore(DateTime.now())) {
    status = 'expired';
  }

  return DocumentRecord(
    id: id,
    type: (x['type'] ?? 'other').toString(),
    name: (x['name'] as String?) ?? '',
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
