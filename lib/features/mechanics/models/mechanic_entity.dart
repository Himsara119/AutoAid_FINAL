class MechanicPlace {
  final String placeId;
  final String name;
  final String? phone;
  final double? lat;
  final double? lng;

  MechanicPlace({
    required this.placeId,
    required this.name,
    this.phone,
    this.lat,
    this.lng,
  });

  factory MechanicPlace.fromJson(Map<String, dynamic> x) => MechanicPlace(
    placeId: x['place_id'],
    name: x['name'] ?? '',
    phone: x['phone'],
    lat: (x['lat'] as num?)?.toDouble(),
    lng: (x['lng'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() =>
      {'place_id': placeId, 'name': name, 'phone': phone, 'lat': lat, 'lng': lng};
}
