import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String dealershipId;
  final String? currentOwnerId;
  final String make, model, trim;
  final int year;
  final String? vin, registrationNumber;
  final String fuelType;
  final int mileage;
  final bool isForSale, deleted;
  final String status;
  final double? price;
  final String? currency;
  final List<String> photos;
  final Timestamp? createdAt, updatedAt;

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

  factory VehicleModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final x = d.data()!;
    return VehicleModel(
      id: d.id,
      dealershipId: x['dealershipId'],
      currentOwnerId: x['current_owner_id'],
      make:x['make'] ?? '',
      model: x['model'] ?? '',
      trim: x['trim'] ?? '',
      year: (x['year'] ?? 0),
      vin: x['vin'],
      registrationNumber: x['registration_number'],
      fuelType: x['fuel_type'] ?? 'petrol',
      mileage: (x['mileage'] ?? 0) as int,
      isForSale: x['is_for_sale'] ?? false,
      deleted: x['deleted'] ?? false,
      status: x['status'] ?? 'active',
      price: (x['price'] as num?)?.toDouble(),
      currency: x['currency'],
      photos: List<String>.from(x['photos'] ?? []),
      createdAt: x['created_at'],
      updatedAt: x['updated_at'],
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
}
