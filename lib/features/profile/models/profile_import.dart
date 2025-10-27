// lib/features/profile/models/profile_import.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_entity.dart';

/// Split "First Last" into a simple map. No fancy records, no drama.
Map<String, String?> splitDisplayName(String? displayName) {
  final dn = (displayName ?? '').trim();
  if (dn.isEmpty) return {'first': null, 'last': null};

  final parts = dn.split(RegExp(r'\s+'));
  final first = parts.first;
  final last = parts.length > 1 ? parts.sublist(1).join(' ') : null;
  return {'first': first, 'last': last};
}

/// Local copy of role parsing because `_roleFrom` is private in another file.
UserRole parseUserRole(String? v) {
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

/// Convert a raw row (like your JSON) → Firestore-ready map for ProfileEntity.
Future<Map<String, dynamic>> profileMapFromRow(
    Map<String, dynamic> row,
    ) async {
  final name = splitDisplayName(row['display_name'] as String?);
  final String? f = name['first'];
  final String? l = name['last'];

  // Turn "dealerships/dealer_001" into a proper DocumentReference if present.
  DocumentReference? dealershipRef;
  final path = row['dealership_id'] as String?;
  if (path != null && path.trim().isNotEmpty) {
    dealershipRef = FirebaseFirestore.instance.doc(path);
  }

  return ProfileEntity(
    uid: row['user_id'] as String,
    email: (row['email'] ?? '') as String,
    firstName: f,
    lastName: l,
    phone: row['phone'] as String?,
    photoURL: row['photo_url'] as String?,
    role: parseUserRole(row['role'] as String?),
    dealershipRef: dealershipRef,
    settings: (row['settings'] as Map?)?.cast<String, dynamic>() ?? const {},
    deleted: (row['deleted'] as bool?) ?? false,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  ).toMap(forCreate: true);
}
