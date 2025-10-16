// lib/features/reports/ui/report_builder_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ReportBuilderScreen extends StatefulWidget {
  const ReportBuilderScreen({super.key});

  @override
  State<ReportBuilderScreen> createState() => _ReportBuilderScreenState();
}

class _ReportBuilderScreenState extends State<ReportBuilderScreen> {
  String? _selectedVehicle;
  String _format = 'PDF Document';

  final Map<String, bool> _sections = {
    'Overview': true,
    'Service History': true,
    'Documents': false,
    'AI Report': true,
  };

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
          'Report Builder',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header icon + title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1E8FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.document_upload5, color: Color(0xFF7C3AED), size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text('Create Your Report',
                        style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      'Select the sections you want to include in your\nreport. Toggle on the sections you need.',
                      textAlign: TextAlign.center,
                      style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280), height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              Text('Report Sections',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),

              const Text('Vehicle',
                  style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE6E8ED)),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedVehicle,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  hint: const Text('Select vehicle'),
                  icon: const Icon(Iconsax.arrow_down_1),
                  items: const [
                    DropdownMenuItem(value: 'Toyota RAV4', child: Text('Toyota RAV4')),
                    DropdownMenuItem(value: 'Honda Civic', child: Text('Honda Civic')),
                    DropdownMenuItem(value: 'Mazda CX-5', child: Text('Mazda CX-5')),
                  ],
                  onChanged: (v) => setState(() => _selectedVehicle = v),
                ),
              ),
              const SizedBox(height: 20),

              ..._sections.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SectionTile(
                  title: e.key,
                  subtitle: _subtitleFor(e.key),
                  icon: _iconFor(e.key),
                  iconBg: _colorFor(e.key),
                  value: e.value,
                  onChanged: (v) => setState(() => _sections[e.key] = v),
                ),
              )),

              const SizedBox(height: 20),

              Text('Report Options',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),

              const Text('Format',
                  style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE6E8ED)),
                ),
                child: DropdownButtonFormField<String>(
                  value: _format,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  icon: const Icon(Iconsax.arrow_down_1),
                  items: const [
                    DropdownMenuItem(value: 'PDF Document', child: Text('PDF Document')),
                    DropdownMenuItem(value: 'Word Document', child: Text('Word Document')),
                  ],
                  onChanged: (v) => setState(() => _format = v!),
                ),
              ),

              const SizedBox(height: 22),

              Text('Report Summary',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),

              Text(
                'Selected sections: ${_sections.values.where((v) => v).length} of ${_sections.length}',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _sections.entries
                    .where((e) => e.value)
                    .map((e) => Chip(
                  label: Text(e.key),
                  labelStyle: const TextStyle(
                      color: Color(0xFF7C3AED), fontWeight: FontWeight.w600),
                  backgroundColor: const Color(0xFFF1E8FF),
                ))
                    .toList(),
              ),
              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Report will be generated and sent to your email',
                  style: t.bodySmall?.copyWith(color: const Color(0xFF9CA3AF)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              shadowColor: const Color(0xFF7C3AED).withOpacity(0.3),
            ),
            onPressed: () {},
            child: const Text('Generate Report',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  /* --------------------------- Helpers ---------------------------- */

  String _subtitleFor(String section) {
    switch (section) {
      case 'Overview':
        return 'Summary and key metrics';
      case 'Service History':
        return 'Past service records';
      case 'Documents':
        return 'Related files and attachments';
      case 'AI Report':
        return 'AI-generated insights';
      default:
        return '';
    }
  }

  IconData _iconFor(String section) {
    switch (section) {
      case 'Overview':
        return Iconsax.chart_15;
      case 'Service History':
        return Iconsax.activity;
      case 'Documents':
        return Iconsax.document_text;
      case 'AI Report':
        return Iconsax.cpu;
      default:
        return Iconsax.category;
    }
  }

  Color _colorFor(String section) {
    switch (section) {
      case 'Overview':
        return const Color(0xFFEFF4FF);
      case 'Service History':
        return const Color(0xFFEFFAF3);
      case 'Documents':
        return const Color(0xFFFFF7E8);
      case 'AI Report':
        return const Color(0xFFF1E8FF);
      default:
        return const Color(0xFFE6E8ED);
    }
  }
}

/* --------------------------- Section Tile ---------------------------- */

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8ED)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: const Color(0xFF111827), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.3)),
                Text(subtitle, style: t.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
              ],
            ),
          ),
          Switch(
            activeColor: const Color(0xFF7C3AED),
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
