// lib/features/vehicles/screens/vehicles_list_screen.dart
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Routes
import '../../../app.dart' show Routes;

// Domain model
import '../models/vehicle_model.dart';

// Centralized Firestore accessor
import '../../../firestore_service.dart'; // exposes FirestoreService.db

void _d(String msg, {Object? err, StackTrace? st, String tag = 'Vehicles'}) {
  if (kDebugMode) dev.log(msg, name: tag, error: err, stackTrace: st);
}

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  String _filter = 'All';
  final _searchCtrl = TextEditingController();

  // optional force-rebuild key for manual refresh
  int _reloadKey = 0;

  Query<Map<String, dynamic>> _buildQuery() {
    final db = FirestoreService.db;

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
        break; // All
    }

    // deterministic order; if filtering on status + ordering on created_at, you’ll need a composite index
    q = q.orderBy('created_at', descending: true);

    _d('Query built | filter=$_filter');
    return q;
  }

  Future<void> _refresh() async {
    _d('Manual refresh requested');
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
      setState(() {}); // local search, client-side
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
                      _d('Back pressed → go to Dashboard');
                      Get.offAllNamed(Routes.app);
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
                  Text(
                    'Vehicles',
                    style: t.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _d('Notifications tap (noop)'),
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

            // Filters
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
                  key: ValueKey(_reloadKey), // pressing Refresh rebuilds
                  stream: _buildQuery().snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      _d('Stream error: ${snap.error}');
                      return Center(child: Text('Error: ${snap.error}'));
                    }

                    final rawDocs = snap.data?.docs ?? [];

                    // Map into domain models with schema guard
                    final models = <VehicleModel>[];
                    for (final d in rawDocs) {
                      try {
                        final data = d.data();

                        // guard for dealership key inconsistency (legacy docs)
                        data['dealershipId'] =
                            data['dealershipId'] ?? data['dealership_id'];

                        final vm = VehicleModel.fromDoc(d);
                        models.add(vm);
                      } catch (e, st) {
                        _d('Doc parse failed id=${d.id} → $e', err: e, st: st);
                      }
                    }

                    // Client-side search filter
                    final q = _searchCtrl.text.trim().toLowerCase();
                    final filtered = q.isEmpty
                        ? models
                        : models.where((m) {
                      final haystack = [
                        m.make,
                        m.model,
                        m.vin ?? '',
                        m.trim,
                        m.fuelType,
                        m.year?.toString() ?? '',
                        m.registrationNumber ?? '',
                      ].join(' ').toLowerCase();
                      return haystack.contains(q);
                    }).toList();

                    _d('Render list | total=${models.length} filtered=${filtered.length}');

                    if (filtered.isEmpty) {
                      // Empty state
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
                            onPressed: () async {
                              _d('CTA Add Vehicle from empty state');
                              await Get.toNamed(
                                Routes.vehicleadd,
                                parameters: {'source': 'vehicles_list'},
                                preventDuplicates: true,
                              );
                            },
                          ),
                        ),
                      );
                    }

                    // List (cards)
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final v = filtered[i];

                        final title = '${v.make} ${v.model}'.trim();
                        final year = v.year?.toString() ?? '';
                        final type = _prettyFuel(v.fuelType);
                        final vin = v.vin ?? '';
                        final status = _prettyStatus(v.status);

                        void _goToDetails() {
                          if (v.id.isEmpty) return;
                          _d('Navigate → details id=${v.id}');
                          Get.toNamed(
                            Routes.vehicleDetails, // singular, consistent
                            parameters: {'id': v.id},
                            preventDuplicates: true,
                          );
                        }

                        return _VehicleCard(
                          title: title,
                          year: year,
                          type: type,
                          vin: vin,
                          status: status,
                          onTap: _goToDetails, // whole tile navigates
                          onArrowTap: _goToDetails, // chevron navigates too
                        );
                      },
                    );
                  },
                ),
              ),
            ),
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
      case 'active':
        return 'Complete'; // UI label
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
    this.onArrowTap,
  });

  final String title;
  final String year;
  final String type;
  final String vin;
  final String status;
  final VoidCallback? onTap;
  final VoidCallback? onArrowTap;

  Color _badgeBg() {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFFF7E8);
      case 'Complete':
        return const Color(0xFFEFFAF3);
      case 'Sold':
        return const Color(0xFFEFF4FF);
      default:
        return const Color(0xFFF2F4F7);
    }
  }

  Color _badgeFg() {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Complete':
        return const Color(0xFF16A34A);
      case 'Sold':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF475467);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap, // whole tile press
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
                  Text(title, style: t.titleLarge?.copyWith(color: const Color(0xFF0F172A))),
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
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onArrowTap ?? onTap, // chevron also navigates
                  child: Icon(Icons.chevron_right, color: Colors.black.withOpacity(0.5)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
