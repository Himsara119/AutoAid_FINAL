import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/model/user_model.dart';

class UserRepository {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('users');

  Future<UserModel?> getById(String uid) async {
    final d = await _col.doc(uid).get();
    return d.exists ? UserModel.fromDoc(d) : null;
  }

  Future<void> update(String uid, Map<String, dynamic> patch) =>
      _col.doc(uid).update({...patch, 'updated_at': FieldValue.serverTimestamp()});

  Future<void> addDeviceToken(String uid, String token, {required String platform}) =>
      _col.doc(uid).collection('device_tokens').doc(token).set({
        'platform': platform, 'last_seen_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
}
