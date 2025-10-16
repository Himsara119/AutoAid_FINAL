import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceOrderItem {
  final String id;
  final String type; // labor|part|fee
  final String name;
  final String? description;
  final double qty;
  final double unitPrice;
  final double lineTotal;

  ServiceOrderItem({
    required this.id,
    required this.type,
    required this.name,
    this.description,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory ServiceOrderItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final x = d.data()!;
    return ServiceOrderItem(
      id: d.id,
      type: x['type'],
      name: x['name'],
      description: x['description'],
      qty: (x['qty'] as num).toDouble(),
      unitPrice: (x['unit_price'] as num).toDouble(),
      lineTotal: (x['line_total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'description': description,
    'qty': qty,
    'unit_price': unitPrice,
    'line_total': lineTotal,
  };
}

class ServiceOrder {
  final String id;
  final String dealershipId;
  final String customerId;
  final String vehicleId;
  final String? appointmentId;
  final String status; // draft|approved|in_progress|done|rejected
  final double subtotal, tax, total;
  final String currency;
  final Timestamp? createdAt, updatedAt;

  ServiceOrder({
    required this.id,
    required this.dealershipId,
    required this.customerId,
    required this.vehicleId,
    this.appointmentId,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.currency,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceOrder.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final x = d.data()!;
    return ServiceOrder(
      id: d.id,
      dealershipId: x['dealership_id'],
      customerId: x['customer_id'],
      vehicleId: x['vehicle_id'],
      appointmentId: x['appointment_id'],
      status: x['status'] ?? 'draft',
      subtotal: (x['subtotal'] as num).toDouble(),
      tax: (x['tax'] as num).toDouble(),
      total: (x['total'] as num).toDouble(),
      currency: x['currency'] ?? 'USD',
      createdAt: x['created_at'],
      updatedAt: x['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'dealership_id': dealershipId,
    'customer_id': customerId,
    'vehicle_id': vehicleId,
    'appointment_id': appointmentId,
    'status': status,
    'subtotal': subtotal,
    'tax': tax,
    'total': total,
    'currency': currency,
    'created_at': createdAt ?? FieldValue.serverTimestamp(),
    'updated_at': FieldValue.serverTimestamp(),
  };
}
