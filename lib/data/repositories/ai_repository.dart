import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/ai/models/ai_diagnosis_model.dart';

class AIRepository {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('ai_diagnoses');

  /// Stub: plug in your real AI call before saving.
  Future<String> diagnoseAndSave({
    required String dealershipId,
    required String vehicleId,
    required List<String> symptoms,
  }) async {
    // TODO: replace with real AI call
    final fake = {
      'probable_causes': ['Worn spark plugs', 'Clogged air filter'],
      'severity': 'medium',
      'recommended_actions': ['Replace spark plugs', 'Replace air filter'],
    };

    final doc = _col.doc();
    await doc.set(AIDiagnosis(
      id: doc.id,
      dealershipId: dealershipId,
      vehicleId: vehicleId,
      inputSymptoms: symptoms,
      aiResult: fake,
      confidence: 0.78,
    ).toJson());
    return doc.id;
  }

  Future<List<AIDiagnosis>> listByVehicle(String vehicleId) async {
    final q = await _col.where('vehicle_id', isEqualTo: vehicleId)
        .orderBy('created_at', descending: true).get();
    return q.docs.map(AIDiagnosis.fromDoc).toList();
  }
}
