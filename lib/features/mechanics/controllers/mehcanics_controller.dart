import 'dart:convert';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

const kMapsKey = String.fromEnvironment('MAPS_API_KEY', defaultValue: '');

class NearbyGaragesController extends GetxController {
  final loading = true.obs;
  final fetching = false.obs;
  final error = RxnString();

  final camera = const CameraPosition(target: LatLng(6.9271, 79.8612), zoom: 12).obs;
  final markers = <Marker>{}.obs;

  GoogleMapController? map;
  LatLng? _center;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      loading.value = true;
      await _ensurePermissions();
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _center = LatLng(pos.latitude, pos.longitude);
      camera.value = CameraPosition(target: _center!, zoom: 15);
      markers.value = {_meMarker(_center!)};
      await fetchNearbyGarages(_center!);
      await _animate(_center!);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> recenter() async {
    if (_center != null) await _animate(_center!);
  }

  Future<void> fetchNearbyGarages(LatLng center) async {
    if (kMapsKey.isEmpty) { error.value = 'Missing Maps/Places API key.'; return; }
    fetching.value = true;
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
            '?location=${center.latitude},${center.longitude}'
            '&rankby=distance'
            '&type=car_repair'
            '&key=$kMapsKey',
      );
      final res = await http.get(url);
      if (res.statusCode != 200) throw 'Places ${res.statusCode}';
      final data = json.decode(res.body) as Map<String, dynamic>;
      final results = (data['results'] as List? ?? []);

      final m = <Marker>{ _meMarker(center) };
      for (final r in results.take(40)) {
        final loc = r['geometry']?['location'];
        if (loc == null) continue;
        final lat = (loc['lat'] as num).toDouble();
        final lng = (loc['lng'] as num).toDouble();
        final id  = r['place_id']?.toString() ?? '$lat,$lng';
        final name = r['name']?.toString() ?? 'Garage';
        final rating = r['rating']?.toString();
        final openNow = r['opening_hours']?['open_now'] == true;

        m.add(
          Marker(
            markerId: MarkerId(id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              // This is the “INFOWINDOW” the video hand-waved about.
              title: name,
              snippet: [
                if (rating != null) '★ $rating',
                if (openNow) 'Open now',
              ].join(' • '),
              onTap: () => _launchDirections(lat, lng, id, name),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
      }
      markers.value = m;
    } catch (e) {
      error.value = e.toString();
    } finally {
      fetching.value = false;
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

  Future<void> _animate(LatLng target) async {
    final c = map;
    if (c == null) return;
    await c.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 15),
    ));
  }

  Marker _meMarker(LatLng p) => Marker(
    markerId: const MarkerId('me'),
    position: p,
    zIndex: 10,
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    infoWindow: const InfoWindow(title: 'You are here'),
  );

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
}
