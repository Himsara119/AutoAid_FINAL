// lib/features/notifications/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// A tolerant view-model that can read either a classic notification doc
/// OR a reminder doc. We normalize fields so the UI doesn't care.
///
/// Notifications (flat):
///   user_id, title, body, type, is_read, sent_at
///
/// Reminders (flat):
///   owner_id, title, description, status, notified, due_at, type?
class AppNotification {
  final String id;
  final String userId;     // notifications.user_id | reminders.owner_id
  final String title;      // notifications.title   | reminders.title
  final String body;       // notifications.body    | reminders.description
  final String type;       // booking|payment|reminder|system (fallback: reminder for reminders)
  final Map<String, dynamic> data;  // passthrough if present; optional
  final bool isRead;       // notifications.is_read | reminders.notified
  final Timestamp? sentAt; // notifications.sent_at | reminders.due_at

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

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final x = doc.data() ?? const <String, dynamic>{};

    // Detect if this doc looks like a reminder
    final bool isReminderDoc =
        x.containsKey('owner_id') || x.containsKey('due_at') || x.containsKey('notified');

    // Normalize fields
    final String userId = (x['user_id'] as String?) ??
        (x['owner_id'] as String?) ??
        '';

    final String title = (x['title'] as String?) ?? '';

    // Prefer body; fall back to description for reminders
    final String body = (x['body'] as String?) ??
        (x['description'] as String?) ??
        '';

    // If it's clearly a reminder doc, default type to 'reminder'
    final String type = ((x['type'] as String?) ?? (isReminderDoc ? 'reminder' : 'system')).toLowerCase();

    // Pass through any nested data map if present
    final Map<String, dynamic> data =
    x['data'] is Map ? Map<String, dynamic>.from(x['data'] as Map) : const {};

    // For reminders, `notified: true` means "read"
    final bool isRead = (x['is_read'] as bool?) ??
        (x['notified'] as bool?) ??
        false;

    // Use sent_at for notifications, due_at for reminders
    final Timestamp? sentAt = (x['sent_at'] is Timestamp)
        ? x['sent_at'] as Timestamp
        : (x['due_at'] is Timestamp)
        ? x['due_at'] as Timestamp
        : null;

    return AppNotification(
      id: doc.id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      data: data,
      isRead: isRead,
      sentAt: sentAt,
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
