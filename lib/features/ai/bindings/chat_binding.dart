import 'package:get/get.dart';

import '../controllers/chat_controller.dart';
import '../llama_client.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(
          () => ChatController(Get.find<LlamaClient>()),
    );
  }
}
