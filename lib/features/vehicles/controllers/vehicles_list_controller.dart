import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/vehicle_model.dart';

class VehicleListController extends GetxController {
  VehicleListController({
    FirebaseFirestore? db,
    this.databaseId = 'autoaid',
  }) : _db = db ??
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      );

  final FirebaseFirestore _db;
  final String databaseId;

  /// Reactive list of vehicles
  final vehicles = <VehicleModel>[].obs;

  /// Loading + error flags
  final loading = true.obs;
  final error = RxnString();

  /// Current filters
  final filter = 'All'.obs;
  final search = ''.obs;

  /// Force manual reloads
  final _reloadKey = 0.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _listenVehicles();

    // rebuild stream when filter/search changes
    everAll([filter, search, _reloadKey], (_) => _listenVehicles());
  }

  Future<void> refreshList() async => _reloadKey.value++;

  void _listenVehicles() {
    loading.value = true;
    error.value = null;

    // prevent ghost listeners
    _sub?.cancel();

    Query<Map<String, dynamic>> q =
    _db.collection('vehicles').where('deleted', isEqualTo: false);

    switch (filter.value) {
      case 'Active':
        q = q.where('status', isEqualTo: 'active');
        break;
      case 'Pending':
        q = q.where('status', isEqualTo: 'pending');
        break;
      case 'Sold':
        q = q.where('status', isEqualTo: 'sold');
        break;
      case 'Archived':
        q = q.where('status', isEqualTo: 'archived');
        break;
      default:
        break;
    }

    // order by the same field you write in AddVehicleController
    q = q.orderBy('created_at', descending: true);

    final term = search.value.trim().toLowerCase();

    _sub = q.snapshots().listen((snap) {
      final list = snap.docs.map(VehicleModel.fromDoc).toList();

      final filtered = term.isEmpty
          ? list
          : list.where((v) {
        // Make sure VehicleModel maps snake_case fields properly:
        // fuel_type -> fuelType, etc.
        final blob = [
          v.make,
          v.model,
          v.vin ?? '',
          v.trim ?? '',
          v.fuelType ?? '',
        ].join(' ').toLowerCase();
        return blob.contains(term);
      }).toList();

      vehicles.assignAll(filtered);
      loading.value = false;
    }, onError: (e) {
      error.value = e.toString();
      loading.value = false;
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
