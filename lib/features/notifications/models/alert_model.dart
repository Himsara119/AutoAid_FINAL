// lib/features/notifications/models/alert_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Severity ranks for sorting and consistent usage.
class AlertSeverity {
  static const overdue = 'overdue';
  static const urgent = 'urgent';
  static const upcoming = 'upcoming';
  static const normal = 'normal'; // kept for compatibility when you need it
}

/// Common alert "type" suggestions; use any string you prefer.
class AlertType {
  static const serviceDue = 'service_due';
  static const documentExpiry = 'document_expiry';
}

class AlertEntity {
  final String id;

  /// Vehicle id the alert belongs to.
  /// If not present in the document, infer from the parent path:
  ///   vehicles/{vehicleId}/notifications/{id}
  final String vehicleId;

  /// Optional, for UI: e.g. "BMW X5 2021" or "Toyota Corolla 2019"
  final String? vehicleName;

  final String source;     // "service" | "document"
  final String sourceId;
  final String type;       // "service_due" | "insurance_expiry" | ...
  final String title;
  final String message;
  final String severity;   // "overdue" | "urgent" | "upcoming" | "normal"
  final Timestamp? dueAt;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final bool read;
  final String? userId;
  final String? dealershipId;

  const AlertEntity({
    required this.id,
    required this.vehicleId,
    this.vehicleName,
    required this.source,
    required this.sourceId,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    this.dueAt,
    this.createdAt,
    this.updatedAt,
    this.read = false,
    this.userId,
    this.dealershipId,
  });

