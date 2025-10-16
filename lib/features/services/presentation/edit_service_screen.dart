// lib/features/service/ui/edit_service_record_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;

class EditServiceRecordScreen extends StatefulWidget {
  const EditServiceRecordScreen({
    super.key,
    this.serviceDate = '2024-03-15',
    this.nextServiceDate = '2024-09-15',
    this.mileageKm = 45250,
    this.workshop = 'AutoCare Plus',
    this.cost = 125.50,
    this.notes =
    'Regular oil change service. Checked all fluid levels and tire pressure. '
        'Next service recommended at 50,000 km.',
    this.invoiceName = 'invoice_march_2024.pdf',
    this.invoiceSize = '245 KB',
  });

  final String serviceDate;
  final String nextServiceDate;
  final int mileageKm;
  final String workshop;
  final double cost;
  final String notes;
  final String invoiceName;
  final String invoiceSize;

  @override
  State<EditServiceRecordScreen> createState() => _EditServiceRecordScreenState();
}

class _EditServiceRecordScreenState extends State<EditServiceRecordScreen> {
  // Controllers
  final _serviceDate = TextEditingController();
  final _nextServiceDate = TextEditingController();
  final _mileage = TextEditingController();
  final _workshop = TextEditingController();
  final _cost = TextEditingController();
  final _notes = TextEditingController();

  String? _serviceType; // dropdown
  bool _hasInvoice = true; // toggles the “existing invoice” row

  @override
  void initState() {
    super.initState();
    _serviceDate.text = widget.serviceDate;
    _nextServiceDate.text = widget.nextServiceDate;
    _mileage.text = '${widget.mileageKm}';
    _workshop.text = widget.workshop;
    _cost.text = widget.cost.toStringAsFixed(2);
    _notes.text = widget.notes;
  }

  @override
  void dispose() {
    _serviceDate.dispose();
    _nextServiceDate.dispose();
    _mileage.dispose();
    _workshop.dispose();
    _cost.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Edit Service Record',
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Color(0xFF111827)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('Service Date'),
              _Box(
                child: _DateField(
                  controller: _serviceDate,
                  onPick: () => _pickDateInto(_serviceDate),
                ),
              ),
              const SizedBox(height: 16),

              _Label('Next Service Date'),
              _Box(
                child: _DateField(
                  controller: _nextServiceDate,
                  onPick: () => _pickDateInto(_nextServiceDate),
                ),
              ),
              const SizedBox(height: 16),

              _Label('Mileage'),
              _Box(
                child: _SuffixField(
                  controller: _mileage,
                  hint: '0',
                  suffix: 'km',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 16),

              _Label('Service Type'),
              _Box(
                child: DropdownButtonFormField<String>(
                  value: _serviceType,
                  icon: const Icon(Iconsax.arrow_down_1),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  hint: const Text('Select service type'),
                  items: const [
                    DropdownMenuItem(value: 'Oil Change', child: Text('Oil Change')),
                    DropdownMenuItem(value: 'Brake Service', child: Text('Brake Service')),
                    DropdownMenuItem(value: 'Tire Rotation', child: Text('Tire Rotation')),
                    DropdownMenuItem(value: 'General Inspection', child: Text('General Inspection')),
                  ],
                  onChanged: (v) => setState(() => _serviceType = v),
                ),
              ),
              const SizedBox(height: 16),

              _Label('Workshop/Provider'),
              _Box(
                child: TextFormField(
                  controller: _workshop,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Workshop name',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8, right: 4),
                      child: Icon(Iconsax.setting_4),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 40),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _Label('Cost'),
              _Box(
                child: TextFormField(
                  controller: _cost,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 12, right: 6),
                      child: Text('\$',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF6B7280))),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 40),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _Label('Notes'),
              _Box(
                child: TextFormField(
                  controller: _notes,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add notes...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _Label('Invoice'),
              if (_hasInvoice) ...[
                _InvoiceRow(
                  name: widget.invoiceName,
                  size: widget.invoiceSize,
                  onDelete: () => setState(() => _hasInvoice = false),
                  onDownload: () {},
                ),
                const SizedBox(height: 12),
              ],

              // Dashed dropzone to replace invoice
              _DashedCard(
                child: SizedBox(
                  width: double.infinity,
                  height: 140,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(color: Color(0xFFEAF0FF), shape: BoxShape.circle),
                        padding: const EdgeInsets.all(10),
                        child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF8391A1)),
                      ),
                      const SizedBox(height: 10),
                      Text('Replace Invoice',
                          style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('PDF, JPG, PNG up to 10MB',
                          style: t.bodySmall?.copyWith(color: const Color(0xFF8391A1))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom actions
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.save_2),
                label: const Text('Save Changes',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                onPressed: _save,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Iconsax.trash, color: Color(0xFFDC2626)),
                label: const Text('Delete Record',
                    style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFBEBEB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: const Color(0xFFFFF5F5),
                ),
                onPressed: _delete,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------------------------- Actions ---------------------------- */

  Future<void> _pickDateInto(TextEditingController target) async {
    final now = DateTime.tryParse(target.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 20),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF7C3AED),
            onPrimary: Colors.white,
            onSurface: Color(0xFF111827),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      target.text = _iso(picked);
      setState(() {});
    }
  }

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _save() {
    // Collect, validate, and persist to backend.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Service record updated')),
    );
    Navigator.of(context).maybePop();
  }

  void _delete() {
    // Confirm + delete.
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('This action cannot be undone. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record deleted')),
              );
              Navigator.of(context).maybePop();
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }
}

/* ----------------------------- Widgets ----------------------------- */

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.controller, required this.onPick});
  final TextEditingController controller;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Iconsax.calendar_1, color: Color(0xFF111827)),
            SizedBox(width: 8),
            Icon(Iconsax.calendar_edit, color: Color(0xFFB7C0CC)),
            SizedBox(width: 10),
          ],
        ),
      ),
      onTap: onPick,
    );
  }
}

class _SuffixField extends StatelessWidget {
  const _SuffixField({
    required this.controller,
    required this.hint,
    required this.suffix,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final String suffix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(suffix,
                style: t.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({
    required this.name,
    required this.size,
    required this.onDelete,
    required this.onDownload,
  });

  final String name;
  final String size;
  final VoidCallback onDelete;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEB),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(size, style: t.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Iconsax.trash, color: Color(0xFFDC2626)),
          ),
          IconButton(
            tooltip: 'Download',
            onPressed: onDownload,
            icon: const Icon(Iconsax.import_3, color: Color(0xFF111827)),
          ),
        ],
      ),
    );
  }
}

/* ----------------------- Dashed card painter ----------------------- */

class _DashedCard extends StatelessWidget {
  const _DashedCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0xFFD9DFEA),
        radius: 12,
        dashLength: 6,
        gapLength: 6,
        strokeWidth: 1.2,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double dashLength;
  final double gapLength;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = math.min(distance + dashLength, metric.length);
        final extract = metric.extractPath(distance, end);
        canvas.drawPath(extract, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
