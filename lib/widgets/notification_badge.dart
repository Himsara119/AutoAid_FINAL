import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key, required this.severity});
  final String severity;

  @override
  Widget build(BuildContext context) {
    final color = switch (severity) {
      'overdue' => const Color(0xFFD32F2F),
      'urgent'  => const Color(0xFFF57C00),
      'upcoming'=> const Color(0xFF1976D2),
      _         => const Color(0xFF607D8B),
    };
    final label = switch (severity) {
      'overdue' => 'Overdue',
      'urgent'  => 'Urgent',
      'upcoming'=> 'Upcoming',
      _         => 'Info',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
