// lib/features/notifications/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// Controller + model
import '../controllers/alerts_feed_controller.dart';
import '../models/alert_model.dart';

// OPTIONAL: if you have FirebaseAuth
import 'package:firebase_auth/firebase_auth.dart' as fb;

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    this.userId,
    this.vehicleId,
    this.title = 'Notifications',
  });

  /// If [vehicleId] is provided, shows alerts for that vehicle.
  /// Otherwise uses [userId] (or resolves from auth) and shows a global feed.
  final String? userId;
  final String? vehicleId;
  final String title;

  String? _resolveUserId() {
    if (userId != null && userId!.isNotEmpty) return userId;

    final args = Get.arguments is Map ? (Get.arguments as Map) : const {};
    final argUid = args['userId']?.toString();
    if (argUid != null && argUid.isNotEmpty) return argUid;

    try {
      final fbUid = fb.FirebaseAuth.instance.currentUser?.uid;
      if (fbUid != null && fbUid.isNotEmpty) return fbUid;
    } catch (_) {}

    return null;
  }

  String? _resolveVehicleId() {
    if (vehicleId != null && vehicleId!.isNotEmpty) return vehicleId;
    final args = Get.arguments is Map ? (Get.arguments as Map) : const {};
    final vid = args['vehicleId']?.toString();
    if (vid != null && vid.isNotEmpty) return vid;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedVehicleId = _resolveVehicleId();
    final resolvedUserId = _resolveUserId();

    final feed = Get.put(
      AlertsFeedController(
        vehicleId: resolvedVehicleId,
        userId: resolvedVehicleId == null ? resolvedUserId : null,
      ),
      tag: 'alerts_feed_${resolvedVehicleId ?? resolvedUserId ?? 'none'}',
    );

    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,

        // TOP-LEFT: back + refresh
        leadingWidth: 96,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Iconsax.arrow_left_2, color: Color(0xFF111827)),
              onPressed: () => Get.back(),
            ),
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Iconsax.refresh, color: Color(0xFF111827)),
              onPressed: () async {
                await feed.refresh(); // controller provides Future<void>
              },
            ),
          ],
        ),

        title: Text(
          title,
          style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800),
        ),
        centerTitle: true,

        // Keep "Mark all as read" on the right
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Iconsax.tick_circle, color: Color(0xFF111827)),
            onPressed: () async {
              if (resolvedVehicleId != null && resolvedVehicleId.isNotEmpty) {
                await feed.markAllDoneForVehicle(resolvedVehicleId);
              } else if (resolvedUserId != null && resolvedUserId.isNotEmpty) {
                await feed.markAllDoneForUser(resolvedUserId);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          _TabsBar(controller: feed),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Expanded(
            // Pull-to-refresh wrapper
            child: RefreshIndicator(
              onRefresh: () => feed.refresh(),
              child: Obx(() {
                if (feed.loading.value) {
                  // Keep it scrollable so pull-to-refresh still works
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: CircularProgressIndicator()),
                    ],
                  );
                }
                if (feed.error.value != null) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 80),
                    children: [
                      Center(child: Text('Error: ${feed.error.value}', style: t.bodyMedium)),
                    ],
                  );
                }
                if (feed.alerts.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 80),
                    children: [
                      Center(child: Text('No notifications found.', style: t.bodyMedium)),
                    ],
                  );
                }

                // Controller already applies severity filter based on tab,
                // and hides read items on non-All tabs. Use it directly.
                final list = feed.alerts;

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final a = list[i];
                    return Dismissible(
                      key: ValueKey('${a.vehicleId}_${a.id}'),
                      direction: (a.read ?? false) ? DismissDirection.none : DismissDirection.endToStart,
                      background: const SizedBox.shrink(),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFFAF3),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Iconsax.tick_circle, color: Color(0xFF16A34A)),
                            SizedBox(width: 8),
                            Text(
                              'Mark read',
                              style: TextStyle(
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      confirmDismiss: (_) async {
                        if (!(a.read ?? false)) {
                          await feed.markDone(a);
                        }
                        // Don't remove from list immediately; stream will update.
                        return false;
                      },
                      child: InkWell(
                        onTap: () => feed.openAlert(a, markRead: true),
                        child: _AlertCard(alert: a),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/* =============================== FILTER BAR =============================== */

class _TabsBar extends StatelessWidget {
  const _TabsBar({required this.controller});
  final AlertsFeedController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            _SegChip(
              label: 'All',
              selected: controller.currentTab.value == 0,
              onTap: () => controller.currentTab.value = 0,
            ),
            const SizedBox(width: 10),
            _SegChip(
              label: 'Urgent',
              selected: controller.currentTab.value == 1,
              onTap: () => controller.currentTab.value = 1,
            ),
            const SizedBox(width: 10),
            _SegChip(
              label: 'Upcoming',
              selected: controller.currentTab.value == 2,
              onTap: () => controller.currentTab.value = 2,
            ),
          ],
        ),
      );
    });
  }
}

