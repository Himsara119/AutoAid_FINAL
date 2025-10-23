// lib/features/notifications/controllers/notifications_controller.dart
import 'dart:async';
import 'dart:developer' as dev;
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/notification_model.dart';

class NotificationsController extends GetxController {
  NotificationsController({FirebaseFirestore? db})
      : _db = db ??
      FirebaseFirestore.instanceFor(
        app: Firebase.app(), // Required by latest FlutterFire
        databaseId: 'autoaid',
      );

  final FirebaseFirestore _db;

  // --- Reactive state ---
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  // --- Internals ---
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _listSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _countSub;

  @override
  void onInit() {
    super.onInit();
    _subscribe();
  }

  void _subscribe() {
    loading.value = true;
    error.value = '';

    _listSub?.cancel();
    _countSub?.cancel();

    try {
      _listSub = _db
          .collection('reminders')
          .where('user_id', isEqualTo: _currentUserId())
          .orderBy('sent_at', descending: true)
          .snapshots()
          .listen((snap) {
        final items = snap.docs.map(AppNotification.fromDoc).toList();
        notifications.assignAll(items);
        loading.value = false;
        dev.log('Notifications: ${items.length} item(s)', name: 'Notifications');
      }, onError: (e, st) {
        loading.value = false;
        error.value = e.toString();
        dev.log('Notifications stream error', error: e, stackTrace: st);
      });

      _countSub = _db
          .collection('reminders')
          .where('user_id', isEqualTo: _currentUserId())
          .where('is_read', isEqualTo: false)
          .snapshots()
          .listen((snap) {
        unreadCount.value = snap.size;
        dev.log('Unread count=${snap.size}', name: 'Notifications');
      });
    } catch (e, st) {
      loading.value = false;
      error.value = e.toString();
      dev.log('Notifications subscribe() failed', error: e, stackTrace: st);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _db.collection('reminders').doc(id).update({'is_read': true});
      dev.log('markAsRead $id', name: 'Notifications');
    } catch (e, st) {
      dev.log('markAsRead error', error: e, stackTrace: st);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final snap = await _db
          .collection('reminders')
          .where('user_id', isEqualTo: _currentUserId())
          .where('is_read', isEqualTo: false)
          .get();

      for (final d in snap.docs) {
        await d.reference.update({'is_read': true});
      }

      dev.log('markAllAsRead', name: 'Notifications');
    } catch (e, st) {
      dev.log('markAllAsRead error', error: e, stackTrace: st);
    }
  }

  List<AppNotification> get unread => notifications.where((n) => !n.isRead).toList();
  List<AppNotification> get read => notifications.where((n) => n.isRead).toList();

  @override
  void onClose() {
    _listSub?.cancel();
    _countSub?.cancel();
    super.onClose();
  }

  String _currentUserId() => 'demo_user_id'; // Replace with logged-in user ID
}
