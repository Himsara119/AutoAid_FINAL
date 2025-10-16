import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void main() => runApp(const _DemoApp());

class _DemoApp extends StatelessWidget {
  const _DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Find Mechanic',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: purple, primary: purple),
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F6FA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6E8ED)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6E8ED)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: purple, width: 1.2),
          ),
        ),
      ),
      home: const FindMechanicScreen(),
    );
  }
}

class FindMechanicScreen extends StatefulWidget {
  const FindMechanicScreen({super.key});

  @override
  State<FindMechanicScreen> createState() => _FindMechanicScreenState();
}

class _FindMechanicScreenState extends State<FindMechanicScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: _RoundIconButton(
          icon: Iconsax.arrow_left_2,
          onTap: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Find Mechanic',
          style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _RoundIconButton(
              icon: Iconsax.setting_4,
              onTap: () {
                // open filters sheet later
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Open filters')));
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search by location or service',
                  prefixIcon: Icon(Iconsax.search_normal_1),
                ),
                onSubmitted: (q) {
                  // later: trigger maps query
                },
              ),
            ),

            // Map area
            Expanded(
              child: Stack(
                children: [
                  // ====== START: DROP-IN MAP TARGET ======
                  // Replace _MapPlaceholder with your Google Map.
                  //
                  // 1) Add google_maps_flutter to pubspec:
                  //    google_maps_flutter: ^2.x.x
                  // 2) Import: import 'package:google_maps_flutter/google_maps_flutter.dart';
                  // 3) Swap this widget with GoogleMap(...).
                  //
                  // Example:
                  // GoogleMap(
                  //   initialCameraPosition: const CameraPosition(
                  //     target: LatLng(37.7749, -122.4194),
                  //     zoom: 12,
                  //   ),
                  //   myLocationEnabled: true,
                  //   myLocationButtonEnabled: false,
                  //   zoomControlsEnabled: false,
                  //   onMapCreated: (c) => _mapController = c,
                  //   markers: {...},
                  // )
                  const _MapPlaceholder(),
                  // ====== END: DROP-IN MAP TARGET ======

                  // Bottom-right locate button
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _FloatingLocateButton(
                      onTap: () {
                        // later: animate to user location with mapController.animateCamera(...)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Locate me')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================== MINI WIDGETS ============================== */

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE6E8ED)),
        ),
        child: Icon(icon, color: const Color(0xFF111827)),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    // Pretty gradient to mimic a map area while you wire Google Maps.
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.zero,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3F7E7), Color(0xFFDDEBFF)],
        ),
      ),
      child: Stack(
        children: [
          // subtle wave hints
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _WavesPainter()),
            ),
          ),
          // fake user pin
          const Positioned(
            left: 120,
            top: 80,
            child: _UserDot(),
          ),
          // a couple of fake mechanic pins
          const Positioned(left: 260, top: 140, child: _ToolPin()),
          const Positioned(left: 80, bottom: 90, child: _ToolPin()),
        ],
      ),
    );
  }
}

class _FloatingLocateButton extends StatelessWidget {
  const _FloatingLocateButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(Iconsax.gps, color: Color(0xFF111827)),
        ),
      ),
    );
  }
}

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 8)],
      ),
      alignment: Alignment.center,
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Color(0xFF2F6BFF),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ToolPin extends StatelessWidget {
  const _ToolPin();

  @override
  Widget build(BuildContext context) {
    return const Icon(Iconsax.pen_tool, size: 18, color: Colors.white, shadows: [
      Shadow(color: Color(0x33000000), blurRadius: 8),
    ]);
  }
}

class _WavesPainter extends CustomPainter {
  const _WavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1A000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final paths = [
      Path()
        ..moveTo(0, size.height * 0.45)
        ..quadraticBezierTo(size.width * 0.25, size.height * 0.40, size.width * 0.5, size.height * 0.45)
        ..quadraticBezierTo(size.width * 0.75, size.height * 0.50, size.width, size.height * 0.45),
      Path()
        ..moveTo(0, size.height * 0.55)
        ..quadraticBezierTo(size.width * 0.25, size.height * 0.50, size.width * 0.5, size.height * 0.55)
        ..quadraticBezierTo(size.width * 0.75, size.height * 0.60, size.width, size.height * 0.55),
      Path()
        ..moveTo(0, size.height * 0.65)
        ..quadraticBezierTo(size.width * 0.25, size.height * 0.60, size.width * 0.5, size.height * 0.65)
        ..quadraticBezierTo(size.width * 0.75, size.height * 0.70, size.width, size.height * 0.65),
    ];

    for (final p in paths) {
      canvas.drawPath(p, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
