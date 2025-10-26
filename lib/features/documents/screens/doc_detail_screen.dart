// ignore_for_file: use_build_context_synchronously
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

import '../models/document_model.dart';          // <-- use the shared model
import 'edit_document_screen.dart' hide DocumentRecord;

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
          'This will remove the record. The file will also be deleted from cloud storage.',
        ),
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
      if (rec.fileUrl != null && rec.fileUrl!.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(rec.fileUrl!);
          await ref.delete();
        } catch (_) {/* best-effort */}
      }
      await _db
          .collection('vehicles')
          .doc(widget.vehicleId)
          .collection('documents')
          .doc(widget.documentId)
          .delete();

      _snack('Document deleted.');
      Get.back();
    } catch (e) {
      _snack('Delete failed: $e');
    }
  }

  void _replaceFile(DocumentRecord rec) {
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
      appBar: AppBar(title: const Text('Document')),
      bottomNavigationBar: _BottomActionBar(
        primaryLabel: 'Close',
        secondaryLabel: 'Replace',
        onPrimary: () => Get.back(),
        onSecondary: () async {
          final rec = await _stream().first;
          _replaceFile(rec);
        },
      ),
      body: StreamBuilder<DocumentRecord>(
        stream: _stream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return _CenteredMsg('Error: ${snap.error}');
          if (!snap.hasData) return const _CenteredMsg('Not found.');

          final rec = snap.data!;
          final isExpired = rec.status == 'expired';
          final isImage = rec.contentType?.startsWith('image/') == true;
          final isPdf = rec.contentType == 'application/pdf';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            children: [
              _Card(
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: 0.08),
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
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: rec.fileUrl == null ? null : () => _openFile(rec.fileUrl!),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: c.primary.withValues(alpha: 0.10),
                          foregroundColor: c.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        icon: const Icon(Iconsax.export_1, size: 20),
                        label: Text(
                          kIsWeb ? 'Open' : 'Open / Download',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
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

/* ----------------------------- Bottom action bar ----------------------------- */

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String primaryLabel;   // filled button on the right
  final String secondaryLabel; // outlined button on the left
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: onSecondary,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: c.primary.withValues(alpha: 0.35)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    foregroundColor: c.primary,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  child: Text(secondaryLabel, overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: onPrimary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  child: Text(primaryLabel, overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------------------- Small helpers ----------------------------- */

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
  const kb = 1024, mb = 1024 * 1024;
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
