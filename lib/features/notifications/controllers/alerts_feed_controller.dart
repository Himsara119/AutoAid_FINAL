// lib/features/notifications/controllers/alerts_feed_controller.dart
import 'dart:async';
import 'dart:developer' as dev;

import 'package:get/get.dart';

import '../../../data/repositories/alerts_repository.dart';
import '../models/alert_model.dart';

class AlertsFeedController extends GetxController {
  AlertsFeedController({
    this.vehicleId,
    this.userId,
    this.serviceDetailRoute = '/serviceDetail',
    this.documentDetailRoute = '/documentdetail',
  }) : _repo = AlertsRepository();

  final String? vehicleId;
  final String? userId;
  final AlertsRepository _repo;

  /// Route names can be overridden from the caller if your app uses different names.
  final String serviceDetailRoute;
  final String documentDetailRoute;

  // UI state
  final alerts = <AlertEntity>[].obs;
  final loading = true.obs;
  final error = RxnString();

  // 0 = All, 1 = Urgent, 2 = Upcoming
  final currentTab = 0.obs;

  StreamSubscription<List<AlertEntity>>? _sub;

  @override
  void onInit() {
    super.onInit();
    // Rebind whenever the tab changes (so we can query by severity).
    ever<int>(currentTab, (_) {
      // Show spinner when switching tabs to avoid stale ghost rows
      loading.value = true;
      _bind();
    });
    _bind();
  }

  @override
  void onClose() {
    _sub?.cancel();
    _sub = null;
    super.onClose();
  }

  /// Pull-to-refresh hook. Keeps the contract simple for the UI.
  /// We cancel and resubscribe; Firestore streams will fetch the latest snapshot.
  Future<void> refresh() async {
    try {
      loading.value = true;
      error.value = null;
      _bind();
      // Give the stream a moment to tick; avoids "instant complete" on UI spinners.
      await Future<void>.delayed(const Duration(milliseconds: 50));
    } catch (e, st) {
      _onError(e, st);
    }
  }

  /// Legacy alias if you wired it already.
  void refreshFeed() {
    // Don't change existing calls; keep it working.
    // Prefer the Future version for RefreshIndicator.
    unawaited(refresh());
  }

  /// Programmatic tab switch with proper state handling.
  void setTab(int index) {
    if (index == currentTab.value) return;
    currentTab.value = index;
  }

  void _bind() {
    _sub?.cancel();
    error.value = null;

    // Severity filter derived from tab
    String? severityFilter;
    if (currentTab.value == 1) severityFilter = AlertSeverity.urgent;
    if (currentTab.value == 2) severityFilter = AlertSeverity.upcoming;

    if (vehicleId != null && vehicleId!.isNotEmpty) {
      dev.log('Binding vehicle feed for vehicleId=$vehicleId',
          name: 'AlertsFeedController');
      _sub = _repo
          .streamForVehicle(
        vehicleId: vehicleId!,
        severity: severityFilter,
      )
          .listen(_onData, onError: _onError);
      return;
    }

    if (userId != null && userId!.isNotEmpty) {
      dev.log('Binding global feed for userId=$userId',
          name: 'AlertsFeedController');
      _sub = _repo
          .streamAllForUser(
        userId: userId!,
        severity: severityFilter,
      )
          .listen(_onData, onError: _onError);
    } else {
      loading.value = false;
      error.value = 'No vehicleId or userId provided to AlertsFeedController.';
      dev.log('Bind aborted: neither vehicleId nor userId provided',
          name: 'AlertsFeedController');
    }
  }

