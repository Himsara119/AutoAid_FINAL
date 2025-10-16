// lib/features/reports/ui/condition_report_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ConditionReportScreen extends StatelessWidget {
  const ConditionReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Condition Report',
            style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Color(0xFF111827)),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Generated + status chip
              Row(
                children: [
                  const Text('Generated on Dec 15, 2024',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12.5)),
                  const Spacer(),
                  _Chip(label: 'Valid', color: const Color(0xFF22C55E)),
                ],
              ),
              const SizedBox(height: 10),

              // Summary
              _SectionCard(
                title: 'Summary',
                child: Column(
                  children: const [
                    _SummaryRow(label: 'Vehicle', value: '2020 Honda Civic LX'),
                    _Divider(),
                    _SummaryRow(
                      label: 'VIN',
                      value: '2HGFC2F59LH123456',
                      isLink: true,
                    ),
                    _Divider(),
                    _SummaryRow(label: 'Mileage', value: '45,230 miles'),
                    _Divider(),
                    _SummaryRow(label: 'Inspection Date', value: 'Dec 12, 2024'),
                  ],
                ),
              ),

              // Key Metrics
              _SectionCard(
                title: 'Key Metrics',
                child: Column(
                  children: const [
                    _MetricOverall(score: '8.5', outOf: '/10'),
                    _Divider(),
                    _MetricRow(
                      label: 'Exterior',
                      rating: 'Good',
                      desc:
                      'Minor scratches on rear bumper; paint in\nexcellent condition',
                    ),
                    _Divider(),
                    _MetricRow(
                      label: 'Interior',
                      rating: 'Excellent',
                      desc:
                      'No visible wear; all electronics functioning\nproperly',
                    ),
                    _Divider(),
                    _MetricRow(
                      label: 'Mechanical',
                      rating: 'Very Good',
                      desc:
                      'Engine runs smooth; brakes recently\nserviced; new tires',
                    ),
                  ],
                ),
              ),

              // AI Insights
              _SectionCard(
                title: 'AI Insights',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1E8FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Iconsax.cpu, color: Color(0xFF7C3AED), size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'This vehicle shows excellent maintenance history and is in above-'
                            'average condition for its age and mileage. The minor exterior '
                            'scratches are cosmetic and don’t affect structural integrity. '
                            'Recent brake service and new tires indicate proactive maintenance. '
                            'Overall, this represents good value with minimal immediate repair needs expected.',
                        style: TextStyle(color: Color(0xFF111827), height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),

              // Attachments
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('Attachments',
                    style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ),
              _CardContainer(
                child: Column(
                  children: const [
                    _AttachmentTile(
                      name: 'Full Inspection Report.pdf',
                      size: '2.4 MB',
                      leadingColor: Color(0xFFEF4444),
                      icon: Iconsax.document_text,
                      downloadable: true,
                    ),
                    _Divider(),
                    _AttachmentTile(
                      name: 'Vehicle Photos.zip',
                      size: '15.2 MB',
                      leadingColor: Color(0xFF7C3AED),
                      icon: Iconsax.folder_2,
                      downloadable: true,
                      chevron: true,
                    ),
                    _Divider(),
                    _AttachmentTile(
                      name: 'Maintenance History.pdf',
                      size: '1.1 MB',
                      leadingColor: Color(0xFF06B6D4),
                      icon: Iconsax.document_download,
                      downloadable: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Sticky bottom actions
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.document_download, size: 18),
                label: const Text('Download Report',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Iconsax.share, size: 18, color: Color(0xFF7C3AED)),
                label: const Text('Share Report',
                    style: TextStyle(
                        color: Color(0xFF7C3AED), fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF7C3AED)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================== WIDGETS ============================== */

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Text(title,
                style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
          ),
          const _Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(padding: const EdgeInsets.all(8), child: child),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.isLink = false});
  final String label;
  final String value;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isLink ? const Color(0xFF2563EB) : const Color(0xFF111827),
                  fontWeight: isLink ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricOverall extends StatelessWidget {
  const _MetricOverall({required this.score, required this.outOf});
  final String score;
  final String outOf;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text('Overall Score',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
        ),
        Row(
          children: [
            Text(score,
                style: const TextStyle(
                    color: Color(0xFF7C3AED),
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
            Text(' $outOf', style: const TextStyle(color: Color(0xFF6B7280))),
          ],
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.rating,
    required this.desc,
  });

  final String label;
  final String rating;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child:
          Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rating,
                  style: const TextStyle(
                      color: Color(0xFF111827), fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                desc,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Color(0xFF9CA3AF), height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.name,
    required this.size,
    required this.leadingColor,
    required this.icon,
    this.downloadable = false,
    this.chevron = false,
  });

  final String name;
  final String size;
  final Color leadingColor;
  final IconData icon;
  final bool downloadable;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: leadingColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: leadingColor, size: 20),
      ),
      title: Text(name,
          style: const TextStyle(
              color: Color(0xFF111827), fontWeight: FontWeight.w600)),
      subtitle: Text(size, style: const TextStyle(color: Color(0xFF6B7280))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (downloadable)
            IconButton(
              onPressed: () {},
              icon: const Icon(Iconsax.arrow_down_1, size: 18, color: Color(0xFF6B7280)),
              tooltip: 'Download',
            ),
          if (chevron)
            const Icon(Iconsax.arrow_right_3, size: 18, color: Color(0xFF9CA3AF)),
        ],
      ),
      onTap: () {},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 20, thickness: 1, color: Color(0xFFF0F2F5));
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}
