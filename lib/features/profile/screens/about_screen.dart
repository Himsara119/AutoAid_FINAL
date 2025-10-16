import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void main() => runApp(const _DemoApp());

class _DemoApp extends StatelessWidget {
  const _DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'About • AutoAid',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        colorScheme: ColorScheme.fromSeed(seedColor: purple, primary: purple),
      ),
      home: const AboutScreen(),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
        centerTitle: true,
        title: Text('About',
            style: t.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            )),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // App avatar + name + subtitle
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: c.primary.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(Iconsax.car, color: c.primary, size: 44),
                    ),
                    const SizedBox(height: 14),
                    Text('AutoAid',
                        style: t.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        )),
                    const SizedBox(height: 4),
                    Text(
                      'Your Smart Car Companion',
                      style: t.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Description
              Text(
                'AutoAid is designed to help dealerships and car owners efficiently track vehicles, manage important documents, and generate comprehensive reports. Stay organized and keep your automotive information at your fingertips.',
                textAlign: TextAlign.center,
                style: t.bodyMedium?.copyWith(
                  height: 1.6,
                  color: const Color(0xFF475467),
                ),
              ),

              const SizedBox(height: 22),

              // Version Information
              _SectionCard(
                title: 'Version Information',
                children: const [
                  _InfoRow(label: 'Version', value: '2.1.4'),
                  _InfoRow(label: 'Build', value: '2024.03.15'),
                  _InfoRow(label: 'Last Updated', value: 'March 15, 2024'),
                ],
              ),
              const SizedBox(height: 14),

              // Developed By
              _SectionCard(
                title: 'Developed By',
                children: const [
                  _InfoRow(label: 'Company', value: 'AutoTech Solutions'),
                  _InfoRow(label: 'Location', value: 'San Francisco, CA'),
                  _InfoRow(label: 'Founded', value: '2019'),
                ],
              ),

              const SizedBox(height: 18),

              // Contact
              Text('Contact Support',
                  style: t.titleMedium?.copyWith(
                    color: c.primary,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 10),

              const _ContactTile(
                leadingBg: Color(0xFFF2EAFF),
                leadingIcon: Iconsax.sms,
                title: 'Email Support',
                subtitle: 'support@autoaid.com',
              ),
              const SizedBox(height: 10),
              const _ContactTile(
                leadingBg: Color(0xFFEFF4FF),
                leadingIcon: Iconsax.global,
                title: 'Website',
                subtitle: 'www.autoaid.com',
              ),
              const SizedBox(height: 10),
              const _ContactTile(
                leadingBg: Color(0xFFFFF0EB),
                leadingIcon: Iconsax.call,
                title: 'Support Hotline',
                subtitle: '1-800-AUTOAID',
              ),

              const SizedBox(height: 16),

              // Links
              const _LinkTile(
                icon: Iconsax.shield,
                title: 'Privacy Policy',
              ),
              const SizedBox(height: 10),
              const _LinkTile(
                icon: Iconsax.document_text,
                title: 'Terms of Service',
              ),

              const SizedBox(height: 22),

              // Footer
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================== MINI WIDGETS ============================== */

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: t.titleMedium?.copyWith(
                color: const Color(0xFF7C4DFF),
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE6E8ED)),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: t.bodyMedium?.copyWith(
                  color: const Color(0xFF667085),
                  fontWeight: FontWeight.w600,
                )),
          ),
          Text(value,
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              )),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.leadingBg,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
  });

  final Color leadingBg;
  final IconData leadingIcon;
  final String title;
  final String subtitle;

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
              color: leadingBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(leadingIcon, color: const Color(0xFF7C4DFF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: t.bodyMedium
                        ?.copyWith(color: const Color(0xFF6B7280))),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3, size: 18, color: Color(0xFF98A2B3)),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7C4DFF)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827))),
          ),
          const Icon(Iconsax.arrow_right_3,
              size: 18, color: Color(0xFF98A2B3)),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      children: [
        Text('© 2024 AutoTech Solutions. All rights reserved.',
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(color: const Color(0xFF98A2B3))),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Made with', style: t.bodySmall?.copyWith(color: const Color(0xFF98A2B3))),
            const SizedBox(width: 4),
            const Icon(Icons.favorite, size: 14, color: Color(0xFFE11D48)),
            const SizedBox(width: 4),
            Text('for automotive professionals',
                style: t.bodySmall?.copyWith(color: const Color(0xFF98A2B3))),
          ],
        ),
      ],
    );
  }
}
