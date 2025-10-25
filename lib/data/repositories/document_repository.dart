import 'dart:io' show File;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;

class DocumentRepository {
  DocumentRepository({
    this.databaseId = 'autoaid',
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _db = firestore ??
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      ),
        _storage = storage ??
            FirebaseStorage.instanceFor(
              app: Firebase.app(),
              bucket: Firebase.app().options.storageBucket,
            );

  final String databaseId;
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  /* ============================== Paths ============================== */

  CollectionReference<Map<String, dynamic>> _col(String vehicleId) =>
      _db.collection('vehicles').doc(vehicleId).collection('documents');

  DocumentReference<Map<String, dynamic>> _doc(String vehicleId, String documentId) =>
      _col(vehicleId).doc(documentId);

  Reference _fileRef(String vehicleId, String documentId, String fileName) =>
      _storage.ref('documents/$vehicleId/$documentId/$fileName');

  /* ============================== Reads ============================== */

  Stream<List<Map<String, dynamic>>> streamForVehicle(String vehicleId) {
    return _col(vehicleId)
        .orderBy('expiry_date', descending: false)
        .snapshots()
        .map((q) => q.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<Map<String, dynamic>?> getById(String vehicleId, String documentId) async {
    final snap = await _doc(vehicleId, documentId).get();
    if (!snap.exists) return null;
    return {'id': snap.id, ...snap.data()!};
  }

  /* ============================== Writes ============================== */

  /// Creates a new document record. If [fileBytes] or [file] is provided, uploads it first.
  /// Returns the created documentId.
  Future<String> create({
    required String vehicleId,
    required Map<String, dynamic> data,
    String? fileName,
    String? contentType,
    int? fileSize,
    Uint8List? fileBytes,
    File? file,
  }) async {
    final now = Timestamp.now();
    final docRef = _col(vehicleId).doc(); // server ID

    String? url;
    int? size = fileSize;

    if ((fileBytes != null || file != null) && fileName != null && fileName.isNotEmpty) {
      final ref = _fileRef(vehicleId, docRef.id, fileName);
      final meta = SettableMetadata(contentType: contentType ?? 'application/octet-stream');
      final task = kIsWeb || file == null ? ref.putData(fileBytes!, meta) : ref.putFile(file, meta);
      final snap = await task.whenComplete(() {});
      url = await ref.getDownloadURL();
      size = size ?? snap.totalBytes;
    }

    // compute status
    final bool noExpiry = (data['no_expiry'] ?? false) == true;
    final Timestamp? expiry = data['expiry_date'] as Timestamp?;
    final expired = !noExpiry && expiry != null && expiry.toDate().isBefore(DateTime.now());

    final payload = <String, dynamic>{
      ...data,
      if (fileName != null) 'file_name': fileName,
      if (url != null) 'file_url': url,
      if (size != null) 'file_size': size,
      'content_type': contentType,
      'status': expired ? 'expired' : 'active',
      'created_at': now,
      'updated_at': now,
      'vehicle_id': vehicleId,
    };

    await docRef.set(payload, SetOptions(merge: true));
    return docRef.id;
  }

  /// Updates fields on an existing document.
  /// If a new file is supplied, it uploads and replaces the old one (best-effort delete).
  Future<void> update({
    required String vehicleId,
    required String documentId,
    required Map<String, dynamic> data,
    // existing file fields (optional, for cleanup)
    String? existingFileUrl,
    // new file to replace
    String? newFileName,
    String? newContentType,
    int? newFileSize,
    Uint8List? newFileBytes,
    File? newFile,
  }) async {
    final now = Timestamp.now();

    String? fileUrl = data['file_url'] as String?;
    String? fileName = data['file_name'] as String?;
    int? fileSize = data['file_size'] as int?;
    String? contentType = data['content_type'] as String?;

    final hasNew =
        newFileName != null && newFileName.isNotEmpty && (newFileBytes != null || newFile != null);

    if (hasNew) {
      final ref = _fileRef(vehicleId, documentId, newFileName!);
      final meta = SettableMetadata(contentType: newContentType ?? 'application/octet-stream');
      final task = kIsWeb || newFile == null ? ref.putData(newFileBytes!, meta) : ref.putFile(newFile, meta);
      final snap = await task.whenComplete(() {});
      final url = await ref.getDownloadURL();

      // best-effort delete of the previous file
      final toDelete = existingFileUrl ?? fileUrl;
      if (toDelete != null && toDelete.isNotEmpty) {
        try {
          await _storage.refFromURL(toDelete).delete();
        } catch (_) {
          // swallow; we don't block the update if delete fails
        }
      }

      fileUrl = url;
      fileName = newFileName;
      fileSize = newFileSize ?? snap.totalBytes;
      contentType = newContentType;
    }

    // recompute status
    final bool noExpiry = (data['no_expiry'] ?? false) == true;
    final Timestamp? expiry = data['expiry_date'] as Timestamp?;
    final expired = !noExpiry && expiry != null && expiry.toDate().isBefore(DateTime.now());

    final payload = <String, dynamic>{
      ...data,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'content_type': contentType,
      'status': expired ? 'expired' : 'active',
      'updated_at': now,
      'vehicle_id': vehicleId,
    };

    await _doc(vehicleId, documentId).set(payload, SetOptions(merge: true));
  }

  /// Deletes the Firestore record and best-effort deletes the stored file if present.
  Future<void> delete({
    required String vehicleId,
    required String documentId,
    String? fileUrl,
  }) async {
    // try storage delete first so we keep the record if it fails
    if (fileUrl != null && fileUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(fileUrl).delete();
      } catch (_) {
        // ignore; still delete Firestore
      }
    }
    await _doc(vehicleId, documentId).delete();
  }
}
