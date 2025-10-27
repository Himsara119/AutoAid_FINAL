// lib/features/vehicles/controllers/service_records_controller.dart
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/service_record.dart';

// Notifications
import '../../notifications/models/alert_model.dart';
import '../../../data/repositories/alerts_repository.dart';

class ServiceRecordsController extends GetxController {
  ServiceRecordsController(
      this.vehicleId, {
        FirebaseFirestore? db,
        this.databaseId = 'autoaid',
      })  : _db = db ??
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      ),
        _alerts = AlertsRepository(db: db);

  final String vehicleId;
  final String databaseId;
  final FirebaseFirestore _db;
  final AlertsRepository _alerts;

  // reactive state
  final loading = true.obs;
  final error = RxnString();
  final records = <ServiceRecord>[].obs;

  late final CollectionReference<Map<String, dynamic>> _col =
  _db.collection('vehicles').doc(vehicleId).collection('services');

  @override
  void onInit() {
    super.onInit();
    _listen();
  }

  void _listen() {
    loading.value = true;
    error.value = null;

    _col.orderBy('service_date', descending: true).snapshots().listen((qs) async {
      // 1) Update UI list
      final list = qs.docs
          .map((doc) => ServiceRecord.fromDoc(doc, vehicleId: vehicleId))
          .toList(growable: false);
      records.assignAll(list);
      loading.value = false;

      if (kDebugMode) {
        dev.log('Loaded ${list.length} service records for $vehicleId',
            name: 'ServiceRecordsController');
      }

      // 2) Mirror notifications based on what changed
      for (final change in qs.docChanges) {
        final doc = change.doc;
        try {
          if (change.type == DocumentChangeType.removed) {
            // delete corresponding alert (deterministic id via source tuple)
            await _alerts.deleteBySource(
              vehicleId: vehicleId,
              source: 'service',
              sourceId: doc.id,
              type: AlertType.serviceDue, // typically "service_due"
            );
            dev.log('Alert deleted (service removed): service ${doc.id}',
                name: 'ServiceRecordsController');
            continue;
          }

          // added or modified → recompute alert
          final data = doc.data();
          if (data == null) {
            // shouldn’t happen, but be defensive
            await _alerts.deleteBySource(
              vehicleId: vehicleId,
              source: 'service',
              sourceId: doc.id,
              type: AlertType.serviceDue,
            );
            dev.log('Alert deleted (no data in doc): service ${doc.id}',
                name: 'ServiceRecordsController');
            continue;
          }

          await _createOrUpdateNotification(doc.id, data,
              isModification: change.type == DocumentChangeType.modified);
          dev.log('Alert upserted for service ${doc.id} (change=${change.type.name})',
              name: 'ServiceRecordsController');
        } catch (e, st) {
          dev.log('Mirror error for service ${doc.id}',
              name: 'ServiceRecordsController', error: e, stackTrace: st);
        }
      }
    }, onError: (e, st) {
      if (kDebugMode) {
        dev.log('Service stream error',
            name: 'ServiceRecordsController', error: e, stackTrace: st);
      }
      error.value = e.toString();
      loading.value = false;
    });
  }

  /// Add new service record and trigger notification sync
  Future<String> addRecord(Map<String, dynamic> payload) async {
    final ref = await _col.add({
      ...payload,
      'vehicle_id': vehicleId,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    if (kDebugMode) {
      dev.log('Service record added: ${ref.id}',
          name: 'ServiceRecordsController');
    }

    // Best effort: in case the snapshot listener hasn’t fired yet.
    await _createOrUpdateNotification(ref.id, payload, isModification: false);
    return ref.id;
  }

  /// Delete service record and corresponding notification
  Future<void> deleteRecord(String id) async {
    await _col.doc(id).delete();
    await _alerts.deleteBySource(
      vehicleId: vehicleId,
      source: 'service',
      sourceId: id,
      type: AlertType.serviceDue,
    );

    if (kDebugMode) {
      dev.log('Deleted service record + alert: $id',
          name: 'ServiceRecordsController');
    }
  }

  // ==========================================================
  // =============  NOTIFICATION LOGIC SECTION  ===============
  // ==========================================================

  Future<void> _createOrUpdateNotification(
      String serviceId,
      Map<String, dynamic> payload, {
        required bool isModification,
      }) async {
    try {
      if (!payload.containsKey('next_service_date') ||
          payload['next_service_date'] == null) {
        await _alerts.deleteBySource(
          vehicleId: vehicleId,
          source: 'service',
          sourceId: serviceId,
          type: AlertType.serviceDue,
        );
        if (kDebugMode) {
          dev.log(
            'Skipped alert for $serviceId: no next_service_date.',
            name: 'ServiceRecordsController',
          );
        }
        return;
      }

      final nextDate = _asDate(payload['next_service_date']);
      final daysUntil = _daysUntil(nextDate);

      // Determine severity string for repo
      // Treat overdue as "urgent" severity, keep title/message explicit.
      late final String severity;
      if (daysUntil < 0) {
        severity = 'urgent';
      } else if (daysUntil <= 2) {
        severity = 'urgent';
      } else if (daysUntil <= 7) {
        severity = 'upcoming';
      } else {
        // more than a week away: remove any existing alert to avoid clutter
        await _alerts.deleteBySource(
          vehicleId: vehicleId,
          source: 'service',
          sourceId: serviceId,
          type: AlertType.serviceDue,
        );
        if (kDebugMode) {
          dev.log('Removed alert for $serviceId (next service in $daysUntil days)',
              name: 'ServiceRecordsController');
        }
        return;
      }

      // Build readable content
      final title = daysUntil < 0
          ? 'Service overdue by ${-daysUntil} day${-daysUntil == 1 ? '' : 's'}'
          : 'Service due in $daysUntil day${daysUntil == 1 ? '' : 's'}';

      final message =
          'Next service date: ${nextDate.toLocal().toString().split(" ").first}';

      // Upsert with deterministic id: {vehicleId}_service_{serviceId}_service_due
      await _alerts.upsertBySource(
        vehicleId: vehicleId,
        source: 'service',
        sourceId: serviceId,
        type: AlertType.serviceDue,
        title: title,
        message: message,
        severity: severity,
        dueAt: Timestamp.fromDate(nextDate),
        // If severity escalated on a modification, repo will flip read=false
        forceUnreadOnEscalation: isModification,
      );

      if (kDebugMode) {
        dev.log(
          'Alert synced for $vehicleId → $severity (in $daysUntil days)',
          name: 'ServiceRecordsController',
        );
      }
    } catch (e, st) {
      dev.log('Error creating service alert',
          name: 'ServiceRecordsController', error: e, stackTrace: st);
    }
  }

  // ------------------ Helpers ------------------

  DateTime _asDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) {
      final d = DateTime.tryParse(v);
      if (d != null) return d;
    }
    throw StateError('next_service_date is not a valid date-like type: $v');
  }

  int _daysUntil(DateTime due) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(due.year, due.month, due.day);
    return d.difference(today).inDays;
  }
}
