// lib/features/auth/ui/forget_password_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(_ForgetPasswordController());
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // very light lilac background like your mock
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF2EDFF), Color(0xFFF8F9FF)],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back to Login (top-left)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      foregroundColor: const Color(0xFF111827),
                    ),
                    onPressed: () => Get.back(),
                    icon: const Icon(Iconsax.arrow_left_2, size: 18),
                    label: const Text('Back to Login'),
                  ),
                ),

                // Center the card vertically
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE6E8ED)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 24,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // top icon chip
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: scheme.primary.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Iconsax.key, color: scheme.primary, size: 26),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Forgot Password?',
                              style: t.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "we'll send you reset instructions\n"
                                  "to your email address.",
                              textAlign: TextAlign.center,
                              style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280), height: 1.35),
                            ),
                            const SizedBox(height: 18),

                            // form
                            Form(
                              key: c.formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Email Address',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: c.email,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your email address',
                                      // suffix icon on the RIGHT like your mock
                                      suffixIcon: const Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Icon(Iconsax.sms, size: 20),
                                      ),
                                      suffixIconConstraints:
                                      const BoxConstraints(minHeight: 20, minWidth: 20),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 16,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide:
                                        BorderSide(color: scheme.primary, width: 1.6),
                                      ),
                                    ),
                                    validator: (v) {
                                      final x = v?.trim() ?? '';
                                      final rx = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                                      if (x.isEmpty) return 'Email is required';
                                      if (!rx.hasMatch(x)) return 'Enter a valid email';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Obx(
                                        () => SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: c.loading.value ? null : c.sendResetLink,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF7C3AED), // purple like mock
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: c.loading.value
                                            ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                            : const Text(
                                          'Send Reset Link',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ForgetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final loading = false.obs;

  Future<void> sendResetLink() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      loading.value = true;
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email.text.trim());

      Get.snackbar(
        'Email sent',
        'Check your inbox for the reset link.',
        snackPosition: SnackPosition.BOTTOM,
      );

      await Future.delayed(const Duration(milliseconds: 5000));
      Get.back(); // back to Login
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Reset failed', e.message ?? 'Could not send reset email.');
    } catch (_) {
      Get.snackbar('Reset failed', 'Something went wrong. Try again.');
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    email.dispose();
    super.onClose();
  }
}

