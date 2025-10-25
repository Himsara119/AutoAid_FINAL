import 'package:get/get.dart';

// existing imports
import '../features/ai/chat_bridge.dart';
import '../features/ai/image_analysis_service.dart';
import '../features/ai/llama_client.dart';
import '../utils/validators/network_manager.dart';
import '../data/repositories/auth_repository.dart';
import '../features/auth/controller/user_controller.dart';
import '../features/vehicles/controllers/vehicle_stats_controller.dart';
import '../data/repositories/notifications_repository.dart';
import '../features/notifications/controllers/notifications_controller.dart' hide NotificationsRepository;


class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    // ---- your existing stuff (unchanged) ----
    Get.put<NetworkManager>(NetworkManager(), permanent: true);

    Get.lazyPut<AuthenticationRepository>(() => AuthenticationRepository(), fenix: true);

    if (!Get.isRegistered<UserController>()) {
      Get.put<UserController>(UserController(), permanent: true);
    }

    Get.lazyPut<VehicleStatsController>(() => VehicleStatsController(), fenix: true);

    Get.lazyPut<NotificationsRepository>(() => NotificationsRepository(), fenix: true);
    Get.put<NotificationsController>(NotificationsController(), permanent: true);

    // ---- NEW: global AI singletons (reused across screens) ----
    if (!Get.isRegistered<ImageAnalysisService>()) {
      Get.put<ImageAnalysisService>(ImageAnalysisService(), permanent: true);
    }
    if (!Get.isRegistered<LlamaClient>()) {
      Get.put<LlamaClient>(LlamaClient(), permanent: true);
    }
    if (!Get.isRegistered<ChatBridge>()) {
      Get.put<ChatBridge>(ChatBridge(), permanent: true);
    }
  }
}
