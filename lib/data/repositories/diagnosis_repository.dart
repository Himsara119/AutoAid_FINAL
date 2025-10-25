import 'package:cloud_firestore/cloud_firestore.dart';

class DiagnosisRepo {
  final _col = FirebaseFirestore.instance.collection('ai_diagnoses');

  Future<void> saveDiagnosis({
    required String diagId,
    required String vehicleId,
    required String dealershipId,
    required List<String> symptoms,
    required List<String> probableCauses,
    required List<String> recommendedActions,
    required String severity,
    required double confidence,
  }) async {
    await _col.doc(diagId).set({
      'diag_id': diagId,
      'vehicle_id': vehicleId,
      'dealership_id': dealershipId,
      'input_symptoms': symptoms,
      'ai_result': {
        'probable_causes': probableCauses,
        'recommended_actions': recommendedActions,
        'severity': severity,
      },
      'confidence': confidence,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
