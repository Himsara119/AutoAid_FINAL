import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a generated or uploaded report linked to a vehicle.
///
/// Use [createWriteMap] for creates (server timestamps).
/// Use [toJson] for partial updates/patches (no forced timestamps).
class ReportModel {
  final String id;
  final String dealershipId;
  final String vehicleId;
  final String? customerId;

  /// e.g. "inspection", "condition", "resale", "insurance"
  final String category;

  final String fileName;
  final String fileUrl;
  final String fileType; // application/pdf, image/png, etc.
  final String? notes;

  /// Stored in-memory as DateTime for convenience.
  final DateTime? createdAt; // firestore fields: uploaded_at / created_at
  final DateTime? updatedAt; // firestore field:  updated_at

  const ReportModel({
    required this.id,
    required this.dealershipId,
    required this.vehicleId,
    this.customerId,
    required this.category,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /* ----------------------------- FACTORIES ----------------------------- */

  /// Robust constructor from a Firestore document.
  factory ReportModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return ReportModel(
      id: doc.id,
      dealershipId: _asString(data['dealership_id']),
      vehicleId: _asString(data['vehicle_id']),
      customerId: _asNullableString(data['customer_id']),
      category: _asString(data['category'], fallback: 'report'),
      fileName: _asString(data['file_name']),
      fileUrl: _asString(data['file_url']),
      fileType: _asString(data['file_type']),
      notes: _asNullableString(data['notes']),
      createdAt: _asDateTime(data['uploaded_at'] ?? data['created_at']),
      updatedAt: _asDateTime(data['updated_at']),
    );
  }

  /// If you have a raw map + id (e.g., from a converter or cache).
  factory ReportModel.fromMap(String id, Map<String, dynamic> data) {
    return ReportModel(
      id: id,
      dealershipId: _asString(data['dealership_id']),
      vehicleId: _asString(data['vehicle_id']),
      customerId: _asNullableString(data['customer_id']),
      category: _asString(data['category'], fallback: 'report'),
      fileName: _asString(data['file_name']),
      fileUrl: _asString(data['file_url']),
      fileType: _asString(data['file_type']),
      notes: _asNullableString(data['notes']),
      createdAt: _asDateTime(data['uploaded_at'] ?? data['created_at']),
      updatedAt: _asDateTime(data['updated_at']),
    );
  }

  /* ----------------------------- WRITES ----------------------------- */

  /// For PATCH/UPDATE where you control exactly what to send.
  /// Does NOT force server timestamps.
  Map<String, dynamic> toJson() {
    return {
      'dealership_id': dealershipId,
      'vehicle_id': vehicleId,
      if (customerId != null) 'customer_id': customerId,
      'category': category,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (createdAt != null) 'uploaded_at': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updated_at': Timestamp.fromDate(updatedAt!),
    };
  }

  /// Preferred for CREATEs. Lets Firestore set both timestamps.
  static Map<String, dynamic> createWriteMap({
    required String dealershipId,
    required String vehicleId,
    String? customerId,
    required String category,
    required String fileName,
    required String fileUrl,
    required String fileType,
    String? notes,
  }) {
    return {
      'dealership_id': dealershipId,
      'vehicle_id': vehicleId,
      if (customerId != null) 'customer_id': customerId,
      'category': category,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'uploaded_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /* ----------------------------- UTILS ----------------------------- */

  ReportModel copyWith({
    String? fileName,
    String? fileUrl,
    String? fileType,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id,
      dealershipId: dealershipId,
      vehicleId: vehicleId,
      customerId: customerId,
      category: category,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/* ------------------------- helpers ------------------------- */

String _asString(Object? v, {String fallback = ''}) =>
    v is String ? v : (v == null ? fallback : v.toString());

String? _asNullableString(Object? v) => v == null ? null : v.toString();

DateTime? _asDateTime(Object? v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is Timestamp) return v.toDate();
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
  if (v is String) return DateTime.tryParse(v);
  return null;
}
