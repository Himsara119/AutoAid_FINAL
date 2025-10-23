import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../data/repositories/vehicle_repository.dart';
import '../../auth/controller/user_controller.dart';

class VehicleStatsController extends GetxController {
  final _repo = VehicleRepository();

  final total = 0.obs;
  final active = 0.obs;
  final sold = 0.obs;

  final loading = true.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    refreshCounts();
  }

  Future<void> refreshCounts() async {
    try {
      loading.value = true;
      error.value = null;
      debugPrint('Refreshing vehicle stats...');

      // Be defensive: UserController may not be registered yet
      UserController? userC =
      Get.isRegistered<UserController>() ? Get.find<UserController>() : null;

      final role = userC?.role ?? 'guest';
      String? dealershipPath;
      String? buyerUserId;

      if (role.startsWith('dealer')) {
        dealershipPath = userC?.dealershipPath;
      } else if (role == 'buyer' || role == 'customer') {
        buyerUserId = userC?.userId;
      } // else: guest/admin/global -> no filters

      total.value = await _repo.countTotal(
        dealershipPath: dealershipPath,
        buyerUserId: buyerUserId,
      );
      debugPrint('Total vehicles: ${total.value}');

      active.value = await _repo.countActive(
        dealershipPath: dealershipPath,
        buyerUserId: buyerUserId,
      );
      debugPrint('Active vehicles: ${active.value}');


      sold.value = await _repo.countSold(
        dealershipPath: dealershipPath,
        buyerUserId: buyerUserId,
      );
      debugPrint('Sold vehicles: ${sold.value}');
    } catch (e) {
      error.value = e.toString();
      debugPrint('Vehicle stats error: $e');
    } finally {
      loading.value = false;
    }
  }
}
