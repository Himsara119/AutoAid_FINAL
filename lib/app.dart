// lib/app.dart
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Screens
import 'package:finalapp/features/notifications/screens/notifications_screen.dart';
import 'package:finalapp/features/profile/screens/about_screen.dart';
import 'package:finalapp/features/profile/screens/help_screen.dart';
import 'package:finalapp/features/profile/screens/profile_edit_screen.dart';
import 'package:finalapp/features/vehicles/tabs/reports_tab.dart';
import 'package:finalapp/features/vehicles/screens/add_vehicle_screen.dart';
import 'package:finalapp/features/vehicles/screens/vehicle_detail_screen.dart';
import 'package:finalapp/features/vehicles/screens/vehicles_list_screen.dart';
import 'package:finalapp/features/vehicles/tabs/overview_tab.dart';
import 'package:finalapp/features/services/presentation/service_detail_screen.dart';

// Global bindings
import 'bindings/general_bindings.dart';

// Auth + shell
import 'features/ai/bindings/chat_binding.dart';
import 'features/ai/bindings/visual_scan_binding.dart';
import 'features/ai/screens/ai_chat_screen.dart';
import 'features/ai/screens/ai_scan_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/documents/screens/doc_detail_screen.dart';
import 'features/mechanics/screens/mechanic_map_screen.dart';
import 'features/profile/screens/profile_view_screen.dart';
import 'features/reports/screens/report_builder_screen.dart';
import 'features/reports/screens/report_preview_screen.dart';
import 'features/shell/app_shell.dart';

// Controller for binding
import 'features/vehicles/controllers/vehicle_detail_controller.dart';

/* ------------------------------- MAIN APP ------------------------------- */

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: GeneralBindings(),
      title: 'FinalApp',

      defaultTransition: Transition.cupertino,
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

      // Do NOT start on a route that needs params
      initialRoute: Routes.login,

      getPages: AppPages.pages,

      // If someone fat-fingers a route name, don’t crash the app
      unknownRoute: GetPage(
        name: '/404',
        page: () => Scaffold(
          appBar: AppBar(title: const Text('Not Found')),
          body: const Center(child: Text('Route not found')),
        ),
      ),
    );
  }
}

/* ------------------------------- ROUTES -------------------------------- */

class Routes {
  static const login = '/login';
  static const app = '/app';
  static const profile = '/profile';         // profile view as standalone
  static const profileTab = '/profileTab';   // alias, same screen

  static const addVehicle = '/add-vehicle';  // alias -> list (kept for backward compat)
  static const vehicleadd = '/vehicleadd';   // actual add vehicle screen
  static const vehiclelist = '/vehiclelist';
  static const vehicleDetails = '/vehicleDetails';

  static const visualScan = '/visual-scan';
  static const reportBuilder = '/report-builder';
  static const reportScreen = '/reportScreen';

  static const mechanicFinder = '/mechanic-finder';
  static const serviceDetail = '/serviceDetail';
  static const notifications = '/notifications';
  static const documentdetail = '/documentdetail';

  // Profile subroutes
  static const about = '/about';
  static const editProfile = '/profileEdit';
  static const help = '/helpscreen';