  void _onData(List<AlertEntity> items) {
    // Defensive cleanup: drop null/empty ids and optionally soft-deleted rows if model supports it.
    items = items
        .where((a) => a.id.isNotEmpty)
        .toList(growable: false);

    // De-dup by id to avoid flicker when metadata changes arrive
    final seen = <String>{};
    items = items.where((a) => seen.add(a.id)).toList(growable: false);

    // For Urgent/Upcoming tabs, hide completed (read == true)
    if (currentTab.value != 0) {
      items = items.where((a) => !(a.read ?? false)).toList(growable: false);
    }

    // Sort by severity rank then due date (AlertEntity.compareTo)
    items.sort((a, b) => a.compareTo(b));

    alerts.assignAll(items);
    loading.value = false;
    error.value = null;

    dev.log(
      'Feed tick → ${items.length} alerts '
          '(vehicleId=${vehicleId ?? "-"}, userId=${userId ?? "-"})',
      name: 'AlertsFeedController',
    );
  }

  void _onError(Object e, [StackTrace? st]) {
    loading.value = false;
    error.value = e.toString();
    dev.log('Feed error', name: 'AlertsFeedController', error: e, stackTrace: st);
  }

  // ---------------- Actions: "completed" uses the existing `read` flag ----------------

  Future<void> markDone(AlertEntity a) async {
    await _repo.markAsRead(vehicleId: a.vehicleId, id: a.id, read: true);
    // Optional: await refresh();  // usually not needed; stream updates
  }

  Future<void> toggleDone(AlertEntity a) async {
    await _repo.markAsRead(
      vehicleId: a.vehicleId,
      id: a.id,
      read: !(a.read ?? false),
    );
    // Optional: await refresh();
  }

  Future<void> markAllDoneForVehicle(String vehicleId) async {
    await _repo.markAllAsReadForVehicle(vehicleId);
    // Optional: await refresh();
  }

  Future<void> markAllDoneForUser(String userId) async {
    await _repo.markAllAsReadForUser(userId);
    // Optional: await refresh();
  }

  // ---------------- Navigation ----------------

  /// Open the relevant details screen for an alert.
  /// If [markRead] is true, we mark it read first (best effort).
  Future<void> openAlert(AlertEntity a, {bool markRead = true}) async {
    try {
      if (markRead && !(a.read ?? false)) {
        await _repo.markAsRead(vehicleId: a.vehicleId, id: a.id, read: true);
      }

      final route = _routeFor(a);
      if (route == null) {
        dev.log('No route mapping for alert: type=${a.type}, source=${a.source}',
            name: 'AlertsFeedController');
        Get.snackbar('Can’t open', 'This alert type does not have a details screen yet.');
        return;
      }

      final args = _argsFor(a);

      await Get.toNamed(route, arguments: args);
    } catch (e, st) {
      dev.log('openAlert failed', name: 'AlertsFeedController', error: e, stackTrace: st);
      Get.snackbar('Navigation failed', 'Couldn’t open that alert.');
    }
  }

  /// Map alert to route name. Change defaults via constructor if your app uses different names.
  String? _routeFor(AlertEntity a) {
    final typeStr = a.type is String ? a.type as String : a.type.toString();
    final src = (a.source ?? '').toLowerCase();

    // Prefer explicit source, then fall back to type heuristics.
    if (src == 'service' || typeStr.contains('service')) {
      return serviceDetailRoute;
    }
    if (src == 'document' || typeStr.contains('document') || typeStr.contains('insurance') || typeStr.contains('registration')) {
      return documentDetailRoute;
    }
    return null; // unknown type
  }

  /// Arguments expected by the details screens. Adjust keys if your pages differ.
  Map<String, dynamic> _argsFor(AlertEntity a) {
    final src = (a.source ?? '').toLowerCase();
    if (src == 'service') {
      return {
        'vehicleId': a.vehicleId,
        'serviceId': a.sourceId, // detail screen can load by id
      };
    }
    if (src == 'document') {
      return {
        'vehicleId': a.vehicleId,
        'documentId': a.sourceId,
      };
    }
    return {
      'vehicleId': a.vehicleId,
      'source': a.source,
      'sourceId': a.sourceId,
      'alertId': a.id,
    };
  }
}
