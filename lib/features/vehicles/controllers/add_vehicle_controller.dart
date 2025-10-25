// lib/features/vehicles/controllers/add_vehicle_controller.dart
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddVehicleController {
  AddVehicleController({
    FirebaseFirestore? db,
    this.databaseId = 'autoaid',
    FirebaseStorage? storage,
  })  : _db = db ??
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      ),
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;
  final String databaseId;

  static const _tag = 'AddVehicleController';

  /// Create a new vehicle document, upload optional photos, return its document id.
  Future<String> saveVehicle({
    required String make,
    required String model,
    required String year,
    required String mileage,
    required String vin,
    required String status,

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

    String ownerId = 'users/user_dealer_owner_001',
    String currentOwnerId = 'users/user_dealer_owner_001',
    String dealershipId = 'dealerships/dealer_001',

    // New: photos to upload after document creation
    List<XFile> photos = const [],
  }) async {
    final yr = int.tryParse(year);
    final km = int.tryParse(mileage);
    if (yr == null || yr < 1900) throw ArgumentError('Invalid year: "$year"');
    if (km == null || km < 0) throw ArgumentError('Invalid mileage: "$mileage"');

    final now = DateTime.now();
    final docRef = _db.collection('vehicles').doc();

    final payload = <String, dynamic>{
      'vehicle_id': docRef.id,

      'make': make.trim(),
      'model': model.trim(),
      'trim': (trim ?? '').trim(),
      'year': yr,
      'vin': vin.trim(),
      'mileage': km,
      'status': status.toLowerCase(),

      'owner_id': ownerId,
      'current_owner_id': currentOwnerId,
      'dealership_id': dealershipId,

      'registration_number': (registrationNumber ?? '').trim(),
      'price': price ?? 0,
      'currency': (currency ?? 'LKR').trim(),
      'fuel_type': (fuelType ?? 'petrol').trim(),
      'is_for_sale': isForSale ?? false,
      'reminder_enabled': reminderEnabled ?? true,
      'service_interval_km': serviceIntervalKm ?? 1000,
      'service_interval_months': serviceIntervalMonths ?? 6,

      // Will be updated after uploads; keep for schema consistency
      'photos': <dynamic>[],

      'deleted': false,
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
      'schema_version': 1,
    };

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
    await docRef.set(payload, SetOptions(merge: true));
    _log('SAVE ✓ base document id=${docRef.id}');

    // Photo uploads (optional)
    if (photos.isNotEmpty) {
      final uploaded = await _uploadPhotos(docRef.id, photos);
      if (uploaded.isNotEmpty) {
        await docRef.update({
          'photos': uploaded,
          'primary_photo': uploaded.first,
          'updated_at': FieldValue.serverTimestamp(),
        });
        _log('PHOTOS ✓ uploaded=${uploaded.length} id=${docRef.id}');
      }
    }

    return docRef.id;
  }

  /// Partial update with merge semantics.
  Future<void> updateVehicle(String id, Map<String, dynamic> patch) async {
    patch['updated_at'] = Timestamp.fromDate(DateTime.now());
    _log('UPDATE → vehicles/$id\n${_pretty(patch)}');
    await _db.collection('vehicles').doc(id).set(patch, SetOptions(merge: true));
    _log('UPDATE ✓ success id=$id');
  }

  /// Optional helper for future flows.
  Future<void> deleteVehicle(String id) async {
    _log('DELETE → vehicles/$id (soft delete=false then hard delete)');
    await _db.collection('vehicles').doc(id).delete();
    _log('DELETE ✓ success id=$id');
  }

  Future<List<String>> _uploadPhotos(String vehicleId, List<XFile> photos) async {
    final List<String> urls = [];
    final int ts = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < photos.length; i++) {
      final XFile x = photos[i];
      final Uint8List bytes = await x.readAsBytes();
      final String path = 'vehicles/$vehicleId/photos/$ts-$i.jpg';
      final ref = _storage.ref().child(path);

      final meta = SettableMetadata(contentType: 'image/jpeg');
      await ref.putData(bytes, meta);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

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
