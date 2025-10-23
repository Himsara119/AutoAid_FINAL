import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single notification document in Firestore.
/// Tolerates BOTH schemas:
/// 1) flat: user_id, title, body, type, is_read, sent_at
/// 2) nested: data.user_id, data.title, data.body, data.type, data.is_read, data.sent_at
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // booking | payment | reminder | system
  final Map<String, dynamic> data;
  final bool isRead;
  final Timestamp? sentAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.isRead,
    this.sentAt,
  });

  /// Safely construct from a Firestore document (handles flat or nested).
  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final x = doc.data() ?? const <String, dynamic>{};
    final Map<String, dynamic> d =
    x['data'] is Map ? Map<String, dynamic>.from(x['data'] as Map) : const {};

    String pickStr(String rootKey, String nestedKey, [String fallback = '']) {
      final root = x[rootKey];
      final nest = d[nestedKey];
      if (root is String && root.isNotEmpty) return root;
      if (nest is String && nest.isNotEmpty) return nest;
      return fallback;
    }

    bool pickBool(String rootKey, String nestedKey, [bool fallback = false]) {
      final root = x[rootKey];
      final nest = d[nestedKey];
      if (root is bool) return root;
      if (nest is bool) return nest;
      return fallback;
    }

    Timestamp? pickTs(String rootKey, String nestedKey) {
      final root = x[rootKey];
      final nest = d[nestedKey];
      return (root is Timestamp)
          ? root
          : (nest is Timestamp)
          ? nest
          : null;
    }

    return AppNotification(
      id: doc.id,
      userId: pickStr('user_id', 'user_id'),
      title: pickStr('title', 'title'),
      body: pickStr('body', 'body'),
      type: pickStr('type', 'type', 'system'),
      data: d.isNotEmpty ? d : (x['data'] is Map<String, dynamic> ? Map<String, dynamic>.from(x['data'] as Map) : const {}),
      isRead: pickBool('is_read', 'is_read', false),
      sentAt: pickTs('sent_at', 'sent_at'),
    );
  }

  /// Serialize for upload to Firestore (flat form; still fine if you also keep nested on write).
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'title': title,
    'body': body,
    'type': type,
    'data': data,
    'is_read': isRead,
    'sent_at': sentAt ?? FieldValue.serverTimestamp(),
  };

  bool get isUnread => !isRead;

  String get formattedType =>
      type.isEmpty ? '' : type[0].toUpperCase() + type.substring(1).toLowerCase();

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    Timestamp? sentAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}
