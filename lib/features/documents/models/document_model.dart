import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

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
}

/// Nice-to-have computed bits used by the UI.
extension DocumentRecordComputed on DocumentRecord {
  String get displayType {
    switch (type) {
      case 'insurance': return 'Insurance Policy';
      case 'registration': return 'Vehicle Registration';
      case 'emission': return 'Emission Certificate';
      default: return 'Document';
    }
  }

  IconData get icon {
    switch (type) {
      case 'insurance': return Iconsax.shield_tick;
      case 'registration': return Iconsax.document;
      case 'emission': return Iconsax.flash;
      default: return Iconsax.document_text;
    }
  }

  String validityText() {
    if (noExpiry) return 'No expiry';
    if (expiryDate == null) return 'No expiry date set';
    final y = expiryDate!.year;
    const m3 = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final label = '${m3[expiryDate!.month - 1]} $y';
    return expiryDate!.isBefore(DateTime.now()) ? 'Expired $label' : 'Valid until $label';
  }

  bool get isExpiringSoon {
    if (noExpiry || expiryDate == null) return false;
    final in30 = DateTime.now().add(const Duration(days: 30));
    return expiryDate!.isBefore(in30) && expiryDate!.isAfter(DateTime.now());
  }
}
