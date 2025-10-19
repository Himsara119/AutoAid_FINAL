import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(_CheckEmailController(email));
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Green success badge
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFFAF3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.tick_circle, color: Color(0xFF16A34A), size: 32),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Check Your Email',
                    style: t.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Description (verification, not password reset)
                  Text(
                    'A verification email has been sent to your address.\n'
                        'Please check your inbox and tap the link to verify.',
                    style: t.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // Back to Login (primary)
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.offAllNamed('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Back to Login',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /*// Resend Verification (secondary)
                  Obx(() => TextButton(
                    onPressed: (c.loading.value || c.cooldown.value > 0)
                        ? null
                        : c.resendVerificationEmail,
                    child: c.loading.value
                        ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(
                      c.cooldown.value > 0
                          ? 'Resend in ${c.cooldown.value}s'
                          : 'Resend Email',
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),*/

                  const SizedBox(height: 24),

                  // Footer hint
                  Text(
                    "Didn't receive the email? Check your spam folder or try again.",
                    style: t.bodySmall?.copyWith(color: const Color(0xFF9CA3AF), height: 1.35),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckEmailController extends GetxController {
  _CheckEmailController(this.email);
  final String email;

  final loading = false.obs;
  final cooldown = 0.obs;

  /// Resends a **verification** email (not password reset).
  /// Requires the user to still be signed in.
  Future<void> resendVerificationEmail() async {
    try {
      loading.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // If you sign out after signup, this will be null. Warn and send them to login.
        Get.snackbar('Not signed in', 'Please login to resend the verification email.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      await user.sendEmailVerification();
      Get.snackbar('Sent', 'Another verification email was sent to $email.',
          snackPosition: SnackPosition.BOTTOM);

      // Cooldown disables the button without showing the spinner
      await _startCooldown(45);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Resend failed', e.message ?? 'Could not resend.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      // Spinner stops after the network call; button stays disabled by cooldown.
      loading.value = false;
    }
  }

  Future<void> _startCooldown(int seconds) async {
    cooldown.value = seconds;
    while (cooldown.value > 0) {
      await Future.delayed(const Duration(seconds: 1));
      cooldown.value--;
    }
  }
}