/* =============================== ALERT CARD =============================== */

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});
  final AlertEntity alert;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    // Be tolerant: enum or string type
    final typeKey = (alert.type is String) ? (alert.type as String) : alert.type.toString();

    (IconData, Color, Color) iconSpec;
    if (typeKey.contains('service')) {
      iconSpec = (Iconsax.setting_4, const Color(0xFFFFE7E6), const Color(0xFFE11D48));
    } else if (typeKey.contains('insurance')) {
      iconSpec = (Iconsax.shield_tick, const Color(0xFFFFE7E6), const Color(0xFFE11D48));
    } else if (typeKey.contains('registration')) {
      iconSpec = (Iconsax.card, const Color(0xFFFFE7E6), const Color(0xFFE11D48));
    } else {
      iconSpec = (Iconsax.notification, const Color(0xFFF2F5F9), const Color(0xFF6B7280));
    }

    final (icon, tint, iconColor) = iconSpec;

    final Widget badge = switch (alert.severity) {
      AlertSeverity.urgent =>
      const _Badge(text: 'Urgent', bg: Color(0xFFFFE7E6), fg: Color(0xFFE11D48)),
      AlertSeverity.upcoming =>
      const _Badge(text: 'Upcoming', bg: Color(0xFFFFF2E1), fg: Color(0xFFF59E0B)),
      AlertSeverity.overdue =>
      const _Badge(text: 'Overdue', bg: Color(0xFFFFE7E6), fg: Color(0xFFE11D48)),
      _ =>
      const _Badge(text: 'Normal', bg: Color(0xFFEFF2F6), fg: Color(0xFF6B7280)),
    };

    final unreadShade = (alert.read ?? false) ? Colors.white : const Color(0xFFFAFBFF);

    return Container(
      decoration: BoxDecoration(
        color: unreadShade,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E8ED)),
        boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 6))],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: t.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    badge,
                  ],
                ),
                const SizedBox(height: 6),
                if ((alert.vehicleName ?? '').isNotEmpty) ...[
                  Text(
                    alert.vehicleName!,
                    style: t.bodyMedium?.copyWith(
                      color: const Color(0xFF374151),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  alert.message,
                  style: t.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6472),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Iconsax.calendar_1, size: 16, color: Color(0xFF9AA3AE)),
                    const SizedBox(width: 6),
                    Text(
                      'Due: ${alert.dueAt != null ? alert.dueAt!.toDate().toString().substring(0, 10) : 'N/A'}',
                      style: t.bodyMedium?.copyWith(color: const Color(0xFF9AA3AE)),
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
}

/* ============================ REUSABLE WIDGETS ============================ */

class _SegChip extends StatelessWidget {
  const _SegChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEFF3FF) : const Color(0xFFF2F4F7),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? const Color(0xFF6D8BFF) : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF1F2937) : const Color(0xFF4B5563),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}