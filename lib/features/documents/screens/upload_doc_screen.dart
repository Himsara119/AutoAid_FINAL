// lib/features/documents/ui/upload_document_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final _form = GlobalKey<FormState>();

  // picked image placeholder
  ImageProvider? _preview;

  // form fields
  String? _docType;
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _issuer = TextEditingController();
  final _notes = TextEditingController();
  final _issueDate = TextEditingController();
  final _expiryDate = TextEditingController();

  bool _noExpiry = false;

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _issuer.dispose();
    _notes.dispose();
    _issueDate.dispose();
    _expiryDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Upload Document',
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashed upload area
                _DashedCard(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _pickAny,
                    child: SizedBox(
                      width: double.infinity,
                      height: 170,
                      child: _preview == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1E8FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Color(0xFF7C3AED), size: 26),
                          ),
                          const SizedBox(height: 10),
                          Text('No document selected',
                              style: t.bodyMedium?.copyWith(
                                  color: const Color(0xFF9CA3AF))),
                          const SizedBox(height: 2),
                          Text('Tap below to scan or upload',
                              style: t.bodySmall?.copyWith(
                                  color: const Color(0xFF9CA3AF))),
                        ],
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image(image: _preview!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Primary and Secondary actions
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt_rounded, size: 20),
                    label: const Text('Scan New Document',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _pickFromCamera,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Iconsax.image, size: 20, color: Color(0xFF111827)),
                    label: const Text('Upload from Gallery',
                        style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F2F6),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _pickFromGallery,
                  ),
                ),

                const SizedBox(height: 16),

                // Form fields
                _Label('Document Type'),
                _Box(
                  child: DropdownButtonFormField<String>(
                    value: _docType,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    hint: const Text('Select document type'),
                    icon: const Icon(Iconsax.arrow_down_1),
                    items: const [
                      DropdownMenuItem(value: 'Insurance Policy', child: Text('Insurance Policy')),
                      DropdownMenuItem(value: 'Registration', child: Text('Registration')),
                      DropdownMenuItem(value: 'Emission Test', child: Text('Emission Test')),
                      DropdownMenuItem(value: 'Warranty', child: Text('Warranty')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    validator: (v) => v == null ? 'Please select a type' : null,
                    onChanged: (v) => setState(() => _docType = v),
                  ),
                ),

                const SizedBox(height: 14),
                _Label('Document Name'),
                _Box(
                  child: TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      hintText: 'Enter document name',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),

                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label.rich('Document Number', '(Optional)'),
                          _Box(
                            child: TextFormField(
                              controller: _number,
                              decoration: const InputDecoration(
                                hintText: 'Enter document number',
                                border: InputBorder.none,
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                _Label('Issuer'),
                _Box(
                  child: TextFormField(
                    controller: _issuer,
                    decoration: const InputDecoration(
                      hintText: 'e.g., DMV, Insurance Company',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),

                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Issue Date'),
                          _Box(
                            child: TextFormField(
                              controller: _issueDate,
                              readOnly: true,
                              decoration: const InputDecoration(
                                hintText: 'Select',
                                border: InputBorder.none,
                                suffixIcon: Icon(Iconsax.calendar_1),
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              onTap: () => _pickDate(_issueDate),
                              validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Expiry Date'),
                          _Box(
                            child: TextFormField(
                              controller: _expiryDate,
                              readOnly: true,
                              enabled: !_noExpiry,
                              decoration: InputDecoration(
                                hintText: _noExpiry ? 'No expiry' : 'Select',
                                border: InputBorder.none,
                                suffixIcon: const Icon(Iconsax.calendar_1),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                              ),
                              onTap: _noExpiry ? null : () => _pickDate(_expiryDate),
                              validator: (v) {
                                if (_noExpiry) return null;
                                return v == null || v.isEmpty ? 'Required' : null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Row(
                  children: [
                    Checkbox(
                      value: _noExpiry,
                      onChanged: (v) => setState(() => _noExpiry = v ?? false),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    const Text('No Expiry', style: TextStyle(color: Color(0xFF111827))),
                  ],
                ),

                const SizedBox(height: 6),
                _Label('Notes'),
                _Box(
                  child: TextFormField(
                    controller: _notes,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Add any additional notes or comments...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Sticky Save button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
            ),
            onPressed: _save,
            child: const Text('Save Document',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  /* --------------------------- Actions --------------------------- */

  Future<void> _pickDate(TextEditingController target) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 20),
      initialDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C3AED),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      target.text = _fmt(picked);
      setState(() {});
    }
  }

  String _fmt(DateTime d) =>
      '${_pad(d.day)}/${_pad(d.month)}/${d.year}';
  String _pad(int v) => v < 10 ? '0$v' : '$v';

  // Wire these to image_picker or your scanner later.
  void _pickAny() {}
  void _pickFromGallery() {}
  void _pickFromCamera() {}

  void _save() {
    if (!_form.currentState!.validate()) return;
    // Collect data and persist to backend/storage as needed.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document saved')),
    );
    Navigator.of(context).maybePop();
  }
}

/* --------------------------- UI helpers --------------------------- */

class _Label extends StatelessWidget {
  const _Label(this.text, {super.key});
  final String text;

  // for "Optional" small gray suffix
  factory _Label.rich(String main, String small) => _LabelRich(main: main, small: small);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ));
  }
}

class _LabelRich extends StatelessWidget implements _Label {
  const _LabelRich({required this.main, required this.small});
  final String main;
  final String small;

  @override
  String get text => main;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: main,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
        children: [
          const TextSpan(text: ' '),
          TextSpan(
            text: small,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

/* ----------------------- Dashed card painter ---------------------- */

class _DashedCard extends StatelessWidget {
  const _DashedCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0xFFE2E5EA),
        radius: 14,
        dashLength: 6,
        gapLength: 6,
        strokeWidth: 1.2,
      ),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(10),
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
        final len = dashLength.clamp(0, metric.length - distance);
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
