// lib/features/vehicles/ui/vehicle_details_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class VehicleDocumentScreen extends StatefulWidget {
  const VehicleDocumentScreen({super.key});

  @override
  State<VehicleDocumentScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDocumentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this, initialIndex: 2); // Documents selected
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

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
        title: const Text(
          'Vehicle Details',
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Color(0xFF111827)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {},
        child: const Icon(Iconsax.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo placeholder
              _DashedCard(
                child: SizedBox(
                  height: 148,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1E8FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF7C3AED), size: 26),
                      ),
                      const SizedBox(height: 8),
                      Text('No image selected',
                          style: t.bodyMedium?.copyWith(color: const Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title + meta
              Text('Toyota RAV4', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Row(
                children: [
                  _meta('2022'),
                  _dot(),
                  _meta('XLE AWD'),
                  _dot(),
                  _meta('32,450 miles'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  _ConditionDot(color: Color(0xFF16A34A)),
                  SizedBox(width: 6),
                  Text('Excellent Condition', style: TextStyle(color: Color(0xFF16A34A))),
                ],
              ),
              const SizedBox(height: 16),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE6E8ED)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: TabBar(
                  controller: _tab,
                  isScrollable: true,
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(color: Color(0xFF7C3AED), width: 2.4),
                    insets: EdgeInsets.symmetric(horizontal: 14),
                  ),
                  labelColor: const Color(0xFF111827),
                  unselectedLabelColor: const Color(0xFF6B7280),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Service History'),
                    Tab(text: 'Documents'),
                    Tab(text: 'Reports'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Documents list (mock data)
              ..._docs.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DocumentTile(doc: d),
              )),

              // Info banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDCE5FE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Keep your documents up to date',
                              style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            'Uploading a renewal helps you avoid lapses or fines. '
                                'Supported formats: .pdf, .jpg, .png (max 10MB).',
                            style: t.bodySmall?.copyWith(color: const Color(0xFF6B7280), height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _meta(String text) => Text(
    text,
    style: const TextStyle(color: Color(0xFF6B7280)),
  );

  static Widget _dot() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Text('•', style: TextStyle(color: Color(0xFF9CA3AF))),
  );
}

/* ----------------------------- MODELS & DATA ----------------------------- */

enum DocStatus { valid, expiring, expired, none }

class DocItem {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String issuer;
  final String number;
  final String issue;
  final String expires;
  final DocStatus status;

  const DocItem({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.issuer,
    required this.number,
    required this.issue,
    required this.expires,
    this.status = DocStatus.none,
  });
}

const _docs = <DocItem>[
  DocItem(
    icon: Iconsax.shield_tick,
    iconBg: Color(0xFFEFFAF3),
    title: 'Insurance Policy',
    issuer: 'Esure Farm Insurance',
    number: 'Policy: JN-1298',
    issue: 'Issued: Jan 18, 2024',
    expires: 'Expires: Jan 18, 2025',
    status: DocStatus.valid,
  ),
  DocItem(
    icon: Iconsax.note_21,
    iconBg: Color(0xFFEFF4FF),
    title: 'Vehicle Registration',
    issuer: 'Department of Motor Vehicles',
    number: 'Issue No: 3421',
    issue: 'Issued: Mar 28, 2023',
    expires: 'Expires: Mar 28, 2025',
    status: DocStatus.valid,
  ),
  DocItem(
    icon: Iconsax.flash_1,
    iconBg: Color(0xFFFFF7E8),
    title: 'Emission Test Certificate',
    issuer: 'California Air Resources Board',
    number: 'Result: PASS',
    issue: 'Issued: Aug 12, 2024',
    expires: 'Expires: Aug 12, 2025',
    status: DocStatus.expiring,
  ),
  DocItem(
    icon: Iconsax.crown_1,
    iconBg: Color(0xFFF2F0FF),
    title: 'Extended Warranty',
    issuer: 'Runy Financial Services',
    number: 'Contract: FLS-98',
    issue: 'Issued: Feb 1, 2022',
    expires: 'Expires: Feb 1, 2026',
    status: DocStatus.valid,
  ),
  DocItem(
    icon: Iconsax.search_favorite_1,
    iconBg: Color(0xFFFFEEEE),
    title: 'Safety Inspection',
    issuer: 'Authorized Service Center',
    number: 'Invoice: 8852',
    issue: 'Issued: Dec 5, 2023',
    expires: 'Expired: Dec 5, 2024',
    status: DocStatus.expired,
  ),
  DocItem(
    icon: Iconsax.document_text,
    iconBg: Color(0xFFEFF4FF),
    title: 'Vehicle Title',
    issuer: 'Department of Motor Vehicles',
    number: 'Title No: TX-9091',
    issue: 'Issued: Nov 10, 2022',
    expires: 'No expiry',
  ),
  DocItem(
    icon: Iconsax.bank,
    iconBg: Color(0xFFEFFAF3),
    title: 'Loan Agreement',
    issuer: 'Union Auto Finance',
    number: 'Loan: AP-5031',
    issue: 'Issued: Jan 5, 2023',
    expires: 'Term: 60 months',
    status: DocStatus.valid,
  ),
  DocItem(
    icon: Iconsax.book,
    iconBg: Color(0xFFEFF4FF),
    title: "Owner's Manual",
    issuer: 'BMW Group',
    number: 'BMW RAV4 - PDF v5.2',
    issue: 'Uploaded: Apr 10, 2024',
    expires: '',
  ),
];

/* ------------------------------ UI WIDGETS ------------------------------- */

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.doc});
  final DocItem doc;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: doc.iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(doc.icon, color: const Color(0xFF111827), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(doc.title,
                          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                    _StatusChip(status: doc.status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(doc.issuer, style: t.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(doc.number,
                          style: t.bodySmall?.copyWith(color: const Color(0xFF111827))),
                    ),
                    Expanded(
                      child: Text(doc.issue,
                          style: t.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
                    ),
                    Expanded(
                      child: Text(doc.expires,
                          textAlign: TextAlign.right,
                          style: t.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            children: [
              IconButton(
                tooltip: 'Download',
                icon: const Icon(Iconsax.import_3, size: 18, color: Color(0xFF6B7280)),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Share',
                icon: const Icon(Iconsax.export_1, size: 18, color: Color(0xFF6B7280)),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final DocStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == DocStatus.none) return const SizedBox.shrink();

    Color bg, fg;
    String text;
    switch (status) {
      case DocStatus.valid:
        bg = const Color(0xFFEFFAF3);
        fg = const Color(0xFF16A34A);
        text = 'Valid';
        break;
      case DocStatus.expiring:
        bg = const Color(0xFFFFF7E8);
        fg = const Color(0xFFF59E0B);
        text = 'Expiring Soon';
        break;
      case DocStatus.expired:
        bg = const Color(0xFFFFEEEE);
        fg = const Color(0xFFEF4444);
        text = 'Expired';
        break;
      default:
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF6B7280);
        text = '';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class _ConditionDot extends StatelessWidget {
  const _ConditionDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/* --------------------------- Dashed card painter -------------------------- */

class _DashedCard extends StatelessWidget {
  const _DashedCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0xFFE2E5EA),
        radius: 14,
        dashLength: 6,
        gapLength: 6,
        strokeWidth: 1.2,
      ),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(10),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double dashLength;
  final double gapLength;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final len = dashLength.clamp(0, metric.length - distance);
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
