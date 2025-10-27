// lib/data/repositories/alerts_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../features/notifications/models/alert_model.dart';

/// Alerts/Notifications repository
/// Firestore layout:
///   vehicles/{vehicleId}/notifications/{notificationId}
class AlertsRepository {
  AlertsRepository({FirebaseFirestore? db})
      : _db = db ??
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'autoaid',
      );

  final FirebaseFirestore _db;

  // ---------------- internals ----------------

  // Subcollection under a specific vehicle
  CollectionReference<Map<String, dynamic>> _vehCol(String vehicleId) =>
      _db.collection('vehicles').doc(vehicleId).collection('notifications');

  // Document reference for a specific notification
  DocumentReference<Map<String, dynamic>> _vehDoc(
      String vehicleId,
      String notifId,
      ) =>
      _vehCol(vehicleId).doc(notifId);

  // Collection group over ALL vehicles' notifications
  Query<Map<String, dynamic>> get _group =>
      _db.collectionGroup('notifications');

  /// Canonical deterministic id so we can upsert/delete reliably
  /// NOTE: Keeping your existing format intact to avoid breaking live data.
  /// Format: {vehicleId}_{source}_{sourceId}_{type}
  String notifId({
    required String vehicleId,
    required String source, // "service" | "document"
    required String sourceId,
    required String type, // "service_due" | "insurance_expiry" | ...
  }) =>
      '${vehicleId}_${source}_$sourceId$type';

  /// Rank to detect severity escalation
  static const Map<String, int> _sevRank = {
    'normal': 0,
    'upcoming': 1,
    'urgent': 2,
  };

  // ---------------- vehicle name cache ----------------

  final Map<String, String?> _vehicleNameCache = {};

  Future<String?> _getVehicleName(String vehicleId) async {
    if (vehicleId.isEmpty) return null;
    if (_vehicleNameCache.containsKey(vehicleId)) {
      return _vehicleNameCache[vehicleId];
    }
    try {
      final vDoc = await _db.collection('vehicles').doc(vehicleId).get();
      if (!vDoc.exists) {
        _vehicleNameCache[vehicleId] = null;
        return null;
      }
      final data = vDoc.data() ?? {};
      final make = (data['make'] ?? '').toString();
      final model = (data['model'] ?? '').toString();
      final year = (data['year'] ?? '').toString();
      final name = [make, model, year]
          .where((s) => s.toString().trim().isNotEmpty)
          .join(' ')
          .trim();
      _vehicleNameCache[vehicleId] = name.isEmpty ? null : name;
      return _vehicleNameCache[vehicleId];
    } catch (_) {
      _vehicleNameCache[vehicleId] = null;
      return null;
    }
  }

  // ---------------- Streams ----------------

  /// Stream all alerts across ALL vehicles for a given user (profile screen).
  /// Optional filters:
  /// - [severity]: 'urgent' | 'upcoming' | 'normal'
  /// - [daysAhead]: cap future window (default 45). Always includes past 365 days for overdue.
  Stream<List<AlertEntity>> streamAllForUser({
    required String userId,
    String? severity,
    int daysAhead = 45,
  }) async* {
    final now = DateTime.now();
    final back = Timestamp.fromDate(now.subtract(const Duration(days: 365)));
    final ahead = Timestamp.fromDate(now.add(Duration(days: daysAhead)));

    Query<Map<String, dynamic>> q = _group
        .where('user_id', isEqualTo: userId)
        .where('due_at', isGreaterThanOrEqualTo: back)
        .where('due_at', isLessThanOrEqualTo: ahead)
        .orderBy('due_at', descending: false);

    if (severity != null && severity.isNotEmpty) {
      q = q.where('severity', isEqualTo: severity);
    }

    await for (final snap in q.snapshots()) {
      // Warm vehicle names
      final ids = <String>{};
      for (final d in snap.docs) {
        final vid = (d.data()['vehicle_id'] ?? '').toString();
        if (vid.isNotEmpty) ids.add(vid);
      }
      await Future.wait(ids.map(_getVehicleName));

      final results = snap.docs
          .map((d) {
        final entity = AlertEntity.fromDoc(d);
        final vName = _vehicleNameCache[entity.vehicleId];
        return entity.copyWith(vehicleName: vName);
      })
          .toList()
        ..sort((a, b) => a.compareTo(b));

      yield results;
    }
  }

  /// Stream alerts for a single vehicle (vehicle context).
  /// Optional filters:
  /// - [severity]
  /// - [daysAhead] window, defaults to 14. Always includes past 365 days for overdue.
  Stream<List<AlertEntity>> streamForVehicle({
    required String vehicleId,
    String? severity,
    int daysAhead = 14,
  }) async* {
    final now = DateTime.now();
    final back = Timestamp.fromDate(now.subtract(const Duration(days: 365)));
    final ahead = Timestamp.fromDate(now.add(Duration(days: daysAhead)));

    Query<Map<String, dynamic>> q = _vehCol(vehicleId)
        .where('due_at', isGreaterThanOrEqualTo: back)
        .where('due_at', isLessThanOrEqualTo: ahead)
        .orderBy('due_at', descending: false);

    if (severity != null && severity.isNotEmpty) {
      q = q.where('severity', isEqualTo: severity);
    }

    // Prime vehicle name once.
    final vName = await _getVehicleName(vehicleId);

    await for (final snap in q.snapshots()) {
      final items = snap.docs
          .map((d) => AlertEntity.fromDoc(d).copyWith(vehicleName: vName))
          .toList()
        ..sort((a, b) => a.compareTo(b));
      yield items;
    }
  }

  // ---------------- Mutations (back-compat) ----------------

  /// Create or overwrite an alert under a vehicle with server timestamps.
  /// Expects [alert.id] to already be deterministic if you want idempotence.
  Future<void> create({
    required String vehicleId,
    required AlertEntity alert,
  }) async {
    await _vehCol(vehicleId).doc(alert.id).set(
      alert.toMap(withTimestamps: true),
      SetOptions(merge: true),
    );
  }

  /// Upsert helper (alias of create).
  Future<void> upsert({
    required String vehicleId,
    required AlertEntity alert,
  }) =>
      create(vehicleId: vehicleId, alert: alert);

  // ---------------- Mutations (deterministic id, mirrors) ----------------

  /// Idempotent upsert using deterministic id `{vehicleId}_{source}_{sourceId}_{type}`.
  /// If [forceUnreadOnEscalation] is true and severity increases, flip `read=false`.
  Future<void> upsertBySource({
    required String vehicleId,
    required String source, // "service" | "document"
    required String sourceId,
    required String type, // "service_due" | "insurance_expiry" | ...
    required String title,
    required String message,
    required String severity, // "normal" | "upcoming" | "urgent"
    Timestamp? dueAt,
    String? userId,
    String dealershipId = 'default',
    bool forceUnreadOnEscalation = true,
  }) async {
    final id = notifId(
      vehicleId: vehicleId,
      source: source,
      sourceId: sourceId,
      type: type,
    );
    final ref = _vehDoc(vehicleId, id);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final now = FieldValue.serverTimestamp();

      bool nextRead = false;
      if (snap.exists) {
        final prev = snap.data()?['severity'] as String? ?? 'normal';
        final prevRead = snap.data()?['read'] == true;
        final escalated =
            (_sevRank[severity] ?? 0) > (_sevRank[prev] ?? 0);
        nextRead =
        forceUnreadOnEscalation ? (escalated ? false : prevRead) : prevRead;
      }

      final data = <String, dynamic>{
        'vehicle_id': vehicleId,
        'source': source,
        'source_id': sourceId,
        'type': type,
        'title': title,
        'message': message,
        'severity': severity,
        if (dueAt != null) 'due_at': dueAt,
        if (userId != null) 'user_id': userId,
        'dealership_id': dealershipId,
        'read': nextRead,
        'updated_at': now,
        if (!snap.exists) 'created_at': now,
      };

      tx.set(ref, data, SetOptions(merge: true));
    });
  }

  /// Delete a notification by its source triple.
  Future<void> deleteBySource({
    required String vehicleId,
    required String source,
    required String sourceId,
    required String type,
  }) async {
    final id = notifId(
      vehicleId: vehicleId,
      source: source,
      sourceId: sourceId,
      type: type,
    );
    await _vehDoc(vehicleId, id).delete();
  }

  // ---------------- NEW: Cascaded delete for a source (all types) ----------------

  /// Batch-delete ALL notifications for a given source record under a vehicle,
  /// regardless of `type`. Use this right after deleting a document/service.
  Future<void> deleteForSource({
    required String vehicleId,
    required String source,   // 'document' | 'service'
    required String sourceId, // the id of that document/service
  }) async {
    final col = _vehCol(vehicleId);
    final qs = await col
        .where('source', isEqualTo: source)
        .where('source_id', isEqualTo: sourceId)
        .get(const GetOptions(source: Source.server));

    if (qs.docs.isEmpty) return;

    final batch = _db.batch();
    for (final d in qs.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  // ---------------- Mark-as-read helpers ----------------

  /// Mark a specific alert as read/unread.
  Future<void> markAsRead({
    required String vehicleId,
    required String id,
    bool read = true,
  }) async {
    await _vehDoc(vehicleId, id).update({
      'read': read,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Mark ALL unread alerts for a user as read (across vehicles).
  Future<void> markAllAsReadForUser(String userId) async {
    final q = await _group
        .where('user_id', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final d in q.docs) {
      batch.update(d.reference, {
        'read': true,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Mark ALL unread alerts for a single vehicle.
  Future<void> markAllAsReadForVehicle(String vehicleId) async {
    final q = await _vehCol(vehicleId).where('read', isEqualTo: false).get();
    final batch = _db.batch();
    for (final d in q.docs) {
      batch.update(d.reference, {
        'read': true,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Delete an alert by vehicle + id.
  Future<void> delete({
    required String vehicleId,
    required String id,
  }) async {
    await _vehDoc(vehicleId, id).delete();
  }
}
