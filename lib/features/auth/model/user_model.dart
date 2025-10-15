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
    required this.role,
    this.dealershipId,
    required this.deleted,
    required this.settings,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final x = d.data()!;
    return UserModel(
      id: d.id,
      displayName: x['display_name'] ?? '',
      email: x['email'] ?? '',
      phone: x['phone'],
      photoUrl: x['photo_url'],
      role: x['role'] ?? 'user',
      dealershipId: x['dealership_id'],
      deleted: x['deleted'] ?? false,
      settings: Map<String, dynamic>.from(x['settings'] ?? {}),
      createdAt: x['created_at'],
      updatedAt: x['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Display_Name': displayName,
    'Email': email,
    'Phone': phone,
    'Photo_Url': photoUrl,
    'Role': role,
    'Dealership_Id': dealershipId,
    'Deleted': deleted,
    'Settings': settings,
    'Created_At': createdAt ?? FieldValue.serverTimestamp(),
    'Updated_At': FieldValue.serverTimestamp(),
  };
}
