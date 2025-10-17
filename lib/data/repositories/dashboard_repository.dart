import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../features/dashboard/models/kpi_entity.dart';
import '../../features/dashboard/models/alert_entity.dart';
import '../../../../data/repositories/dashboard_repository.dart';



class DashboardData {
  final String userName;
  final List<KPIEntity> kpis;
  final List<AlertEntity> alerts;

  DashboardData({
    required this.userName,
    required this.kpis,
    required this.alerts,
  });
}

abstract class DashboardRepository {
  Future<DashboardData> fetchDashboard();
}

class FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardData> fetchDashboard() async {
    await Future.delayed(const Duration(milliseconds: 650));

    final kpis = <KPIEntity>[
      KPIEntity(
        kind: KPIKind.totalVehicles,
        label: 'Total Vehicles',
        value: 12,
        icon: Iconsax.car,
        iconBg: const Color(0xFFEFF4FF),
        iconColor: const Color(0xFF2563EB),
      ),
      KPIEntity(
        kind: KPIKind.active,
        label: 'Active',
        value: 8,
        icon: Iconsax.tick_circle,
        iconBg: const Color(0xFFEFFAF3),
        iconColor: const Color(0xFF16A34A),
      ),
      KPIEntity(
        kind: KPIKind.sold,
        label: 'Sold',
        value: 4,
        icon: Iconsax.receipt_item,
        iconBg: const Color(0xFFEFF1F5),
        iconColor: const Color(0xFF0F172A),
      ),
    ];

    final alerts = <AlertEntity>[
      const AlertEntity(
        id: 'a1',
        title: 'Insurance Expired',
        subtitle: 'BMW X5 2021 — Expired 3 days ago',
        severity: AlertSeverity.danger,
        leading: Iconsax.warning_2,
      ),
      const AlertEntity(
        id: 'a2',
        title: 'Service Due',
        subtitle: 'Toyota Camry 2020 — Due in 5 days',
        severity: AlertSeverity.warning,
        leading: Iconsax.setting_4,
      ),
      const AlertEntity(
        id: 'a3',
        title: 'Registration Reminder',
        subtitle: 'Honda Accord 2019 — Expires in 30 days',
        severity: AlertSeverity.info,
        leading: Iconsax.document_text,
      ),
    ];

    return DashboardData(
      userName: 'Alex',
      kpis: kpis,
      alerts: alerts,
    );
  }
}
