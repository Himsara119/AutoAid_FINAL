import 'package:finalapp/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:iconsax/iconsax.dart';

import 'forget_password_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FinalApp());
}

class FinalApp extends StatelessWidget {
  const FinalApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF7C4DFF); // your purple
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinalApp',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 1.4),
          ),
        ),
      ),
      home: const LoginScreen(), // start here
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _obscure = ValueNotifier<bool>(true);
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _obscure.dispose();
    super.dispose();
  }

  void _snack(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  void _onSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      _snack('Sign in Successful', bg: Colors.green.shade600);
      // Push dashboard (keeps back stack)
      Get.to(() => const DashboardScreen());
      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DashboardDemo()));
    }
  }

  @override
  Widget build(BuildContext context) {
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
            key: _formKey,
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
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.direct_right),
                    hintText: 'Enter your email',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                const _FieldLabel('Password'),
                ValueListenableBuilder<bool>(
                  valueListenable: _obscure,
                  builder: (_, obs, __) {
                    return TextFormField(
                      controller: _passCtrl,
                      obscureText: obs,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Iconsax.password_check),
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          onPressed: () => _obscure.value = !obs,
                          icon: Icon(obs ? Iconsax.eye_slash : Iconsax.eye),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        if (v.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    );
                  },
                ),

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                      ),
                      const Text('Remember me'),
                    ]),
                    TextButton(
                      onPressed: () => Get.to(() => const ForgetPasswordScreen()),
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _PrimaryButton(text: 'Sign In', onPressed: _onSignIn),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                //_OutlineButton(
                  //text: 'Continue with Google',
                  //onPressed: () => _snack('Google Sign-In tapped'),
                  //icon: const _GoogleG(),
                //),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account?', style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
                    TextButton(
                      onPressed: () => _snack('Sign up tapped'),
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

/* ============================== WIDGETS BELOW ============================== */

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

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Text(text),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget? icon;
  const _OutlineButton({required this.text, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: 8)],
        Text(text),
      ],
    );

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: const BorderSide(color: Color(0xFFE6E6E6)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          foregroundColor: const Color(0xFF111827),
          backgroundColor: Colors.white,
        ),
        child: row,
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    const line = Expanded(child: Divider(thickness: 1, color: Color(0xFFE6E6E6)));
    return const Row(children: [line, Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('or')), line]);
  }
}

class _GoogleG extends StatelessWidget {
  const _GoogleG();
  @override
  Widget build(BuildContext context) {
    return const Text('G', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFDB4437)));
  }
}
