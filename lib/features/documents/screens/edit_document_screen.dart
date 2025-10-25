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

/// EditDocumentScreen
/// - Prefills from existing record (passed in) or fetches by id.
/// - Allows metadata updates.
/// - Optional: replace file (uploads new, deletes old).
/// - Writes to: vehicles/{vehicleId}/documents/{documentId} (db='autoaid').
/// - On success: Get.back(result: 'updated').

class EditDocumentScreen extends StatefulWidget {
  const EditDocumentScreen({
    super.key,
    required this.vehicleId,
    required this.documentId,
    this.existing,
    this.databaseId = 'autoaid',
  });

  final String vehicleId;
  final String documentId;
  final DocumentRecord? existing; // optional if you navigated here from detail
  final String databaseId;

  @override
  State<EditDocumentScreen> createState() => _EditDocumentScreenState();
}

class _EditDocumentScreenState extends State<EditDocumentScreen> {
  final _form = GlobalKey<FormState>();

  // Fields
  String _type = 'other';
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _issuerCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _issueDate;
  DateTime? _expiryDate;
  bool _noExpiry = false;

  // Existing file
  String? _existingFileUrl;
  String? _existingFileName;
  int? _existingFileSize;
  String? _existingContentType;

  // New file (optional)
  String? _newFileName;
  String? _newContentType;
  int? _newFileSize;
  Uint8List? _newFileBytes;
  File? _newFile;

