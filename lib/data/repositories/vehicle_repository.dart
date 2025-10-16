import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/vehicles/models/vehicle_model.dart';

class VehicleRepository {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('vehicles');

  Future<String> create(VehicleModel v) async {
    final doc = _col.doc();
    await doc.set(v.toJson());
    return doc.id;
  }

  Future<VehicleModel?> getById(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? VehicleModel.fromDoc(d) : null;
  }

  Future<List<VehicleModel>> listByDealership(String dealershipId) async {
    final q = await _col
        .where('dealership_id', isEqualTo: dealershipId)
        .where('deleted', isEqualTo: false)
        .orderBy('updated_at', descending: true)
        .get();
    return q.docs.map(VehicleModel.fromDoc).toList();
  }

  Future<void> update(String id, Map<String, dynamic> patch) =>
      _col.doc(id).update({...patch, 'updated_at': FieldValue.serverTimestamp()});

  Future<void> softDelete(String id) =>
      _col.doc(id).update({'deleted': true, 'updated_at': FieldValue.serverTimestamp()});

  Future<void> transferOwnership({
    required String vehicleId,
    required String fromUserId,
    required String toUserId,
    double? price,
    String? notes,
  }) async {
    final ref = _col.doc(vehicleId);
    final transferRef = ref.collection('ownership_transfers').doc();
    await _db.runTransaction((tx) async {
      tx.update(ref, {
        'current_owner_id': toUserId,
        'status': 'sold',
        'is_for_sale': false,
        'updated_at': FieldValue.serverTimestamp(),
      });
      tx.set(transferRef, {
        'from_user': fromUserId,
        'to_user': toUserId,
        'price': price,
        'notes': notes,
        'transferred_at': FieldValue.serverTimestamp(),
      });
    });
  }
}
