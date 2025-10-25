// lib/features/documents/screens/upload_document_screen.dart
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

/// UploadDocumentScreen
/// Visual style aligned with your Add/Edit Vehicle screen:
/// - Bold field headers
/// - Flat, underlined inputs
/// - Trailing info/calendar icons
/// - Top-right Save action
class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({
    super.key,
    required this.vehicleId,
    this.databaseId = 'autoaid',
  });

  final String vehicleId;
  final String databaseId;

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final _form = GlobalKey<FormState>();

  // Fields
  String _type = 'insurance';
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _issuerCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _issueDate;
  DateTime? _expiryDate;
  bool _noExpiry = false;

  // File selection
  String? _fileName;
  String? _contentType; // e.g. application/pdf, image/png
  int? _fileSize;
  Uint8List? _fileBytes; // for web or memory upload
  File? _file; // for io upload

  bool _saving = false;

  FirebaseFirestore get _db => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: widget.databaseId,
  );

  FirebaseStorage get _storage => FirebaseStorage.instanceFor(
    app: Firebase.app(),
    bucket: Firebase.app().options.storageBucket,
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _issuerCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  /* ============================== UI helpers ============================== */

  InputBorder get _underline => const UnderlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFCDD3DF), width: 1),
  );

  TextStyle get _header =>
      const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827));

  Widget _sectionSpacer() => const SizedBox(height: 18);

  String _dateLabel(DateTime? d) => d == null ? 'Not set' : DateFormat.y().add_MMM().add_d().format(d);

  Future<void> _pickIssue() => _pickDate(isIssue: true);
  Future<void> _pickExpiry() => _pickDate(isIssue: false);

  Future<void> _pickDate({required bool isIssue}) async {
    final now = DateTime.now();
    final initial = isIssue ? (_issueDate ?? now) : (_expiryDate ?? now);
    final first = DateTime(1990, 1, 1);
    final last = DateTime(now.year + 15, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: isIssue ? 'Select issue date' : 'Select expiry date',
    );
    if (picked == null) return;
    setState(() {
      if (isIssue) {
        _issueDate = picked;
      } else {
        _expiryDate = picked;
        _noExpiry = false;
      }
    });
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'heic', 'webp'],
    );
    if (res == null || res.files.isEmpty) return;

    final f = res.files.first;
    setState(() {
      _fileName = f.name;
      _fileSize = f.size;
      _contentType = _inferContentTypeFromName(f.name);
      if (kIsWeb) {
        _fileBytes = f.bytes;
        _file = null;
      } else {
        if (f.path != null) _file = File(f.path!);
        _fileBytes = f.bytes; // mobile may or may not have bytes; File takes precedence
      }
    });
  }

  String _inferContentTypeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'application/octet-stream';
  }

  String _fmtSize(int? s) {
    if (s == null) return '';
    const kb = 1024;
    const mb = 1024 * 1024;
    if (s >= mb) return '${(s / mb).toStringAsFixed(1)} MB';
    if (s >= kb) return '${(s / kb).toStringAsFixed(1)} KB';
    return '$s B';
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  /* ============================== Save ============================== */

  Future<void> _save() async {
    final valid = _form.currentState?.validate() ?? false;
    if (!valid) return;

    if (_fileName == null || (_file == null && _fileBytes == null)) {
      _snack('Attach a PDF or image first.');
      return;
    }
    if (!_noExpiry && _expiryDate == null) {
      _snack('Set an expiry date or toggle "No expiry".');
      return;
    }

    setState(() => _saving = true);

    try {
      final now = Timestamp.now();
      final uid = FirebaseAuth.instance.currentUser?.uid;

      final col = _db.collection('vehicles').doc(widget.vehicleId).collection('documents');
      final docRef = col.doc();
      final docId = docRef.id;

      final storagePath = 'documents/${widget.vehicleId}/$docId/$_fileName';
      final meta = SettableMetadata(contentType: _contentType ?? 'application/octet-stream');

      final task = kIsWeb || _file == null
          ? _storage.ref(storagePath).putData(_fileBytes as Uint8List, meta)
          : _storage.ref(storagePath).putFile(_file as File, meta);

      final snap = await task.whenComplete(() {});
      final url = await snap.ref.getDownloadURL();
      final size = _fileSize ?? snap.totalBytes;

      final expired = !_noExpiry && _expiryDate != null && _expiryDate!.isBefore(DateTime.now());
      final status = expired ? 'expired' : 'active';

      final data = <String, dynamic>{
        'type': _type,
        'name': _nameCtrl.text.trim(),
        'number': _numberCtrl.text.trim().isEmpty ? null : _numberCtrl.text.trim(),
        'issuer': _issuerCtrl.text.trim().isEmpty ? null : _issuerCtrl.text.trim(),
        'issue_date': _issueDate == null ? null : Timestamp.fromDate(_issueDate!),
        'expiry_date': _noExpiry || _expiryDate == null ? null : Timestamp.fromDate(_expiryDate!),
        'no_expiry': _noExpiry,
        'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        'file_url': url,
        'file_name': _fileName,
        'file_size': size,
        'content_type': _contentType,
        'status': status,
        'created_at': now,
        'updated_at': now,
        'created_by': uid == null ? null : 'users/$uid',
        'vehicle_id': widget.vehicleId,
      };

      await docRef.set(data, SetOptions(merge: true));

      _snack('Document saved.');
      if (mounted) Get.back(result: docId);
    } catch (e) {
      _snack('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /* ============================== Build ============================== */

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Add Document',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Save',
            onPressed: _saving ? null : _save,
            icon: const Icon(Iconsax.save_2),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _saving,
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              // TYPE
              Text('Type', style: _header),
              const SizedBox(height: 6),
              InputDecorator(
                decoration: InputDecoration(
                  border: _underline,
                  enabledBorder: _underline,
                  focusedBorder: _underline,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Icon(Iconsax.information, size: 18, color: Color(0xFF98A2B3)),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _type,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'insurance', child: Text('Insurance')),
                      DropdownMenuItem(value: 'registration', child: Text('Registration')),
                      DropdownMenuItem(value: 'emission', child: Text('Emission')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? 'other'),
                  ),
                ),
              ),

              _sectionSpacer(),
              // NAME
              Text('Document Name', style: _header),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Comprehensive Auto Insurance',
                  border: _underline,
                  focusedBorder: _underline,
                  enabledBorder: _underline,
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Icon(Iconsax.information, size: 18, color: Color(0xFF98A2B3)),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),

              _sectionSpacer(),
              // NUMBER
              Text('Document Number', style: _header),
              const SizedBox(height: 6),
              TextFormField(
                controller: _numberCtrl,
                decoration: InputDecoration(
                  hintText: 'Policy or certificate number',
                  border: _underline,
                  focusedBorder: _underline,
                  enabledBorder: _underline,
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Icon(Iconsax.information, size: 18, color: Color(0xFF98A2B3)),
                  ),
                ),
              ),

              _sectionSpacer(),
              // ISSUER
              Text('Issuer', style: _header),
              const SizedBox(height: 6),
              TextFormField(
                controller: _issuerCtrl,
                decoration: InputDecoration(
                  hintText: 'DMV / Insurance Company',
                  border: _underline,
                  focusedBorder: _underline,
                  enabledBorder: _underline,
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Icon(Iconsax.information, size: 18, color: Color(0xFF98A2B3)),
                  ),
                ),
              ),

              _sectionSpacer(),
              // DATES
              Text('Issue Date', style: _header),
              const SizedBox(height: 6),
              _FlatPicker(
                label: _dateLabel(_issueDate),
                icon: Iconsax.calendar_1,
                onTap: _pickIssue,
              ),
              const SizedBox(height: 16),
              Text('Expiry Date', style: _header),
              const SizedBox(height: 6),
              _FlatPicker(
                label: _noExpiry ? 'No expiry' : _dateLabel(_expiryDate),
                icon: Iconsax.calendar,
                onTap: _noExpiry ? null : _pickExpiry,
                disabled: _noExpiry,
              ),
              CheckboxListTile(
                value: _noExpiry,
                onChanged: (v) => setState(() {
                  _noExpiry = v ?? false;
                  if (_noExpiry) _expiryDate = null;
                }),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('No expiry'),
              ),

              _sectionSpacer(),
              // FILE
              Text('Attachment', style: _header),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: const Color(0xFFCDD3DF))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Iconsax.document_upload, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_fileName ?? 'No file selected',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _fileName == null ? const Color(0xFF98A2B3) : null)),
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (_contentType != null) _contentType!,
                                if (_fileSize != null) _fmtSize(_fileSize),
                              ].join(' • '),
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Iconsax.add, size: 20, color: Color(0xFF6B7280)),
                    ],
                  ),
                ),
              ),

              _sectionSpacer(),
              // NOTES
              Text('Notes', style: _header),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesCtrl,
                minLines: 2,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Any additional notes or comments…',
                  border: _underline,
                  enabledBorder: _underline,
                  focusedBorder: _underline,
                ),
              ),

              const SizedBox(height: 28),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Iconsax.save_2),
                  label: Text(_saving ? 'Saving…' : 'Save Document'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================== Flat picker row ============================== */

class _FlatPicker extends StatelessWidget {
  const _FlatPicker({
    required this.label,
    required this.icon,
    this.onTap,
    this.disabled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final underline = const BorderSide(color: Color(0xFFCDD3DF), width: 1);
    final textColor = disabled ? const Color(0xFF9CA3AF) : const Color(0xFF111827);

    return InkWell(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: underline)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  color: textColor,
                ),
              ),
            ),
            Icon(icon, size: 20, color: const Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }
}
