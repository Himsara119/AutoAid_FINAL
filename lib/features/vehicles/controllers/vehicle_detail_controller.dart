// lib/features/vehicles/controllers/vehicle_detail_controller.dart
import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/vehicle_model.dart';

class VehicleDetailController extends GetxController {
  VehicleDetailController(
      this.id, {
        FirebaseFirestore? db,
        this.databaseId = 'autoaid',
      }) : _db = db ??
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      );

  final String id;
  final String databaseId;
  final FirebaseFirestore _db;

  // Reactive state
  final loading = true.obs;
  final error = RxnString();
  final vehicle = Rxn<VehicleModel>();

  late final DocumentReference<Map<String, dynamic>> _ref =
  _db.collection('vehicles').doc(id);

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  void _d(String msg, {Object? err, StackTrace? st}) {
    if (kDebugMode) {
      dev.log(
        msg,
        name: 'VehicleDetail[$id]',
        error: err,
        stackTrace: st,
      );
    }
  }

  Stream<VehicleModel> _stream() =>
      _ref.snapshots().map((snap) => VehicleModel.fromDoc(snap));

  @override
  void onInit() {
    super.onInit();
    _d('onInit → connected to Firestore (db="$databaseId") path=${_ref.path}');
    _listen();
  }

  void _listen() {
    _d('Listening to Firestore for updates...');
    loading.value = true;
    error.value = null;

    _sub?.cancel();
    _sub = _ref.snapshots().listen((snap) {
      if (!snap.exists) {
        _d('snapshot ✖ document not found → ${_ref.path}');
        vehicle.value = null;
        loading.value = false;
        return;
      }

      final data = snap.data();
      if (data == null) {
        _d('snapshot ✖ empty data for doc: ${_ref.path}');
        vehicle.value = null;
        loading.value = false;
        return;
      }

      // If marked deleted, skip showing in UI
      if (data['deleted'] == true) {
        _d('snapshot ✖ document marked deleted → ${_ref.path}');
        vehicle.value = null;
        loading.value = false;
        return;
      }

      final v = VehicleModel.fromDoc(snap);
      _d(
        'snapshot ✓ '
            'make="${v.make}" model="${v.model}" year=${v.year} '
            'mileage=${v.mileage} status=${v.status}',
      );

      vehicle.value = v;
      loading.value = false;
    }, onError: (e, st) {
      _d('snapshot ✖ Firestore error', err: e, st: st);
      error.value = e.toString();
      loading.value = false;
    });
  }

  Future<void> hardReload() async {
    _d('hardReload → GET ${_ref.path}');
    try {
      loading.value = true;
      final d = await _ref.get();
      if (!d.exists) {
        _d('hardReload ✖ document not found');
        vehicle.value = null;
        return;
      }

      final data = d.data();
      if (data == null || data['deleted'] == true) {
        _d('hardReload ✖ document deleted or empty');
        vehicle.value = null;
        return;
      }

      vehicle.value = VehicleModel.fromDoc(d);
      _d('hardReload ✓ vehicle updated locally');
      error.value = null;
    } catch (e, st) {
      _d('hardReload ✖ $e', err: e, st: st);
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    _d('onClose → cancelling Firestore stream');
    _sub?.cancel();
    super.onClose();
  }
}
