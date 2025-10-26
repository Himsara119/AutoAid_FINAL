import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

void main() => runApp(const _DemoApp());

// Read API key from --dart-define (don’t hardcode this)
const kMapsKey = String.fromEnvironment('MAPS_API_KEY', defaultValue: '');

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

  GoogleMapController? _map;
  LatLng? _center;
  Set<Marker> _markers = {};
  bool _loading = true;
  bool _fetching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      await _ensurePermissions();
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _center = LatLng(pos.latitude, pos.longitude);
      _markers = {_meMarker(_center!)};
      setState(() {});
      await _fetchNearbyGarages(center: _center!);
      await _animate(_center!, zoom: 15);
    } catch (e) {
      setState(() => _error = e.toString());
      _snack('Error', _error!);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _ensurePermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw 'Location services are disabled.';
    }
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    if (p == LocationPermission.denied) throw 'Location permission denied.';
    if (p == LocationPermission.deniedForever) {
      throw 'Location permission permanently denied in settings.';
    }
  }

  Future<void> _fetchNearbyGarages({required LatLng center, String? keyword}) async {
    if (kMapsKey.isEmpty) {
      throw 'Missing MAPS_API_KEY. Run app with --dart-define=MAPS_API_KEY=...';
    }
    setState(() {
      _fetching = true;
      _error = null;
    });
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
            '?location=${center.latitude},${center.longitude}'
            '&rankby=distance'
            '&type=car_repair'
            '${keyword != null && keyword.trim().isNotEmpty ? '&keyword=${Uri.encodeQueryComponent(keyword)}' : ''}'
            '&key=$kMapsKey',
      );

      final res = await http.get(url);
      if (res.statusCode != 200) throw 'Places API error: ${res.statusCode}';
      final data = json.decode(res.body) as Map<String, dynamic>;
      final results = (data['results'] as List? ?? []);

      final next = <Marker>{_meMarker(center)};
      for (final r in results.take(40)) {
        final loc = r['geometry']?['location'];
        if (loc == null) continue;
        final lat = (loc['lat'] as num).toDouble();
        final lng = (loc['lng'] as num).toDouble();
        final id = r['place_id']?.toString() ?? '$lat,$lng';
        final name = r['name']?.toString() ?? 'Garage';
        final rating = r['rating']?.toString();
        final openNow = r['opening_hours']?['open_now'] == true;

        next.add(
          Marker(
            markerId: MarkerId(id),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(
              title: name,
              snippet: [
                if (rating != null) '★ $rating',
                if (openNow) 'Open now',
              ].join(' • '),
              onTap: () => _launchDirections(lat, lng, id, name),
            ),
          ),
        );
      }
      setState(() => _markers = next);
    } catch (e) {
      setState(() => _error = e.toString());
      _snack('Error', _error!);
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  Future<void> _animate(LatLng target, {double zoom = 14}) async {
    final m = _map;
    if (m == null) return;
    await m.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: zoom)),
    );
  }

  Future<void> _recenter() async {
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _center = LatLng(pos.latitude, pos.longitude);
      await _animate(_center!, zoom: 15);
      // Optional: refresh nearby results at new center
      await _fetchNearbyGarages(center: _center!, keyword: _searchCtrl.text.trim());
    } catch (e) {
      _snack('Locate failed', e.toString());
    }
  }

  void _launchDirections(double lat, double lng, String placeId, String name) {
    final qName = Uri.encodeQueryComponent(name);
    launchUrlString(
      'https://www.google.com/maps/dir/?api=1'
          '&destination=$lat,$lng'
          '&destination_place_id=$placeId'
          '&travelmode=driving&dir_action=navigate'
          '&query=$qName',
      mode: LaunchMode.externalApplication,
    );
  }

  void _snack(String title, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: $msg')),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _map?.dispose();
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
                decoration: InputDecoration(
                  hintText: 'Search by location or service',
                  prefixIcon: const Icon(Iconsax.search_normal_1),
                  suffixIcon: _fetching
                      ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                      : IconButton(
                    icon: const Icon(Iconsax.refresh),
                    onPressed: _center == null
                        ? null
                        : () => _fetchNearbyGarages(
                        center: _center!, keyword: _searchCtrl.text.trim()),
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (q) {
                  if (_center != null) {
                    _fetchNearbyGarages(center: _center!, keyword: q.trim());
                  }
                },
              ),
            ),

            // Map area
            Expanded(
              child: Stack(
                children: [
                  // Actual Google Map
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    GoogleMap(
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      compassEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: _center ?? const LatLng(6.9271, 79.8612),
                        zoom: _center == null ? 12 : 15,
                      ),
                      markers: _markers,
                      onMapCreated: (controller) => _map = controller,
                    ),

                  // Bottom-right locate button
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _FloatingLocateButton(onTap: _recenter),
                  ),

                  // Inline error banner
                  if (_error != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 90,
                      child: Material(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
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

  Marker _meMarker(LatLng p) => Marker(
    markerId: const MarkerId('me'),
    position: p,
    zIndex: 10,
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: const InfoWindow(title: 'You are here'),
  );
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
