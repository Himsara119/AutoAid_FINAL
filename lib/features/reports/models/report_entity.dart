import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String dealershipId;
  final String vehicleId;
  final String? customerId;
  final String category; // e.g., "inspection", "condition", "service_summary"
  final String fileName;
  final String fileUrl;
  final String fileType; // application/pdf, image/png, etc.
  final String? notes;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  ReportModel({
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

  factory ReportModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ReportModel(
      id: doc.id,
      dealershipId: data['dealership_id'] ?? '',
      vehicleId: data['vehicle_id'] ?? '',
      customerId: data['customer_id'],
      category: data['category'] ?? 'report',
      fileName: data['file_name'] ?? '',
      fileUrl: data['file_url'] ?? '',
      fileType: data['file_type'] ?? '',
      notes: data['notes'],
      createdAt: data['uploaded_at'],
      updatedAt: data['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'dealership_id': dealershipId,
    'vehicle_id': vehicleId,
    'customer_id': customerId,
    'category': category,
    'file_name': fileName,
    'file_url': fileUrl,
    'file_type': fileType,
    'notes': notes,
    'uploaded_at': createdAt ?? FieldValue.serverTimestamp(),
    'updated_at': FieldValue.serverTimestamp(),
  };
}
