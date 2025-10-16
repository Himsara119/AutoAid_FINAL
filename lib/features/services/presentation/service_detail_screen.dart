import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void main() => runApp(const ServiceDetailFixedApp());

class ServiceDetailFixedApp extends StatelessWidget {
  const ServiceDetailFixedApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Service Detail',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(seedColor: purple, primary: purple, surface: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF111827),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const ServiceDetailScreen(),
    );
  }
}

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: const Icon(Iconsax.arrow_left_2)),
        title: const Text(''), // leave blank so title shows in body
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE7E9EF)),
        ),
      ),

      bottomNavigationBar: const _BottomActions(),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            // Title + badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Oil Change',
                    style: t.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800, fontSize: 26, color: const Color(0xFF111827))),
                const _StatusBadgeCompleted(),
              ],
            ),
            const SizedBox(height: 16),

            _RoundedSection(
              child: Column(
                children: const [
                  _KVRow(label: 'Date', value: 'March 15, 2024'),
                  _DividerThin(),
                  _KVRow(label: 'Mileage', value: '45,230 miles'),
                  _DividerThin(),
                  _KVRow(label: 'Cost', value: '\$89.99'),
                  _DividerThin(),
                  _KVRow(label: 'Workshop', value: 'Quick Lube Express'),
                  _DividerThin(),
                  _KVRow(label: 'Next Service', value: 'June 15, 2024'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _CardBlock(
              header: Text('Notes', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              child: const Text(
                'Regular maintenance service completed. Oil filter replaced with premium grade filter. '
                    'Engine oil changed to 5W-30 synthetic blend. '
                    'All fluid levels checked and topped off. No issues detected during inspection.',
                style: TextStyle(color: Color(0xFF374151), height: 1.6, fontSize: 15),
              ),
            ),

            const SizedBox(height: 16),

            _CardBlock(
              header: Text('Invoice', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              child: const _FileTile(
                icon: Iconsax.document_text,
                fileName: 'oil-change-receipt.pdf',
                sizeText: '124 KB',
                actionText: 'View',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- Widgets ---------------- */

class _StatusBadgeCompleted extends StatelessWidget {
  const _StatusBadgeCompleted({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAFBF0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.tick_circle, size: 16, color: Color(0xFF168A45)),
          SizedBox(width: 8),
          Text('Completed', style: TextStyle(color: Color(0xFF168A45), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RoundedSection extends StatelessWidget {
  const _RoundedSection({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8ED)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: child,
    );
  }
}

class _DividerThin extends StatelessWidget {
  const _DividerThin({super.key});
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFE6E8ED));
  }
}

class _KVRow extends StatelessWidget {
  const _KVRow({required this.label, required this.value, super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700))),
          Text(value,
              style:
              const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  const _CardBlock({required this.header, required this.child, super.key});
  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE6E8ED)),
          ),
          padding: const EdgeInsets.all(14),
          child: child,
        ),
      ],
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.icon,
    required this.fileName,
    required this.sizeText,
    required this.actionText,
    super.key,
  });

  final IconData icon;
  final String fileName;
  final String sizeText;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(sizeText, style: const TextStyle(color: Color(0xFF6B7280))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(actionText, style: TextStyle(color: primary, fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          const Icon(Iconsax.arrow_right_3, color: Color(0xFF98A2B3)),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE7E9EF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('Edit Record'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
