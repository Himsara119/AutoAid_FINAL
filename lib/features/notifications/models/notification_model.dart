import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // booking|payment|reminder|system
  final Map<String, dynamic> data;
  final bool isRead;
  final Timestamp? sentAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    this.sentAt,
  });

  /// Create from Firestore document snapshot
  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final x = doc.data() ?? const <String, dynamic>{};
    return AppNotification(
      id: doc.id,
      userId: x['user_id'] ?? '',
      title: x['title'] ?? '',
      body: x['body'] ?? '',
      type: x['type'] ?? 'system',
      data: Map<String, dynamic>.from(x['data'] ?? const {}),
      isRead: x['is_read'] ?? false,
      sentAt: x['sent_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'title': title,
    'body': body,
    'type': type,
    'data': data,
    'is_read': isRead,
    'sent_at': sentAt ?? FieldValue.serverTimestamp(),
  };
}
