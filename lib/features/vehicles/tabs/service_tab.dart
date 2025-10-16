import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void main() => runApp(const VehicleDetailsServiceApp());

class VehicleDetailsServiceApp extends StatelessWidget {
  const VehicleDetailsServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicle Details',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins', // ensure Poppins in pubspec
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
      home: const VehicleDetailsServiceScreen(),
    );
  }
}

class VehicleDetailsServiceScreen extends StatelessWidget {
  const VehicleDetailsServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 4,
      initialIndex: 1, // Service History selected
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vehicle Details'),
          leading: IconButton(onPressed: () {}, icon: const Icon(Iconsax.arrow_left_2)),
          actions: const [Padding(padding: EdgeInsets.only(right: 6), child: Icon(Iconsax.more))],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Theme.of(context).dividerColor),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Iconsax.add, color: Colors.white),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // hero image placeholder
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _ImagePlaceholder(),
                ),
              ),
              // title + meta
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
              // tabs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
                  child: _TabsBar(),
                ),
              ),

              // tab views
              SliverFillRemaining(
                hasScrollBody: true,
                child: TabBarView(
                  children: [
                    // Overview
                    _EmptyStub(text: 'Overview coming soon'),
                    // Service History
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                      children: const [
                        _ServiceCard(
                          title: 'Oil Change Service',
                          date: 'Mar 15, 2024',
                          mileage: '45,230 mi',
                          workshop: 'AutoCare Center',
                          cost: '\$89.99',
                          status: _ServiceStatus.completed,
                        ),
                        SizedBox(height: 14),
                        _ServiceCard(
                          title: 'Brake Pad Replacement',
                          date: 'Feb 28, 2024',
                          mileage: '44,850 mi',
                          workshop: 'Premium Auto Service',
                          cost: '\$320.50',
                          status: _ServiceStatus.completed,
                        ),
                        SizedBox(height: 14),
                        _ServiceCard(
                          title: 'Tire Rotation',
                          date: 'Mar 12, 2024',
                          mileage: '43,920 mi',
                          workshop: 'Quick Lube Express',
                          cost: '\$45.00',
                          status: _ServiceStatus.due,
                        ),
                        SizedBox(height: 18),
                        _ServiceDetailCard(
                          title: 'Annual Service',
                          status: _ServiceStatus.completed,
                          rows: [
                            _KV('Date', 'Aug 15, 2023'),
                            _KV('Mileage', '38,900 km'),
                            _KV('Workshop', 'BMW Service Center'),
                            _KV('Cost', '\$350'),
                            _KV('Status', ''),
                          ],
                        ),
                      ],
                    ),
                    // Documents
                    _EmptyStub(text: 'Documents coming soon'),
                    // Reports
                    _EmptyStub(text: 'Reports coming soon'),
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

enum _ServiceStatus { completed, due }

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final _ServiceStatus status;

  @override
  Widget build(BuildContext context) {
    final isDone = status == _ServiceStatus.completed;
    final bg = isDone ? const Color(0xFFEAFBF0) : const Color(0xFFFFF2CC);
    final fg = isDone ? const Color(0xFF168A45) : const Color(0xFF946200);
    final text = isDone ? 'Completed' : 'Due';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.title,
    required this.date,
    required this.mileage,
    required this.workshop,
    required this.cost,
    required this.status,
  });

  final String title;
  final String date;
  final String mileage;
  final String workshop;
  final String cost;
  final _ServiceStatus status;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6E8ED)),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title + status chip + chevron
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(title,
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: status),
                const SizedBox(width: 8),
                const Icon(Iconsax.arrow_right_3, color: Color(0xFF98A2B3)),
              ],
            ),
            const SizedBox(height: 8),
            // date / mileage row
            Row(
              children: [
                Text(date, style: const TextStyle(color: Color(0xFF6B7280))),
                const _DotDivider(),
                Text(mileage, style: const TextStyle(color: Color(0xFF6B7280))),
              ],
            ),
            const SizedBox(height: 12),
            // workshop + cost rows
            Row(
              children: const [
                Icon(Iconsax.setting_2, size: 18, color: Color(0xFF98A2B3)),
                SizedBox(width: 8),
                Expanded(child: Text('AutoCare Center', style: TextStyle(color: Color(0xFF344054)))),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Iconsax.dollar_square, size: 18, color: Color(0xFF98A2B3)),
                const SizedBox(width: 8),
                Text(cost, style: const TextStyle(color: Color(0xFF344054))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KV {
  final String k;
  final String v;
  const _KV(this.k, this.v);
}

class _ServiceDetailCard extends StatelessWidget {
  const _ServiceDetailCard({
    required this.title,
    required this.status,
    required this.rows,
  });

  final String title;
  final _ServiceStatus status;
  final List<_KV> rows;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E8ED)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              ),
              _StatusBadge(status: status),
              const SizedBox(width: 8),
              const Icon(Iconsax.arrow_right_3, color: Color(0xFF98A2B3)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          ...rows.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(e.k, style: const TextStyle(color: Color(0xFF6B7280))),
                ),
                Text(e.v, style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _EmptyStub extends StatelessWidget {
  const _EmptyStub({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text, style: const TextStyle(color: Color(0xFF98A2B3))));
  }
}
