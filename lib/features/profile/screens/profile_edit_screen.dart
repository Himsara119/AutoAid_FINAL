// lib/features/profile/ui/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Image picker
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}
//Profile Edit Renewed
class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();

  // Optional extras
  final _phone = TextEditingController();
  final _company = TextEditingController();
  final _address = TextEditingController();

  // State
  bool _loading = true;
  bool _saving = false;
  String? _error;

  String? _photoUrl;        // persisted URL in Auth
  File? _pickedFile;        // temporary local selection

  fb.User? _user;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      _user = fb.FirebaseAuth.instance.currentUser;
      if (_user == null) {
        setState(() => _error = 'No authenticated user.');
        return;
      }

      // Parse display name into first/last
      final dn = _user!.displayName ?? '';
      final parts = dn.trim().split(RegExp(r'\s+'));
      _first.text = parts.isNotEmpty ? parts.first : '';
      _last.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      _email.text = _user!.email ?? '';
      _photoUrl = _user!.photoURL;

      // Optional mirror from Firestore if you store extra fields
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();
        if (doc.exists) {
          final d = doc.data()!;
          _phone.text = (d['phone'] ?? '') as String;
          _company.text = (d['company'] ?? '') as String;
          _address.text = (d['address'] ?? '') as String;
        }
      } catch (_) {
        // non-blocking
      }
    } catch (e) {
      _error = 'Failed to load profile: $e';
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    _company.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Edit Profile',
            style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Color(0xFF111827)),
          onPressed: () => Get.back(id: 2),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!,
              style: t.titleMedium?.copyWith(color: Colors.red)),
        ),
      )
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF0F2F6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          )
                        ],
                        image: (_pickedFile != null || (_photoUrl ?? '').isNotEmpty)
                            ? DecorationImage(
                          fit: BoxFit.cover,
                          image: _pickedFile != null
                              ? FileImage(_pickedFile!)
                              : NetworkImage(_photoUrl!) as ImageProvider,
                        )
                            : null,
                      ),
                      child: (_pickedFile == null && (_photoUrl ?? '').isEmpty)
                          ? const Icon(Iconsax.user,
                          color: Color(0xFF9CA3AF), size: 40)
                          : null,
                    ),
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: GestureDetector(
                        onTap: _changePhoto,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Iconsax.camera,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _changePhoto,
                  child: const Text('Edit Photo',
                      style: TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w600,
                      )),
                ),

                const SizedBox(height: 10),

                // First Name
                const _Label('First Name'),
                const SizedBox(height: 6),
                _InputBox(
                  child: TextFormField(
                    controller: _first,
                    decoration: const InputDecoration(
                      hintText: 'Enter your first name',
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'First name is required'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Last Name
                const _Label('Last Name'),
                const SizedBox(height: 6),
                _InputBox(
                  child: TextFormField(
                    controller: _last,
                    decoration: const InputDecoration(
                      hintText: 'Enter your last name',
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Last name is required'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Email
                const _Label('Email'),
                const SizedBox(height: 6),
                _InputBox(
                  child: TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    validator: (v) {
                      final x = v?.trim() ?? '';
                      final rx = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                      if (x.isEmpty) return 'Email is required';
                      if (!rx.hasMatch(x)) return 'Enter a valid email';
                      return null;
                    },
                  ),
                ),

                // Optional fields
                const SizedBox(height: 12),
                const _Label('Phone (optional)'),
                const SizedBox(height: 6),
                _InputBox(
                  child: TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '+94...',
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const _Label('Company/Dealership (optional)'),
                const SizedBox(height: 6),
                _InputBox(
                  child: TextFormField(
                    controller: _company,
                    decoration: const InputDecoration(
                      hintText: 'Company name',
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const _Label('Address (optional)'),
                const SizedBox(height: 6),
                _InputBox(
                  child: TextFormField(
                    controller: _address,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Street, City, Country',
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Save
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      shadowColor:
                      const Color(0xFF7C3AED).withOpacity(0.25),
                    ),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Save Changes',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 10),

                // Cancel
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE6E8ED)),
                      ),
                    ),
                    onPressed: () => Get.back(id: 2),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ---------------------------- Actions ---------------------------- */

  Future<void> _changePhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PickerRow(
                icon: Iconsax.camera,
                label: 'Take Photo',
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 8),
              _PickerRow(
                icon: Iconsax.image,
                label: 'Choose from Gallery',
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
              _PickerRow(
                icon: Iconsax.trash,
                label: 'Remove Photo',
                danger: true,
                onTap: () {
                  _pickedFile = null;
                  _photoUrl = '';
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final x = await picker.pickImage(source: source, maxWidth: 1200, imageQuality: 85);
    if (x == null) return;

    _pickedFile = File(x.path);
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_user == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final futures = <Future<void>>[];

      // 1) Upload avatar if selected
      String? uploadedUrl = _photoUrl;
      if (_pickedFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('users/${_user!.uid}/avatar.jpg');
        await ref.putFile(_pickedFile!);
        uploadedUrl = await ref.getDownloadURL();
        futures.add(_user!.updatePhotoURL(uploadedUrl));
      }

      // 2) Update display name (First + Last)
      final dn = '${_first.text.trim()} ${_last.text.trim()}'.trim();
      if (dn != (_user!.displayName ?? '')) {
        futures.add(_user!.updateDisplayName(dn));
      }

      // 3) Update email (re-auth required). No password changing in this build.
      final newEmail = _email.text.trim();
      bool sentVerification = false;
      if (newEmail != (_user!.email ?? '')) {
        final ok = await _reauthenticateDialog(
          context,
          title: 'Confirm Password',
          message: 'Enter your current password to update email.',
        );
        if (ok.ok) {
          final action = fb.ActionCodeSettings(
            url: 'https://yourapp.example.com/email-changed',
            handleCodeInApp: true,
            androidPackageName: 'com.example.app',
            androidInstallApp: true,
            androidMinimumVersion: '21',
            iOSBundleId: 'com.example.app',
          );
          await _user!.verifyBeforeUpdateEmail(newEmail, action);
          sentVerification = true;
        } else if (ok.error != null) {
          Get.snackbar('Error', ok.error!, snackPosition: SnackPosition.BOTTOM);
        }
      }

      // Wait for batched Auth updates
      if (futures.isNotEmpty) {
        await Future.wait(futures);
        await _user!.reload();
        _user = fb.FirebaseAuth.instance.currentUser;
      }

      // 4) Mirror to Firestore (optional)
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
        'firstName': _first.text.trim(),
        'lastName': _last.text.trim(),
        'displayName': dn,
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'company': _company.text.trim(),
        'address': _address.text.trim(),
        'photoURL': uploadedUrl ?? _photoUrl ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (sentVerification) {
        Get.snackbar(
          'Verify your new email',
          'We sent a confirmation link to $newEmail. The change applies after you confirm.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar('Profile updated', 'Your changes were saved.',
            snackPosition: SnackPosition.BOTTOM);
      }

      Get.back(id: 2, result: true);
    } catch (e) {
      _error = 'Save failed: $e';
      Get.snackbar('Error', _error!, snackPosition: SnackPosition.BOTTOM);
      setState(() {});
    } finally {
      setState(() => _saving = false);
    }
  }

  /* ------------------------ Re-auth helper dialog ------------------------ */

  Future<_ReauthResult> _reauthenticateDialog(BuildContext context,
      {required String title, required String message}) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (ok != true) return _ReauthResult(false, error: 'Cancelled');

    try {
      final email = _user?.email;
      if (email == null || email.isEmpty) {
        return _ReauthResult(false, error: 'No email on account to re-authenticate.');
      }
      final cred = fb.EmailAuthProvider.credential(email: email, password: ctrl.text);
      await _user!.reauthenticateWithCredential(cred);
      return _ReauthResult(true);
    } catch (e) {
      return _ReauthResult(false, error: e.toString());
    }
  }
}

/* ---------------------------- UI Pieces ---------------------------- */

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFEF4444) : const Color(0xFF111827);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

/* ----------------------------- Small model ----------------------------- */
class _ReauthResult {
  final bool ok;
  final String? error;
  _ReauthResult(this.ok, {this.error});
}
