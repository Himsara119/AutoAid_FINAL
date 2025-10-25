import 'package:get/get.dart';
import '../controllers/visual_scan_controller.dart';
import '../image_analysis_service.dart';

class VisualScanBinding extends Bindings {
  @override
  void dependencies() {
    // Controller depends on the global ImageAnalysisService
    Get.lazyPut<VisualScanController>(
          () => VisualScanController(Get.find<ImageAnalysisService>()),
    );
  }
}
