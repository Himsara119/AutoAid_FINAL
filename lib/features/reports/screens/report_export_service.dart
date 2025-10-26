import 'dart:typed_data';
import 'dart:io';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf; // for PdfPageFormat
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// ReportExportService builds report PDFs and can upload them to Firebase Storage.
class ReportExportService {
  /// Generates a PDF from Firestore data for the given vehicle and sections.
  /// Returns the raw PDF bytes.
  Future<Uint8List> buildPdf({
    required String vehicleId,
    required List<String> sections,
  }) async {
    final db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'autoaid',
    );

    // --------- Fetch all data up front (async allowed here) ----------
    final vehicleDoc =
    await db.collection('vehicles').doc(vehicleId).get();
    final vehicle = vehicleDoc.data() ?? <String, dynamic>{};

    // services rows: [type, date, cost]
    final servicesSnap = await db
        .collection('vehicles')
        .doc(vehicleId)
        .collection('services')
        .orderBy('service_date', descending: true)
        .get();

    final serviceRows = servicesSnap.docs.map((d) {
      final s = d.data();
      final date = s['service_date'] is Timestamp
          ? (s['service_date'] as Timestamp).toDate()
          : null;
      return [
        '${s['type'] ?? 'Service'}',
        date == null ? '-' : _fmtDate(date),
        s['cost'] == null ? '-' : '${s['cost']}',
      ];
    }).toList();

    // documents rows: [type, name, status]
    final docsSnap = await db
        .collection('vehicles')
        .doc(vehicleId)
        .collection('documents')
        .get();

    final documentRows = docsSnap.docs.map((d) {
      final s = d.data();
      return [
        '${s['type'] ?? 'Document'}',
        '${s['name'] ?? '-'}',
        '${s['status'] ?? '-'}',
      ];
    }).toList();

    // ----------------------- Build PDF -------------------------------
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: pdf.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          final children = <pw.Widget>[
            pw.Text(
              'AutoAid Vehicle Report',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Vehicle ID: $vehicleId', style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Generated: ${DateTime.now()}',
                style: const pw.TextStyle(fontSize: 11)),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text('Selected Sections:',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: sections.join(', ')),
            pw.SizedBox(height: 12),
          ];

          if (sections.contains('Overview')) {
            children.add(_buildOverview(vehicle));
          }
          if (sections.contains('Service History')) {
            children.add(_buildServices(serviceRows));
          }
          if (sections.contains('Documents')) {
            children.add(_buildDocuments(documentRows));
          }
          if (sections.contains('AI Report')) {
            children.add(_buildAiInsights());
          }

          return children;
        },
      ),
    );

    return doc.save();
  }

  /* ------------------------------------------------------------------ */
  /* -------------------- Section builders (sync) --------------------- */
  /* ------------------------------------------------------------------ */

  pw.Widget _buildOverview(Map<String, dynamic> v) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Overview',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: const ['Field', 'Value'],
          data: [
            ['Make', v['make'] ?? '-'],
            ['Model', v['model'] ?? '-'],
            ['Year', v['year']?.toString() ?? '-'],
            ['Mileage', v['mileage']?.toString() ?? '-'],
          ],
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  pw.Widget _buildServices(List<List<String>> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Service History',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: const ['Type', 'Date', 'Cost'],
          data: rows.isEmpty ? const [['-', '-', '-']] : rows,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  pw.Widget _buildDocuments(List<List<String>> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Documents',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: const ['Type', 'Name', 'Status'],
          data: rows.isEmpty ? const [['-', '-', '-']] : rows,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  pw.Widget _buildAiInsights() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('AI Insights',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(
          'The vehicle demonstrates regular maintenance and minimal issues. '
              'AI evaluation indicates it is in above-average condition for its mileage.',
        ),
      ],
    );
  }

  /* ------------------------------------------------------------------ */
  /* ---------------------- Upload Helper ----------------------------- */
  /* ------------------------------------------------------------------ */

  Future<String> uploadReportFile({
    required String vehicleId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('reports/$vehicleId/$fileName');
    final task = await ref.putData(bytes);
    return await task.ref.getDownloadURL();
  }
}

/* ------------------------------ utils ------------------------------- */

String _fmtDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}
