import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// If you generated options, prefer:
// import 'firebase_options.dart';

void _d(String msg, {Object? err, StackTrace? st, String tag = 'Vehicles'}) {
  if (kDebugMode) dev.log(msg, name: tag, error: err, stackTrace: st);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp();
    _d('Firebase.initializeApp() ✓');
  } catch (e, st) {
    _d('Firebase init failed: $e', err: e, st: st);
    rethrow;
  }
  runApp(const VehiclesApp());
}

class VehiclesApp extends StatelessWidget {
  const VehiclesApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicles',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          primary: purple,
          surface: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F6FA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6E8ED)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6E8ED)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: purple, width: 1.2),
          ),
        ),
      ),
      home: const VehiclesScreen(),
    );
  }
}

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  int _tabIndex = 1; // keep your mock vibe
  String _filter = 'All';
  final _searchCtrl = TextEditingController();

  // used to force rebuild of Stream when you press Refresh
  int _reloadKey = 0;

  Query<Map<String, dynamic>> _buildQuery() {
    final db = FirebaseFirestore.instance;
    Query<Map<String, dynamic>> q =
    db.collection('vehicles').where('deleted', isEqualTo: false);

    switch (_filter) {
      case 'Active':
        q = q.where('status', isEqualTo: 'active');
        break;
      case 'Pending':
        q = q.where('status', isEqualTo: 'pending');
        break;
      default:
      // All
        break;
    }
    // deterministic order
    q = q.orderBy('created_at', descending: true);
    _d('Query built | filter=$_filter');
    return q;
  }

  Future<void> _refresh() async {
    _d('Manual refresh requested');
    // The stream is realtime anyway, but this forces a rebuild
    setState(() => _reloadKey++);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshed')),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      _d('search="${_searchCtrl.text}"');
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      /*bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) {
          _d('BottomNav tapped index=$i');
          setState(() => _tabIndex = i);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: c.primary,
        unselectedItemColor: const Color(0xFF98A2B3),
        backgroundColor: const Color(0xFFF7F7FC),
        items: const [
          BottomNavigationBarItem(icon: Icon(Iconsax.home_1), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Profile'),
        ],
      ),*/
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _d('Back pressed');
                      Navigator.of(context).maybePop();
                    },
                    icon: const Icon(Iconsax.arrow_left_2),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Iconsax.car, color: c.primary),
                  ),
                  const SizedBox(width: 10),
                  Text('Vehicles',
                      style: t.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      )),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      _d('Notifications tap (noop)');
                    },
                    icon: const Icon(Iconsax.notification),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: _refresh,
                    icon: const Icon(Iconsax.refresh),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search vehicles...',
                  prefixIcon: Icon(Iconsax.search_normal_1),
                ),
              ),
            ),

            // Filters + funnel
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  _FilterChipPill(
                    label: 'All',
                    selected: _filter == 'All',
                    onTap: () => setState(() => _filter = 'All'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChipPill(
                    label: 'Active',
                    selected: _filter == 'Active',
                    onTap: () => setState(() => _filter = 'Active'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChipPill(
                    label: 'Pending',
                    selected: _filter == 'Pending',
                    onTap: () => setState(() => _filter = 'Pending'),
                  ),
                  const Spacer(),
                  _IconPill(
                    icon: Iconsax.filter,
                    onTap: () => _d('Filter funnel tap'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // List / Empty + pull-to-refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  key: ValueKey(_reloadKey), // so pressing Refresh rebuilds
                  stream: _buildQuery().snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      _d('Stream error: ${snap.error}');
                      return Center(child: Text('Error: ${snap.error}'));
                    }

                    final docs = snap.data?.docs ?? [];
                    final q = _searchCtrl.text.trim().toLowerCase();
                    final filtered = q.isEmpty
                        ? docs
                        : docs.where((d) {
                      final m = d.data();
                      final text = [
                        m['make'] ?? '',
                        m['model'] ?? '',
                        m['vin'] ?? '',
                        m['trim'] ?? '',
                        m['fuel_type'] ?? '',
                      ].join(' ').toLowerCase();
                      return text.contains(q);
                    }).toList();

                    _d('Render list | total=${docs.length} filtered=${filtered.length}');

                    if (filtered.isEmpty) {
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _EmptyState(
                            icon: Iconsax.car,
                            title: 'No vehicles added yet',
                            message:
                            'Add your first vehicle to start tracking maintenance, service records, and more.',
                            buttonText: 'Add Vehicle',
                            onPressed: () {
                              _d('CTA Add Vehicle from empty state');
                              // TODO: navigate to your AddVehicle screen
                              // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddVehicleScreen()));

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Navigate to Add Vehicle')),
                              );
                            },
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final v = filtered[i].data();
                        final title =
                        '${v['make'] ?? ''} ${v['model'] ?? ''}'.trim();
                        final year = '${v['year'] ?? ''}';
                        final type = _prettyFuel(v['fuel_type']);
                        final vin = v['vin']?.toString() ?? '';
                        final status = _prettyStatus(v['status']);
                        return _VehicleCard(
                          title: title,
                          year: year,
                          type: type,
                          vin: vin,
                          status: status,
                          onTap: () => _d('Vehicle tap vin=$vin'),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Big “Add Vehicle” button like your mock
            /*SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      _d('CTA Add Vehicle from footer');
                      // TODO: navigate to your AddVehicle screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigate to Add Vehicle')),
                      );
                    },
                    child: const Text('Add Vehicle'),
                  ),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  static String _prettyFuel(dynamic f) {
    final s = (f?.toString() ?? '').toLowerCase();
    switch (s) {
      case 'electric':
        return 'Electric';
      case 'hybrid':
        return 'Hybrid';
      case 'diesel':
        return 'Diesel';
      default:
        return 'Petrol';
    }
  }

  static String _prettyStatus(dynamic s) {
    final v = (s?.toString() ?? '').toLowerCase();
    switch (v) {
      case 'pending':
        return 'Pending';
      case 'sold':
        return 'Sold';
      case 'archived':
        return 'Archived';
      default:
        return 'Complete';
    }
  }
}

/* ============================== MINI WIDGETS ============================== */

class _FilterChipPill extends StatelessWidget {
  const _FilterChipPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        _d('Filter change → $label');
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c.primary.withOpacity(0.15) : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? c.primary.withOpacity(0.4) : const Color(0xFFE6E8ED),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? c.primary : const Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}

class _IconPill extends StatelessWidget {
  const _IconPill({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E8ED)),
        ),
        padding: const EdgeInsets.all(12),
        child: Icon(icon, color: const Color(0xFF475467)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            color: c.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: c.primary, size: 64),
        ),
        const SizedBox(height: 28),
        Text(
          title,
          textAlign: TextAlign.center,
          style: t.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: t.bodyMedium?.copyWith(
            height: 1.5,
            color: const Color(0xFF6B7280),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            child: Text(buttonText),
          ),
        ),
        const SizedBox(height: 26),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.title,
    required this.year,
    required this.type,
    required this.vin,
    required this.status,
    this.onTap,
  });

  final String title;
  final String year;
  final String type;
  final String vin;
  final String status;
  final VoidCallback? onTap;

  Color _badgeBg() {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFFF7E8);
      case 'Complete':
        return const Color(0xFFEFFAF3);
      default:
        return const Color(0xFFEFF4FF);
    }
  }

  Color _badgeFg() {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Complete':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.directions_car_filled_outlined),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: t.titleLarge?.copyWith(color: const Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text(year, style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
                  Text(type, style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
                  Text('VIN:$vin', style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _badgeBg(),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(status, style: t.labelLarge?.copyWith(color: _badgeFg())),
                ),
                const SizedBox(height: 18),
                Icon(Icons.chevron_right, color: Colors.black.withOpacity(0.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
