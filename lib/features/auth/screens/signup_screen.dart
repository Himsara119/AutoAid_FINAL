// lib/features/auth/ui/signup_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(SignUpController());
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // subtle gradient like the mock
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF0ECFF), Color(0xFFF7F9FF)],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withOpacity(0.25),
                              offset: const Offset(0, 12),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Create\nAccount',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.1),
                      ),
                      const SizedBox(height: 8),
                      const Text('Sign up to get started', style: TextStyle(color: Color(0xFF6B7280))),
                      const SizedBox(height: 20),

                      // Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 10)),
                          ],
                        ),
                        child: Form(
                          key: c.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _LabeledField(
                                label: 'First Name',
                                child: TextFormField(
                                  controller: c.firstName,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your first name',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'First name is required' : null,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _LabeledField(
                                label: 'Last Name',
                                child: TextFormField(
                                  controller: c.lastName,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your last name',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _LabeledField(
                                label: 'Email',
                                child: TextFormField(
                                  controller: c.email,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your email',
                                    prefixIcon: Icon(Icons.email_outlined),
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
                              const SizedBox(height: 12),
                              _LabeledField(
                                label: 'Password',
                                child: Obx(() => TextFormField(
                                  controller: c.password,
                                  obscureText: c.hidePass.value,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    hintText: 'Create a password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                          c.hidePass.value ? Icons.visibility_off : Icons.visibility),
                                      onPressed: c.togglePass,
                                    ),
                                  ),
                                  validator: (v) =>
                                  (v == null || v.length < 6) ? 'Use at least 6 characters' : null,
                                )),
                              ),
                              const SizedBox(height: 12),
                              _LabeledField(
                                label: 'Confirm Password',
                                child: Obx(() => TextFormField(
                                  controller: c.confirmPassword,
                                  obscureText: c.hideConfirm.value,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    hintText: 'Confirm your password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(c.hideConfirm.value
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: c.toggleConfirm,
                                    ),
                                  ),
                                  validator: (v) =>
                                  v != c.password.text ? 'Passwords do not match' : null,
                                )),
                              ),
                              const SizedBox(height: 8),
                              Obx(() => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: c.agree.value,
                                    onChanged: (v) => c.agree.value = v ?? false,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                            color: Color(0xFF4B5563), fontSize: 13),
                                        children: [
                                          const TextSpan(text: 'I agree to the '),
                                          TextSpan(
                                            text: 'Terms of Service',
                                            style: const TextStyle(
                                              color: Color(0xFF2563EB),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            recognizer: TapGestureRecognizer()..onTap = c.openTerms,
                                          ),
                                          const TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: const TextStyle(
                                              color: Color(0xFF2563EB),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = c.openPrivacy,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: scheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                  onPressed: c.submit,
                                  child: const Text('Sign Up',
                                      style:
                                      TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ',
                              style: TextStyle(color: Color(0xFF6B7280))),
                          TextButton(
                            onPressed: () {
                              // Change this to your route name
                              Get.toNamed('/login');
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('or continue with',
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialIconButton(
                            child: const Icon(Icons.g_mobiledata, size: 28),
                            onTap: () => Get.snackbar('Google', 'Hook this to Google Sign-In'),
                          ),
                          const SizedBox(width: 16),
                          _SocialIconButton(
                            child: const Icon(Icons.apple, size: 24),
                            onTap: () => Get.snackbar('Apple', 'Hook this to Apple Sign-In'),
                          ),
                          const SizedBox(width: 16),
                          _SocialIconButton(
                            child: const Icon(Icons.facebook, size: 24),
                            onTap: () => Get.snackbar('Facebook', 'Hook this to Facebook Login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SignUpController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  final hidePass = true.obs;
  final hideConfirm = true.obs;
  final agree = false.obs;

  void togglePass() => hidePass.value = !hidePass.value;
  void toggleConfirm() => hideConfirm.value = !hideConfirm.value;

  void openTerms() {
    // TODO: open your Terms URL
  }

  void openPrivacy() {
    // TODO: open your Privacy URL
  }

  Future<void> submit() async {
    final valid = formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (!agree.value) {
      Get.snackbar('Hold up', 'Please accept the Terms and Privacy Policy');
      return;
    }
    final repo = Get.find<AuthenticationRepository>();

    try {
      Get.focusScope?.unfocus();
      // If your repo uses a different method name, change this one line:
      await repo.registerWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
      );
      Get.snackbar('Success', 'Account created');
      // Navigate to home or email verification
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Signup failed', e.toString());
    }
  }

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            )),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _SocialIconButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 54,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: child,
        ),
      ),
    );
  }
}
