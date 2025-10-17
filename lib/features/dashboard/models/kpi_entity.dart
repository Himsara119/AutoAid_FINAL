import 'package:flutter/material.dart';

enum KPIKind { totalVehicles, active, sold }

class KPIEntity {
  final KPIKind kind;
  final String label;
  final int value;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;

  const KPIEntity({
    required this.kind,
    required this.label,
    required this.value,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
  });

  KPIEntity copyWith({int? value}) => KPIEntity(
    kind: kind,
    label: label,
    value: value ?? this.value,
    iconBg: iconBg,
    iconColor: iconColor,
    icon: icon,
  );
}
