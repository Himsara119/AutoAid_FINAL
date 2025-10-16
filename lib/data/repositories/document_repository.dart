import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../features/documents/models/document_model.dart';

class DocumentRepository {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('documents');

  Future<String> uploadVehicleFile({
    required String dealershipId,
    required String vehicleId,
    required String category,
    required File file,
    required String fileName,
    required String fileType,
    String? notes,
    DateTime? expiresAt,
  }) async {
    final ref = _storage.ref('documents/$vehicleId/${DateTime.now().millisecondsSinceEpoch}_$fileName');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    final doc = _col.doc();
    await doc.set(DocumentModel(
      id: doc.id,
      dealershipId: dealershipId,
      vehicleId: vehicleId,
      category: category,
      fileName: fileName,
      fileUrl: url,
      fileType: fileType,
      expiresAt: expiresAt != null ? Timestamp.fromDate(expiresAt) : null,
      notes: notes,
    ).toJson());

    return doc.id;
  }

  Future<List<DocumentModel>> listByVehicle(String vehicleId) async {
    final q = await _col.where('vehicle_id', isEqualTo: vehicleId)
        .orderBy('uploaded_at', descending: true).get();
    return q.docs.map(DocumentModel.fromDoc).toList();
  }

  Future<void> update(String id, Map<String, dynamic> patch) =>
      _col.doc(id).update({...patch, 'updated_at': FieldValue.serverTimestamp()});

  Future<void> delete(String id) => _col.doc(id).delete();
}
