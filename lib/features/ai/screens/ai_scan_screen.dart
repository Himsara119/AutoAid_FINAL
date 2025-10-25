// lib/features/visual_scan/ui/visual_scan_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/visual_scan_controller.dart';


class VisualScanScreen extends StatelessWidget {
  const VisualScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<VisualScanController>(); // put via binding before routing
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

              _DashedCard(
                child: Obx(() {
                  final file = c.pickedImage.value;
                  return Container(
                    width: double.infinity,
                    height: 240,
                    alignment: Alignment.center,
                    child: file == null
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
                            Icons.camera_alt_rounded,
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
                      child: Image.file(
                        File(file.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 240,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 50,
                width: double.infinity,
                child: Obx(() {
                  final hasImage = c.pickedImage.value != null;
                  return ElevatedButton.icon(
                    icon: hasImage
                        ? const Icon(Iconsax.send_2, size: 20)
                        : const Icon(Icons.camera_alt_rounded, size: 20),
                    label: Text(
                      hasImage ? 'Analyze & Send to Chat' : 'Upload / Take Photo',
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
                    onPressed: () async {
                      if (!hasImage) {
                        _showSourceSheet(context, c);
                      } else {
                        await c.analyzeAndSendToChat();
                      }
                    },
                  );
                }),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                      icon: Icons.photo_rounded,
                      label: 'Gallery',
                      onTap: () => c.pickFromGallery(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PillButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () => c.pickFromCamera(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /*Text('Recent Scans', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
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
              ),*/

              const SizedBox(height: 12),
              Obx(() => c.loading.value ? const LinearProgressIndicator() : const SizedBox.shrink()),
              Obx(() => c.error.value != null
                  ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(c.error.value!, style: const TextStyle(color: Colors.red)),
              )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  void _showSourceSheet(BuildContext ctx, VisualScanController c) {
    showModalBottomSheet(
      context: ctx,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.gallery),
              title: const Text('Gallery'),
              onTap: () { Navigator.pop(ctx); c.pickFromGallery(); },
            ),
            ListTile(
              leading: const Icon(Iconsax.camera),
              title: const Text('Camera'),
              onTap: () { Navigator.pop(ctx); c.pickFromCamera(); },
            ),
          ],
        ),
      ),
    );
  }
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
            child: Icon(Iconsax.car, color: iconColor, size: 18),
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
