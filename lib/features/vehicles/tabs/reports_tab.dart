import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: const [
        _ReportCard(icon: Iconsax.clipboard_text, title: 'Condition Report', subtitle: 'Generated Dec 2024'),
        SizedBox(height: 12),
        _ReportCard(icon: Iconsax.activity, title: 'Resale Report', subtitle: 'Generated Nov 2024'),
        SizedBox(height: 12),
        _ReportCard(icon: Iconsax.shield_tick, title: 'Insurance Report', subtitle: 'Generated Oct 2024'),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6E8ED)),
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: c.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: c.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(subtitle, style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
            ]),
          ),
        ]),
      ),
    );
  }
}
