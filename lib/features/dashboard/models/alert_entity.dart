import 'package:flutter/material.dart';

enum AlertSeverity { info, warning, danger }

class AlertEntity {
  final String id;
  final String title;
  final String subtitle;
  final AlertSeverity severity;
  final IconData leading;

  const AlertEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.severity,
    required this.leading,
  });
}
