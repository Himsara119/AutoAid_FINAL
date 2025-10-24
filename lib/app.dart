// lib/app.dart
import 'package:finalapp/features/profile/screens/about_screen.dart';
import 'package:finalapp/features/profile/screens/help_screen.dart';
import 'package:finalapp/features/profile/screens/profile_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Global bindings
import 'bindings/general_bindings.dart';

// Auth + shell
import 'features/auth/screens/login_screen.dart';
import 'features/shell/app_shell.dart';

// Core feature screens
import 'features/profile/screens/profile_view_screen.dart';
import 'features/vehicles/screens/vehicles_list_screen.dart';

// Quick actions / other flows
import 'features/ai/screens/ai_chat_screen.dart';            // AI Assistant
import 'features/ai/screens/ai_scan_screen.dart';            // Visual Scan
import 'features/vehicles/screens/add_vehicle_screen.dart';  // Add Vehicle
import 'features/reports/screens/report_builder_screen.dart'; // Report Builder
import 'features/mechanics/screens/mechanic_map_screen.dart'; // Find Mechanic

/* ------------------------------- MAIN APP ------------------------------- */

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: GeneralBindings(),
      title: 'FinalApp',

      defaultTransition: Transition.cupertino, // choose any style you want
      transitionDuration: const Duration(milliseconds: 400),

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          primary: AppColors.blue,
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 26),
          titleLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, height: 1.4),
          labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      // Load shell with bottom navigation as the entry point
      //Call the page here to test page
      initialRoute: Routes.vehiclelist,

      getPages: AppPages.pages,
    );
  }
}

/* ------------------------------- ROUTES -------------------------------- */

class Routes {
  static const login = '/login';
  static const app = '/app';
  static const profile = '/profile';
  static const addVehicle = '/add-vehicle';
  static const visualScan = '/visual-scan';
  static const reportBuilder = '/report-builder';
  static const mechanicFinder = '/mechanic-finder';
  static const aiScreen = '/aiscreen';
  static const vehicleadd = '/vehicleadd';
  static const vehiclelist = '/vehiclelist';

  //Randiya UI's To Call
  static const about = '/about';
  static const profileEdit = '/profileEdit';
  static const helpscreen = '/helpscreen';
  static const profileTab = '/profileTab';
}

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.about,
      page: () => const AboutScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.profileEdit,
      page: () => const EditProfileScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.helpscreen,
      page: () => const HelpSupportScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.profileTab,
      page: () => const ProfileScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.vehicleadd,
      page: () => const AddVehicleScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.vehiclelist,
      page: () => const VehiclesScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.app,
      page: () => const AppShell(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.addVehicle,
      page: () => const VehiclesScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.visualScan,
      page: () => const VisualScanScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.reportBuilder,
      page: () => const ReportBuilderScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.mechanicFinder,
      page: () => const FindMechanicScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.aiScreen,
      page: () => const AiDiagnosisChatScreen(),
      transition: Transition.cupertino,
    ),
  ];
}

/* ------------------------------- COLORS -------------------------------- */

class AppColors {
  static const blue = Color(0xFF2563EB);
  static const blueLight = Color(0xFFEFF4FF);
  static const tileBg = Color(0xFFFFFFFF);
  static const border = Color(0xFFE6E8ED);
  static const success = Color(0xFF16A34A);
  static const successBg = Color(0xFFEFFAF3);
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFFFFF7E8);
  static const danger = Color(0xFFEF4444);
  static const dangerBg = Color(0xFFFFEEEE);
  static const info = Color(0xFF2563EB);
  static const infoBg = Color(0xFFEFF4FF);
  static const muted = Color(0xFF6B7280);
}
