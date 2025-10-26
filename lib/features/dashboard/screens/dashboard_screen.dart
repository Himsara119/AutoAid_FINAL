// lib/features/dashboard/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// where you defined these
import '../../../app.dart' show Routes, AppColors;
// controller that does the Firestore counts
import '../../vehicles/controllers/vehicle_stats_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Post-frame refresh so the Obx on this screen rebuilds with fresh numbers
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.isRegistered<VehicleStatsController>()) {
        try {
          await Get.find<VehicleStatsController>().refreshCounts();
        } catch (_) {
          // don't blow up the dashboard if something hiccups
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stats = Get.find<VehicleStatsController>(); // already created post-login

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // HEADER
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
                          Text('Good morning, Alex', style: t.bodyMedium?.copyWith(color: AppColors.muted)),
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

            // AI Assistant Banner (tappable)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Get.toNamed(Routes.aiScreen),
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
                                  style: t.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text('How can I help you today?',
                                  style: t.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9))),
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
                  mainAxisExtent: 164,
                ),
                delegate: SliverChildListDelegate([
                  QuickActionCard(
                    iconBg: const Color(0xFFEFFAF3),
                    iconColor: AppColors.success,
                    icon: Iconsax.add_square,
                    title: 'Add Vehicle',
                    subtitle: 'Register new car',
                    onTap: () => Get.toNamed(Routes.vehicleadd),
                  ),
                  QuickActionCard(
                    iconBg: const Color(0xFFEFF4FF),
                    iconColor: AppColors.blue,
                    icon: Iconsax.scan_barcode,
                    title: 'Visual Scan',
                    subtitle: 'Scan damage',
                    onTap: () => Get.toNamed(Routes.visualScan, preventDuplicates: true),
                  ),
                  QuickActionCard(
                    iconBg: const Color(0xFFF2F0FF),
                    iconColor: const Color(0xFF7C3AED),
                    icon: Iconsax.document_text,
                    title: 'Generate Report',
                    subtitle: 'Create analysis',
                    // IMPORTANT: Open Report Builder unlocked with no preselected vehicle.
                    // If later you have a known id, pass: arguments: {'vehicleId': someVehicleId}
                    onTap: () => Get.toNamed(
                      Routes.reportBuilder,
                      arguments: {'vehicleId': null},
                      preventDuplicates: true,
                    ),
                  ),
                  QuickActionCard(
                    iconBg: const Color(0xFFFFF7E8),
                    iconColor: AppColors.warning,
                    icon: Iconsax.setting_4,
                    title: 'Find Mechanic',
                    subtitle: 'Locate service',
                    onTap: () => Get.toNamed(Routes.mechanicFinder, preventDuplicates: true),
                  ),
                ]),
              ),
            ),

            // Vehicle Overview (reactive, tappable)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: Text('Vehicle Overview', style: t.titleLarge),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Get.toNamed(
                    Routes.vehiclelist, // open list with All filter by default
                    parameters: {'filter': 'All'},
                    preventDuplicates: true,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.tileBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Obx(() {
                      final stats = Get.find<VehicleStatsController>();
                      if (stats.loading.value) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [_SkeletonStat(), _SkeletonStat(), _SkeletonStat()],
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatItem(
                            icon: Iconsax.car,
                            label: 'Vehicles',
                            value: '${stats.total.value}',
                            onTap: () => Get.toNamed(
                              Routes.vehiclelist,
                              parameters: {'filter': 'All'},
                              preventDuplicates: true,
                            ),
                          ),
                          StatItem(
                            icon: Iconsax.tick_circle,
                            label: 'Active',
                            value: '${stats.active.value}',
                            iconColor: AppColors.success,
                            iconBg: AppColors.successBg,
                            onTap: () => Get.toNamed(
                              Routes.vehiclelist,
                              parameters: {'filter': 'Active'},
                              preventDuplicates: true,
                            ),
                          ),
                          StatItem(
                            icon: Iconsax.receipt_item,
                            label: 'Sold',
                            value: '${stats.sold.value}',
                            iconColor: const Color(0xFF0F172A),
                            iconBg: const Color(0xFFEFF1F5),
                            onTap: () => Get.toNamed(
                              Routes.vehiclelist,
                              parameters: {'filter': 'Sold'},
                              preventDuplicates: true,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),

            // Alerts & Notifications
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                child: Text('Alerts & Notifications', style: t.titleLarge),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: const [
                    AlertCard(
                      bg: AppColors.dangerBg,
                      iconBg: Color(0xFFFFE4E4),
                      iconColor: AppColors.danger,
                      title: 'Insurance Expired',
                      subtitle: 'BMW X5 2021 - Expired 3 days ago',
                      ctaText: 'Renew Now',
                    ),
                    SizedBox(height: 12),
                    AlertCard(
                      bg: AppColors.warningBg,
                      iconBg: Color(0xFFFFF0D6),
                      iconColor: AppColors.warning,
                      title: 'Service Due',
                      subtitle: 'Toyota Camry 2020 - Due in 5 days',
                      ctaText: 'Schedule Service',
                    ),
                    SizedBox(height: 12),
                    AlertCard(
                      bg: AppColors.infoBg,
                      iconBg: Color(0xFFDCE8FF),
                      iconColor: AppColors.info,
                      title: 'Registration Reminder',
                      subtitle: 'Honda Accord 2019 - Expires in 30 days',
                      ctaText: 'View Details',
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
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
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
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
        ),
      ),
    );
  }
}

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

class _SkeletonStat extends StatelessWidget {
  const _SkeletonStat({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFEFF1F5), shape: BoxShape.circle)),
        const SizedBox(height: 12),
        Container(width: 28, height: 18, color: const Color(0xFFEFF1F5)),
        const SizedBox(height: 6),
        Container(width: 72, height: 14, color: const Color(0xFFEFF1F5)),
      ],
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
