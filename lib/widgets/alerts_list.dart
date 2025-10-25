// lib/features/dashboard/widgets/alerts_list.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../app.dart' show AppColors;
import '../features/notifications/controllers/notifications_controller.dart';

class AlertsList extends StatelessWidget {
  const AlertsList({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final ctrl = Get.find<NotificationsController>();

    return Obx(() {
      if (ctrl.loading.value) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: AppColors.info)),
          ),
        );
      }

      if (ctrl.error.isNotEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Error: ${ctrl.error.value}',
              style: t.bodyMedium?.copyWith(color: AppColors.danger),
            ),
          ),
        );
      }

      final items = ctrl.notifications;
      if (items.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            child: _emptyCard(t),
          ),
        );
      }

      final sorted = [...items]..sort((a, b) {
        final at = a.sentAt?.toDate();
        final bt = b.sentAt?.toDate();
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });

      final top3 = sorted.take(3).toList();

      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(t, ctrl),
              const SizedBox(height: 12),
              for (var i = 0; i < top3.length; i++)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                  child: _ReminderCard(
                    title: top3[i].title,
                    body: top3[i].body,
                    sentAt: top3[i].sentAt?.toDate(),
                    isUnread: top3[i].isUnread,
                    onMarkRead: () => ctrl.markAsRead(top3[i].id),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _header(TextTheme t, NotificationsController ctrl) {
    return Row(
      children: [
        Expanded(child: Text('Reminders', style: t.titleLarge)),
        Obx(() {
          final unread = ctrl.unreadCount.value;
          if (unread <= 0) return const SizedBox.shrink();
          return TextButton(
            onPressed: ctrl.markAllAsRead,
            child: Text('Mark all read', style: t.labelLarge?.copyWith(color: AppColors.info)),
          );
        }),
      ],
    );
  }

  Widget _emptyCard(TextTheme t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tileBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(color: AppColors.infoBg, shape: BoxShape.circle),
            padding: const EdgeInsets.all(10),
            child: const Icon(Iconsax.happyemoji, color: AppColors.info, size: 20),
          ),
          const SizedBox(width: 12),
          //Expanded(
            //child: Text('No reminders right now.', style: t.bodyMedium?.copyWith(color: AppColors.muted)),
          //),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.title,
    required this.body,
    required this.sentAt,
    required this.isUnread,
    required this.onMarkRead,
  });

  final String title;
  final String body;
  final DateTime? sentAt;
  final bool isUnread;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final dueText = sentAt == null ? 'No date' : _friendlyDue(sentAt!);
    final urgent = _urgency('$title $body', sentAt);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.tileBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(color: urgent.bg, shape: BoxShape.circle),
            padding: const EdgeInsets.all(10),
            child: Icon(urgent.icon, color: urgent.fg, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleMedium),
                const SizedBox(height: 4),
                //Text(body, style: t.bodyMedium?.copyWith(color: AppColors.muted)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Iconsax.clock, size: 14, color: Color(0xFF9AA3AE)),
                    const SizedBox(width: 6),
                    Text('Due $dueText', style: t.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
                    const Spacer(),
                    if (isUnread)
                      TextButton(
                        onPressed: onMarkRead,
                        child: Text('Mark read', style: t.labelLarge?.copyWith(color: AppColors.info)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyDue(DateTime due) {
    final now = DateTime.now();
    final delta = due.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (delta == 0) return 'today';
    if (delta == 1) return 'tomorrow';
    if (delta == -1) return 'yesterday';
    if (delta.abs() <= 7) return delta > 0 ? 'in $delta days' : '${delta.abs()} days ago';
    return '${due.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}';
  }

  _Urgency _urgency(String text, DateTime? due) {
    final looksUrgent = text.toLowerCase().contains('expire') ||
        text.toLowerCase().contains('overdue') ||
        text.toLowerCase().contains('immediately');
    final overdue = due != null && due.isBefore(DateTime.now());
    if (overdue || looksUrgent) {
      return const _Urgency(bg: AppColors.dangerBg, fg: AppColors.danger, icon: Iconsax.warning_2);
    }
    return const _Urgency(bg: AppColors.infoBg, fg: AppColors.info, icon: Iconsax.notification);
  }
}

class _Urgency {
  final Color bg;
  final Color fg;
  final IconData icon;
  const _Urgency({required this.bg, required this.fg, required this.icon});
}
