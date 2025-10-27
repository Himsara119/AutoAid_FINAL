// lib/widgets/alerts_list.dart
import 'package:flutter/material.dart';
import '../features/notifications/models/alert_model.dart'; // ← correct model
import 'notification_badge.dart';

/// Renders a list of notification alerts.
/// Expects AlertEntity from features/notifications/models/alert_model.dart
class AlertsList extends StatelessWidget {
  const AlertsList({super.key, required this.items, this.onTap});

  final List<AlertEntity> items;
  final void Function(AlertEntity a)? onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No notifications'));
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (_, i) {
        final a = items[i];

        // Be tolerant: some backfilled records may have type but not source
        final isService =
            (a.source == 'service') || (a.type.toLowerCase().contains('service'));

        return ListTile(
          leading: Icon(isService ? Icons.build : Icons.description),
          title: Text(a.title),
          subtitle: Text(a.message),
          trailing: NotificationBadge(severity: a.severity), // expects String
          onTap: () => onTap?.call(a),
        );
      },
    );
  }
}
