// lib/features/vehicles/models/service_record.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRecord {
  ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.serviceDate,
    this.nextServiceDate,
    required this.mileage,
    required this.provider,
    required this.cost,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,

    // Invoice (optional)
    this.invoiceUrl,
    this.invoiceName,
    this.invoiceSizeBytes,
  });

  /// Firestore document id (services/{id})
  final String id;

  /// Parent vehicle id (vehicles/{vehicleId})
  final String vehicleId;

  /// e.g. "Oil Change", "Brake Service"
  final String type;

  /// When the service was performed
  final DateTime serviceDate;

  /// Optional: next service date
  final DateTime? nextServiceDate;

  /// Odometer at service time
  final int mileage;

  /// Workshop / provider name
  final String provider;

  /// Total cost (numeric, currency handled at UI)
  final num cost;

  /// "completed" | "due" | anything else you invent later
  final String status;

  /// Free-form notes
  final String notes;

  /// Audit fields
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Invoice fields (optional)
  final String? invoiceUrl;       // e.g. https://.../invoice.pdf
  final String? invoiceName;      // e.g. oil-change-receipt.pdf
  final int? invoiceSizeBytes;    // raw size (for pretty label below)

  /// Pretty size like "124 KB" or "2.1 MB"
  String get invoiceSizeLabel {
    final b = invoiceSizeBytes ?? 0;
    if (b <= 0) return '';
    if (b < 1024) return '$b B';
    final kb = b / 1024.0;
    if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
    final mb = kb / 1024.0;
    return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
  }

  /* -------------------------- Factories / Parsing -------------------------- */

  /// Build from a Firestore doc in: vehicles/{vehicleId}/services/{serviceId}
  static ServiceRecord fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc, {
        String? vehicleId,
      }) {
    final data = doc.data() ?? const {};
    return ServiceRecord.fromMap(
      data,
      id: doc.id,
      vehicleId: vehicleId ?? (data['vehicle_id'] as String? ?? ''),
    );
  }

  /// Convenience for query snapshots.
  static ServiceRecord fromSnap(QueryDocumentSnapshot<Map<String, dynamic>> snap,
      {String? vehicleId}) {
    return fromDoc(snap, vehicleId: vehicleId);
  }

  /// Build from a plain map. You must supply id and vehicleId.
  factory ServiceRecord.fromMap(
      Map<String, dynamic> m, {
        required String id,
        required String vehicleId,
      }) {
    DateTime? _ts(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    int _int(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    num _num(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v;
      return num.tryParse(v.toString()) ?? 0;
    }

    String _str(dynamic v) => (v ?? '').toString();

    final created = _ts(m['created_at']) ?? DateTime.now();
    final updated = _ts(m['updated_at']) ?? created;

    return ServiceRecord(
      id: id,
      vehicleId: vehicleId,
      type: _str(m['type']).trim(),
      serviceDate: _ts(m['service_date']) ?? DateTime.now(),
      nextServiceDate: _ts(m['next_service_date']),
      mileage: _int(m['mileage']),
      provider: _str(m['provider']).trim(),
      cost: _num(m['cost']),
      status: _str(m['status']).trim().toLowerCase(),
      notes: _str(m['notes']),
      createdAt: created,
      updatedAt: updated,

      // Invoice fields (all optional)
      invoiceUrl: (m['invoice_url'] as String?)?.trim(),
      invoiceName: (m['invoice_name'] as String?)?.trim(),
      invoiceSizeBytes: m['invoice_size_bytes'] is int
          ? m['invoice_size_bytes'] as int
          : int.tryParse('${m['invoice_size_bytes']}'),
    );
  }

  /* ------------------------------- Serialization ------------------------------- */

  /// Map for writing to Firestore. Keeps snake_case to match existing data.
  Map<String, dynamic> toMap() {
    return {
      // convenience duplicates if you seed or query across collections
      'service_id': id,
      'vehicle_id': vehicleId,

      'type': type,
      'service_date': Timestamp.fromDate(serviceDate),
      'next_service_date': nextServiceDate == null ? null : Timestamp.fromDate(nextServiceDate!),
      'mileage': mileage,
      'provider': provider,
      'cost': cost,
      'status': status,
      'notes': notes,

      // invoice
      'invoice_url': invoiceUrl,
      'invoice_name': invoiceName,
      'invoice_size_bytes': invoiceSizeBytes,

      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  ServiceRecord copyWith({
    String? id,
    String? vehicleId,
    String? type,
    DateTime? serviceDate,
    DateTime? nextServiceDate,
    int? mileage,
    String? provider,
    num? cost,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? invoiceUrl,
    String? invoiceName,
    int? invoiceSizeBytes,
  }) {
    return ServiceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      serviceDate: serviceDate ?? this.serviceDate,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      mileage: mileage ?? this.mileage,
      provider: provider ?? this.provider,
      cost: cost ?? this.cost,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      invoiceName: invoiceName ?? this.invoiceName,
      invoiceSizeBytes: invoiceSizeBytes ?? this.invoiceSizeBytes,
    );
  }
}