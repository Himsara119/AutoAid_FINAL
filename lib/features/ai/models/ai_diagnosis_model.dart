import 'package:cloud_firestore/cloud_firestore.dart';

class AIDiagnosis {
  final String id;
  final String dealershipId;
  final String vehicleId;
  final List<String> inputSymptoms;
  final Map<String, dynamic> aiResult; // probable_causes[], severity, recommended_actions[]
  final double? confidence;
  final Timestamp? createdAt;

  AIDiagnosis({
    required this.id,
    required this.dealershipId,
    required this.vehicleId,
    required this.inputSymptoms,
    required this.aiResult,
    this.confidence,
    this.createdAt,
  });

  factory AIDiagnosis.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final x = d.data()!;
    return AIDiagnosis(
      id: d.id,
      dealershipId: x['dealership_id'],
      vehicleId: x['vehicle_id'],
      inputSymptoms: List<String>.from(x['input_symptoms'] ?? []),
      aiResult: Map<String, dynamic>.from(x['ai_result'] ?? {}),
      confidence: (x['confidence'] as num?)?.toDouble(),
      createdAt: x['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'dealership_id': dealershipId,
    'vehicle_id': vehicleId,
    'input_symptoms': inputSymptoms,
    'ai_result': aiResult,
    'confidence': confidence,
    'created_at': createdAt ?? FieldValue.serverTimestamp(),
  };
}
