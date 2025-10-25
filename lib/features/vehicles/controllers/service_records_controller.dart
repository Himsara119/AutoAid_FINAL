// lib/features/vehicles/controllers/service_records_controller.dart
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/service_record.dart';

class ServiceRecordsController extends GetxController {
  ServiceRecordsController(
      this.vehicleId, {
        FirebaseFirestore? db,
        this.databaseId = 'autoaid',
      }) : _db = db ??
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      );

  final String vehicleId;
  final String databaseId;
  final FirebaseFirestore _db;

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

    _col.orderBy('service_date', descending: true).snapshots().listen((qs) {
      final list = qs.docs
          .map((doc) => ServiceRecord.fromDoc(doc, vehicleId: vehicleId))
          .toList(growable: false);

      records.assignAll(list);
      loading.value = false;
    }, onError: (e, st) {
      if (kDebugMode) {
        dev.log(
          'Service stream error',
          name: 'ServiceRecordsController',
          error: e,
          stackTrace: st,
        );
      }
      error.value = e.toString();
      loading.value = false;
    });
  }

  /// Optional: direct add (useful for tests or quick inserts)
  Future<String> addRecord(Map<String, dynamic> payload) async {
    final ref = await _col.add({
      ...payload,
      'vehicle_id': vehicleId, // keep redundancy handy for queries/exports
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Optional: delete a record
  Future<void> deleteRecord(String id) => _col.doc(id).delete();
}