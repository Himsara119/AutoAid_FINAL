import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AlertsRepository {
  AlertsRepository({
    this.databaseId = 'autoaid',
    FirebaseApp? app,
    FirebaseAuth? auth,
    this.notificationsColl = 'notifications',
    this.remindersColl = 'reminders',
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

  final String notificationsColl;
  final String remindersColl;

  /// Live user-scoped notifications, newest first.
  /// Doc shape (your screenshot):
  /// { user_id: "users/<uid>", title, body, type, is_read, sent_at, data: {...} }
  Stream<List<Map<String, dynamic>>> watchNotifications({int limit = 20}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    final q = _db
        .collection(notificationsColl)
        .where('user_id', isEqualTo: 'users/$uid')
        .orderBy('sent_at', descending: true)
        .limit(limit);

    return q.snapshots().map(
          (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    );
  }

  /// Live user-scoped reminders, soonest first.
  /// Doc shape (your screenshot):
  /// { owner_id: "users/<uid>", status: "active", due_at, title, description, type, severity, ... }
  Stream<List<Map<String, dynamic>>> watchReminders({int limit = 20}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    final q = _db
        .collection(remindersColl)
        .where('owner_id', isEqualTo: 'users/$uid')
        .where('status', isEqualTo: 'active')
        .orderBy('due_at') // soonest due on top
        .limit(limit);

    return q.snapshots().map(
          (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    );
  }

  /// Dashboard preview: merge both, pick top N by urgency/newness.
  /// - Reminders sorted by due_at ASC (sooner first)
  /// - Notifications sorted by sent_at DESC (newer first)
  Stream<List<Map<String, dynamic>>> watchTopAlerts({int limit = 5}) {
    final n$ = watchNotifications(limit: limit);
    final r$ = watchReminders(limit: limit);

    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    List<Map<String, dynamic>> _n = const [];
    List<Map<String, dynamic>> _r = const [];
    StreamSubscription? sn;
    StreamSubscription? sr;

    void emit() {
      final merged = <Map<String, dynamic>>[
        ..._n.map((x) => {...x, '_src': 'notification'}),
        ..._r.map((x) => {...x, '_src': 'reminder'}),
      ];

      merged.sort((a, b) {
        int tsA = a['_src'] == 'notification'
            ? ((a['sent_at'] as Timestamp?)?.toDate().millisecondsSinceEpoch ?? 0)
            : ((a['due_at'] as Timestamp?)?.toDate().millisecondsSinceEpoch ?? 0);
        int tsB = b['_src'] == 'notification'
            ? ((b['sent_at'] as Timestamp?)?.toDate().millisecondsSinceEpoch ?? 0)
            : ((b['due_at'] as Timestamp?)?.toDate().millisecondsSinceEpoch ?? 0);
        return tsB.compareTo(tsA); // newer/sooner first
      });

      controller.add(merged.take(limit).toList());
    }

    sn = n$.listen((v) {
      _n = v;
      emit();
    }, onError: controller.addError);

    sr = r$.listen((v) {
      _r = v;
      emit();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await sn?.cancel();
      await sr?.cancel();
    };

    return controller.stream;
  }
}
