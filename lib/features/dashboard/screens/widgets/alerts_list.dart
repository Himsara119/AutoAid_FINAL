import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/dashboard_controller.dart';
import '../../models/alert_entity.dart';

class AlertsList extends GetView<DashboardController> {
  const AlertsList({super.key});

  Color _bg(AlertSeverity s) => switch (s) {
    AlertSeverity.danger => const Color(0xFFFFEEEE),
    AlertSeverity.warning => const Color(0xFFFFF7E8),
    AlertSeverity.info => const Color(0xFFEFF4FF),
  };

  Color _iconColor(AlertSeverity s) => switch (s) {
    AlertSeverity.danger => const Color(0xFFEF4444),
    AlertSeverity.warning => const Color(0xFFF59E0B),
    AlertSeverity.info => const Color(0xFF2563EB),
  };

  Color _iconBg(AlertSeverity s) => switch (s) {
    AlertSeverity.danger => const Color(0xFFFFE4E4),
    AlertSeverity.warning => const Color(0xFFFFF0D6),
    AlertSeverity.info => const Color(0xFFDCE8FF),
  };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Obx(() {
      final items = controller.alerts;
      return Column(
        children: items
            .map((a) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _bg(a.severity),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE6E8ED)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(color: _iconBg(a.severity), shape: BoxShape.circle),
                padding: const EdgeInsets.all(10),
                child: Icon(a.leading, color: _iconColor(a.severity), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.title, style: t.titleMedium),
                    const SizedBox(height: 4),
                    Text(a.subtitle,
                        style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {},
                      child: Text('View', style: t.labelLarge?.copyWith(color: const Color(0xFF2563EB))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ))
            .toList(),
      );
    });
  }
}
