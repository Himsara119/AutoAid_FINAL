import 'package:cloud_firestore/cloud_firestore.dart';

class ReportRepository {
  final _db = FirebaseFirestore.instance;

  /// For now: write a generated report record into /documents with file_url placeholder.
  Future<String> createVehicleReport({
    required String dealershipId,
    required String vehicleId,
    required String fileUrl,
    String fileType = 'application/pdf',
    String fileName = 'vehicle_report.pdf',
    String category = 'report',
  }) async {
    final doc = _db.collection('documents').doc();
    await doc.set({
      'dealership_id': dealershipId,
      'vehicle_id': vehicleId,
      'customer_id': null,
      'category': category,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'uploaded_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'notes': 'Auto-generated report',
    });
    return doc.id;
  }
}
