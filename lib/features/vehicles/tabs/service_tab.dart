// lib/features/vehicles/tabs/service_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../app.dart';
import '../../services/presentation/add_service_screen.dart';
import '../../services/presentation/service_detail_screen.dart';
import '../controllers/service_records_controller.dart';
import '../controllers/vehicle_detail_controller.dart';
import '../models/service_record.dart';

class ServiceHistoryTab extends StatelessWidget {
  const ServiceHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Vehicle id comes from VehicleDetailsScreen via Get
    final vehicleCtrl = Get.find<VehicleDetailController>();
    final vehicleId = vehicleCtrl.id;

    // Bind the streaming controller once per vehicle
    if (!Get.isRegistered<ServiceRecordsController>()) {
      Get.put(ServiceRecordsController(vehicleId));
    }
    final c = Get.find<ServiceRecordsController>();

    final df = DateFormat.yMMMd();

    return Stack(
      children: [
        Obx(() {
          if (c.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.error.value != null) {
            return Center(child: Text(c.error.value!, style: const TextStyle(color: Colors.red)));
          }
          if (c.records.isEmpty) {
            return const _EmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            itemCount: c.records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final ServiceRecord r = c.records[i];
              final title = r.type.isNotEmpty ? r.type : 'Service';
              final date = df.format(r.serviceDate);
              final mileage = _formatMiles(r.mileage);
              final workshop = r.provider.isNotEmpty ? r.provider : '—';
              final cost = r.cost > 0 ? _formatCost(r.cost) : '—';
              final status = r.status.toLowerCase() == 'completed'
                  ? _ServiceStatus.completed
                  : _ServiceStatus.due;

              return _ServiceCard(
                title: title,
                date: date,
                mileage: '$mileage mi',
                workshop: workshop,
                cost: cost,
                status: status,
                onTap: () {
                  // Pass both: fast render (record) + deep-link/refresh (serviceId)
                  Get.to(() => ServiceDetailScreen(
                    vehicleId: vehicleId,
                    serviceId: r.id,   // <- future-proof
                    record: r,         // <- immediate render
                  ));
                },
              );
            },
          );
        }),

        // FAB for adding a new record
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            icon: const Icon(Iconsax.add),
            label: const Text('Add'),
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
            onPressed: () => Get.to(() => AddServiceRecordScreen(vehicleId: vehicleId)),
          ),
        ),
      ],
    );
  }

  static String _formatMiles(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final left = s.length - i;
      buf.write(s[i]);
      if (left > 1 && left % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }

  static String _formatCost(num v) => '\$${v.toStringAsFixed(2)}';
}

/* --- Mini Widgets --- */

enum _ServiceStatus { completed, due }

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.title,
    required this.date,
    required this.mileage,
    required this.workshop,
    required this.cost,
    required this.status,
    this.onTap,
  });

  final String title;
  final String date;
  final String mileage;
  final String workshop;
  final String cost;
  final _ServiceStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isDone = status == _ServiceStatus.completed;
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFEAFBF0) : const Color(0xFFFFF2CC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isDone ? 'Completed' : 'Due',
        style: TextStyle(
          color: isDone ? const Color(0xFF168A45) : const Color(0xFF946200),
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final content = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E8ED)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
          badge,
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Text(date, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(width: 10),
          Text(mileage, style: const TextStyle(color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Iconsax.setting_2, size: 18, color: Color(0xFF98A2B3)),
          const SizedBox(width: 8),
          Expanded(child: Text(workshop, style: const TextStyle(color: Color(0xFF344054)))),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Iconsax.dollar_square, size: 18, color: Color(0xFF98A2B3)),
          const SizedBox(width: 8),
          Text(cost, style: const TextStyle(color: Color(0xFF344054))),
        ]),
      ]),
    );

    return onTap == null
        ? content
        : InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: content,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      children: const [
        SizedBox(height: 40),
        Center(child: Text('No service records yet', style: TextStyle(color: Color(0xFF6B7280)))),
      ],
    );
  }
}