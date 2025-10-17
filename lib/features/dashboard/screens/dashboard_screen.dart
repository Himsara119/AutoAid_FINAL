import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// === Controller + Repo ===
import '../../../data/repositories/dashboard_repository.dart';
import '../controllers/dashboard_controller.dart';
// If your paths differ, fix the two imports above accordingly.

void main() {
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // ← use GetMaterialApp
      title: 'FinalApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
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
      home: const DashboardScreen(),
    );
  }
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

/* ----------------------------- DASHBOARD UI ----------------------------- */

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bind controller (fake repo for now; swap to your real repo later)
    final c = Get.put(DashboardController(FakeDashboardRepository()));
    final t = Theme.of(context).textTheme;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.blue,
        unselectedItemColor: AppColors.muted,
        items: const [
          BottomNavigationBarItem(icon: Icon(Iconsax.home_1), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // tiny loader at top of screen while fake repo resolves
          final loadingBar = c.isLoading.value
              ? const LinearProgressIndicator(minHeight: 2)
              : const SizedBox.shrink();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: loadingBar),

              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dashboard', style: t.headlineMedium),
                            const SizedBox(height: 6),
                            Text(
                              'Good morning, ${c.greetingName}',
                              style: t.bodyMedium?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      const CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                      ),
                    ],
                  ),
                ),
              ),

              // AI Assistant banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI Assistant',
                                  style: t.titleLarge?.copyWith(
                                      color: Colors.white, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text('How can I help you today?',
                                  style: t.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.9))),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(Iconsax.cpu, color: Colors.white, size: 26),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                  child: Text('Quick Actions', style: t.titleLarge),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 140,
                  ),
                  delegate: SliverChildListDelegate([
                    QuickActionCard(
                      iconBg: const Color(0xFFEFFAF3),
                      iconColor: AppColors.success,
                      icon: Iconsax.add_square,
                      title: 'Add Vehicle',
                      subtitle: 'Register new car',
                      onTap: c.addVehicle,
                    ),
                    QuickActionCard(
                      iconBg: const Color(0xFFEFF4FF),
                      iconColor: AppColors.blue,
                      icon: Iconsax.scan_barcode,
                      title: 'Visual Scan',
                      subtitle: 'Scan damage',
                      onTap: c.visualScan,
                    ),
                    QuickActionCard(
                      iconBg: const Color(0xFFF2F0FF),
                      iconColor: const Color(0xFF7C3AED),
                      icon: Iconsax.document_text,
                      title: 'Generate Report',
                      subtitle: 'Create analysis',
                      onTap: c.generateReport,
                    ),
                    QuickActionCard(
                      iconBg: const Color(0xFFFFF7E8),
                      iconColor: AppColors.warning,
                      icon: Iconsax.setting_4,
                      title: 'Find Mechanic',
                      subtitle: 'Locate service',
                      onTap: c.findMechanic,
                    ),
                  ]),
                ),
              ),

              // Vehicle Overview (KPIs from controller)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: Text('Vehicle Overview', style: t.titleLarge),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.tileBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Obx(() {
                      final items = c.kpis;
                      if (items.isEmpty) {
                        return const SizedBox(
                          height: 72,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: items
                            .map((k) => StatItem(
                          icon: k.icon,
                          label: k.label,
                          value: '${k.value}',
                          iconBg: k.iconBg,
                          iconColor: k.iconColor,
                        ))
                            .toList(),
                      );
                    }),
                  ),
                ),
              ),

              // Alerts & Notifications (from controller)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                  child: Text('Alerts & Notifications', style: t.titleLarge),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(() {
                    final items = c.alerts;
                    if (items.isEmpty) {
                      return const SizedBox(
                        height: 80,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    Color bg(sev) => switch (sev) {
                      AlertSeverity.danger => AppColors.dangerBg,
                      AlertSeverity.warning => AppColors.warningBg,
                      _ => AppColors.infoBg,
                    };
                    Color iconBg(sev) => switch (sev) {
                      AlertSeverity.danger => const Color(0xFFFFE4E4),
                      AlertSeverity.warning => const Color(0xFFFFF0D6),
                      _ => const Color(0xFFDCE8FF),
                    };
                    Color iconColor(sev) => switch (sev) {
                      AlertSeverity.danger => AppColors.danger,
                      AlertSeverity.warning => AppColors.warning,
                      _ => AppColors.info,
                    };

                    return Column(
                      children: [
                        for (final a in items) ...[
                          AlertCard(
                            bg: bg(a.severity),
                            iconBg: iconBg(a.severity),
                            iconColor: iconColor(a.severity),
                            title: a.title,
                            subtitle: a.subtitle,
                            ctaText: 'View Details',
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/* ---------------------------- REUSABLE WIDGETS --------------------------- */

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.tileBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const Spacer(),
            Text(title, style: t.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: t.bodyMedium?.copyWith(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  const StatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconBg = AppColors.blueLight,
    this.iconColor = AppColors.blue,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 12),
        Text(value, style: t.titleLarge),
        const SizedBox(height: 6),
        Text(label, style: t.bodyMedium?.copyWith(color: AppColors.muted)),
      ],
    );
  }
}

enum AlertSeverity { info, warning, danger } // for local mapping if needed

class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.bg,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.ctaText,
  });

  final Color bg;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String ctaText;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            padding: const EdgeInsets.all(10),
            child: Icon(Iconsax.warning_2, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: t.bodyMedium?.copyWith(color: AppColors.muted)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {},
                  child: Text(
                    ctaText,
                    style: t.labelLarge?.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
