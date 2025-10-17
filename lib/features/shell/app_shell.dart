import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// your two tabs
import '../dashboard/screens/dashboard_screen.dart';
import '../profile/screens/profile_view_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(_ShellController());
    final t = Theme.of(context).textTheme;

    return Obx(() => Scaffold(
      body: IndexedStack(
        index: c.index.value,
        children: const [
          DashboardScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: c.index.value,
        onTap: c.change,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF6B7280),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home_1),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.user),
            label: 'Profile',
          ),
        ],
      ),
    ));
  }
}

class _ShellController extends GetxController {
  final index = 0.obs;
  void change(int i) => index.value = i;
}
