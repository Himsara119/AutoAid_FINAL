// lib/features/vehicles/ui/edit_vehicle_screen.dart
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditVehicleScreen extends StatefulWidget {
  const EditVehicleScreen({
    super.key,
    required this.vehicleId,
  });

  final String vehicleId;

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  static const _tag = 'EditVehicleScreen';
  void _d(String msg, {Object? err, StackTrace? st}) {
    if (kDebugMode) dev.log(msg, name: _tag, error: err, stackTrace: st);
  }

  late final FirebaseFirestore _db;
  late final FirebaseStorage _storage;

  final _formKey = GlobalKey<FormState>();

  // Controllers (mirrors AddVehicleScreen)
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _trimCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _mileageCtrl = TextEditingController();
  final _vinCtrl = TextEditingController();
  final _regNoCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _svcKmCtrl = TextEditingController();
  final _svcMoCtrl = TextEditingController();

  // Dropdown/switch fields
  String _status = 'Active';
  final List<String> _statuses = const ['Active', 'Pending', 'Sold', 'Archived'];

  String _fuelType = 'petrol';
  final List<String> _fuelTypes = const ['petrol', 'diesel', 'hybrid', 'electric'];

  String _currency = 'LKR';
  final List<String> _currencies = const ['LKR', 'USD', 'EUR', 'GBP'];

  bool _isForSale = false;
  bool _reminderEnabled = true;

  bool _loading = true;
  String? _error;

  // Photos
  final _picker = ImagePicker();
  final List<String> _existingPhotos = [];   // URLs already in Firestore
  final List<XFile> _newPhotos = [];         // Local picks not yet uploaded
  String? _primaryPhoto;                     // URL (existing or uploaded later)

  @override
  void initState() {
    super.initState();
    _db = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'autoaid');
    _storage = FirebaseStorage.instance;
    _loadVehicle();
  }

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _trimCtrl.dispose();
    _yearCtrl.dispose();
    _mileageCtrl.dispose();
    _vinCtrl.dispose();
    _regNoCtrl.dispose();
    _priceCtrl.dispose();
    _svcKmCtrl.dispose();
    _svcMoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVehicle() async {
    try {
      _d('Fetch doc ${widget.vehicleId}');
      final doc = await _db.collection('vehicles').doc(widget.vehicleId).get();
      if (!doc.exists) throw StateError('Vehicle not found');

      final data = doc.data()!;

      // Bind values safely
      _makeCtrl.text = (data['make'] ?? '').toString();
      _modelCtrl.text = (data['model'] ?? '').toString();
      _trimCtrl.text = (data['trim'] ?? '').toString();
      _yearCtrl.text = (data['year'] ?? '').toString();
      _mileageCtrl.text = (data['mileage'] ?? '').toString();
      _vinCtrl.text = (data['vin'] ?? '').toString();
      _regNoCtrl.text = (data['registration_number'] ?? '').toString();

      _status = _cap((data['status'] ?? 'active').toString());
      _fuelType = (data['fuel_type'] ?? 'petrol').toString();

      _isForSale = (data['is_for_sale'] ?? false) as bool;
      _currency = (data['currency'] ?? 'LKR').toString();

      final price = data['price'];
      _priceCtrl.text = price == null ? '' : price.toString();

      final svcKm = data['service_interval_km'];
      final svcMo = data['service_interval_months'];
      _svcKmCtrl.text = svcKm == null ? '' : svcKm.toString();
      _svcMoCtrl.text = svcMo == null ? '' : svcMo.toString();

      _reminderEnabled = (data['reminder_enabled'] ?? true) as bool;

      // Photos
      final List<String> photos =
          (data['photos'] as List?)?.whereType<String>().toList() ?? const <String>[];
      _existingPhotos
        ..clear()
        ..addAll(photos);
      _primaryPhoto = (data['primary_photo'] as String?)?.trim();
      if (_primaryPhoto != null && _primaryPhoto!.isEmpty) _primaryPhoto = null;

      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (e, st) {
      _d('Load failed', err: e, st: st);
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _pickMorePhotos() async {
    try {
      final imgs = await _picker.pickMultiImage(imageQuality: 88);
      if (imgs != null && imgs.isNotEmpty) {
        setState(() => _newPhotos.addAll(imgs));
      }
    } catch (e, st) {
      _d('pick photos failed', err: e, st: st);
      _toast('Unable to pick images: $e');
    }
  }

  void _removeExistingAt(int index) {
    setState(() {
      final removed = _existingPhotos.removeAt(index);
      if (_primaryPhoto == removed) _primaryPhoto = _existingPhotos.isNotEmpty ? _existingPhotos.first : null;
    });
  }

  void _removeNewAt(int index) {
    setState(() => _newPhotos.removeAt(index));
  }

  void _setPrimary(String url) {
    setState(() => _primaryPhoto = url);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final yr = int.tryParse(_digitsOnly(_yearCtrl.text.trim()));
    final km = int.tryParse(_digitsOnly(_mileageCtrl.text.trim()));
    if (yr == null || yr < 1900) return _toast('Enter a valid year');
    if (km == null || km < 0) return _toast('Enter a valid mileage');

    final p = _priceCtrl.text.trim().isEmpty
        ? null
        : num.tryParse(_priceCtrl.text.trim().replaceAll(',', ''));

    setState(() => _loading = true);
    try {
      // 1) Upload any newly added photos
      List<String> uploaded = [];
      if (_newPhotos.isNotEmpty) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        uploaded = await Future.wait(_newPhotos.asMap().entries.map((e) async {
          final i = e.key;
          final x = e.value;
          final Uint8List bytes = await x.readAsBytes();
          final path = 'vehicles/${widget.vehicleId}/photos/edit-$ts-$i.jpg';
          final ref = _storage.ref(path);
          await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
          return await ref.getDownloadURL();
        }));
      }

      // 2) Consolidate final photos list
      final List<String> finalPhotos = [
        ..._existingPhotos,
        ...uploaded,
      ];

      // 3) Pick primary if none set
      String? finalPrimary = _primaryPhoto;
      if (finalPrimary == null && finalPhotos.isNotEmpty) {
        finalPrimary = finalPhotos.first;
      }
      if (finalPrimary != null && !finalPhotos.contains(finalPrimary)) {
        // if user deleted it, fallback to first
        finalPrimary = finalPhotos.isNotEmpty ? finalPhotos.first : null;
      }

      // 4) Main payload
      final payload = <String, dynamic>{
        'make': _makeCtrl.text.trim(),
        'model': _modelCtrl.text.trim(),
        'trim': _trimCtrl.text.trim(),
        'year': yr,
        'mileage': km,
        'vin': _vinCtrl.text.trim(), // read-only in UI, but keep consistent in schema
        'registration_number': _regNoCtrl.text.trim(),

        'status': _status.toLowerCase(),
        'fuel_type': _fuelType.toLowerCase(),

        'is_for_sale': _isForSale,
        'currency': _currency,
        'price': p,

        'service_interval_km': _svcKmCtrl.text.trim().isEmpty ? null : int.tryParse(_svcKmCtrl.text.trim()),
        'service_interval_months': _svcMoCtrl.text.trim().isEmpty ? null : int.tryParse(_svcMoCtrl.text.trim()),
        'reminder_enabled': _reminderEnabled,

        'photos': finalPhotos,
        if (finalPrimary != null) 'primary_photo': finalPrimary,

        'updated_at': Timestamp.now(),
      };

      await _db.collection('vehicles').doc(widget.vehicleId).update(payload);
      _toast('Vehicle saved');
      if (mounted) Get.back(result: {'updated': true, 'id': widget.vehicleId});
    } on FirebaseException catch (e) {
      _toast('Firestore error: ${e.message ?? e.code}');
    } catch (e, st) {
      _d('Save failed', err: e, st: st);
      _toast('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteSoft() async {
    setState(() => _loading = true);
    try {
      await _db.collection('vehicles').doc(widget.vehicleId).update({
        'deleted': true,
        'updated_at': Timestamp.now(),
      });
      if (mounted) Get.back(result: {'deleted': true, 'id': widget.vehicleId});
    } catch (e) {
      _toast('Delete failed: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Edit Vehicle',
          style: t.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Iconsax.trash),
            onPressed: _loading ? null : _deleteSoft,
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo Manager
                _PhotosEditor(
                  existing: _existingPhotos,
                  newPhotos: _newPhotos,
                  primary: _primaryPhoto,
                  onPick: _pickMorePhotos,
                  onRemoveExistingAt: _removeExistingAt,
                  onRemoveNewAt: _removeNewAt,
                  onSetPrimary: _setPrimary,
                ),
                const SizedBox(height: 24),

                // Make
                const _FieldLabel('Make'),
                TextFormField(
                  controller: _makeCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Toyota',
                    suffixIcon: _HintIcon(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Model
                const _FieldLabel('Model'),
                TextFormField(
                  controller: _modelCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Camry',
                    suffixIcon: _HintIcon(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Trim
                const _FieldLabel('Trim'),
                TextFormField(
                  controller: _trimCtrl,
                  decoration: const InputDecoration(hintText: 'EX / G / S'),
                ),
                const SizedBox(height: 16),

                // Year
                const _FieldLabel('Year'),
                TextFormField(
                  controller: _yearCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '2022',
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Iconsax.calendar_1),
                    ),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1900) return 'Enter a valid year';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mileage
                const _FieldLabel('Mileage'),
                TextFormField(
                  controller: _mileageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '25000',
                    suffixIcon: _HintIcon(),
                  ),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Enter a valid mileage';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // VIN
                const _FieldLabel('VIN'),
                TextFormField(
                  controller: _vinCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: '1HGBH41JXMN109186',
                    suffixIcon: _HintIcon(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Registration number
                const _FieldLabel('Registration Number'),
                TextFormField(
                  controller: _regNoCtrl,
                  decoration: const InputDecoration(hintText: 'WP-CAB-1234'),
                ),
                const SizedBox(height: 16),

                // Status
                const _FieldLabel('Status'),
                _Dropdown<String>(
                  value: _status,
                  items: _statuses,
                  onChanged: (v) => setState(() => _status = v),
                ),
                const SizedBox(height: 18),

                // Fuel Type
                const _FieldLabel('Fuel Type'),
                _Dropdown<String>(
                  value: _fuelType,
                  items: _fuelTypes,
                  onChanged: (v) => setState(() => _fuelType = v),
                ),
                const SizedBox(height: 18),

                // Price + Currency
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Price'),
                          TextFormField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'e.g. 7250000'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Currency'),
                          _Dropdown<String>(
                            value: _currency,
                            items: _currencies,
                            onChanged: (v) => setState(() => _currency = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SwitchListTile(
                  value: _isForSale,
                  onChanged: (v) => setState(() => _isForSale = v),
                  title: const Text('Mark as For Sale'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 6),

                // Service intervals
                const _FieldLabel('Service Interval'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _svcKmCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'KM (e.g. 1000)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _svcMoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Months (e.g. 6)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                SwitchListTile(
                  value: _reminderEnabled,
                  onChanged: (v) => setState(() => _reminderEnabled = v),
                  title: const Text('Enable reminders'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),

                // Documents card removed per your earlier spec

                // Save / Delete
                _PrimaryButton(text: 'Save Changes', onPressed: _loading ? null : _save),
                const SizedBox(height: 12),
                _DangerOutlineButton(text: 'Delete Vehicle', onPressed: _loading ? null : _deleteSoft),
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

  String _cap(String s) {
    if (s.isEmpty) return s;
    final low = s.toLowerCase();
    return low[0].toUpperCase() + low.substring(1);
  }

  String _digitsOnly(String v) => v.replaceAll(RegExp(r'[^0-9]'), '');
}

/* =============================== MINI WIDGETS =============================== */

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF111827),
        ),
      ),
    );
  }
}

class _HintIcon extends StatelessWidget {
  const _HintIcon();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 6),
      child: Icon(Iconsax.info_circle, color: Color(0xFFB8BDC7)),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({super.key, required this.value, required this.items, required this.onChanged});
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          borderRadius: BorderRadius.circular(16),
          icon: const Icon(Iconsax.arrow_down_1),
          isExpanded: true,
          style: const TextStyle(fontSize: 16, color: Color(0xFF111827)),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
              value: e,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text('$e'),
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onPressed});
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text(text),
      ),
    );
  }
}

class _DangerOutlineButton extends StatelessWidget {
  const _DangerOutlineButton({required this.text, required this.onPressed});
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFEF4444);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          foregroundColor: red,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text(text),
      ),
    );
  }
}