  /// Build from an existing alert doc.
  factory AlertEntity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};

    // vehicleId may be omitted in subcollection docs; infer from path if needed
    String vehicleId = (d['vehicle_id'] ?? '').toString();
    if (vehicleId.isEmpty) {
      final parent = doc.reference.parent.parent; // vehicles/{vehicleId}
      if (parent != null) vehicleId = parent.id;
    }

    return AlertEntity(
      id: doc.id,
      vehicleId: vehicleId,
      vehicleName: _strOrNull(d['vehicle_name']),
      source: (d['source'] ?? '').toString(),
      sourceId: (d['source_id'] ?? '').toString(),
      type: (d['type'] ?? '').toString(),
      title: (d['title'] ?? '').toString(),
      message: (d['message'] ?? '').toString(),
      severity: (d['severity'] ?? AlertSeverity.normal).toString(),
      dueAt: _tryTs(d['due_at']),
      createdAt: _tryTs(d['created_at']),
      updatedAt: _tryTs(d['updated_at']),
      read: d['read'] == true,
      userId: _strOrNull(d['user_id']),
      dealershipId: _strOrNull(d['dealership_id']),
    );
  }

  Map<String, dynamic> toMap({bool withTimestamps = false}) {
    final map = <String, dynamic>{
      // keep vehicle_id for convenience; not strictly required in subcollection
      'vehicle_id': vehicleId,
      if (vehicleName != null && vehicleName!.isNotEmpty) 'vehicle_name': vehicleName,
      'source': source,
      'source_id': sourceId,
      'type': type,
      'title': title,
      'message': message,
      'severity': severity,
      'due_at': dueAt,
      'read': read,
      'user_id': userId,
      'dealership_id': dealershipId,
    };

    if (withTimestamps) {
      map['created_at'] = createdAt ?? FieldValue.serverTimestamp();
      map['updated_at'] = FieldValue.serverTimestamp();
    } else {
      map['created_at'] = createdAt;
      map['updated_at'] = updatedAt;
    }
    return map;
  }

  /// Extended copyWith so generators can stamp userId/dealershipId and adjust fields as needed.
  AlertEntity copyWith({
    bool? read,
    String? title,
    String? message,
    String? vehicleName,
    String? userId,
    String? dealershipId,
    String? severity,
    Timestamp? dueAt,
  }) {
    return AlertEntity(
      id: id,
      vehicleId: vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      source: source,
      sourceId: sourceId,
      type: type,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      read: read ?? this.read,
      userId: userId ?? this.userId,
      dealershipId: dealershipId ?? this.dealershipId,
    );
  }

  /// Sorting helper: severity rank then nearest due date.
  int compareTo(AlertEntity other) {
    final rank = {
      AlertSeverity.overdue: 0,
      AlertSeverity.urgent: 1,
      AlertSeverity.upcoming: 2,
      AlertSeverity.normal: 3,
    };
    final r1 = rank[severity] ?? 99;
    final r2 = rank[other.severity] ?? 99;
    if (r1 != r2) return r1.compareTo(r2);

    final a = dueAt?.toDate();
    final b = other.dueAt?.toDate();
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  /// Convenience: days until due date (negative if overdue). Null when unknown.
  int? get daysUntil {
    final d = dueAt?.toDate();
    if (d == null) return null;
    final today = _midnight(DateTime.now());
    final due = _midnight(d);
    return due.difference(today).inDays;
  }

  bool get isOverdue => (daysUntil ?? 1) < 0;
  bool get isUrgent => !isOverdue && (daysUntil ?? 99) <= 2;
  bool get isUpcoming => !isOverdue && !isUrgent && (daysUntil ?? 99) <= 7;

  // ---------- Builders from source documents (ignore if out-of-window) ----------

  /// Build an alert from a service record doc if due within 7 days, urgent in ≤2, or overdue.
  /// Expects fields: next_service_date (Timestamp/Date/string), optional vehicle_name.
  static AlertEntity? fromServiceRecord({
    required DocumentSnapshot<Map<String, dynamic>> doc,
    required String vehicleId,
    String? vehicleName,
    int urgentDays = 2,
    int upcomingDays = 7,
  }) {
    final data = doc.data();
    if (data == null) return null;

    final due = _tryTs(data['next_service_date']);
    if (due == null) return null;

    final days = _daysUntilTs(due);
    final severity = _classify(days, urgentDays: urgentDays, upcomingDays: upcomingDays);
    if (severity == null) return null;

    final title = days < 0
        ? 'Service overdue by ${-days} day${-days == 1 ? '' : 's'}'
        : severity == AlertSeverity.urgent
        ? 'Service due in $days days'
        : 'Service in $days days';

    final message = 'Next service date: ${due.toDate().toIso8601String().split("T").first}';

    return AlertEntity(
      id: 'service_${doc.id}',
      vehicleId: vehicleId,
      vehicleName: vehicleName ?? _strOrNull(data['vehicle_name']),
      source: 'service',
      sourceId: doc.id,
      type: AlertType.serviceDue,
      title: title,
      message: message,
      severity: severity,
      dueAt: due,
      createdAt: null,
      updatedAt: null,
      read: false,
      userId: _strOrNull(data['user_id']),
      dealershipId: _strOrNull(data['dealership_id']),
    );
  }

  /// Build an alert from a document record if it has an expiry and is due soon/overdue.
  /// Expects fields: expiry_date (Timestamp/Date/string), no_expiry (bool).
  static AlertEntity? fromDocumentRecord({
    required DocumentSnapshot<Map<String, dynamic>> doc,
    required String vehicleId,
    String? vehicleName,
    int urgentDays = 2,
    int upcomingDays = 7,
    int upcomingDocsDaysOverride = 45, // documents often need a longer runway
  }) {
    final data = doc.data();
    if (data == null) return null;

    final noExpiry = data['no_expiry'] == true;
    if (noExpiry) return null;

    final due = _tryTs(data['expiry_date']);
    if (due == null) return null;

    final days = _daysUntilTs(due);

    // For documents: let "upcoming" stretch to 45 days by default.
    final severity = _classify(
      days,
      urgentDays: urgentDays,
      upcomingDays: upcomingDocsDaysOverride,
    );
    if (severity == null) return null;

    final title = days < 0
        ? 'Document expired ${-days} day${-days == 1 ? '' : 's'} ago'
        : severity == AlertSeverity.urgent
        ? 'Document expires in $days days'
        : 'Document due in $days days';

    final message = 'Expiry date: ${due.toDate().toIso8601String().split("T").first}';

    return AlertEntity(
      id: 'document_${doc.id}',
      vehicleId: vehicleId,
      vehicleName: vehicleName ?? _strOrNull(data['vehicle_name']),
      source: 'document',
      sourceId: doc.id,
      type: AlertType.documentExpiry,
      title: title,
      message: message,
      severity: severity,
      dueAt: due,
      createdAt: null,
      updatedAt: null,
      read: false,
      userId: _strOrNull(data['user_id']),
      dealershipId: _strOrNull(data['dealership_id']),
    );
  }
}

// ------------------------------ Helpers ------------------------------

String? _strOrNull(dynamic v) {
  final s = v?.toString();
  if (s == null || s.trim().isEmpty) return null;
  return s;
}

Timestamp? _tryTs(dynamic v) {
  if (v is Timestamp) return v;
  if (v is DateTime) return Timestamp.fromDate(v);
  if (v is String) {
    final d = DateTime.tryParse(v);
    if (d != null) return Timestamp.fromDate(d);
  }
  if (v is int) {
    // Accept both ms and s since people love chaos
    if (v > 100000000000) return Timestamp.fromMillisecondsSinceEpoch(v);
    return Timestamp.fromMillisecondsSinceEpoch(v * 1000);
  }
  return null;
}

DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);

int _daysUntilTs(Timestamp ts) {
  final today = _midnight(DateTime.now());
  final due = _midnight(ts.toDate());
  return due.difference(today).inDays;
}

/// Returns severity or null if it should be ignored.
String? _classify(int daysUntil, {required int urgentDays, required int upcomingDays}) {
  if (daysUntil < 0) return AlertSeverity.overdue;
  if (daysUntil <= urgentDays) return AlertSeverity.urgent;
  if (daysUntil <= upcomingDays) return AlertSeverity.upcoming;
  return null;
}
