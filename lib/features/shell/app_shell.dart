// lib/features/shell/app_shell.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../dashboard/screens/dashboard_screen.dart';
import '../profile/screens/profile_view_screen.dart';
import '../notifications/controllers/notifications_controller.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.put(_ShellController());

    if (!Get.isRegistered<NotificationsController>()) {
      Get.put<NotificationsController>(NotificationsController(), permanent: true);
    }

    return Obx(() => Scaffold(
      body: IndexedStack(
        index: shell.index.value,
        children: const [
          DashboardScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: shell.index.value,
        onTap: shell.change,
      ),
    ));
  }
}

class _ShellController extends GetxController {
  final index = 0.obs;
  void change(int i) => index.value = i;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final notif = Get.find<NotificationsController>();

    return Obx(() {
      final unread = notif.unreadCount.value;
      return BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF6B7280),
        items: [
          BottomNavigationBarItem(
            icon: _NavIconWithBadge(
              icon: Iconsax.home_1,
              showBadge: unread > 0,
              label: unread > 99 ? '99+' : '$unread',
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Iconsax.user),
            label: 'Profile',
          ),
        ],
      );
    });
  }
}

class _NavIconWithBadge extends StatelessWidget {
  const _NavIconWithBadge({required this.icon, required this.showBadge, this.label});
  final IconData icon;
  final bool showBadge;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (showBadge)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                label ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}
