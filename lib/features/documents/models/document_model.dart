import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Canonical Firestore model for:
/// vehicles/{vehicleId}/documents/{documentId}
///
/// Fields:
/// - type: "insurance" | "registration" | "emission" | "other"
/// - name: string
/// - number: string|null
/// - issuer: string|null
/// - issue_date: Timestamp|null
/// - expiry_date: Timestamp|null
/// - no_expiry: bool
/// - notes: string|null
/// - file_url: string|null
/// - file_name: string|null
/// - file_size: int|null (bytes)
/// - content_type: string|null
/// - status: "active" | "expired" | "archived"
/// - created_at: Timestamp
/// - updated_at: Timestamp
/// - vehicle_id: string (kept for analytics/debug parity)
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

  /* ============================== Factories ============================== */

  factory DocumentRecord.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    return _fromMap(d.id, d.data());
  }

  factory DocumentRecord.fromSnap(DocumentSnapshot<Map<String, dynamic>> d) {
    return _fromMap(d.id, d.data() ?? const {});
  }

  static DocumentRecord _fromMap(String id, Map<String, dynamic> x) {
    String status = (x['status'] ?? 'active') as String;
    final bool noExpiry = (x['no_expiry'] ?? false) as bool;
    final Timestamp? expTs = x['expiry_date'] as Timestamp?;
    final DateTime? expiry = expTs?.toDate();

    // Auto-calc expired if lazy data
    if (!noExpiry && expiry != null && expiry.isBefore(DateTime.now())) {
      status = 'expired';
    }

    return DocumentRecord(
      id: id,
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
      fileSize: x['file_size'] is int ? x['file_size'] as int : null,
      contentType: x['content_type'] as String?,
      status: status,
      createdAt: ((x['created_at'] as Timestamp?)?.toDate()) ?? DateTime.now(),
      updatedAt: ((x['updated_at'] as Timestamp?)?.toDate()) ?? DateTime.now(),
    );
  }

  /* ============================== UI helpers ============================== */

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

  /// "No expiry" | "No expiry date set" | "Expired Mar 2025" | "Valid until Mar 2025"
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

  /* ============================== Copy utils ============================== */

  DocumentRecord copyWith({
    String? type,
    String? name,
    String? number,
    String? issuer,
    DateTime? issueDate,
    DateTime? expiryDate,
    bool? noExpiry,
    String? notes,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? contentType,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentRecord(
      id: id,
      type: type ?? this.type,
      name: name ?? this.name,
      number: number ?? this.number,
      issuer: issuer ?? this.issuer,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      noExpiry: noExpiry ?? this.noExpiry,
      notes: notes ?? this.notes,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      contentType: contentType ?? this.contentType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'name': name,
      'number': number,
      'issuer': issuer,
      'issue_date': issueDate == null ? null : Timestamp.fromDate(issueDate!),
      'expiry_date': expiryDate == null ? null : Timestamp.fromDate(expiryDate!),
      'no_expiry': noExpiry,
      'notes': notes,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'content_type': contentType,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}
