// lib/features/profile/controllers/profile_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class ProfileController extends GetxController {
  final displayName = ''.obs;
  final email = ''.obs;
  final photoURL = RxnString();
  final loading = true.obs;

  fb.User? _user;
  StreamSubscription<fb.User?>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = fb.FirebaseAuth.instance.userChanges().listen((u) {
      _user = u;
      if (u == null) {
        displayName.value = '';
        email.value = '';
        photoURL.value = null;
        loading.value = false;
        return;
      }
      displayName.value = u.displayName ?? '';
      email.value = u.email ?? '';
      photoURL.value = u.photoURL;
      loading.value = false;
    });
  }

  fb.User? get user => _user;

  Future<void> refreshFromAuth() async {
    final u = fb.FirebaseAuth.instance.currentUser;
    await u?.reload();
    final nu = fb.FirebaseAuth.instance.currentUser;
    _user = nu;
    displayName.value = nu?.displayName ?? '';
    email.value = nu?.email ?? '';
    photoURL.value = nu?.photoURL;
  }

  Future<void> signOut() async {
    await fb.FirebaseAuth.instance.signOut();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
