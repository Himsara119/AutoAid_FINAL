import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String id;
  final String dealershipId;
  final String? vehicleId;
  final String? customerId;
  final String category;
  final String fileName, fileUrl, fileType;
  final Timestamp? uploadedAt, updatedAt, expiresAt;
  final String? notes;

  DocumentModel({
    required this.id,
    required this.dealershipId,
    this.vehicleId,
    this.customerId,
    required this.category,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.uploadedAt,
    this.updatedAt,
    this.expiresAt,
    this.notes,
  });

  factory DocumentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final x = d.data()!;
    return DocumentModel(
      id: d.id,
      dealershipId: x['dealership_id'],
      vehicleId: x['vehicle_id'],
      customerId: x['customer_id'],
      category: x['category'],
      fileName: x['file_name'],
      fileUrl: x['file_url'],
      fileType: x['file_type'],
      uploadedAt: x['uploaded_at'],
      updatedAt: x['updated_at'],
      expiresAt: x['expires_at'],
      notes: x['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Dealership_ID': dealershipId,
    'Vehicle_ID': vehicleId,
    'Customer_ID': customerId,
    'Category': category,
    'File_Name': fileName,
    'File_URL': fileUrl,
    'File_Type': fileType,
    'Uploaded_At': uploadedAt ?? FieldValue.serverTimestamp(),
    'Updated_At': FieldValue.serverTimestamp(),
    'notes': notes,
  };
}
