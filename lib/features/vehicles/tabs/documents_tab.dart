// lib/features/vehicles/tabs/documents_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../documents/screens/upload_doc_screen.dart'; // needed for Firebase.app()

// TODO: fix these imports to match your folder structure
// import '../../documents/screens/upload_document_screen.dart';
// import '../../documents/screens/document_detail_screen.dart';

class DocumentsTab extends StatelessWidget {
  const DocumentsTab({
    super.key,
    required this.vehicleId,
    this.databaseId = 'autoaid',
  });

  final String vehicleId;
  final String databaseId;

  @override
  Widget build(BuildContext context) {
    // Use named Firestore (multi-db) correctly by passing the app.
    // If you don't use multi-db, you can replace this with FirebaseFirestore.instance.
    final db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: databaseId,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => UploadDocumentScreen(vehicleId: vehicleId));
        },
        icon: const Icon(Iconsax.add),
        label: const Text('Add'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db
            .collection('vehicles')
            .doc(vehicleId)
            .collection('documents')
            .orderBy('expiry_date', descending: false)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Could not load documents.\n${snap.error}'));
          }

          final docs = snap.data?.docs ?? const [];
          if (docs.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 110),
              children: const [_EmptyState()],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final d = docs[i];
              final x = d.data();

              final type = (x['type'] ?? 'other').toString();
              final icon = _iconForType(type);
              final title = _displayType(type);
              final subtitle = _validityText(
                noExpiry: (x['no_expiry'] ?? false) as bool,
                expiryTs: x['expiry_date'],
              );

              return _ReportCard(
                icon: icon,
                title: title,
                subtitle: subtitle,
                onTap: () {
                  // TODO: navigate to your Detail screen
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (_) => DocumentDetailScreen(
                  //     vehicleId: vehicleId,
                  //     documentId: d.id,
                  //   ),
                  // ));
                },
              );
            },
          );
        },
      ),
    );
  }
}

/* ============================== UI pieces ============================== */

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE6E8ED)),
        ),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: c.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(subtitle, style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3, size: 18, color: Color(0xFF9CA3AF)),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      children: [
        Text('No documents yet', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(
          'Tap the Add button to upload insurance, registration, or emission docs.',
          style: t.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/* ============================== Helpers ============================== */

IconData _iconForType(String type) {
  switch (type) {
    case 'insurance':
      return Iconsax.shield_tick;
    case 'registration':
      return Iconsax.document_text;
    case 'emission':
      return Iconsax.flash_1;
    default:
      return Iconsax.document;
  }
}

String _displayType(String type) {
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

/// Builds a label like:
/// - "No expiry"
/// - "No expiry date set"
/// - "Expired Jan 2025"
/// - "Valid until Mar 2026"
String _validityText({required bool noExpiry, required Object? expiryTs}) {
  if (noExpiry) return 'No expiry';
  if (expiryTs == null) return 'No expiry date set';

  DateTime? expiry;
  if (expiryTs is Timestamp) {
    expiry = expiryTs.toDate();
  } else if (expiryTs is Map && expiryTs.containsKey('_seconds')) {
    expiry = DateTime.fromMillisecondsSinceEpoch((expiryTs['_seconds'] as int) * 1000);
  }

  if (expiry == null) return 'No expiry date set';
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  final label = '${months[expiry.month - 1]} ${expiry.year}';
  return expiry.isBefore(DateTime.now()) ? 'Expired $label' : 'Valid until $label';
}
