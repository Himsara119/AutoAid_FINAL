import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardRepository {
  final _db = FirebaseFirestore.instance;

  Future<Map<String, int>> dealershipCounts(String dealershipId) async {
    final vehicles = await _db
        .collection('vehicles')
        .where('dealership_id', isEqualTo: dealershipId)
        .where('deleted', isEqualTo: false)
        .count()
        .get();

    final reminders = await _db
        .collection('reminders')
        .where('dealership_id', isEqualTo: dealershipId)
        .count()
        .get();

    final orders = await _db
        .collection('service_orders')
        .where('dealership_id', isEqualTo: dealershipId)
        .count()
        .get();

    final invoices = await _db
        .collection('invoices')
        .where('dealership_id', isEqualTo: dealershipId)
        .count()
        .get();

    return {
      'vehicles': vehicles.count ?? 0,
      'reminders': reminders.count ?? 0,
      'service_orders': orders.count ?? 0,
      'invoices': invoices.count ?? 0,
    };
  }
}
