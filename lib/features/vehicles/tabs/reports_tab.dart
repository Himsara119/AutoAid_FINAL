import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void main() => runApp(const VehicleDetailsApp());

class VehicleDetailsApp extends StatelessWidget {
  const VehicleDetailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicle Details',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins', // make sure Poppins is in pubspec
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(seedColor: purple, primary: purple, surface: Colors.white),
        dividerColor: const Color(0xFFE7E9EF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      home: const VehicleDetailsScreen(),
    );
  }
}

class VehicleDetailsScreen extends StatelessWidget {
  const VehicleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 4,
      initialIndex: 3, // Reports tab selected like the mock
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vehicle Details'),
          leading: IconButton(onPressed: () {}, icon: const Icon(Iconsax.arrow_left_2)),
          actions: const [Padding(padding: EdgeInsets.only(right: 6), child: Icon(Iconsax.more)),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Theme.of(context).dividerColor),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: c.primary,
          child: const Icon(Iconsax.add, color: Colors.white),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _ImagePlaceholder(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Toyota RAV4', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 22)),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          _MetaChip(text: '2022'),
                          _DotDivider(),
                          _MetaChip(text: 'XLE AWD'),
                          _DotDivider(),
                          _MetaChip(text: '32,450 miles'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          _StatusDot(color: Color(0xFF16A34A)),
                          SizedBox(width: 8),
                          Text('Excellent Condition', style: TextStyle(color: Color(0xFF111827))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
                  child: _TabsBar(),
                ),
              ),
              // Reports list (TabBarView pinned below)
              SliverFillRemaining(
                hasScrollBody: true,
                child: TabBarView(
                  children: [
                    // Overview
                    _EmptyStub(text: 'Overview coming soon'),
                    // Service History
                    _EmptyStub(text: 'Service history coming soon'),
                    // Documents
                    _EmptyStub(text: 'Documents coming soon'),
                    // Reports
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      children: const [
                        _ReportCard(
                          icon: Iconsax.clipboard_text,
                          title: 'Condition Report',
                          subtitle: 'Generated on Dec 15, 2024',
                        ),
                        SizedBox(height: 12),
                        _ReportCard(
                          icon: Iconsax.pen_tool,
                          title: 'Service Summary',
                          subtitle: 'Generated on Dec 12, 2024',
                        ),
                        SizedBox(height: 12),
                        _ReportCard(
                          icon: Iconsax.activity,
                          title: 'Resale Report',
                          subtitle: 'Generated on Dec 10, 2024',
                        ),
                        SizedBox(height: 12),
                        _ReportCard(
                          icon: Iconsax.shield_tick,
                          title: 'Insurance Report',
                          subtitle: 'Generated on Dec 8, 2024',
                        ),
                        SizedBox(height: 12),
                        _ReportCard(
                          icon: Iconsax.rotate_left,
                          title: 'History Report',
                          subtitle: 'Generated on Dec 5, 2024',
                        ),
                        SizedBox(height: 12),
                        _ReportCard(
                          icon: Iconsax.dollar_circle,
                          title: 'Valuation Report',
                          subtitle: 'Generated on Dec 1, 2024',
                        ),
                      ],
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
}

/* ============================== MINI WIDGETS ============================== */

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dashed borders in Flutter require decoration_painter; we’ll keep it minimal and clean.
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9DEE8)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFEFF1F6),
            child: Icon(Iconsax.camera, color: Color(0xFF98A2B3), size: 28),
          ),
          SizedBox(height: 10),
          Text('No image selected', style: TextStyle(color: Color(0xFF98A2B3))),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Color(0xFF475467), fontWeight: FontWeight.w600));
  }
}

class _DotDivider extends StatelessWidget {
  const _DotDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text('•', style: TextStyle(color: Color(0xFF98A2B3), fontSize: 16)),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _TabsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return TabBar(
      isScrollable: true,
      labelColor: c.primary,
      unselectedLabelColor: const Color(0xFF6B7280),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      indicatorColor: c.primary,
      indicatorWeight: 3,
      tabs: const [
        Tab(text: 'Overview'),
        Tab(text: 'Service History'),
        Tab(text: 'Documents'),
        Tab(text: 'Reports'),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

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
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: c.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  Text(subtitle, style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Iconsax.import), // download-like glyph
              color: const Color(0xFF667085),
              tooltip: 'Download',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStub extends StatelessWidget {
  const _EmptyStub({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: const TextStyle(color: Color(0xFF98A2B3))),
    );
  }
}
