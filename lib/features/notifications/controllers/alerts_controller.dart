// lib/features/notifications/controllers/alerts_controller.dart
import 'dart:async';
import 'dart:developer' as dev;

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../data/repositories/alerts_repository.dart';
import '../models/alert_model.dart';

class AlertsController extends GetxController {
  AlertsController({FirebaseFirestore? db, String? userId})
      : _db = db ??
      FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'autoaid',
      ),
        _userId = userId ?? 'demo_user_id';

  final FirebaseFirestore _db;
  final String _userId;
  late final AlertsRepository _repo = AlertsRepository(db: _db);

  // Reactive state
  final RxList<AlertEntity> alerts = <AlertEntity>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;
  // 0 = All, 1 = Urgent, 2 = Upcoming
  final RxInt currentTab = 0.obs;

  // Internals
  StreamSubscription<List<AlertEntity>>? _listSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _countSub;

  @override
  void onInit() {
    super.onInit();
    dev.log('AlertsController.onInit userId=$_userId', name: 'AlertsController');
    // Log tab switches
    ever<int>(currentTab, (v) {
      dev.log('Tab changed -> $v', name: 'AlertsController');
    });
    _subscribe();
  }

  /// Subscribe to notifications list + unread count (collectionGroup)
  void _subscribe() {
    loading.value = true;
    error.value = '';
    dev.log('Subscribing to alerts + unread streams…', name: 'AlertsController');

    _listSub?.cancel();
    _countSub?.cancel();

    try {
      // Main list stream
      _listSub = _repo.streamAllForUser(userId: _userId).listen(
            (items) {
          alerts.assignAll(items);
          loading.value = false;
          dev.log(
            'List stream tick: items=${items.length}'
                ' (unread=${items.where((e) => !e.read).length})',
            name: 'AlertsController',
          );
        },
        onError: (e, st) {
          error.value = e.toString();
          loading.value = false;
          dev.log('List stream error: $e', name: 'AlertsController', stackTrace: st, error: e);
        },
        onDone: () {
          dev.log('List stream done', name: 'AlertsController');
        },
        cancelOnError: false,
      );

      // Unread count stream
      _countSub = _db
          .collectionGroup('notifications')
          .where('user_id', isEqualTo: _userId)
          .where('read', isEqualTo: false)
          .snapshots()
          .listen(
            (snap) {
          unreadCount.value = snap.size;
          dev.log(
            'Count stream tick: unread=${snap.size} (from ${snap.docs.length} docs, hasPendingWrites=${snap.metadata.hasPendingWrites})',
            name: 'AlertsController',
          );
        },
        onError: (e, st) {
          dev.log('Count stream error: $e', name: 'AlertsController', stackTrace: st, error: e);
        },
        onDone: () {
          dev.log('Count stream done', name: 'AlertsController');
        },
        cancelOnError: false,
      );
    } catch (e, st) {
      loading.value = false;
      error.value = e.toString();
      dev.log('subscribe() failed: $e', name: 'AlertsController', stackTrace: st, error: e);
    }
  }

  /// Convenience: filtered list based on currentTab
  List<AlertEntity> get filtered {
    switch (currentTab.value) {
      case 1:
        return alerts.where((a) => a.severity == 'urgent').toList();
      case 2:
        return alerts.where((a) => a.severity == 'upcoming').toList();
      default:
        return alerts;
    }
  }

  /// Mark one alert as read (subcollection path requires vehicleId)
  Future<void> markAsRead({
    required String vehicleId,
    required String id,
  }) async {
    dev.log('markAsRead requested for $vehicleId/$id', name: 'AlertsController');
    try {
      await _repo.markAsRead(vehicleId: vehicleId, id: id, read: true);
      final i = alerts.indexWhere((a) => a.id == id && a.vehicleId == vehicleId);
      if (i != -1) {
        alerts[i] = alerts[i].copyWith(read: true);
        dev.log('Local state updated for $vehicleId/$id', name: 'AlertsController');
      } else {
        dev.log('Local list did not contain $vehicleId/$id', name: 'AlertsController');
      }
    } catch (e, st) {
      dev.log('markAsRead error: $e', name: 'AlertsController', stackTrace: st, error: e);
    }
  }

  /// Mark all unread alerts for this user as read (across vehicles)
  Future<void> markAllAsRead() async {
    dev.log('markAllAsRead requested for user=$_userId', name: 'AlertsController');
    try {
      await _repo.markAllAsReadForUser(_userId);
      int changed = 0;
      for (var i = 0; i < alerts.length; i++) {
        if (!alerts[i].read) {
          alerts[i] = alerts[i].copyWith(read: true);
          changed++;
        }
      }
      unreadCount.value = 0;
      dev.log('markAllAsRead complete; locally flipped $changed item(s)', name: 'AlertsController');
    } catch (e, st) {
      dev.log('markAllAsRead error: $e', name: 'AlertsController', stackTrace: st, error: e);
    }
  }

  List<AlertEntity> get unread => alerts.where((a) => !a.read).toList();
  List<AlertEntity> get read => alerts.where((a) => a.read).toList();

  @override
  void onClose() {
    dev.log('onClose: cancelling streams…', name: 'AlertsController');
    _listSub?.cancel();
    _countSub?.cancel();
    super.onClose();
  }
}
