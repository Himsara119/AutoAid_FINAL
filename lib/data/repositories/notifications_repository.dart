import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/notifications/models/notification_model.dart';

class NotificationsRepository {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('notifications');

  Future<List<AppNotification>> listForUser(String userId, {int limit = 50}) async {
    final q = await _col
        .where('user_id', isEqualTo: userId)
        .orderBy('sent_at', descending: true)
        .limit(limit)
        .get();

    // Use a lambda so Dart infers AppNotification correctly
    return q.docs.map((doc) => AppNotification.fromDoc(doc)).toList();
  }

  Future<void> markRead(String id) =>
      _col.doc(id).update({'is_read': true});
}
