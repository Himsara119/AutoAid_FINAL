// lib/bindings/general_bindings.dart
import 'package:get/get.dart';

// existing imports
import '../utils/validators/network_manager.dart';
import '../data/repositories/auth_repository.dart';
import '../features/auth/controller/user_controller.dart';
import '../features/vehicles/controllers/vehicle_stats_controller.dart';

// notifications (repo + controller)
import '../data/repositories/notifications_repository.dart';
import '../features/notifications/controllers/notifications_controller.dart' hide NotificationsRepository;

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    // Global network check
    Get.put<NetworkManager>(NetworkManager(), permanent: true);

    // Auth and user-related bindings
    Get.lazyPut<AuthenticationRepository>(() => AuthenticationRepository(), fenix: true);

    if (!Get.isRegistered<UserController>()) {
      Get.put<UserController>(UserController(), permanent: true);
    }

    // Vehicle stats controller (lazily created, auto-restored)
    Get.lazyPut<VehicleStatsController>(() => VehicleStatsController(), fenix: true);

    // Notifications: repo + controller
    // Keep the repo lazy so it can be resurrected; keep the controller alive since it holds streams.
    Get.lazyPut<NotificationsRepository>(() => NotificationsRepository(), fenix: true);

    // If your NotificationsController has a default ctor that does Get.find() internally:
    Get.put<NotificationsController>(NotificationsController(), permanent: true);

    // If instead it expects the repo in its constructor, use this version:
    // Get.put<NotificationsController>(
    //   NotificationsController(Get.find<NotificationsRepository>()),
    //   permanent: true,
    // );
  }
}
