// lib/data/repositories/notifications_repository.dart
import 'dart:async';
import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../features/notifications/models/notification_model.dart';


class NotificationsRepository {
  NotificationsRepository({
    this.databaseId = 'autoaid',
    FirebaseApp? app,
    FirebaseAuth? auth,
    this.collection = 'reminders', // ← we read reminders, not notifications
  })  : _app = app ?? Firebase.app(),
        _auth = auth ?? FirebaseAuth.instance,
        _db = FirebaseFirestore.instanceFor(
          app: app ?? Firebase.app(),
          databaseId: databaseId,
        );

  final String databaseId;
  final FirebaseApp _app;
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  /// Firestore collection name (defaults to 'reminders')
  final String collection;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection(collection);

  /// Live list for the current user, soonest due first.
  /// Reminders look like:
  /// { owner_id:"users/<uid>", title, description, status, notified, due_at:Timestamp }
  Stream<List<AppNotification>> watchUserNotifications({int limit = 50}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      dev.log('watchUserNotifications: no user', name: 'NotificationsRepo');
      return const Stream<List<AppNotification>>.empty();
    }

    dev.log('watchUserNotifications: users/$uid from [$collection]', name: 'NotificationsRepo');

    final q = _col
        .where('owner_id', isEqualTo: 'users/$uid')
        .orderBy('due_at', descending: false)
        .limit(limit);

    return q.snapshots().map((snap) {
      dev.log('watchUserNotifications: ${snap.docs.length} docs', name: 'NotificationsRepo');
      for (final d in snap.docs) {
        dev.log('  • ${d.id} -> ${d.data()}', name: 'NotificationsRepo');
      }
      return snap.docs.map((d) => AppNotification.fromDoc(d)).toList();
    }).handleError((e, st) {
      dev.log('watchUserNotifications error: $e', name: 'NotificationsRepo', error: e, stackTrace: st);
    });
  }

  /// Live unread count (for badge): status==active and notified==false
  Stream<int> watchUnreadCount() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream<int>.empty();

    final q = _col
        .where('owner_id', isEqualTo: 'users/$uid')
        .where('status', isEqualTo: 'active')
        .where('notified', isEqualTo: false);

    return q.snapshots().map((s) {
      final n = s.size;
      dev.log('watchUnreadCount: $n', name: 'NotificationsRepo');
      return n;
    });
  }

  /// Mark one reminder as read (notified = true)
  Future<void> markAsRead(String id) async {
    try {
      await _col.doc(id).update({
        'notified': true,
        'read_at': FieldValue.serverTimestamp(),
      });
      dev.log('markAsRead: $id', name: 'NotificationsRepo');
    } catch (e, st) {
      dev.log('markAsRead error: $e', name: 'NotificationsRepo', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Mark all unread reminders as read (batch)
  Future<void> markAllAsRead({int batchLimit = 450}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final unread = await _col
          .where('owner_id', isEqualTo: 'users/$uid')
          .where('status', isEqualTo: 'active')
          .where('notified', isEqualTo: false)
          .orderBy('due_at', descending: false)
          .limit(batchLimit)
          .get();

      if (unread.docs.isEmpty) {
        dev.log('markAllAsRead: nothing to do', name: 'NotificationsRepo');
        return;
      }

      final wb = _db.batch();
      for (final d in unread.docs) {
        wb.update(d.reference, {
          'notified': true,
          'read_at': FieldValue.serverTimestamp(),
        });
      }
      await wb.commit();
      dev.log('markAllAsRead: updated ${unread.docs.length} docs', name: 'NotificationsRepo');
    } catch (e, st) {
      dev.log('markAllAsRead error: $e', name: 'NotificationsRepo', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Helper for seeding test data quickly
  Future<String> create(AppNotification n) async {
    final ref = await _col.add(n.toJson());
    dev.log('create: ${ref.id}', name: 'NotificationsRepo');
    return ref.id;
  }
}
