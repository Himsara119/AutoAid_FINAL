// lib/features/vehicles/tabs/reports_tab.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';

import '../../reports/controllers/report_controller.dart';
import '../../../app.dart' show Routes, AppColors;

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key, required this.vehicleId});

  /// Parent vehicle id to read: vehicles/{vehicleId}/reports
  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ReportListController(vehicleId), tag: 'reports_$vehicleId');
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          // Your static example cards
          const _ReportCard(
            icon: Iconsax.clipboard_text,
            title: 'Condition Report',
            subtitle: 'Generated Dec 2024',
          ),
          const SizedBox(height: 12),
          const _ReportCard(
            icon: Iconsax.activity,
            title: 'Resale Report',
            subtitle: 'Generated Nov 2024',
          ),
          const SizedBox(height: 12),
          const _ReportCard(
            icon: Iconsax.shield_tick,
            title: 'Insurance Report',
            subtitle: 'Generated Oct 2024',
          ),
          const SizedBox(height: 18),

          Text('Generated Reports', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),

          // Live list from Firestore
          Obx(() {
            if (c.loading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (c.items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No reports yet. Tap Add to generate one.',
                  style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: c.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final r = c.items[i];
                return InkWell(
                  onTap: () {
                    Get.toNamed(
                      Routes.reportScreen,
                      arguments: {
                        'vehicleId': vehicleId,
                        'reportId': r.id,
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE6E8ED)),
                    ),
                    child: Row(
                      children: [
                        _CategoryIcon(category: r.category),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _titleFromCategory(r.category),
                                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${_fmtDate((r.createdAt ?? r.updatedAt)?.toDate())} • ${r.fileName}',
                                style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Iconsax.arrow_right_3, size: 18, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),

      // FAB updated: brand blue, bottom-right, parity with Documents tab
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(
          Routes.reportBuilder,
          arguments: {'vehicleId': vehicleId},
        ),
        icon: const Icon(Iconsax.add),
        label: const Text('Add'),
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/* ------------------------ Static example card ------------------------ */

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(subtitle, style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

/* ------------------------ Helpers for live rows ------------------------ */

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

String _titleFromCategory(String category) {
  final c = category.toLowerCase();
  if (c == 'inspection') return 'Inspection Report';
  if (c == 'condition') return 'Condition Report';
  if (c == 'resale' || c == 'resale_evaluation') return 'Resale Report';
  if (c == 'insurance') return 'Insurance Report';
  return 'Report';
}

String _fmtDate(DateTime? d) {
  if (d == null) return 'Unknown date';
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$mm-$dd';
}