  // AI
  static const chat = '/chat';
  static const aiScreen = '/aiscreen';
}

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: Routes.documentdetail,
      page: () {
        final args = Get.arguments is Map ? Get.arguments as Map : const {};
        final vehicleId = args['vehicleId']?.toString() ?? '';
        final documentId = args['documentId']?.toString() ?? '';
        return DocumentDetailScreen(
          vehicleId: vehicleId,
          documentId: documentId,
        );
      },
      transition: Transition.cupertino,
    ),

    GetPage(
      name: Routes.notifications,
      page: () => const NotificationsScreen(),
      transition: Transition.cupertino,
    ),

    // Service detail: requires vehicleId, and either serviceId or a record
    GetPage(
      name: Routes.serviceDetail,
      page: () {
        final p = Get.parameters;
        final a = Get.arguments;

        String? vehicleId = p['vehicleId'] ?? (a is Map ? a['vehicleId'] as String? : null);
        final String? serviceId = p['serviceId'] ?? (a is Map ? a['serviceId'] as String? : null);
        final dynamic record = (a is Map) ? a['record'] : null;

        if ((vehicleId == null || vehicleId.isEmpty) && record != null) {
          try {
            vehicleId = record.vehicleId as String?;
          } catch (_) {
            // ignore; assert below will handle
          }
        }

        assert(vehicleId != null && vehicleId!.isNotEmpty, 'vehicleId is required');
        assert(serviceId != null && serviceId.isNotEmpty || record != null,
        'Provide either serviceId or record for ServiceDetailScreen');

        return ServiceDetailScreen(
          vehicleId: vehicleId!,
          serviceId: serviceId,
          record: record,
        );
      },
      transition: Transition.cupertino,
    ),

    // Condition Report screen
    GetPage(
      name: Routes.reportScreen,
      page: () {
        final p = Get.parameters;
        final a = Get.arguments;

        final String? vehicleId =
            p['vehicleId'] ?? (a is Map ? a['vehicleId'] as String? : null);
        final String? reportId =
            p['reportId'] ?? (a is Map ? a['reportId'] as String? : null);

        assert(vehicleId != null && vehicleId!.isNotEmpty,
        'vehicleId is required for ConditionReportScreen');
        assert(reportId != null && reportId!.isNotEmpty,
        'reportId is required for ConditionReportScreen');

        return ConditionReportScreen(
          vehicleId: vehicleId!,
          reportId: reportId!,
        );
      },
      transition: Transition.cupertino,
    ),

    // AI chat route
    GetPage(
      name: Routes.chat,
      page: () => const AiDiagnosisChatScreen(),
      binding: ChatBinding(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: Routes.about,
      page: () => const AboutScreen(),
      transition: Transition.cupertino,
    ),

    // Vehicle details with bound controller
    GetPage(
      name: Routes.vehicleDetails,
      page: () => const VehicleDetailsScreen(),
      binding: BindingsBuilder(() {
        final id = Get.parameters['id'] ?? (Get.arguments as String?);
        assert(id != null && id!.isNotEmpty, 'Vehicle id missing');
        Get.lazyPut(() => VehicleDetailController(id!), tag: id, fenix: false);
        dev.log('Route bind → vehicle id=$id', name: 'Routes');
      }),
      transition: Transition.cupertino,
    ),

    // Profile subroutes
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfileScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.help,
      page: () => const HelpSupportScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.profileTab,
      page: () => const ProfileScreen(),
      transition: Transition.cupertino,
    ),

    // Vehicles
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

    // Shell with bottom nav + nested navigators
    GetPage(
      name: Routes.app,
      page: () => const AppShell(),
      transition: Transition.cupertino,
    ),

    // Standalone profile route alias (same screen as profileTab)
    GetPage(
      name: Routes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.cupertino,
    ),

    // Historical alias: points to list screen per your previous setup
    GetPage(
      name: Routes.addVehicle,
      page: () => const VehiclesScreen(),
      transition: Transition.cupertino,
    ),

    // Visual Scan
    GetPage(
      name: Routes.visualScan,
      page: () => const VisualScanScreen(),
      binding: VisualScanBinding(),
      transition: Transition.cupertino,
    ),

    // Report Builder: optional vehicleId
    GetPage(
      name: Routes.reportBuilder,
      page: () {
        final p = Get.parameters;
        final a = Get.arguments;

        final String? vehicleId =
            p['vehicleId'] ?? (a is Map ? a['vehicleId'] as String? : a as String?);

        return ReportBuilderScreen(vehicleId: vehicleId);
      },
      transition: Transition.cupertino,
    ),

    GetPage(
      name: Routes.mechanicFinder,
      page: () => const FindMechanicScreen(),
      transition: Transition.cupertino,
    ),

    // AI alias
    GetPage(
      name: Routes.aiScreen,
      page: () => const AiDiagnosisChatScreen(),
      binding: ChatBinding(),
      transition: Transition.cupertino,
    ),
  ];
}

/* ------------------------------- COLORS -------------------------------- */

class AppColors {
  static const blue = Color(0xFF2563EB);
  static const purple = Color(0xFF800080);
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
}
