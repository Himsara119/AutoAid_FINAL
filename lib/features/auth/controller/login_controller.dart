import 'package:finalapp/features/auth/controller/user_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../app.dart' show Routes;
import '../../dashboard/screens/dashboard_screen.dart';
import '../../vehicles/controllers/vehicle_stats_controller.dart';

class LoginController extends GetxController {
  final _authRepo = AuthenticationRepository();

  Future<void> login(String email, String password) async {
    try {
      await _authRepo.signInWithEmailAndPassword(email: email, password: password);

      final uid = FirebaseAuth.instance.currentUser!.uid;

      if (!Get.isRegistered<UserController>()) {
        Get.put(UserController(), permanent: true);
      }
      await Get.find<UserController>().loadUserByUid(uid);

      if (!Get.isRegistered<VehicleStatsController>()) {
        Get.put(VehicleStatsController(), permanent: true);
      } else {
        await Get.find<VehicleStatsController>().refreshCounts();
      }

      Get.offAllNamed(Routes.login);  // or your shell route
    } catch (e) {
      Get.snackbar('Login failed', e.toString());
    }
  }

  Future<void> logout() async {
    await _authRepo.signOut();
    if (Get.isRegistered<VehicleStatsController>()) Get.delete<VehicleStatsController>(force: true);
    if (Get.isRegistered<UserController>()) Get.delete<UserController>(force: true);
    Get.offAllNamed(Routes.login);
  }
}
