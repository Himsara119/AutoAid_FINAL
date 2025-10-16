import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void main() => runApp(const VehicleOverviewApp());

class VehicleOverviewApp extends StatelessWidget {
  const VehicleOverviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicle Details',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(seedColor: purple, primary: purple),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
        ),
      ),
      home: const VehicleOverviewScreen(),
    );
  }
}

class VehicleOverviewScreen extends StatelessWidget {
  const VehicleOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vehicle Details'),
          leading: IconButton(icon: const Icon(Iconsax.arrow_left_2), onPressed: () {}),
          actions: const [Padding(padding: EdgeInsets.only(right: 8), child: Icon(Iconsax.more))],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFE7E9EF)),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: c.primary,
          child: const Icon(Iconsax.edit_2, color: Colors.white),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Vehicle image
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _ImagePlaceholder(),
                ),
              ),
              // Vehicle basic info
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
                          _MetaText(text: '2022'),
                          _Dot(),
                          _MetaText(text: 'XLE AWD'),
                          _Dot(),
                          _MetaText(text: '32,450 miles'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          _StatusDot(color: Color(0xFF16A34A)),
                          SizedBox(width: 8),
                          Text('Excellent Condition', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Tabs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
                  child: _TabsBar(),
                ),
              ),
              // Tab View
              SliverFillRemaining(
                hasScrollBody: true,
                child: TabBarView(
                  children: [
                    // Overview tab content
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _OverviewBox(title: '32,450', subtitle: 'Miles'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _OverviewBox(title: '8.2/10', subtitle: 'Condition Score'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text('Specifications',
                            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 17)),
                        const SizedBox(height: 12),
                        const _SpecRow(label: 'Engine', value: '2.5L 4-Cylinder'),
                        const _SpecRow(label: 'Transmission', value: '8-Speed Automatic'),
                        const _SpecRow(label: 'Drivetrain', value: 'All-Wheel Drive'),
                        const _SpecRow(label: 'Fuel Economy', value: '27/35 MPG'),
                        const _SpecRow(label: 'VIN', value: '2T3N1RFV8NC123456'),
                        const SizedBox(height: 24),
                        Text('Key Features',
                            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 17)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 40,
                          runSpacing: 10,
                          children: const [
                            _Feature(text: 'Sunroof'),
                            _Feature(text: 'Heated Seats'),
                            _Feature(text: 'Backup Camera'),
                            _Feature(text: 'Bluetooth'),
                            _Feature(text: 'Keyless Entry'),
                            _Feature(text: 'Lane Assist'),
                          ],
                        ),
                      ],
                    ),
                    _EmptyTab(text: 'Service history coming soon'),
                    _EmptyTab(text: 'Documents coming soon'),
                    _EmptyTab(text: 'Reports coming soon'),
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

/* ------------------- Mini Widgets ------------------- */

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9DEE8)),
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

class _MetaText extends StatelessWidget {
  const _MetaText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Color(0xFF475467), fontWeight: FontWeight.w600));
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('•', style: TextStyle(color: Color(0xFF98A2B3))),
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

class _OverviewBox extends StatelessWidget {
  const _OverviewBox({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  const _SpecRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF6B7280)))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Iconsax.tick_circle, color: Color(0xFF16A34A), size: 18),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Color(0xFF111827))),
      ],
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, style: const TextStyle(color: Color(0xFF9CA3AF))));
  }
}
