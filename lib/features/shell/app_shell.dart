// lib/features/shell/app_shell.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// Tabs
import '../dashboard/screens/dashboard_screen.dart';
import '../profile/screens/profile_view_screen.dart';

// Profile sub-screens that must be reachable inside the Profile tab
import '../profile/screens/profile_edit_screen.dart';
import '../profile/screens/about_screen.dart';
import '../profile/screens/help_screen.dart';

// Global alerts badge source
import '../notifications/controllers/alerts_controller.dart';

// Route names
import '../../app.dart' show Routes;

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.put(_ShellController());

    // Register global alerts controller once
    if (!Get.isRegistered<AlertsController>()) {
      Get.put<AlertsController>(AlertsController(), permanent: true);
    }

    return Obx(
          () => Scaffold(
        body: IndexedStack(
          index: shell.index.value,
          children: const [
            _HomeTabNavigator(key: PageStorageKey('tab_home')),
            _ProfileTabNavigator(key: PageStorageKey('tab_profile')),
          ],
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: shell.index.value,
          onTap: shell.change,
        ),
      ),
    );
  }
}

/* --------------------------- Nested Navigators --------------------------- */

class _HomeTabNavigator extends StatelessWidget {
  const _HomeTabNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    // Home can stay on GetNavigator; it uses global routing for deep pages.
    // If you later see similar "onGenerateRoute" issues for Home, mirror the
    // Profile pattern here with a custom Navigator and switch.
    return GetNavigator(
      key: Get.nestedKey(1),
      pages: [
        GetPage(
          name: Routes.app,
          page: () => const DashboardScreen(),
        ),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }
}

class _ProfileTabNavigator extends StatelessWidget {
  const _ProfileTabNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a real Navigator with an onGenerateRoute that knows the profile routes.
    // This fixes: "Navigator.onGenerateRoute was null, but the route named '/profileEdit' was referenced."
    return Navigator(
      key: Get.nestedKey(2),
      initialRoute: Routes.profile,
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case Routes.profile:
            page = const ProfileScreen();
            break;

          case Routes.editProfile:
            page = const EditProfileScreen();
            break;

          case Routes.about:
            page = const AboutScreen();
            break;

          case Routes.help:
            page = const HelpSupportScreen();
            break;

          default:
          // Fallback: go back to profile root if someone fat-fingers a route
            page = const ProfileScreen();
        }

        return GetPageRoute(
          settings: settings,
          page: () => page,
          routeName: settings.name,
          transition: Transition.cupertino,
        );
      },
    );
  }
}

/* ------------------------------- Controller ------------------------------ */

class _ShellController extends GetxController {
  final index = 0.obs;
  void change(int i) => index.value = i;
}

/* --------------------------------- NavBar -------------------------------- */

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final alerts = Get.find<AlertsController>();

    return Obx(() {
      final unread = alerts.unreadCount.value;
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
  const _NavIconWithBadge({
    required this.icon,
    required this.showBadge,
    this.label,
  });

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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}

/* --------------------------------- Usage --------------------------------- */
/*
Push from DASHBOARD (Home tab) with id: 1:
  Get.toNamed(Routes.vehicleadd, id: 1);
  Get.toNamed(Routes.visualScan, id: 1);
  Get.toNamed(Routes.reportBuilder, id: 1, arguments: {'vehicleId': null});
  Get.toNamed(Routes.mechanicFinder, id: 1);
  Get.toNamed(Routes.vehiclelist, id: 1, parameters: {'filter': 'All'});

Push from PROFILE tab with id: 2:
  Get.toNamed(Routes.editProfile, id: 2);
  Get.toNamed(Routes.about, id: 2);
  Get.toNamed(Routes.help, id: 2);

Do not offAll back to dashboard after add/edit flows. Just Get.back().
*/
