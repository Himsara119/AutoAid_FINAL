// user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String role;
  final String? dealershipId;
  final bool deleted;
  final Map<String, dynamic> settings;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.phone,
    this.photoUrl,
    this.role = 'user',
    this.dealershipId,
    this.deleted = false,
    Map<String, dynamic>? settings,
    this.createdAt,
    this.updatedAt,
  }) : settings = settings ?? {};

  Map<String, dynamic> toJson() => {
    // CHANGED: keys in snake_case to be consistent
    'display_name': displayName,
    'email': email,
    'phone': phone,
    'photo_url': photoUrl,
    'role': role,
    'dealership_id': dealershipId,
    'deleted': deleted,
    'settings': settings,
    'created_at': createdAt ?? FieldValue.serverTimestamp(),
    'updated_at': FieldValue.serverTimestamp(),
  };
}
