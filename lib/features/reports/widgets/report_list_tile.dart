import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import '../../profile/models/profile_entity.dart';

/// Small reusable tile for a single report.
/// - Shows category label, file name, and created date
/// - Leading icon maps from category
/// - Optional status chip (pass one if you have it)
/// - onTap should navigate to detail with (vehicleId, reportId)
class ReportListTile extends StatelessWidget {
  const ReportListTile({
    super.key,
    required this.report,
    this.status,           // optional UI chip (e.g., "Completed")
    this.onTap,            // navigate to detail
    this.trailing,         // custom trailing if you want
  });

  final ReportModel report;
  final String? status;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E8ED)),
        ),
        child: Row(
          children: [
            _CategoryIcon(category: report.category),
            const SizedBox(width: 14),

            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title from category
                  Text(
                    _titleFromCategory(report.category),
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Subtitle: date • filename
                  Text(
                    '${_fmtShortDate(_asDateTime(report.createdAt ?? report.updatedAt))} • ${report.fileName}',
                    style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Status chip or default chevron
            trailing ??
                (status != null
                    ? _StatusChip(status: status!)
                    : const Icon(Iconsax.arrow_right_3, size: 18, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

/* ---------- helpers & private widgets ---------- */

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final icon = switch (category.toLowerCase()) {
      'inspection' => Iconsax.clipboard_text,
      'condition' => Iconsax.shield_tick,
      'resale' || 'resale_evaluation' => Iconsax.activity,
      'insurance' => Iconsax.security_card,
      _ => Iconsax.document_text,
    };

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: c.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: c.primary),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final color = s == 'completed'
        ? const Color(0xFF22C55E)
        : s == 'pending'
        ? const Color(0xFFF59E0B)
        : const Color(0xFF9CA3AF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

String _titleFromCategory(String category) {
  final c = category.toLowerCase();
  if (c == 'inspection') return 'Inspection Report';
  if (c == 'condition') return 'Condition Report';
  if (c == 'resale' || c == 'resale_evaluation') return 'Resale Report';
  if (c == 'insurance') return 'Insurance Report';
  return 'Report';
}

DateTime? _asDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is Timestamp) return v.toDate();
  return DateTime.tryParse(v.toString());
}

String _fmtShortDate(DateTime? d) {
  if (d == null) return 'Unknown';
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}
