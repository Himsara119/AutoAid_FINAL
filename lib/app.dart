// lib/app.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/general_bindings.dart';

// Auth + shell
import 'features/auth/screens/login_screen.dart';
import 'features/shell/app_shell.dart';

// Home tab content
import 'features/dashboard/screens/dashboard_screen.dart';

// Profile tab content
import 'features/profile/screens/profile_view_screen.dart';

// Quick actions / other flows
import 'features/ai/screens/ai_scan_screen.dart';                  // VisualScanScreen
import 'features/vehicles/screens/add_vehicle_screen.dart';       // AddVehicleScreen
import 'features/reports/screens/report_builder_screen.dart';     // ReportBuilderScreen
import 'features/mechanics/screens/mechanic_map_screen.dart';     // MechanicMapScreen

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: GeneralBindings(),
      title: 'FinalApp',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      // Start at login. After success, navigate to `/app`.
      initialRoute: '/login',

      // IMPORTANT: do NOT make this list const
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),

        // The shell owns the bottom nav and switches tabs internally.
        GetPage(name: '/app', page: () => const AppShell()),

        // If you ever deep-link directly into a tab’s screen, keep these:
        GetPage(name: '/dashboard', page: () => const DashboardScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),

        // Quick actions / extra routes
        GetPage(name: '/visual-scan', page: () => const VisualScanScreen()),
        GetPage(name: '/add-vehicle', page: () => const AddVehicleScreen()),
        GetPage(name: '/report-builder', page: () => const ReportBuilderScreen()),
        GetPage(name: '/mechanic-finder', page: () => const FindMechanicScreen()),
      ],
    );
  }
}
