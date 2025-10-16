import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/services/models/service_model.dart';

class ServiceRepository {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('service_orders');

  Future<String> create(ServiceOrder order) async {
    final doc = _col.doc();
    await doc.set(order.toJson());
    return doc.id;
  }

  Future<ServiceOrder?> getById(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? ServiceOrder.fromDoc(d) : null;
  }

  Future<void> update(String id, Map<String, dynamic> patch) =>
      _col.doc(id).update({...patch, 'updated_at': FieldValue.serverTimestamp()});

  Future<void> addItem(String orderId, ServiceOrderItem item) =>
      _col.doc(orderId).collection('items').doc(item.id).set(item.toJson());

  Future<List<ServiceOrderItem>> listItems(String orderId) async {
    final q = await _col.doc(orderId).collection('items').get();
    return q.docs.map(ServiceOrderItem.fromDoc).toList();
  }

  Future<void> updateStatus(String id, String status) =>
      _col.doc(id).update({'status': status, 'updated_at': FieldValue.serverTimestamp()});
}
