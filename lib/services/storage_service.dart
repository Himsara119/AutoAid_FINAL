import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class StorageService {
  static Future<String> uploadDoc(
      String uid, String filename, Uint8List bytes) async {
    final ref = FirebaseStorage.instance.ref('users/$uid/docs/$filename');
    await ref.putData(bytes, SettableMetadata(contentType: 'application/pdf'));
    return await ref.getDownloadURL();
  }
}
