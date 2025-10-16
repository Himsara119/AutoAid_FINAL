// lib/features/documents/ui/replace_document_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ReplaceDocumentScreen extends StatefulWidget {
  const ReplaceDocumentScreen({
    super.key,
    this.initialName = 'Health Insurance Policy',
    this.initialIssuer = 'Blue Cross Blue Shield',
    this.initialNumber = 'POL-2024-789456',
    this.initialIssueDate = 'Jan 15, 2024',
    this.initialExpiryDate = 'Jan 14, 2025',
  });

  final String initialName;
  final String initialIssuer;
  final String initialNumber;
  final String initialIssueDate;
  final String initialExpiryDate;

  @override
  State<ReplaceDocumentScreen> createState() => _ReplaceDocumentScreenState();
}

class _ReplaceDocumentScreenState extends State<ReplaceDocumentScreen> {
  ImageProvider? _preview;

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
          'Replace Document',
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload area
              _DashedCard(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickAny,
                  child: SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: _preview == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF1F8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_upload_rounded,
                            color: Color(0xFF8F9BB3),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tap to select or scan new\nfile',
                          textAlign: TextAlign.center,
                          style: t.bodyMedium?.copyWith(
                            color: const Color(0xFF9CA3AF),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Responsive buttons (no overflow)
                        LayoutBuilder(
                          builder: (context, cts) {
                            final narrow = cts.maxWidth < 340;
                            final scanBtn = SizedBox(
                              height: 44,
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Scan New Document',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7C3AED),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                                onPressed: _pickFromCamera,
                              ),
                            );

                            final galleryBtn = SizedBox(
                              height: 44,
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(
                                  Iconsax.image,
                                  size: 18,
                                  color: Color(0xFF7C3AED),
                                ),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Upload from Gallery',
                                    style: TextStyle(
                                      color: Color(0xFF7C3AED),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF7C3AED)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                                onPressed: _pickFromGallery,
                              ),
                            );

                            if (narrow) {
                              return Column(
                                children: [
                                  scanBtn,
                                  const SizedBox(height: 10),
                                  galleryBtn,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: scanBtn),
                                const SizedBox(width: 10),
                                Expanded(child: galleryBtn),
                              ],
                            );
                          },
                        ),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image(image: _preview!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Read-only details (prefilled)
              _ReadOnlyField(label: 'Document Name', value: widget.initialName),
              const SizedBox(height: 10),
              _ReadOnlyField(label: 'Issuer', value: widget.initialIssuer),
              const SizedBox(height: 10),
              _ReadOnlyField(label: 'Document Number', value: widget.initialNumber),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ReadOnlyField(label: 'Issue Date', value: widget.initialIssueDate),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ReadOnlyField(label: 'Expiry Date', value: widget.initialExpiryDate),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Bottom actions
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  foregroundColor: const Color(0xFF111827),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _replaceFile,
                child: const Text('Replace File',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hook these to image_picker or your scanner service.
  void _pickAny() {}
  void _pickFromCamera() {}
  void _pickFromGallery() {}

  void _replaceFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File replaced')),
    );
    Navigator.of(context).maybePop();
  }
}

/* ------------------------------ Widgets ------------------------------ */

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE6E8ED)),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/* --------------------------- Dashed Card --------------------------- */

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
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
    final rrect =
    RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));

    final path = Path()
      ..addRRect(rrect); // ← correct, not addRrect
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dashLength).clamp(0.0, metric.length);
        final extract = metric.extractPath(distance, end);
        canvas.drawPath(extract, paint);
        distance += dashLength + gapLength;
      }
    }
  }


    @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
