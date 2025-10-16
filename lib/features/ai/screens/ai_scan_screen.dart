import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class VisualScanScreen extends StatefulWidget {
  const VisualScanScreen({super.key});

  @override
  State<VisualScanScreen> createState() => _VisualScanScreenState();
}

class _VisualScanScreenState extends State<VisualScanScreen> {
  ImageProvider? _preview; // set this when you actually pick/take a photo

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
          'Visual Scan',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Subtitle
              Text(
                'Scan Your Item',
                style: t.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Take a clear photo or upload an image to\nidentify and analyze your item instantly',
                style: t.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              // Dashed placeholder with optional preview
              _DashedCard(
                child: Container(
                  width: double.infinity,
                  height: 240, // slightly taller
                  alignment: Alignment.center,
                  child: _preview == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1E8FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded, // filled camera
                          color: Color(0xFF7C3AED),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No image selected',
                        style: t.bodyMedium?.copyWith(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image(
                      image: _preview!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 240,
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 16),

              // Primary CTA
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  // FILLED camera icon
                  icon: const Icon(Icons.camera_alt_rounded, size: 20),
                  label: const Text(
                    'Upload / Take Photo',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    shadowColor: const Color(0xFF7C3AED).withOpacity(0.25),
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _pickAny,
                ),
              ),

              const SizedBox(height: 12),

              // Secondary options
              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                      icon: Icons.photo_rounded, // gallery icon
                      label: 'Gallery',
                      onTap: _pickFromGallery,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PillButton(
                      icon: Icons.camera_alt_rounded, // FILLED camera icon
                      label: 'Camera',
                      onTap: _pickFromCamera,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Recent Scans
              Text('Recent Scans', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),

              const _RecentScanTile(
                iconBg: Color(0xFFEFFAF3),
                iconColor: Color(0xFF16A34A),
                title: 'Range Rover',
                subtitle: '2 hours ago',
              ),
              const SizedBox(height: 10),
              const _RecentScanTile(
                iconBg: Color(0xFFEFFAF3),
                iconColor: Color(0xFF16A34A),
                title: 'Audi',
                subtitle: '1 day ago',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TODO: wire these to image_picker or your own service.
  void _pickAny() {/* open action sheet or route */}
  void _pickFromGallery() {/* pick from gallery */}
  void _pickFromCamera() {/* take photo */}
}

/* ---------------------------- UI BUILDING BLOCKS --------------------------- */

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
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

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

class _PillButton extends StatelessWidget {
  const _PillButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F2F6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: const Color(0xFF111827)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentScanTile extends StatelessWidget {
  const _RecentScanTile({
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8ED)),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: const Icon(Iconsax.car, color: Color(0xFF16A34A), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: t.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
              ],
            ),
          ),
          const Icon(Iconsax.arrow_right_3, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}
