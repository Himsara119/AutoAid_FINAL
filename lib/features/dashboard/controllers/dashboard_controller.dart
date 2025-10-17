import 'dart:async';
import 'package:get/get.dart';

import '../models/kpi_entity.dart';
import '../models/alert_entity.dart';
import '../../../data/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  DashboardController(this._repo);

  // Use the interface type defined in your repository file.
  final DashboardRepository _repo;

  // State
  final greetingName = 'Alex'.obs;
  final isLoading = false.obs;
  final kpis = <KPIEntity>[].obs;
  final alerts = <AlertEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      final data = await _repo.fetchDashboard();
      greetingName.value = data.userName;
      kpis.assignAll(data.kpis);
      alerts.assignAll(data.alerts);
    } finally {
      isLoading.value = false;
    }
  }

  // Quick actions (wire navigation later)
// DashboardController
  Future<void> addVehicle() async => Get.toNamed('/add-vehicle');
  Future<void> visualScan() async => Get.toNamed('/visual-scan');
  Future<void> generateReport() async => Get.toNamed('/report-builder');
  Future<void> findMechanic() async => Get.toNamed('/mechanic-finder');

}
