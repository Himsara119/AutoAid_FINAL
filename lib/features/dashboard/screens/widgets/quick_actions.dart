import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/dashboard_controller.dart';

class QuickActions extends GetView<DashboardController> {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget card({
      required IconData icon,
      required String title,
      required String subtitle,
      required Color iconBg,
      required Color iconColor,
      required VoidCallback onTap,
    }) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE6E8ED)),
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
              Text(subtitle, style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
            ],
          ),
        ),
      );
    }

    return GridView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 140,
      ),
      children: [
        card(
          icon: Iconsax.add_square,
          title: 'Add Vehicle',
          subtitle: 'Register new car',
          iconBg: const Color(0xFFEFFAF3),
          iconColor: const Color(0xFF16A34A),
          onTap: controller.addVehicle,
        ),
        card(
          icon: Iconsax.scan_barcode,
          title: 'Visual Scan',
          subtitle: 'Scan damage',
          iconBg: const Color(0xFFEFF4FF),
          iconColor: const Color(0xFF2563EB),
          onTap: controller.visualScan,
        ),
        card(
          icon: Iconsax.document_text,
          title: 'Generate Report',
          subtitle: 'Create analysis',
          iconBg: const Color(0xFFF2F0FF),
          iconColor: const Color(0xFF7C3AED),
          onTap: controller.generateReport,
        ),
        card(
          icon: Iconsax.setting_4,
          title: 'Find Mechanic',
          subtitle: 'Locate service',
          iconBg: const Color(0xFFFFF7E8),
          iconColor: const Color(0xFFF59E0B),
          onTap: controller.findMechanic,
        ),
      ],
    );
  }
}
