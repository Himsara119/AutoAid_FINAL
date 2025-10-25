import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// DocumentDetailScreen
/// - Reads vehicles/{vehicleId}/documents/{documentId} from Firestore (db=autoaid)
/// - Renders header, validity, file metadata, and notes
/// - Actions: Open/Download, Replace file (navigates to EditDocumentScreen), Delete
///
/// Next step (your “fourth” screen): implement EditDocumentScreen to prefill and update.
/// For now this file only navigates there; you’ll add that file next.

class DocumentDetailScreen extends StatefulWidget {
  const DocumentDetailScreen({
    super.key,
    required this.vehicleId,
    required this.documentId,
    this.databaseId = 'autoaid',
  });

  final String vehicleId;
  final String documentId;
  final String databaseId;

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  late final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: widget.databaseId,
  );

  late final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    app: Firebase.app(),
    bucket: Firebase.app().options.storageBucket,
  );

  Stream<DocumentRecord> _stream() => _db
      .collection('vehicles')
      .doc(widget.vehicleId)
      .collection('documents')
      .doc(widget.documentId)
      .snapshots()
      .map((d) => DocumentRecord.fromSnap(d));

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      _snack('Cannot open file URL.');
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _delete(DocumentRecord rec) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete document'),
        content: const Text(
            'This will remove the record. The file will also be deleted from cloud storage.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      // Best-effort storage deletion if we have a direct download URL
      if (rec.fileUrl != null && rec.fileUrl!.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(rec.fileUrl!);
          await ref.delete();
        } catch (_) {
          // ignore storage delete errors; record delete will still proceed
        }
      }
      await _db
          .collection('vehicles')
          .doc(widget.vehicleId)
          .collection('documents')
          .doc(widget.documentId)
          .delete();

      if (mounted) {
        _snack('Document deleted.');
        Get.back();
      }
    } catch (e) {
      _snack('Delete failed: $e');
    }
  }

  void _replaceFile(DocumentRecord rec) {
    // You’ll implement this in the next step.
    // Pass current record so the edit screen can prefill everything and only replace what changed.
    Get.to(() => EditDocumentScreen(
      vehicleId: widget.vehicleId,
      documentId: widget.documentId,
      existing: rec,
      databaseId: widget.databaseId,
    ));
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document'),
        actions: [
          // placeholder "more" menu if you want
        ],
      ),
      body: StreamBuilder<DocumentRecord>(
        stream: _stream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _CenteredMsg('Error: ${snap.error}');
          }
          if (!snap.hasData) {
            return const _CenteredMsg('Not found.');
          }

          final rec = snap.data!;
          final isExpired = rec.status == 'expired';
          final isImage = rec.contentType?.startsWith('image/') == true;
          final isPdf = rec.contentType == 'application/pdf';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            children: [
              // Header card
              _Card(
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: c.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(rec.icon, size: 28, color: c.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rec.displayType,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            rec.validityText(),
                            style: TextStyle(
                              color: isExpired
                                  ? Colors.red[700]
                                  : rec.isExpiringSoon
                                  ? Colors.orange[700]
                                  : Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('Expired',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            )),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Metadata
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Name', rec.name),
                    _kvIf('Number', rec.number),
                    _kvIf('Issuer', rec.issuer),
                    _kv('Issue date', _fmtDate(rec.issueDate)),
                    _kv('Expiry date', rec.noExpiry ? 'No expiry' : _fmtDate(rec.expiryDate)),
                    _kv('Status', rec.status),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // File
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Section('File'),
                    const SizedBox(height: 8),
                    if (rec.fileName != null || rec.contentType != null || rec.fileSize != null)
                      _kv('Name', rec.fileName ?? '—'),
                    _kv('Type', rec.contentType ?? '—'),
                    _kv('Size', rec.fileSize == null ? '—' : _fmtSize(rec.fileSize!)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: rec.fileUrl == null ? null : () => _openFile(rec.fileUrl!),
                          icon: const Icon(Iconsax.document),
                          label: Text(kIsWeb ? 'Open' : 'Open / Download'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _replaceFile(rec),
                          icon: const Icon(Iconsax.document_upload),
                          label: const Text('Replace file'),
                        ),
                      ],
                    ),
                    if (isImage && rec.fileUrl != null) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(rec.fileUrl!, height: 220, fit: BoxFit.cover),
                      ),
                    ],
                    if (isPdf && rec.fileUrl != null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'PDF preview opens externally.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),

              if (rec.notes != null && rec.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Section('Notes'),
                      const SizedBox(height: 8),
                      Text(rec.notes!, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),
              // Danger zone
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Section('Danger zone'),
                    const SizedBox(height: 8),
                    Text(
                      'This will permanently remove the record and its file.',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red[50]),
                        foregroundColor: WidgetStatePropertyAll(Colors.red[800]),
                      ),
                      onPressed: () => _delete(rec),
                      icon: const Icon(Iconsax.trash),
                      label: const Text('Delete document'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/* ============================== Model ============================== */

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
  final String status; // active | expired | archived
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

  String get displayType {
    switch (type) {
      case 'insurance':
        return 'Insurance Policy';
      case 'registration':
        return 'Vehicle Registration';
      case 'emission':
        return 'Emission Certificate';
      default:
        return 'Document';
    }
  }

  IconData get icon {
    switch (type) {
      case 'insurance':
        return Iconsax.shield_tick;
      case 'registration':
        return Iconsax.document;
      case 'emission':
        return Iconsax.flash;
      default:
        return Iconsax.document_text;
    }
  }

  String validityText() {
    if (noExpiry) return 'No expiry';
    if (expiryDate == null) return 'No expiry date set';
    final now = DateTime.now();
    final y = expiryDate!.year;
    final m = _month3(expiryDate!.month);
    final label = '$m $y';
    return expiryDate!.isBefore(now) ? 'Expired $label' : 'Valid until $label';
  }

  bool get isExpiringSoon {
    if (noExpiry || expiryDate == null) return false;
    final in30 = DateTime.now().add(const Duration(days: 30));
    return expiryDate!.isBefore(in30) && expiryDate!.isAfter(DateTime.now());
  }

  static String _month3(int m) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
}

/* ============================== UI bits ============================== */

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700));
  }
}

