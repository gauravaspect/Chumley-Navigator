import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static final Map<String, LatLng> _geocodeCache = {};

  Future<LatLng?> addressToCoordinates(String address) async {
    final cleanAddress = address.trim().toLowerCase();
    if (cleanAddress.contains('brighton') && cleanAddress.contains('queens')) {
      return const LatLng(50.8284, -0.1410);
    }
    if (cleanAddress.contains('ashby road') || cleanAddress.contains('le11')) {
      return const LatLng(52.7658, -1.2285);
    }

    if (_geocodeCache.containsKey(address)) {
      return _geocodeCache[address];
    }
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final lat = locations.first.latitude;
        final lng = locations.first.longitude;
        if (lat.isFinite && lng.isFinite) {
          final loc = LatLng(lat, lng);
          _geocodeCache[address] = loc;
          return loc;
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return null;
  }
}
