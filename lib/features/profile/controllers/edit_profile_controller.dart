// lib/features/profile/controllers/edit_profile_controller.dart
import 'dart:io';
import 'package:finalapp/features/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileController extends GetxController {
  // form
  final first = TextEditingController();
  final last = TextEditingController();
  final email = TextEditingController();
  final newPw = TextEditingController();
  final confirmPw = TextEditingController();
  final phone = TextEditingController();
  final company = TextEditingController();
  final address = TextEditingController();

  // state
  final loading = true.obs;
  final saving = false.obs;
  final error = RxnString();

  final photoUrl = RxnString();  // current/persisted
  final pickedFile = Rxn<File>(); // local temp

  fb.User? _user;

  @override
  Future<void> onInit() async {
    super.onInit();
    await bootstrap();
  }

  Future<void> bootstrap() async {
    try {
      loading.value = true;
      error.value = null;

      _user = fb.FirebaseAuth.instance.currentUser;
      if (_user == null) {
        error.value = 'No authenticated user.';
        return;
      }

      // split name
      final dn = _user!.displayName ?? '';
      final parts = dn.trim().split(RegExp(r'\s+'));
      first.text = parts.isNotEmpty ? parts.first : '';
      last.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      email.text = _user!.email ?? '';
      photoUrl.value = _user!.photoURL;

      // Firestore optional
      try {
        final snap =
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
        if (snap.exists) {
          final d = snap.data()!;
          phone.text = (d['phone'] ?? '') as String;
          company.text = (d['company'] ?? '') as String;
          address.text = (d['address'] ?? '') as String;
        }
      } catch (_) {}
    } catch (e) {
      error.value = 'Failed to load profile: $e';
    } finally {
      loading.value = false;
    }
  }

  Future<void> pickPhoto(ImageSource source) async {
    final x = await ImagePicker().pickImage(source: source, maxWidth: 1200, imageQuality: 85);
    if (x == null) return;
    pickedFile.value = File(x.path);
  }

  void removePhoto() {
    pickedFile.value = null;
    photoUrl.value = '';
  }

  Future<void> save() async {
    if (_user == null) return;
    saving.value = true;
    error.value = null;

    try {
      final tasks = <Future<void>>[];

      // avatar upload
      String? uploadedUrl = photoUrl.value;
      if (pickedFile.value != null) {
        final ref =
        FirebaseStorage.instance.ref().child('users/${_user!.uid}/avatar.jpg');
        await ref.putFile(pickedFile.value!);
        uploadedUrl = await ref.getDownloadURL();
        tasks.add(_user!.updatePhotoURL(uploadedUrl));
      }

      // display name
      final dn = '${first.text.trim()} ${last.text.trim()}'.trim();
      if (dn != (_user!.displayName ?? '')) {
        tasks.add(_user!.updateDisplayName(dn));
      }

      // email change requires reauth then verifyBeforeUpdateEmail (newer SDK)
      final newEmail = email.text.trim();
      if (newEmail != (_user!.email ?? '')) {
        final pass = await _promptPassword('Confirm Password', 'Enter your current password to update email.');
        if (pass != null && pass.isNotEmpty) {
          final cred = fb.EmailAuthProvider.credential(email: _user!.email!, password: pass);
          await _user!.reauthenticateWithCredential(cred);
          // most versions accept plain call without action settings
          await _user!.verifyBeforeUpdateEmail(newEmail);
          Get.snackbar('Verify new email', 'We sent a link to $newEmail. Confirm to finish the change.',
              snackPosition: SnackPosition.BOTTOM);
        }
      }

      // password
      if (newPw.text.trim().isNotEmpty) {
        if (newPw.text.trim() != confirmPw.text.trim()) {
          throw 'Passwords do not match';
        }
        final pass = await _promptPassword('Re-authenticate', 'Enter your current password to change password.');
        if (pass != null && pass.isNotEmpty) {
          final cred = fb.EmailAuthProvider.credential(email: _user!.email!, password: pass);
          await _user!.reauthenticateWithCredential(cred);
          await _user!.updatePassword(newPw.text.trim());
        }
      }

      if (tasks.isNotEmpty) {
        await Future.wait(tasks);
        await _user!.reload();
        _user = fb.FirebaseAuth.instance.currentUser;
      }

      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
        'firstName': first.text.trim(),
        'lastName': last.text.trim(),
        'displayName': dn,
        'email': email.text.trim(),
        'phone': phone.text.trim(),
        'company': company.text.trim(),
        'address': address.text.trim(),
        'photoURL': uploadedUrl ?? photoUrl.value ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar('Profile updated', 'Your changes were saved.',
          snackPosition: SnackPosition.BOTTOM);

      // notify the header to refresh
      final header = Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : null;
      await header?.refreshFromAuth();

      Get.back(id: 2, result: true);
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', error.value!, snackPosition: SnackPosition.BOTTOM);
    } finally {
      saving.value = false;
    }
  }

  Future<String?> _promptPassword(String title, String message) async {
    final ctrl = TextEditingController();
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current password',
                prefixIcon: Icon(Iconsax.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Confirm')),
        ],
      ),
    );
    if (ok == true) return ctrl.text;
    return null;
  }

  @override
  void onClose() {
    first.dispose();
    last.dispose();
    email.dispose();
    newPw.dispose();
    confirmPw.dispose();
    phone.dispose();
    company.dispose();
    address.dispose();
    super.onClose();
  }
}
