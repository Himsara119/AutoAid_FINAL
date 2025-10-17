import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../models/kpi_entity.dart';

class KpiTiles extends GetView<DashboardController> {
  const KpiTiles({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Obx(() {
      final items = controller.kpis;
      if (items.isEmpty) return const SizedBox.shrink();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((k) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: k.iconBg, shape: BoxShape.circle),
                child: Icon(k.icon, color: k.iconColor, size: 22),
              ),
              const SizedBox(height: 12),
              Text('${k.value}', style: t.titleLarge),
              const SizedBox(height: 6),
              Text(k.label, style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
            ],
          );
        }).toList(),
      );
    });
  }
}
