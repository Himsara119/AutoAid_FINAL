import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class InvoicesRepository {
  InvoicesRepository({FirebaseFirestore? db})
          : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('invoices');

  Future<String> createFromServiceOrder(String serviceOrderId) async {
    final orderRef = _db.collection('service_orders').doc(serviceOrderId);
    final orderSnap = await orderRef.get();
    if (!orderSnap.exists) {
      throw(!orderSnap.exists) {
        throw StateError('Service order not found : $serviceOrderId');
      }

    }
  }
}

