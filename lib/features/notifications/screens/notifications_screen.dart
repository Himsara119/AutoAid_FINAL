// lib/features/notifications/ui/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _tab = 0; // 0 = All, 1 = Urgent, 2 = Upcoming

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final items = <_Notif>[
      _Notif(
        title: 'Oil Change Due',
        body: 'Your vehicle is overdue for an oil change. Schedule service immediately.',
        due: 'Jan 15, 2025',
        status: _Status.urgent,
        icon: Iconsax.gas_station,
        tint: const Color(0xFFFFE7E6),
        iconColor: const Color(0xFFE11D48),
      ),
      _Notif(
        title: 'Service Appointment',
        body: 'Scheduled maintenance service at Downtown Auto Center.',
        due: 'Jan 28, 2025',
        status: _Status.upcoming,
        icon: Iconsax.setting_4,
        tint: const Color(0xFFFFF2E1),
        iconColor: const Color(0xFFF59E0B),
      ),
      _Notif(
        title: 'Insurance Renewal',
        body: 'Your auto insurance policy expires soon. Renew to avoid coverage gaps.',
        due: 'Jan 20, 2025',
        status: _Status.urgent,
        icon: Iconsax.shield_tick,
        tint: const Color(0xFFFFE7E6),
        iconColor: const Color(0xFFE11D48),
      ),
      _Notif(
        title: 'Tire Rotation',
        body: 'Regular tire rotation recommended for even wear and longevity.',
        due: 'Feb 05, 2025',
        status: _Status.upcoming,
        icon: Iconsax.car,
        tint: const Color(0xFFFFF2E1),
        iconColor: const Color(0xFFF59E0B),
      ),
      _Notif(
        title: 'Air Filter Check',
        body: 'Check and replace air filter if needed for optimal engine performance.',
        due: 'Feb 15, 2025',
        status: _Status.normal,
        icon: Iconsax.filter_edit,
        tint: const Color(0xFFF2F5F9),
        iconColor: const Color(0xFF6B7280),
      ),
      _Notif(
        title: 'Battery Test',
        body: 'Annual battery performance test to ensure reliable starting.',
        due: 'Mar 01, 2025',
        status: _Status.normal,
        icon: Iconsax.battery_3full,
        tint: const Color(0xFFF2F5F9),
        iconColor: const Color(0xFF6B7280),
      ),
      _Notif(
        title: 'Registration Renewal',
        body: 'Vehicle registration expires soon. Renew online or at DMV office.',
        due: 'Feb 28, 2025',
        status: _Status.upcoming,
        icon: Iconsax.magic_star,
        tint: const Color(0xFFFFF2E1),
        iconColor: const Color(0xFFF59E0B),
      ),
    ];

    final filtered = switch (_tab) {
      1 => items.where((e) => e.status == _Status.urgent).toList(),
      2 => items.where((e) => e.status == _Status.upcoming).toList(),
      _ => items,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Color(0xFF111827)),
          )
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                _SegChip(
                  label: 'All',
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                const SizedBox(width: 10),
                _SegChip(
                  label: 'Urgent',
                  selected: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
                const SizedBox(width: 10),
                _SegChip(
                  label: 'Upcoming',
                  selected: _tab == 2,
                  onTap: () => setState(() => _tab = 2),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              itemBuilder: (_, i) => _NotifCard(n: filtered[i]),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: filtered.length,
            ),
          ),
        ],
      ),
    );
  }
}

/* =========================== MODELS & ENUMS =========================== */

enum _Status { urgent, upcoming, normal }

class _Notif {
  _Notif({
    required this.title,
    required this.body,
    required this.due,
    required this.status,
    required this.icon,
    required this.tint,
    required this.iconColor,
  });

  final String title;
  final String body;
  final String due;
  final _Status status;
  final IconData icon;
  final Color tint;
  final Color iconColor;
}

/* =============================== WIDGETS ============================== */

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
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.n});
  final _Notif n;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final badge = switch (n.status) {
      _Status.urgent => _Badge(text: 'Urgent', bg: const Color(0xFFFFE7E6), fg: const Color(0xFFE11D48)),
      _Status.upcoming => _Badge(text: 'Upcoming', bg: const Color(0xFFFFF2E1), fg: const Color(0xFFF59E0B)),
      _Status.normal => _Badge(text: 'Normal', bg: const Color(0xFFEFF2F6), fg: const Color(0xFF6B7280)),
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E8ED)),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // leading icon bubble
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: n.tint, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(n.icon, color: n.iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          // text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n.title,
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
                Text(
                  n.body,
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
                    Text('Due: ${n.due}',
                        style: t.bodyMedium?.copyWith(color: const Color(0xFF9AA3AE))),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
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
