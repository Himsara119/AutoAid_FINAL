import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileRepository {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = _storage.ref('users/$uid/profile_photo/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    await _db.collection('users').doc(uid).update({
      'photo_url': url, 'updated_at': FieldValue.serverTimestamp(),
    });
    return url;
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> patch) =>
      _db.collection('users').doc(uid)
          .update({...patch, 'updated_at': FieldValue.serverTimestamp()});
}
