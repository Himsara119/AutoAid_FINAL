// lib/features/services/presentation/service_detail_screen.dart
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../vehicles/models/service_record.dart';
import 'add_service_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({
    super.key,
    required this.vehicleId,
    this.serviceId,
    this.record,
    this.databaseId = 'autoaid',
  }) : assert(
  serviceId != null || record != null,
  'Provide either serviceId or record',
  );

  final String vehicleId;
  final String? serviceId;      // for deep-links or refresh
  final ServiceRecord? record;  // for instant render
  final String databaseId;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final _df = DateFormat.yMMMMd();
  bool _loading = true;
  String? _error;
  late FirebaseFirestore _db;

  ServiceRecord? _record;

  void _d(String msg, {Object? err, StackTrace? st}) {
    if (kDebugMode) dev.log(msg, name: 'ServiceDetail', error: err, stackTrace: st);
  }

  @override
  void initState() {
    super.initState();
    _db = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: widget.databaseId);

    // If a record was passed, render immediately. If only id was passed, fetch.
    if (widget.record != null) {
      _record = widget.record;
      _loading = false;
      setState(() {});
    } else {
      _fetchById();
    }
  }

  Future<void> _fetchById([String? explicitId]) async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // Prefer explicit id (from edit result), then widget.serviceId, then current record id.
      final sid = explicitId ?? widget.serviceId ?? _record?.id;
      if (sid == null || sid.isEmpty) {
        throw StateError('Missing service id to fetch');
      }

      final path = 'vehicles/${widget.vehicleId}/services/$sid';
      _d('GET $path');
      final doc = await _db.doc(path).get();
      if (!doc.exists) throw StateError('Service record not found');
      _record = ServiceRecord.fromDoc(doc);
    } catch (e, st) {
      _d('Fetch failed', err: e, st: st);
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Get.back(), icon: const Icon(Iconsax.arrow_left_2)),
        title: const Text(''),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE7E9EF)),
        ),
      ),

      bottomNavigationBar: _record == null
          ? null
          : _BottomActions(
        onEdit: () async {
          // open the editor, wait for result
          final res = await Get.to(() => AddServiceRecordScreen(
            vehicleId: widget.vehicleId,
            existing: _record,      // prefill
            serviceId: _record!.id, // just in case
          ));

          // if updated, re-fetch to refresh this page
          if (res is Map && res['saved'] == true) {
            await _fetchById(_record!.id);
          }

          // if deleted, close details
          if (res is Map && res['deleted'] == true) {
            if (mounted) Get.back(result: {'deleted': true, 'serviceId': _record!.id});
          }
        },
        onClose: () => Get.back(),
      ),

      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
            : ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            // Title + badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _record!.type.isNotEmpty ? _record!.type : 'Service',
                  style: t.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: const Color(0xFF111827),
                  ),
                ),
                _StatusBadge(status: _record!.status),
              ],
            ),
            const SizedBox(height: 16),

            _RoundedSection(
              child: Column(
                children: [
                  _KVRow(label: 'Date', value: _df.format(_record!.serviceDate)),
                  const _DividerThin(),
                  _KVRow(label: 'Mileage', value: '${_fmtMiles(_record!.mileage)} miles'),
                  const _DividerThin(),
                  _KVRow(
                    label: 'Cost',
                    value: _record!.cost > 0 ? '\$${_record!.cost.toStringAsFixed(2)}' : '—',
                  ),
                  const _DividerThin(),
                  _KVRow(
                    label: 'Workshop',
                    value: _record!.provider.isNotEmpty ? _record!.provider : '—',
                  ),
                  const _DividerThin(),
                  _KVRow(
                    label: 'Next Service',
                    value: _record!.nextServiceDate != null
                        ? _df.format(_record!.nextServiceDate!)
                        : '—',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_record!.notes.isNotEmpty)
              _CardBlock(
                header: Text('Notes', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                child: Text(
                  _record!.notes,
                  style: const TextStyle(color: Color(0xFF374151), height: 1.6, fontSize: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _fmtMiles(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final left = s.length - i;
      b.write(s[i]);
      if (left > 1 && left % 3 == 1) b.write(',');
    }
    return b.toString();
  }
}

/* ---------------- Visual bits ---------------- */

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final done = status.toLowerCase() == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFEAFBF0) : const Color(0xFFFFF2CC),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(done ? Iconsax.tick_circle : Iconsax.timer_1,
              size: 16, color: done ? const Color(0xFF168A45) : const Color(0xFF946200)),
          const SizedBox(width: 8),
          Text(
            done ? 'Completed' : 'Due',
            style: TextStyle(
              color: done ? const Color(0xFF168A45) : const Color(0xFF946200),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundedSection extends StatelessWidget {
  const _RoundedSection({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8ED)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: child,
    );
  }
}

class _DividerThin extends StatelessWidget {
  const _DividerThin();
  @override
  Widget build(BuildContext context) => const Divider(height: 1, color: Color(0xFFE6E8ED));
}

class _KVRow extends StatelessWidget {
  const _KVRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  const _CardBlock({required this.header, required this.child});
  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      header,
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E8ED)),
        ),
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    ]);
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.onEdit, required this.onClose});
  final VoidCallback onEdit;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE7E9EF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('Edit Record'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: onClose,
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}