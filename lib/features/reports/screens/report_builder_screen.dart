// lib/features/reports/ui/report_builder_screen.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'package:finalapp/features/reports/screens/report_export_service.dart';
import '../../../data/repositories/report_repository.dart';
import '../../reports/models/report_entity.dart';

/// Report Builder: lets user pick sections and generate a PDF report.
/// If [vehicleId] is provided via route, the picker is locked to that car.
/// If null, user can pick a car from a bottom sheet.
class ReportBuilderScreen extends StatefulWidget {
  const ReportBuilderScreen({
    super.key,
    this.vehicleId,
  });

  final String? vehicleId;

  @override
  State<ReportBuilderScreen> createState() => _ReportBuilderScreenState();
}

class _ReportBuilderScreenState extends State<ReportBuilderScreen> {
  // Firestore (named database: autoaid)
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'autoaid',
  );

  String? _selectedVehicleId;
  String? _selectedVehicleLabel; // UI only
  late final bool _locked;       // true if coming from a specific vehicle

  String _format = 'PDF Document';
  bool _busy = false;

  final Map<String, bool> _sections = <String, bool>{
    'Overview': true,
    'Service History': true,
    'Documents': false,
    'AI Report': true,
  };

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.vehicleId;
    _locked = widget.vehicleId != null && widget.vehicleId!.isNotEmpty;
    _selectedVehicleLabel = _locked ? '(${_shortId(widget.vehicleId!)})' : null;
  }

  // Shrink long Firestore ids
  String _shortId(String id, {int head = 6}) =>
      id.length <= head ? id : '${id.substring(0, head)}…';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Report Builder',
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Color(0xFF111827)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1E8FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.document_upload5, color: Color(0xFF7C3AED), size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text('Create Your Report',
                        style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      'Select the sections you want to include in your\nreport. Toggle on the sections you need.',
                      textAlign: TextAlign.center,
                      style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280), height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              Text('Report Sections', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),

              const Text('Vehicle',
                  style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),

              // Vehicle selector tile: locked if vehicleId was provided via route
              InkWell(
                onTap: _locked ? null : _openVehiclePicker,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE6E8ED)),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    leading: const Icon(Iconsax.car, color: Color(0xFF111827), size: 20),
                    title: const Text(
                      'Selected vehicle',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12.5),
                    ),
                    subtitle: Text(
                      _selectedVehicleLabel ??
                          (_selectedVehicleId != null
                              ? '(${_shortId(_selectedVehicleId!)})'
                              : 'Tap to choose a vehicle'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _selectedVehicleId == null ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(
                      _locked ? Iconsax.lock : Iconsax.arrow_down_1,
                      size: 18,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section toggles
              ..._sections.entries.map(
                    (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SectionTile(
                    title: e.key,
                    subtitle: _subtitleFor(e.key),
                    icon: _iconFor(e.key),
                    iconBg: _colorFor(e.key),
                    value: e.value,
                    onChanged: (v) => setState(() => _sections[e.key] = v),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text('Report Options', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),

              const Text('Format',
                  style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),

              // Format dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE6E8ED)),
                ),
                child: DropdownButtonFormField<String>(
                  value: _format,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  icon: const Icon(Iconsax.arrow_down_1),
                  items: const [
                    DropdownMenuItem(value: 'PDF Document', child: Text('PDF Document')),
                    DropdownMenuItem(value: 'Word Document', child: Text('Word Document')),
                  ],
                  onChanged: (v) => setState(() => _format = v!),
                ),
              ),

              const SizedBox(height: 22),

              Text('Report Summary', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),

              Text(
                'Selected sections: ${_sections.values.where((v) => v).length} of ${_sections.length}',
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _sections.entries
                    .where((e) => e.value)
                    .map(
                      (e) => Chip(
                    label: Text(e.key),
                    labelStyle: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w600),
                    backgroundColor: const Color(0xFFF1E8FF),
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: 20),

              Center(
                child: Text(
                  // Clarify where to see it afterwards
                  'Report will be generated and sent to your email,\n'
                      'and will appear under that vehicle\'s Reports tab.',
                  textAlign: TextAlign.center,
                  style: t.bodySmall?.copyWith(color: const Color(0xFF9CA3AF)),
                ),
              ),
            ],
          ),
        ),
      ),

      // CTA
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              shadowColor: const Color(0xFF7C3AED).withOpacity(0.3),
            ),
            onPressed: _busy || _selectedVehicleId == null ? null : _onGenerate,
            child: _busy
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Text('Generate Report',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  /* --------------------------- Actions ---------------------------- */

  Future<void> _onGenerate() async {
    if (_format != 'PDF Document') {
      _snack('Only PDF is supported right now.');
      return;
    }
    if (_selectedVehicleId == null || _selectedVehicleId!.isEmpty) {
      _snack('Pick a vehicle first.');
      return;
    }

    final selectedSections =
    _sections.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selectedSections.isEmpty) {
      _snack('Pick at least one section.');
      return;
    }

    setState(() => _busy = true);
    try {
      // 1) Build the PDF bytes
      final Uint8List bytes = await ReportExportService().buildPdf(
        vehicleId: _selectedVehicleId!,
        sections: selectedSections,
      );

      // 2) Save temp file and upload to Firebase Storage
      final tempDir = await getTemporaryDirectory();
      final fileName = 'condition_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      final storageRef =
      FirebaseStorage.instance.ref().child('reports/${_selectedVehicleId!}/$fileName');
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      // 3) Persist metadata in Firestore using your repo (server timestamps)
      final data = ReportModel.createWriteMap(
        dealershipId: 'default', // TODO: source from auth/profile
        vehicleId: _selectedVehicleId!,
        category: 'condition',
        fileName: fileName,
        fileUrl: downloadUrl,
        fileType: 'application/pdf',
        notes: 'Sections: ${selectedSections.join(", ")}',
      );

      final repo = ReportRepo();
      await repo.create(_selectedVehicleId!, data);

      // Success: tell them where to go; stay on this screen
      _snack(
        'Report created. Please go to the specific vehicle to view it in Reports.',
        seconds: 5,
      );

      // No navigation here on purpose.
      // If you later want to close the screen: Navigator.of(context).maybePop();
    } catch (e) {
      _snack('Failed to generate: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg, {int seconds = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: seconds),
      ),
    );
  }

  /* --------------------------- Vehicle Picker ---------------------------- */

  void _openVehiclePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                height: 4,
                width: 44,
                margin: const EdgeInsets.only(top: 8, bottom: 12),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Select vehicle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _db
                      .collection('vehicles')
                      .where('deleted', isEqualTo: false)
                      .orderBy('make')
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    }
                    final docs = snap.data?.docs ?? const [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No vehicles found.'));
                    }
                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final d = docs[i];
                        final id = d.id;
                        final make = (d.data()['make'] ?? '').toString();
                        final model = (d.data()['model'] ?? '').toString();
                        final year = (d.data()['year'] ?? '').toString();
                        final label = [year, make, model].where((x) => x.isNotEmpty).join(' ');
                        return ListTile(
                          leading: const Icon(Icons.directions_car_outlined),
                          title: Text(label.isEmpty ? id : label),
                          subtitle: Text(id),
                          onTap: () {
                            setState(() {
                              _selectedVehicleId = id;
                              _selectedVehicleLabel = label.isEmpty ? '(${_shortId(id)})' : label;
                            });
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /* --------------------------- Helpers ---------------------------- */

  String _subtitleFor(String section) {
    switch (section) {
      case 'Overview':
        return 'Summary and key metrics';
      case 'Service History':
        return 'Past service records';
      case 'Documents':
        return 'Related files and attachments';
      case 'AI Report':
        return 'AI-generated insights';
      default:
        return '';
    }
  }

  IconData _iconFor(String section) {
    switch (section) {
      case 'Overview':
        return Iconsax.chart_15;
      case 'Service History':
        return Iconsax.activity;
      case 'Documents':
        return Iconsax.document_text;
      case 'AI Report':
        return Iconsax.cpu;
      default:
        return Iconsax.category;
    }
  }

  Color _colorFor(String section) {
    switch (section) {
      case 'Overview':
        return const Color(0xFFEFF4FF);
      case 'Service History':
        return const Color(0xFFEFFAF3);
      case 'Documents':
        return const Color(0xFFFFF7E8);
      case 'AI Report':
        return const Color(0xFFF1E8FF);
      default:
        return const Color(0xFFE6E8ED);
    }
  }
}

/* --------------------------- Section Tile ---------------------------- */

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme
        .of(context)
        .textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8ED)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: const Color(0xFF111827), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600, height: 1.3)),
                Text(subtitle, style: t.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280))),
              ],
            ),
          ),
          Switch(
            activeColor: const Color(0xFF7C3AED),
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}