Widget _kv(String k, String v) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(width: 140, child: Text(k, style: const TextStyle(color: Colors.black54))),
        const SizedBox(width: 8),
        Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
      ],
    ),
  );
}

Widget _kvIf(String k, String? v) {
  if (v == null || v.trim().isEmpty) return const SizedBox.shrink();
  return _kv(k, v);
}

String _fmtDate(DateTime? d) => d == null ? '—' : DateFormat.yMMMd().format(d);

String _fmtSize(int bytes) {
  const kb = 1024;
  const mb = 1024 * 1024;
  if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(1)} MB';
  if (bytes >= kb) return '${(bytes / kb).toStringAsFixed(1)} KB';
  return '$bytes B';
}

class _CenteredMsg extends StatelessWidget {
  const _CenteredMsg(this.msg);
  final String msg;
  @override
  Widget build(BuildContext context) => Center(child: Text(msg, textAlign: TextAlign.center));
}

/* =========================== Next screen stub =========================== */

/// Placeholder. You’ll implement this in the next step.
/// Keep it here so navigation compiles today.
class EditDocumentScreen extends StatelessWidget {
  const EditDocumentScreen({
    super.key,
    required this.vehicleId,
    required this.documentId,
    required this.existing,
    this.databaseId = 'autoaid',
  });

  final String vehicleId;
  final String documentId;
  final DocumentRecord existing;
  final String databaseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Document')),
      body: const Center(
        child: Text('Next step: implement edit screen with prefilled data and replace upload.'),
      ),
    );
  }
}
