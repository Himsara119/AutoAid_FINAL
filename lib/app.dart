import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

import 'bindings/general_bindings.dart';
import 'features/ai/screens/ai_scan_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/mechanics/screens/mechanic_map_screen.dart';
import 'features/profile/screens/profile_view_screen.dart';
import 'features/reports/screens/report_builder_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/vehicles/screens/add_vehicle_screen.dart';

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

      // Global animation setup
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      // Pages
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/app', page: () => const AppShell()),
        GetPage(name: '/dashboard', page: () => const DashboardScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
        GetPage(name: '/visual-scan', page: () => const VisualScanScreen()),
        GetPage(name: '/add-vehicle', page: () => const AddVehicleScreen()),
        GetPage(name: '/report-builder', page: () => const ReportBuilderScreen()),
        GetPage(name: '/mechanic-finder', page: () => const FindMechanicScreen()),
      ],
    );
  }
}
