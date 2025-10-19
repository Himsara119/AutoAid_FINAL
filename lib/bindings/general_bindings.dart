import 'package:finalapp/utils/validators/network_manager.dart';
import 'package:get/get.dart';

import '../data/repositories/auth_repository.dart';

class GeneralBindings extends Bindings {

  @override
  void dependencies() {
    Get.put(NetworkManager());
    Get.lazyPut<AuthenticationRepository>(() => AuthenticationRepository(), fenix: true);
  }
}


