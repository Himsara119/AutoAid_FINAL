import 'package:cloud_firestore/cloud_firestore.dart';

enum DistanceUnits { km, mi }
enum CurrencyCode { lkr, usd, eur, gbp, jpy }

// New: user roles you actually use
enum UserRole { admin, dealerOwner, staff, customer, unknown }

UserRole _roleFrom(String? v) {
  switch ((v ?? '').toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'dealer_owner':
    case 'dealerowner':
      return UserRole.dealerOwner;
    case 'staff':
      return UserRole.staff;
    case 'customer':
      return UserRole.customer;
    default:
      return UserRole.unknown;
  }
}

String _roleTo(UserRole r) {
  switch (r) {
    case UserRole.admin:
      return 'admin';
    case UserRole.dealerOwner:
      return 'dealer_owner';
    case UserRole.staff:
      return 'staff';
    case UserRole.customer:
      return 'customer';
    case UserRole.unknown:
    default:
      return 'unknown';
  }
}

String _unitsToString(DistanceUnits u) => u == DistanceUnits.mi ? 'MI' : 'KM';
DistanceUnits _unitsFromString(String? v) =>
    (v ?? '').toUpperCase() == 'MI' ? DistanceUnits.mi : DistanceUnits.km;

String _currencyToString(CurrencyCode c) {
  switch (c) {
    case CurrencyCode.usd:
      return 'USD';
    case CurrencyCode.eur:
      return 'EUR';
    case CurrencyCode.gbp:
      return 'GBP';
    case CurrencyCode.jpy:
      return 'JPY';
    case CurrencyCode.lkr:
    default:
      return 'LKR';
  }
}
CurrencyCode _currencyFromString(String? v) {
  switch ((v ?? '').toUpperCase()) {
    case 'USD':
      return CurrencyCode.usd;
    case 'EUR':
      return CurrencyCode.eur;
    case 'GBP':
      return CurrencyCode.gbp;
    case 'JPY':
      return CurrencyCode.jpy;
    case 'LKR':
    default:
      return CurrencyCode.lkr;
  }
}

Timestamp? _ts(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v;
  if (v is DateTime) return Timestamp.fromDate(v);
  return null;
}

class ProfileEntity {
  final String uid;

  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? company;
  final String? address;
  final String? photoURL;

  final DistanceUnits units;   // default KM
  final CurrencyCode currency; // default LKR

  // New fields to mirror your table
  final UserRole role;
  final DocumentReference? dealershipRef; // prefer real reference, not string
  final Map<String, dynamic> settings;    // push_enabled, locale, theme
  final bool deleted;

  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const ProfileEntity({
    required this.uid,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.company,
    this.address,
    this.photoURL,
    this.units = DistanceUnits.km,
    this.currency = CurrencyCode.lkr,
    this.role = UserRole.unknown,
    this.dealershipRef,
    this.settings = const {},
    this.deleted = false,
    this.createdAt,
    this.updatedAt,
  });

  String get displayName {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (f.isEmpty && l.isEmpty) return email;
    if (l.isEmpty) return f;
    return '$f $l';
  }

  String get initials {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    final a = f.isNotEmpty ? f[0] : '';
    final b = l.isNotEmpty ? l[0] : '';
    final s = '$a$b'.toUpperCase();
    return s.isEmpty ? (email.isNotEmpty ? email[0].toUpperCase() : '?') : s;
  }

  factory ProfileEntity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return ProfileEntity(
      uid: doc.id,
      email: (data['email'] ?? '') as String,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      phone: data['phone'] as String?,
      company: data['company'] as String?,
      address: data['address'] as String?,
      photoURL: data['photoURL'] as String?,
      units: _unitsFromString(data['units'] as String?),
      currency: _currencyFromString(data['currency'] as String?),
      role: _roleFrom(data['role'] as String?),
      dealershipRef: data['dealershipRef'] is DocumentReference
          ? data['dealershipRef'] as DocumentReference
          : null,
      settings: (data['settings'] as Map?)?.cast<String, dynamic>() ?? const {},
      deleted: (data['deleted'] as bool?) ?? false,
      createdAt: _ts(data['createdAt']),
      updatedAt: _ts(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap({bool forCreate = false}) => {
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'company': company,
    'address': address,
    'photoURL': photoURL,
    'units': _unitsToString(units),
    'currency': _currencyToString(currency),
    'role': _roleTo(role),
    'dealershipRef': dealershipRef,
    'settings': settings,
    'deleted': deleted,
    'createdAt':
    forCreate ? (createdAt ?? FieldValue.serverTimestamp()) : createdAt,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  ProfileEntity copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? company,
    String? address,
    String? photoURL,
    DistanceUnits? units,
    CurrencyCode? currency,
    UserRole? role,
    DocumentReference? dealershipRef,
    Map<String, dynamic>? settings,
    bool? deleted,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ProfileEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      address: address ?? this.address,
      photoURL: photoURL ?? this.photoURL,
      units: units ?? this.units,
      currency: currency ?? this.currency,
      role: role ?? this.role,
      dealershipRef: dealershipRef ?? this.dealershipRef,
      settings: settings ?? this.settings,
      deleted: deleted ?? this.deleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DocumentReference<ProfileEntity> docRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .withConverter<ProfileEntity>(
      fromFirestore: (snap, _) => ProfileEntity.fromDoc(snap),
      toFirestore: (p, _) => p.toMap(forCreate: false),
    );
  }
}
