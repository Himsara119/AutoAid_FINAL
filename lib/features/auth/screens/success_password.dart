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
                  // success chip
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFFAF3), // light green
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.tick_circle, color: Color(0xFF16A34A), size: 32),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Check Your Email',
                    style: t.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  Text(
                    'Password reset email has been sent to\n'
                        'your email address. Please check your inbox and follow\n'
                        'the instructions.',
                    style: t.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(), // back to Login
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED), // purple
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Obx(() => TextButton(
                    onPressed: c.loading.value ? null : c.resendEmail,
                    child: c.loading.value
                        ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text(
                      'Resend Email',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),

                  const SizedBox(height: 24),

                  Text(
                    "Didn't receive the email? Check your spam\nfolder or try again.",
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

  Future<void> resendEmail() async {
    try {
      loading.value = true;
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      Get.snackbar('Email sent', 'Another password reset link was sent to $email.',
          snackPosition: SnackPosition.BOTTOM);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Resend failed', e.message ?? 'Could not resend the email.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Resend failed', 'Something went wrong. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      loading.value = false;
    }
  }
}
