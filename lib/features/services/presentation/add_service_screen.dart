// lib/features/services/presentation/add_service_screen.dart
import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../vehicles/models/service_record.dart';

class AddServiceRecordScreen extends StatefulWidget {
  const AddServiceRecordScreen({
    super.key,
    required this.vehicleId,
    this.existing,
    this.serviceId,
    this.databaseId = 'autoaid',
  });

  /// Parent vehicle doc id
  final String vehicleId;

  /// If provided, we prefill and do an update
  final ServiceRecord? existing;

  /// Optional id to fetch and edit (used if existing is null)
  final String? serviceId;

  /// Named Firestore DB
  final String databaseId;

  @override
  State<AddServiceRecordScreen> createState() => _AddServiceRecordScreenState();
}

class _AddServiceRecordScreenState extends State<AddServiceRecordScreen> {
  static const _tag = 'AddServiceRecordScreen';
  void _d(String msg, {Object? err, StackTrace? st}) {
    if (kDebugMode) dev.log(msg, name: _tag, error: err, stackTrace: st);
  }

  late final FirebaseFirestore _db;

  final _formKey = GlobalKey<FormState>();

  // inputs
  final _dateCtrl = TextEditingController();
  final _nextDateCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  final _workshopCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final _df = DateFormat.yMMMMd();

  String? _serviceType;
  final _serviceTypes = const [
    'Oil Change',
    'Brake Service',
    'Tire Rotation',
    'Battery',
    'Inspection',
    'Other',
  ];

  String _status = 'completed'; // or 'due'

  bool _loading = true;
  String? _error;

  // working record id (for update)
  String? _serviceId;

  @override
  void initState() {
    super.initState();
    _db = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: widget.databaseId);

    // Allow passing existing record via Get.arguments for convenience
    final args = Get.arguments;
    final ServiceRecord? fromArgs =
    args is Map && args['existing'] is ServiceRecord ? args['existing'] as ServiceRecord : null;

    final existing = widget.existing ?? fromArgs;