/* =============================== PHOTO EDITOR =============================== */

class _PhotosEditor extends StatelessWidget {
  const _PhotosEditor({
    required this.existing,
    required this.newPhotos,
    required this.primary,
    required this.onPick,
    required this.onRemoveExistingAt,
    required this.onRemoveNewAt,
    required this.onSetPrimary,
  });

  final List<String> existing;
  final List<XFile> newPhotos;
  final String? primary;

  final VoidCallback onPick;
  final void Function(int index) onRemoveExistingAt;
  final void Function(int index) onRemoveNewAt;
  final void Function(String url) onSetPrimary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photos',
            style: t.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            )),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton.icon(
              onPressed: onPick,
              icon: const Icon(Iconsax.gallery_add),
              label: const Text('Add Photos'),
            ),
            const SizedBox(width: 12),
            Text(
              _summary(existingCount: existing.length, newCount: newPhotos.length),
              style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Existing photos grid
        if (existing.isNotEmpty) ...[
          Text('Existing', style: t.labelLarge),
          const SizedBox(height: 6),
          _Grid<String>(
            items: existing,
            itemBuilder: (u) => Image.network(u, fit: BoxFit.cover),
            onRemoveAt: onRemoveExistingAt,
            onSetPrimary: (idx) => onSetPrimary(existing[idx]),
            isPrimary: (idx) => primary != null && existing[idx] == primary,
          ),
          const SizedBox(height: 12),
        ],

        // Newly added (local) photos grid
        if (newPhotos.isNotEmpty) ...[
          Text('New (unsaved)', style: t.labelLarge),
          const SizedBox(height: 6),
          _Grid<XFile>(
            items: newPhotos,
            itemBuilder: (x) => kIsWeb
                ? Image.network(x.path, fit: BoxFit.cover)
                : Image.file(File(x.path), fit: BoxFit.cover),
            onRemoveAt: onRemoveNewAt,
            // Primary can only be set to an URL. After save they’ll be URLs.
            onSetPrimary: null,
            isPrimary: null,
          ),
        ],

        if (existing.isEmpty && newPhotos.isEmpty)
          Container(
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD9DEE8)),
            ),
            child: const Text('No photos yet'),
          ),
      ],
    );
  }

  String _summary({required int existingCount, required int newCount}) {
    if (existingCount == 0 && newCount == 0) return 'No photos';
    if (existingCount > 0 && newCount == 0) return '$existingCount existing';
    if (existingCount == 0 && newCount > 0) return '$newCount new';
    return '$existingCount existing, $newCount new';
  }
}

class _Grid<T> extends StatelessWidget {
  const _Grid({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRemoveAt,
    required this.onSetPrimary,
    required this.isPrimary,
  });

  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final void Function(int index) onRemoveAt;
  final void Function(int index)? onSetPrimary;
  final bool Function(int index)? isPrimary;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, i) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: itemBuilder(items[i]),
            ),
            // Remove button
            Positioned(
              top: 6,
              right: 6,
              child: InkWell(
                onTap: () => onRemoveAt(i),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
            // Star to set primary (URLs only)
            if (onSetPrimary != null && isPrimary != null)
              Positioned(
                bottom: 6,
                left: 6,
                child: InkWell(
                  onTap: () => onSetPrimary!(i),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      isPrimary!(i) ? Icons.star : Icons.star_border,
                      size: 16,
                      color: isPrimary!(i) ? Colors.amber : Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
