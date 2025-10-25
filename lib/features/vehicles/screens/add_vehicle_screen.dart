// lib/features/vehicles/screens/add_vehicle_screen.dart
import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

// Firebase bootstrap assumed already done in main.dart
import 'package:finalapp/features/dashboard/screens/dashboard_screen.dart';
import 'package:finalapp/features/vehicles/controllers/vehicle_stats_controller.dart';
import 'package:finalapp/features/vehicles/controllers/add_vehicle_controller.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AddVehicleController _controller;

  // basic fields
  final makeCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final mileageCtrl = TextEditingController();
  final vinCtrl = TextEditingController();

  // extras
  final trimCtrl = TextEditingController();
  final regNoCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final serviceKmCtrl = TextEditingController();
  final serviceMoCtrl = TextEditingController();

  String status = 'Active';
  final statuses = const ['Active', 'Pending', 'Sold', 'Archived'];

  String fuelType = 'petrol';
  final fuelTypes = const ['petrol', 'diesel', 'hybrid', 'electric'];

  String currency = 'LKR';
  final currencies = const ['LKR', 'USD', 'EUR', 'GBP'];

  bool isForSale = false;
  bool reminderEnabled = true;

  // photos
  final _picker = ImagePicker();
  final List<XFile> _photos = [];

  @override
  void initState() {
    super.initState();
    _controller = AddVehicleController();
  }

  @override
  void dispose() {
    for (final c in [
      makeCtrl,
      modelCtrl,
      yearCtrl,
      mileageCtrl,
      vinCtrl,
      trimCtrl,
      regNoCtrl,
      priceCtrl,
      serviceKmCtrl,
      serviceMoCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    try {
      final imgs = await _picker.pickMultiImage(imageQuality: 88);
      if (imgs != null && imgs.isNotEmpty) {
        setState(() => _photos.addAll(imgs));
      }
    } catch (e, st) {
      dev.log('pick photos failed', error: e, stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to pick images: $e')),
      );
    }
  }

  void _removePhotoAt(int i) {
    setState(() => _photos.removeAt(i));
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.offAll(() => const DashboardScreen()),
                      icon: const Icon(Iconsax.arrow_left_2),
                    ),
                    Expanded(
                      child: Text(
                        'Add Vehicle',
                        textAlign: TextAlign.center,
                        style: t.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 18),

                // Photos section (works before save, uploads after save)
                _PhotosSection(
                  photos: _photos,
                  onPick: _pickPhotos,
                  onRemoveAt: _removePhotoAt,
                ),
                const SizedBox(height: 20),

                const _FieldLabel('Make'),
                TextFormField(controller: makeCtrl, validator: _req),
                const SizedBox(height: 14),

                const _FieldLabel('Model'),
                TextFormField(controller: modelCtrl, validator: _req),
                const SizedBox(height: 14),

                const _FieldLabel('Trim'),
                TextFormField(
                  controller: trimCtrl,
                  decoration: const InputDecoration(hintText: 'EX / G / S'),
                ),
                const SizedBox(height: 14),

                const _FieldLabel('Year'),
                TextFormField(
                  controller: yearCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1900) return 'Enter a valid year';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                const _FieldLabel('Mileage'),
                TextFormField(
                  controller: mileageCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 0) return 'Enter a valid mileage';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                const _FieldLabel('VIN'),
                TextFormField(controller: vinCtrl, validator: _req),
                const SizedBox(height: 14),

                const _FieldLabel('Registration Number'),
                TextFormField(
                  controller: regNoCtrl,
                  decoration: const InputDecoration(hintText: 'WP-CAB-1234'),
                ),
                const SizedBox(height: 18),

                const _FieldLabel('Status'),
                _Dropdown<String>(
                  value: status,
                  items: statuses,
                  onChanged: (v) => setState(() => status = v),
                ),
                const SizedBox(height: 18),

                const _FieldLabel('Fuel Type'),
                _Dropdown<String>(
                  value: fuelType,
                  items: fuelTypes,
                  onChanged: (v) => setState(() => fuelType = v),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel('Price'),
                          TextFormField(
                            controller: priceCtrl,
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
                            value: currency,
                            items: currencies,
                            onChanged: (v) => setState(() => currency = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SwitchListTile(
                  value: isForSale,
                  onChanged: (v) => setState(() => isForSale = v),
                  title: const Text('Mark as For Sale'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 6),

                const _FieldLabel('Service Interval'),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: serviceKmCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'KM (e.g. 1000)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: serviceMoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Months (e.g. 6)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                SwitchListTile(
                  value: reminderEnabled,
                  onChanged: (v) => setState(() => reminderEnabled = v),
                  title: const Text('Enable reminders'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 22),

                // Documents card removed by request

                _PrimaryButton(
                  text: 'Add Vehicle',
                  onPressed: () async {
                    final valid = _formKey.currentState?.validate() ?? false;
                    if (!valid) return;

                    try {
                      final raw = priceCtrl.text.trim();
                      final int? priceInt =
                      raw.isEmpty ? null : int.tryParse(raw.replaceAll(',', ''));

                      final int? svcKm = serviceKmCtrl.text.trim().isEmpty
                          ? null
                          : int.tryParse(serviceKmCtrl.text.trim());
                      final int? svcMo = serviceMoCtrl.text.trim().isEmpty
                          ? null
                          : int.tryParse(serviceMoCtrl.text.trim());

                      final id = await _controller.saveVehicle(
                        make: makeCtrl.text,
                        model: modelCtrl.text,
                        year: yearCtrl.text,
                        mileage: mileageCtrl.text,
                        vin: vinCtrl.text,
                        status: status,
                        trim: trimCtrl.text,
                        registrationNumber: regNoCtrl.text,
                        price: priceInt,
                        currency: currency,
                        fuelType: fuelType,
                        isForSale: isForSale,
                        reminderEnabled: reminderEnabled,
                        serviceIntervalKm: svcKm,
                        serviceIntervalMonths: svcMo,
                        photos: _photos, // upload these
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Vehicle saved (id: $id)')),
                      );

                      Get.offAll(() => const DashboardScreen())?.then((_) async {
                        if (Get.isRegistered<VehicleStatsController>()) {
                          await Get.find<VehicleStatsController>().refreshCounts();
                        }
                      });
                    } catch (e, st) {
                      dev.log('Save failed', error: e, stackTrace: st);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
}

/* ============================== MINI WIDGETS ============================== */

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Colors.black.withOpacity(0.75), fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(16),
          items: items
              .map((e) => DropdownMenuItem<T>(
            value: e,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '$e',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ),
          ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}

/// Photo picker section with grid preview and remove.
class _PhotosSection extends StatelessWidget {
  const _PhotosSection({
    required this.photos,
    required this.onPick,
    required this.onRemoveAt,
    super.key,
  });

  final List<XFile> photos;
  final VoidCallback onPick;
  final void Function(int index) onRemoveAt;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Vehicle Photos',
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
              photos.isEmpty ? 'No photos selected' : '${photos.length} selected',
              style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (photos.isNotEmpty)
          GridView.builder(
            itemCount: photos.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, i) {
              final x = photos[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(x.path, fit: BoxFit.cover)
                        : Image.file(File(x.path), fit: BoxFit.cover),
                  ),
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
                ],
              );
            },
          ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onPressed, super.key});
  final String text;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: c.primary.withOpacity(0.9),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
