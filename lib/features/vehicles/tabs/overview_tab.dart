// lib/features/vehicles/tabs/overview_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/vehicle_detail_controller.dart';
import '../models/vehicle_model.dart';
// If your file actually lives in /ui, change this import accordingly.
import '../screens/edit_vehicle_screen.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final VehicleDetailController ctrl = Get.find<VehicleDetailController>();

    return Obx(() {
      if (ctrl.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (ctrl.error.value != null) {
        return Center(child: Text(ctrl.error.value!, style: const TextStyle(color: Colors.red)));
      }

      final VehicleModel v = ctrl.vehicle.value!;
      // Prefer the ID from the model; if missing, fall back to the controller's id.
      final vehicleId = (v.id != null && v.id!.isNotEmpty) ? v.id! : ctrl.id;

      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
          children: [
            _PriceBox(value: _priceText(v), label: 'Price'),
            const SizedBox(height: 20),

            const _SectionTitle('Specifications'),
            const SizedBox(height: 12),

            _SpecRow(label: 'Year', value: v.year.toString()),
            _SpecRow(label: 'Trim', value: v.trim.isNotEmpty ? v.trim : '—'),
            _SpecRow(label: 'Fuel Type', value: _cap(v.fuelType)),
            _SpecRow(label: 'Mileage', value: v.mileage > 0 ? '${v.mileage} miles' : '—'),
            _SpecRow(label: 'VIN', value: v.vin ?? '—'),
            _SpecRow(label: 'Registration No.', value: v.registrationNumber ?? '—'),
            _SpecRow(label: 'Status', value: _cap(v.status)),
            _SpecRow(label: 'For Sale', value: v.isForSale ? 'Yes' : 'No'),
            _SpecRow(label: 'Dealership', value: v.dealershipId.isNotEmpty ? v.dealershipId : '—'),
            _SpecRow(label: 'Current Owner', value: v.currentOwnerId ?? '—'),

            const SizedBox(height: 16),
            Container(height: 1, color: const Color(0xFFE9EDF5)),
            const SizedBox(height: 10),
            Text(
              'Last updated: ${v.updatedAt?.toDate().toLocal() ?? '—'}',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ],
        ),

        // Floating Action Button → Navigate to edit screen
        floatingActionButton: FloatingActionButton(
          backgroundColor: c.primary,
          tooltip: 'Edit Vehicle',
          child: const Icon(Iconsax.edit_2, color: Colors.white),
          onPressed: () async {
            final res = await Get.to(() => EditVehicleScreen(vehicleId: vehicleId));
            // res may be: {'updated': true, 'id': vehicleId} OR {'deleted': true, 'id': vehicleId}
            if (res is Map && res['deleted'] == true) {
              // Edit screen soft-deleted. Pop details and tell the list to drop the tile.
              Get.back(result: {'deleted': true, 'id': vehicleId});
            } else if (res is Map && res['updated'] == true) {
              // Re-fetch the latest doc so overview reflects new values.
              await ctrl.hardReload();
              // Optional toast so user sees feedback on details screen too
              ScaffoldMessenger.of(Get.context!).showSnackBar(
                const SnackBar(content: Text('Vehicle updated')),
              );
            }
          },
        ),
      );
    });
  }
}

/* ------------------------- Helpers & Widgets ------------------------- */

String _priceText(VehicleModel v) {
  if (v.price == null || v.price!.isNaN) return '—';
  final p = v.price!;
  final noCents = p == p.roundToDouble();
  final numStr = noCents ? p.toStringAsFixed(0) : p.toStringAsFixed(2);
  final cur = (v.currency == null || v.currency!.trim().isEmpty) ? '' : ' ${v.currency}';
  return '$numStr$cur';
}

String _cap(String s) {
  if (s.isEmpty) return '—';
  final lower = s.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Text(
      text,
      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 17),
    );
  }
}

class _PriceBox extends StatelessWidget {
  const _PriceBox({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EDF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }
}
