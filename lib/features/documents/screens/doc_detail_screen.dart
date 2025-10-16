import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void main() => runApp(const DocumentThesis());

class DocumentThesis extends StatelessWidget {
  const DocumentThesis({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Insurance Policy',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        colorScheme: ColorScheme.fromSeed(seedColor: purple, primary: purple),
      ),
      home: const InsurancePolicyScreen(),
    );
  }
}

class InsurancePolicyScreen extends StatelessWidget {
  const InsurancePolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: c.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(Iconsax.shield, color: c.primary),
            ),
            const SizedBox(width: 10),
            Text('Insurance Policy',
                style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            const Icon(Iconsax.more),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Badge(text: 'Expiring Soon', color: const Color(0xFFFFEAD5)),
              const SizedBox(height: 16),

              // Document Name
              const _InfoTile(
                label: 'Document Name',
                value: 'Comprehensive Auto Insurance',
              ),
              const SizedBox(height: 10),

              // Issuer
              const _InfoTile(
                label: 'Issuer',
                value: 'State Farm Insurance',
              ),
              const SizedBox(height: 10),

              // Policy Number
              const _InfoTile(
                label: 'Policy Number',
                value: 'SF-2024-789456123',
              ),
              const SizedBox(height: 10),

              // Issue Date
              const _InfoTile(
                label: 'Issue Date',
                value: 'March 15, 2024',
              ),
              const SizedBox(height: 10),

              // Expiry Date
              const _InfoTile(
                label: 'Expiry Date',
                value: 'March 15, 2025',
                valueColor: Color(0xFFF97316),
              ),
              const SizedBox(height: 10),

              // Notes
              const _NotesTile(
                label: 'Notes',
                text:
                'Comprehensive coverage with \$500 deductible. Includes collision, theft, and natural disaster protection. Remember to update mileage annually.',
              ),
              const SizedBox(height: 18),

              // File Card
              const _FileCard(
                fileName: 'auto_insurance_policy_2024.pdf',
                size: '2.4 MB',
              ),
              const SizedBox(height: 18),

              // Reminder
              const _ReminderTile(
                title: 'Remind me before expiry',
                subtitle: '30 days before expiration',
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: _PrimaryButton(
                      text: 'Preview',
                      icon: Iconsax.eye,
                      color: c.primary,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Preview pressed')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OutlineButton(
                      text: 'Replace File',
                      icon: Iconsax.export_1,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Replace pressed')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================== MINI WIDGETS ============================== */

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.clock, size: 16, color: Color(0xFFB45309)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFB45309),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8ED)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: t.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3, size: 18, color: Color(0xFF98A2B3)),
        ],
      ),
    );
  }
}

class _NotesTile extends StatelessWidget {
  const _NotesTile({required this.label, required this.text});
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: t.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 6),
          Text(
            text,
            style: t.bodyMedium?.copyWith(
              color: const Color(0xFF111827),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  const _FileCard({required this.fileName, required this.size});
  final String fileName;
  final String size;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5E5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Iconsax.document, color: Color(0xFFE11D48)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(size,
                    style: t.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3, size: 18, color: Color(0xFF98A2B3)),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Iconsax.notification, color: Color(0xFF94A3B8)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: t.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: t.titleMedium?.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: const Color(0xFF111827)),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: Color(0xFFE6E8ED)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        foregroundColor: const Color(0xFF111827),
      ),
    );
  }
}
