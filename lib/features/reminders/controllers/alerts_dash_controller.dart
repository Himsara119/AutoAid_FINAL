import 'dart:async';
import 'package:get/get.dart';
import '../../../data/repositories/alerts_repository.dart';

class AlertsDashController extends GetxController {
  AlertsDashController({AlertsRepository? repo})
      : _repo = repo ?? AlertsRepository();

  final AlertsRepository _repo;

  final items = <Map<String, dynamic>>[].obs;
  final loading = false.obs;
  final error = ''.obs;

  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    loading.value = true;

    _sub = _repo.watchTopAlerts(limit: 3).listen(
          (data) {
        items.assignAll(data);
        loading.value = false;
        error.value = '';
      },
      onError: (e, _) {
        error.value = e.toString();
        loading.value = false;
      },
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
