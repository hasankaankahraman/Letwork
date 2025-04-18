import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationHelper {
  static final Dio _dio = Dio(BaseOptions(
    headers: {
      'User-Agent': 'letwork-app/1.0 (letwork@example.com)',
    },
  ));

  /// 📍 Koordinattan şehir adını alır
  static Future<String?> getCityFromCoordinates(double lat, double lon) async {
    final url =
        "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon";

    try {
      final response = await _dio.get(url);
      final data = response.data;
      final address = data['address'];

      print("📍 [Koordinat]: ($lat, $lon)");
      print("🌍 [Adres verisi]: $address");

      final fullCity = [
        address?['city'],
        address?['town'],
        address?['village'],
        address?['state'],
        address?['province'],
        address?['region'],
      ].whereType<String>().toSet().join(" ");

      return fullCity.isNotEmpty ? fullCity : null;
    } catch (e) {
      print("❌ [getCityFromCoordinates] Hata: $e");
      return null;
    }
  }

  /// 🏙 Şehir adından koordinat alır
  static Future<LatLng?> getCoordinatesFromCity(String city) async {
    final url = "https://nominatim.openstreetmap.org/search?q=$city&format=json";

    try {
      final response = await _dio.get(url);
      final data = response.data;

      if (data is List && data.isNotEmpty) {
        final first = data.first;
        final lat = double.tryParse(first['lat'].toString());
        final lon = double.tryParse(first['lon'].toString());

        if (lat != null && lon != null) {
          print("✅ [$city] için koordinatlar: ($lat, $lon)");
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      print("❌ [getCoordinatesFromCity] Hata: $e");
    }

    return null;
  }
  // In lib/core/utils/location_helper.dart, add this method:

  static Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      throw Exception('Konum izni reddedildi');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
