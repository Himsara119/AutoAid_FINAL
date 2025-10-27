// lib/features/profile/ui/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// Route constants you already expose from app.dart
import '../../../app.dart' show Routes;

// Live user info from Firebase Auth
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller exists (safe even if already registered elsewhere)
    final p = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);

    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.profile_circle,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final name = (p.displayName.value.isNotEmpty)
                            ? p.displayName.value
                            : 'John Anderson';
                        final email = (p.email.value.isNotEmpty)
                            ? p.email.value
                            : 'john.anderson@email.com';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Profile section
              _SectionCard(
                title: 'Profile',
                children: [
                  _NavTile(
                    iconBg: const Color(0xFFEFF4FF),
                    icon: Iconsax.user_edit,
                    label: 'Edit Profile',
                    onTap: () => _nav(Routes.editProfile, id: 2)
                        .then((_) => p.refreshFromAuth()),
                  ),
                ],
              ),

              // Info section (About + Help)
              _SectionCard(
                title: 'Information',
                children: [
                  _NavTile(
                    iconBg: const Color(0xFFEFF1F5),
                    icon: Iconsax.info_circle,
                    label: 'About',
                    onTap: () => _nav(Routes.about, id: 2),
                  ),
                  _NavTile(
                    iconBg: const Color(0xFFE6FFFB),
                    icon: Iconsax.support,
                    iconColor: const Color(0xFF06B6D4),
                    label: 'Help',
                    onTap: () => _nav(Routes.help, id: 2),
                  ),
                ],
              ),

              // Logout card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE6E8ED)),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 48,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF0F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _logout(p),
                    icon: const Icon(Iconsax.logout, color: Color(0xFFEF4444)),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ------------------------------- Helpers ------------------------------- */

// Normalize Get.toNamed’s nullable Future so callers can safely `.then(...)`
Future<T?> _nav<T>(String route, {int? id}) {
  final fut = Get.toNamed<T>(route, id: id); // Future<T?>?
  return fut ?? Future<T?>.value(null);
}

Future<void> _logout(ProfileController p) async {
  try {
    await p.signOut();
  } catch (_) {
    // even if sign-out hiccups, we still punt them to login
  }
  Get.offAllNamed(Routes.login);
}

/* ------------------------------- Widgets ------------------------------- */

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Text(
              title,
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F2F5)),
          ..._intersperse(
            children,
            const Divider(height: 1, color: Color(0xFFF0F2F5)),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.iconBg,
    required this.icon,
    required this.label,
    this.iconColor = const Color(0xFF111827),
    this.onTap,
  });

  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Iconsax.arrow_right_3, color: Color(0xFF9CA3AF), size: 18),
          ],
        ),
      ),
    );
  }
}

/* ----------------------------- tiny util ----------------------------- */
List<Widget> _intersperse(List<Widget> list, Widget separator) {
  if (list.isEmpty) return list;
  return [
    for (int i = 0; i < list.length; i++) ...[
      list[i],
      if (i != list.length - 1) separator,
    ]
  ];
}
