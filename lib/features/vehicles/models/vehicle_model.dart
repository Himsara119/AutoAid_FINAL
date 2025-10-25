import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String dealershipId;
  final String? currentOwnerId;
  final String make;
  final String model;
  final String trim;
  final int year;
  final String? vin;
  final String? registrationNumber;
  final String fuelType;
  final int mileage;
  final bool isForSale;
  final bool deleted;
  final String status;
  final double? price;
  final String? currency;
  final List<String> photos;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  VehicleModel({
    required this.id,
    required this.dealershipId,
    this.currentOwnerId,
    required this.make,
    required this.model,
    this.trim = '',
    required this.year,
    this.vin,
    this.registrationNumber,
    this.fuelType = 'petrol',
    this.mileage = 0,
    this.isForSale = false,
    this.deleted = false,
    this.status = 'active',
    this.price,
    this.currency,
    this.photos = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Defensive parse helpers
  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static double? _asDoubleNullable(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static List<String> _asStringList(dynamic v) {
    if (v == null) return <String>[];
    if (v is List) {
      return v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    return <String>[];
  }

  factory VehicleModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final x = doc.data() ?? const <String, dynamic>{};

    // Prefer explicit vehicle_id if your writer sets it, otherwise doc.id
    final id = (x['vehicle_id']?.toString().isNotEmpty ?? false)
        ? x['vehicle_id'].toString()
        : doc.id;

    return VehicleModel(
      id: id,
      // READ snake_case because that's what you write in toJson()
      dealershipId: (x['dealership_id'] ?? '').toString(),
      currentOwnerId: (x['current_owner_id']?.toString()),
      make: (x['make'] ?? '').toString(),
      model: (x['model'] ?? '').toString(),
      trim: (x['trim'] ?? '').toString(),
      year: _asInt(x['year']),
      vin: (x['vin']?.toString()),
      registrationNumber: (x['registration_number']?.toString()),
      fuelType: (x['fuel_type'] ?? 'petrol').toString().toLowerCase(),
      mileage: _asInt(x['mileage']),
      isForSale: (x['is_for_sale'] as bool?) ?? false,
      deleted: (x['deleted'] as bool?) ?? false,
      status: (x['status'] ?? 'active').toString().toLowerCase(),
      price: _asDoubleNullable(x['price']),
      currency: x['currency']?.toString(),
      photos: _asStringList(x['photos']),
      createdAt: x['created_at'] is Timestamp ? x['created_at'] as Timestamp : null,
      updatedAt: x['updated_at'] is Timestamp ? x['updated_at'] as Timestamp : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'dealership_id': dealershipId,
    'current_owner_id': currentOwnerId,
    'make': make,
    'model': model,
    'trim': trim,
    'year': year,
    'vin': vin,
    'registration_number': registrationNumber,
    'fuel_type': fuelType,
    'mileage': mileage,
    'is_for_sale': isForSale,
    'deleted': deleted,
    'status': status,
    'price': price,
    'currency': currency,
    'photos': photos,
    'created_at': createdAt ?? FieldValue.serverTimestamp(),
    'updated_at': FieldValue.serverTimestamp(),
  };

  VehicleModel copyWith({
    String? id,
    String? dealershipId,
    String? currentOwnerId,
    String? make,
    String? model,
    String? trim,
    int? year,
    String? vin,
    String? registrationNumber,
    String? fuelType,
    int? mileage,
    bool? isForSale,
    bool? deleted,
    String? status,
    double? price,
    String? currency,
    List<String>? photos,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      dealershipId: dealershipId ?? this.dealershipId,
      currentOwnerId: currentOwnerId ?? this.currentOwnerId,
      make: make ?? this.make,
      model: model ?? this.model,
      trim: trim ?? this.trim,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      fuelType: fuelType ?? this.fuelType,
      mileage: mileage ?? this.mileage,
      isForSale: isForSale ?? this.isForSale,
      deleted: deleted ?? this.deleted,
      status: status ?? this.status,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