  bool _loading = true;
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
  void initState() {
    super.initState();
    _prime();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _issuerCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _prime() async {
    try {
      DocumentRecord rec;
      if (widget.existing != null) {
        rec = widget.existing!;
      } else {
        final snap = await _db
            .collection('vehicles')
            .doc(widget.vehicleId)
            .collection('documents')
            .doc(widget.documentId)
            .get();
        if (!snap.exists) {
          _snack('Document not found.');
          if (mounted) Get.back();
          return;
        }
        rec = DocumentRecord.fromSnap(snap);
      }

      _type = rec.type;
      _nameCtrl.text = rec.name;
      _numberCtrl.text = rec.number ?? '';
      _issuerCtrl.text = rec.issuer ?? '';
      _notesCtrl.text = rec.notes ?? '';
      _issueDate = rec.issueDate;
      _expiryDate = rec.expiryDate;
      _noExpiry = rec.noExpiry;

      _existingFileUrl = rec.fileUrl;
      _existingFileName = rec.fileName;
      _existingFileSize = rec.fileSize;
      _existingContentType = rec.contentType;
    } catch (e) {
      _snack('Failed to load: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickNewFile() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'heic', 'webp'],
    );
    if (res == null || res.files.isEmpty) return;

    final f = res.files.first;
    setState(() {
      _newFileName = f.name;
      _newFileSize = f.size;
      _newContentType = _inferContentTypeFromName(f.name);
      if (kIsWeb) {
        _newFileBytes = f.bytes;
        _newFile = null;
      } else {
        if (f.path != null) _newFile = File(f.path!);
        _newFileBytes = f.bytes;
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

  Future<void> _save() async {
    final valid = _form.currentState?.validate() ?? false;
    if (!valid) return;
    if (!_noExpiry && _expiryDate == null) {
      _snack('Set an expiry date or toggle "No expiry".');
      return;
    }

    setState(() => _saving = true);

    try {
      final now = Timestamp.now();
      final uid = FirebaseAuth.instance.currentUser?.uid;

      final docRef = _db
          .collection('vehicles')
          .doc(widget.vehicleId)
          .collection('documents')
          .doc(widget.documentId);

      String? fileUrl = _existingFileUrl;
      String? fileName = _existingFileName;
      int? fileSize = _existingFileSize;
      String? contentType = _existingContentType;

      // If a new file is picked, upload it and delete the old one
      if (_newFileName != null && (_newFile != null || _newFileBytes != null)) {
        final storagePath = 'documents/${widget.vehicleId}/${widget.documentId}/${_newFileName!}';
        final meta = SettableMetadata(contentType: _newContentType ?? 'application/octet-stream');

        final task = kIsWeb || _newFile == null
            ? _storage.ref(storagePath).putData(_newFileBytes as Uint8List, meta)
            : _storage.ref(storagePath).putFile(_newFile as File, meta);

        final snap = await task.whenComplete(() {});
        final newUrl = await snap.ref.getDownloadURL();
        final newSize = _newFileSize ?? snap.totalBytes;

        // best-effort delete of previous file
        if (_existingFileUrl != null && _existingFileUrl!.isNotEmpty) {
          try {
            final oldRef = _storage.refFromURL(_existingFileUrl!);
            await oldRef.delete();
          } catch (_) {
            // ignore storage delete failure
          }
        }

        fileUrl = newUrl;
        fileName = _newFileName;
        fileSize = newSize;
        contentType = _newContentType;
      }

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
        'file_url': fileUrl,
        'file_name': fileName,
        'file_size': fileSize,
        'content_type': contentType,
        'status': status,
        'updated_at': now,
        if (uid != null) 'updated_by': 'users/$uid',
        'vehicle_id': widget.vehicleId, // keep for analytics/debug parity
      };

      await docRef.set(data, SetOptions(merge: true));

      _snack('Document updated.');
      if (mounted) Get.back(result: 'updated');
    } catch (e) {
      _snack('Failed to update: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate({required bool isIssue}) async {
    final now = DateTime.now();
    final initial = isIssue ? (_issueDate ?? now) : (_expiryDate ?? now);
    final first = DateTime(1990, 1, 1);
    final last = DateTime(now.year + 10, 12, 31);

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

  String _d(DateTime? dt) => dt == null ? 'Not set' : DateFormat.yMMMd().format(dt);

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Document'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Iconsax.save_2),
            label: const Text('Save'),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _saving,
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              const _Section('Type'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'insurance', child: Text('Insurance')),
                  DropdownMenuItem(value: 'registration', child: Text('Registration')),
                  DropdownMenuItem(value: 'emission', child: Text('Emission')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'other'),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              const _Section('Details'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _numberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Number (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _issuerCtrl,
                decoration: const InputDecoration(
                  labelText: 'Issuer (optional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),
              const _Section('Dates'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DateTile(
                      label: 'Issue date',
                      value: _d(_issueDate),
                      onTap: () => _pickDate(isIssue: true),
                      icon: Iconsax.calendar_1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateTile(
                      label: 'Expiry date',
                      value: _noExpiry ? 'No expiry' : _d(_expiryDate),
                      onTap: _noExpiry ? null : () => _pickDate(isIssue: false),
                      icon: Iconsax.calendar,
                      disabled: _noExpiry,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _noExpiry,
                onChanged: (v) => setState(() {
                  _noExpiry = v ?? false;
                  if (_noExpiry) _expiryDate = null;
                }),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('No expiry'),
              ),

              const SizedBox(height: 16),
              const _Section('File'),
              const SizedBox(height: 8),
              _ExistingFileRow(
                fileName: _existingFileName,
                fileSize: _existingFileSize,
                contentType: _existingContentType,
              ),
              const SizedBox(height: 8),
              _NewFilePickerRow(
                fileName: _newFileName,
                fileSize: _newFileSize,
                contentType: _newContentType,
                onPick: _pickNewFile,
              ),

              const SizedBox(height: 16),
              const _Section('Notes'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Any special instructions or comments…',
                  border: OutlineInputBorder(),
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
                  label: Text(_saving ? 'Saving…' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ============================== Shared model ============================== */

class DocumentRecord {
  final String id;
  final String type;
  final String name;
  final String? number;
  final String? issuer;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final bool noExpiry;
  final String? notes;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? contentType;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentRecord({
    required this.id,
    required this.type,
    required this.name,
    required this.number,
    required this.issuer,
    required this.issueDate,
    required this.expiryDate,
    required this.noExpiry,
    required this.notes,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
    required this.contentType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  static DocumentRecord fromSnap(DocumentSnapshot<Map<String, dynamic>> d) {
    final x = d.data() ?? <String, dynamic>{};
    String status = (x['status'] ?? 'active') as String;
    final noExpiry = (x['no_expiry'] ?? false) as bool;
    final expiryTs = x['expiry_date'] as Timestamp?;
    final expiry = expiryTs?.toDate();

    if (!noExpiry && expiry != null && expiry.isBefore(DateTime.now())) {
      status = 'expired';
    }

    return DocumentRecord(
      id: d.id,
      type: (x['type'] ?? 'other').toString(),
      name: (x['name'] ?? '').toString(),
      number: x['number'] as String?,
      issuer: x['issuer'] as String?,
      issueDate: (x['issue_date'] as Timestamp?)?.toDate(),
      expiryDate: expiry,
      noExpiry: noExpiry,
      notes: x['notes'] as String?,
      fileUrl: x['file_url'] as String?,
      fileName: x['file_name'] as String?,
      fileSize: (x['file_size'] is int) ? x['file_size'] as int : null,
      contentType: x['content_type'] as String?,
      status: status,
      createdAt: ((x['created_at'] as Timestamp?)?.toDate()) ?? DateTime.now(),
      updatedAt: ((x['updated_at'] as Timestamp?)?.toDate()) ?? DateTime.now(),
    );
  }
}

/* ============================== UI bits ============================== */

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700));
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
    required this.icon,
    this.disabled = false,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final IconData icon;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.outline.withOpacity(0.4)),
          color: disabled ? c.surfaceVariant.withOpacity(0.3) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ExistingFileRow extends StatelessWidget {
  const _ExistingFileRow({
    required this.fileName,
    required this.fileSize,
    required this.contentType,
  });

  final String? fileName;
  final int? fileSize;
  final String? contentType;

  String _fmtSize(int? s) {
    if (s == null) return '';
    const kb = 1024;
    const mb = 1024 * 1024;
    if (s >= mb) return '${(s / mb).toStringAsFixed(1)} MB';
    if (s >= kb) return '${(s / kb).toStringAsFixed(1)} KB';
    return '$s B';
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.outline.withOpacity(0.4)),
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
            child: const Icon(Iconsax.document, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName ?? 'No file on record', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  [
                    if (contentType != null && contentType!.isNotEmpty) contentType!,
                    if (fileSize != null) _fmtSize(fileSize),
                  ].join(' • '),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewFilePickerRow extends StatelessWidget {
  const _NewFilePickerRow({
    required this.fileName,
    required this.fileSize,
    required this.contentType,
    required this.onPick,
  });

  final String? fileName;
  final int? fileSize;
  final String? contentType;
  final VoidCallback onPick;

  String _fmtSize(int? s) {
    if (s == null) return '';
    const kb = 1024;
    const mb = 1024 * 1024;
    if (s >= mb) return '${(s / mb).toStringAsFixed(1)} MB';
    if (s >= kb) return '${(s / kb).toStringAsFixed(1)} KB';
    return '$s B';
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.outline.withOpacity(0.4)),
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
            child: fileName == null
                ? const Text('No replacement selected', style: TextStyle(color: Colors.black54))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName!, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  [
                    if (contentType != null && contentType!.isNotEmpty) contentType!,
                    if (fileSize != null) _fmtSize(fileSize),
                  ].join(' • '),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(onPressed: onPick, icon: const Icon(Iconsax.add), label: const Text('Replace')),
        ],
      ),
    );
  }
}

/* ============================== Doc model used above ============================== */

class DocumentRecordMinimal {
  // placeholder if you want a slimmer model; not used here.
}
