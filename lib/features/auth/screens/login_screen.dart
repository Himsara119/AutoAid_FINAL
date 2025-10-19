// lib/features/auth/ui/login_screen.dart
import 'package:finalapp/features/auth/screens/success_password.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'forget_password_screen.dart';
import '../../auth/screens/signup_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(_LoginController(), permanent: true);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: c.formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                const _LogoTile(),
                const SizedBox(height: 16),
                Text('Welcome Back', style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Sign in to continue', style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
                const SizedBox(height: 26),

                const _FieldLabel('Email'),
                TextFormField(
                  controller: c.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.direct_right),
                    hintText: 'Enter your email',
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

                const _FieldLabel('Password'),
                Obx(() => TextFormField(
                  controller: c.password,
                  obscureText: c.hidePass.value,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => c.submit(),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.password_check),
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      onPressed: c.togglePass,
                      icon: Icon(c.hidePass.value ? Iconsax.eye_slash : Iconsax.eye),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Min 6 characters';
                    return null;
                  },
                )),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Row(children: [
                      Checkbox(
                        value: c.rememberMe.value,
                        onChanged: (v) => c.rememberMe.value = v ?? false,
                      ),
                      const Text('Remember me'),
                    ])),
                    TextButton(
                      onPressed: () => Get.to(() => const ForgetPasswordScreen()),
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: c.loading.value ? null : c.submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    child: c.loading.value
                        ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Sign In'),
                  ),
                )),

                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 0),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account?', style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
                    TextButton(
                      onPressed: () => Get.to(() => const SignUpScreen()),
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================== CONTROLLER ============================== */

class _LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  final hidePass = true.obs;
  final loading = false.obs;
  final rememberMe = true.obs;

  AuthenticationRepository get repo => Get.find<AuthenticationRepository>();

  void togglePass() => hidePass.value = !hidePass.value;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      loading.value = true;
      Get.focusScope?.unfocus();

      await repo.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      // If we got here, user is verified and logged in
      Get.offAll(() => const DashboardScreen(),
          transition: Transition.fadeIn, duration: const Duration(milliseconds: 250));
    } catch (e) {
      // If repo throws 'email-not-verified', show UX and route to CheckEmailScreen
      final msg = e.toString();
      if (msg.contains('email-not-verified')) {
        Get.snackbar('Email not verified', 'We sent you another verification email.',
            snackPosition: SnackPosition.BOTTOM);
        // Repo signs the user out on unverified; show static email screen
        Get.off(() => CheckEmailScreen(email: email.text.trim()),
            transition: Transition.fadeIn, duration: const Duration(milliseconds: 250));
      } else {
        Get.snackbar('Login failed', msg, snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}

/* ============================== WIDGETS ============================== */

class _LogoTile extends StatelessWidget {
  const _LogoTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Iconsax.user, color: Colors.white, size: 40),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1F2937)),
        ),
      ),
    );
  }
}
