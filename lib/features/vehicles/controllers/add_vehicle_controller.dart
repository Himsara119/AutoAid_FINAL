// lib/features/vehicles/controllers/add_vehicle_controller.dart
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// AddVehicleController
/// - Always sets new/evolving fields with defaults
/// - Uses merge writes so older clients don't break
/// - Adds vehicle_id = doc.id
class AddVehicleController {
  AddVehicleController({
    FirebaseFirestore? db,
    this.databaseId = 'autoaid', // your Firestore DB id
  }) : _db = db ??
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      );

  final FirebaseFirestore _db;
  final String databaseId;

  static const _tag = 'AddVehicleController';

  /// Create a vehicle with defaults.
  ///
  /// Required: make, model, year, mileage, vin, status
  /// Optional fields can be null; defaults will be applied.
  Future<String> saveVehicle({
    // required
    required String make,
    required String model,
    required String year,
    required String mileage,
    required String vin,
    required String status,

    // optional inputs you may wire from the UI later
    String? trim,
    String? registrationNumber,
    int? price,
    String? currency,
    String? fuelType,
    bool? isForSale,
    bool? reminderEnabled,
    int? serviceIntervalKm,
    int? serviceIntervalMonths,

    DateTime? insuranceExpiry,
    DateTime? registrationExpiry,
    DateTime? lastServiceDate,
    DateTime? nextServiceDue,

    // extra metadata hooks
    String ownerId = 'users/user_dealer_owner_001',
    String currentOwnerId = 'users/user_dealer_owner_001',
    String dealershipId = 'dealerships/dealer_001',
  }) async {
    // validate basics
    final yr = int.tryParse(year);
    final km = int.tryParse(mileage);
    if (yr == null || yr < 1900) {
      throw ArgumentError('Invalid year: "$year"');
    }
    if (km == null || km < 0) {
      throw ArgumentError('Invalid mileage: "$mileage"');
    }

    final now = DateTime.now();
    final docRef = _db.collection('vehicles').doc(); // we want the id for vehicle_id

    final payload = <String, dynamic>{
      // canonical identifiers
      'vehicle_id': docRef.id,

      // core
      'make': make.trim(),
      'model': model.trim(),
      'trim': (trim ?? '').trim(),
      'year': yr,
      'vin': vin.trim(),
      'mileage': km,
      'status': status.toLowerCase(),

      // ownership
      'owner_id': ownerId,
      'current_owner_id': currentOwnerId,
      'dealership_id': dealershipId,

      // evolving business fields with defaults
      'registration_number': (registrationNumber ?? '').trim(),
      'price': price ?? 0,
      'currency': (currency ?? 'LKR').trim(),
      'fuel_type': (fuelType ?? 'petrol').trim(),
      'is_for_sale': isForSale ?? false,
      'reminder_enabled': reminderEnabled ?? true,
      'service_interval_km': serviceIntervalKm ?? 1000,
      'service_interval_months': serviceIntervalMonths ?? 6,

      // arrays/objects that can grow later
      'photos': <dynamic>[],

      // lifecycle + bookkeeping
      'deleted': false,
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
      'schema_version': 1, // bump when you change shape
    };

    // Optional dates only when provided
    if (insuranceExpiry != null) {
      payload['insurance_expiry'] = Timestamp.fromDate(insuranceExpiry);
    }
    if (registrationExpiry != null) {
      payload['registration_expiry'] = Timestamp.fromDate(registrationExpiry);
    }
    if (lastServiceDate != null) {
      payload['last_service_date'] = Timestamp.fromDate(lastServiceDate);
    }
    if (nextServiceDue != null) {
      payload['next_service_due'] = Timestamp.fromDate(nextServiceDue);
    }

    _log('SAVE → /$databaseId/vehicles id=${docRef.id}\n${_pretty(payload)}');

    // merge = forward compatible: future fields won’t break old clients
    await docRef.set(payload, SetOptions(merge: true));

    _log('SAVE ✓ success id=${docRef.id}');
    return docRef.id;
  }

  /// If you ever need to update an existing vehicle with the same defaults logic.
  Future<void> updateVehicle(String id, Map<String, dynamic> patch) async {
    patch['updated_at'] = Timestamp.fromDate(DateTime.now());
    _log('UPDATE → vehicles/$id\n${_pretty(patch)}');
    await _db.collection('vehicles').doc(id).set(patch, SetOptions(merge: true));
    _log('UPDATE ✓ success id=$id');
  }

  /* ------------------------------ utilities ------------------------------ */

  void _log(String msg, {Object? err, StackTrace? st}) {
    if (kDebugMode) dev.log(msg, name: _tag, error: err, stackTrace: st);
  }

  String _pretty(Map<String, dynamic> m) {
    final b = StringBuffer('{');
    var first = true;
    m.forEach((k, v) {
      if (!first) b.write(',\n');
      first = false;
      final show = v is Timestamp ? v.toDate().toIso8601String() : v;
      b.write('  $k: $show');
    });
    b.write('\n}');
    return b.toString();
  }
}
