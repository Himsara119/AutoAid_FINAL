import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalapp/app.dart';

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
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
}
