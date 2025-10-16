import 'package:cloud_firestore/cloud_firestore.dart';

class InvoicesRepository {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('invoices');

  /// Create a new invoice document
  Future<String> create({
    required String dealershipId,
    required String serviceOrderId,
    required String customerId,
    required String vehicleId,
    required double amountDue,
    required String currency,
    required String status, // draft|issued|paid|void
    DateTime? dueDate,
  }) async {
    final doc = _col.doc();
    await doc.set({
      'dealership_id': dealershipId,
      'service_order_id': serviceOrderId,
      'customer_id': customerId,
      'vehicle_id': vehicleId,
      'amount_due': amountDue,
      'currency': currency,
      'status': status,
      'due_date': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'issued_at': FieldValue.serverTimestamp(),
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Retrieve an invoice by its ID
  Future<Map<String, dynamic>?> getById(String id) async {
    final d = await _col.doc(id).get();
    return d.exists ? d.data() : null;
  }

  /// List invoices by dealership
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> listByDealership(
      String dealershipId) async {
    final q = await _col
        .where('dealership_id', isEqualTo: dealershipId)
        .orderBy('created_at', descending: true)
        .get();
    return q.docs;
  }

  /// Update invoice fields
  Future<void> update(String id, Map<String, dynamic> patch) =>
      _col.doc(id).update({
        ...patch,
        'updated_at': FieldValue.serverTimestamp(),
      });

  /// Mark an invoice as paid
  Future<void> markPaid(String id) => _col.doc(id).update({
    'status': 'paid',
    'paid_at': FieldValue.serverTimestamp(),
    'updated_at': FieldValue.serverTimestamp(),
  });

  /// Delete an invoice (soft delete if needed)
  Future<void> delete(String id) => _col.doc(id).delete();
}