    if (existing != null) {
      _bind(existing);
      _serviceId = existing.id;
      _loading = false;
      setState(() {});
    } else if (widget.serviceId != null) {
      _serviceId = widget.serviceId;
      _fetchExistingById();
    } else {
      // new record
      _loading = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _nextDateCtrl.dispose();
    _mileageCtrl.dispose();
    _workshopCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchExistingById() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final path = 'vehicles/${widget.vehicleId}/services/${widget.serviceId}';
      _d('GET $path');
      final doc = await _db.doc(path).get();
      if (!doc.exists) throw StateError('Service record not found');

      // IMPORTANT: pass vehicleId so the model is fully populated
      final r = ServiceRecord.fromDoc(doc, vehicleId: widget.vehicleId);
      _bind(r);
      _serviceId = r.id;
    } catch (e, st) {
      _d('Fetch existing failed', err: e, st: st);
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _bind(ServiceRecord r) {
    _dateCtrl.text = _df.format(r.serviceDate);
    if (r.nextServiceDate != null) _nextDateCtrl.text = _df.format(r.nextServiceDate!);
    _mileageCtrl.text = r.mileage > 0 ? r.mileage.toString() : '';
    _workshopCtrl.text = r.provider;
    _costCtrl.text = r.cost > 0 ? r.cost.toStringAsFixed(2) : '';
    _notesCtrl.text = r.notes;
    _serviceType = r.type.isNotEmpty ? r.type : null;
    _status = r.status.isNotEmpty ? r.status : 'completed';
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2010),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      controller.text = _df.format(picked);
    }
  }

  DateTime? _parseDateCtrl(TextEditingController c) {
    if (c.text.trim().isEmpty) return null;
    try {
      return _df.parse(c.text.trim());
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final serviceDate = _parseDateCtrl(_dateCtrl);
    if (serviceDate == null) {
      _toast('Select a valid service date');
      return;
    }
    final nextDate = _parseDateCtrl(_nextDateCtrl);

    final mileage = int.tryParse(_mileageCtrl.text.trim().replaceAll(',', '')) ?? 0;
    final cost = num.tryParse(_costCtrl.text.trim().replaceAll(',', '')) ?? 0;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final col = _db.collection('vehicles').doc(widget.vehicleId).collection('services');

      // create or update
      final bool isUpdate = _serviceId != null && _serviceId!.isNotEmpty;
      final docRef = isUpdate ? col.doc(_serviceId!) : col.doc(); // ← safe bang

      final payload = <String, dynamic>{
        'service_id': docRef.id,
        'vehicle_id': widget.vehicleId,

        'type': (_serviceType ?? 'Service').trim(),
        'provider': _workshopCtrl.text.trim(),
        'status': _status.trim(), // 'completed' or 'due'

        'mileage': mileage,
        'cost': cost,

        'service_date': Timestamp.fromDate(serviceDate),
        'next_service_date': nextDate != null ? Timestamp.fromDate(nextDate) : null,

        'notes': _notesCtrl.text.trim(),

        // audit
        if (!isUpdate) 'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Clean nulls to avoid complaining
      payload.removeWhere((k, v) => v == null);

      await docRef.set(payload, SetOptions(merge: true));

      _toast(isUpdate ? 'Service record updated' : 'Service record added');
      if (mounted) Get.back(result: {'saved': true, 'serviceId': docRef.id});
    } on FirebaseException catch (e) {
      _toast('Firestore error: ${e.message ?? e.code}');
    } catch (e, st) {
      _d('Save failed', err: e, st: st);
      _toast('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    if (_serviceId == null) return;
    setState(() => _loading = true);
    try {
      final path = 'vehicles/${widget.vehicleId}/services/$_serviceId';
      await _db.doc(path).delete();
      if (mounted) Get.back(result: {'deleted': true, 'serviceId': _serviceId});
    } catch (e) {
      _toast('Delete failed: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final isEditing = _serviceId != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Iconsax.arrow_left_2), onPressed: () => Get.back()),
        title: Text(
          isEditing ? 'Edit Service Record' : 'Add Service Record',
          style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (isEditing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Iconsax.trash),
              onPressed: _loading ? null : _delete,
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE7E9EF)),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service date
                const _FieldLabel('Service Date'),
                TextFormField(
                  controller: _dateCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () => _pickDate(_dateCtrl),
                      icon: const Icon(Iconsax.calendar_1),
                    ),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Next date
                const _FieldLabel('Next Service Date'),
                TextFormField(
                  controller: _nextDateCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () => _pickDate(_nextDateCtrl),
                      icon: const Icon(Iconsax.calendar_1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Mileage
                const _FieldLabel('Mileage'),
                TextFormField(
                  controller: _mileageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter mileage',
                    suffixText: 'miles',
                  ),
                ),
                const SizedBox(height: 16),

                // Type
                const _FieldLabel('Service Type'),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE6E8ED)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _serviceType,
                      isExpanded: true,
                      hint: const Text('Select service type'),
                      icon: const Icon(Iconsax.arrow_down_1),
                      borderRadius: BorderRadius.circular(14),
                      items: _serviceTypes
                          .map(
                            (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(e,
                                style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (v) => setState(() => _serviceType = v),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Status
                const _FieldLabel('Status'),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'completed',
                        groupValue: _status,
                        onChanged: (v) => setState(() => _status = v ?? 'completed'),
                        title: const Text('Completed'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'due',
                        groupValue: _status,
                        onChanged: (v) => setState(() => _status = v ?? 'due'),
                        title: const Text('Due'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Workshop
                const _FieldLabel('Workshop / Provider'),
                TextFormField(
                  controller: _workshopCtrl,
                  decoration: const InputDecoration(
                      hintText: 'Enter workshop or service provider'),
                ),
                const SizedBox(height: 16),

                // Cost
                const _FieldLabel('Cost'),
                TextFormField(
                  controller: _costCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                  const InputDecoration(prefixText: '\$ ', hintText: '0.00'),
                ),
                const SizedBox(height: 16),

                // Notes
                const _FieldLabel('Notes'),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Add any additional notes or details...',
                  ),
                ),
                const SizedBox(height: 24),

                // Save
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: c.primary,
                      padding:
                      const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    child:
                    Text(isEditing ? 'Save Changes' : 'Save Record'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

/* ============================== MINI WIDGETS ============================== */

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827)),
      ),
    );
  }
}