import 'package:geolocator/geolocator.dart';
import 'package:letwork/core/utils/location_helper.dart';

class LocationService {
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

  static Future<String?> getCityNameFromCurrentLocation() async {
    try {
      final position = await getCurrentLocation();
      return await LocationHelper.getCityFromCoordinates(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      print("❌ Şehir alınamadı: $e");
      return null;
    }
  }
}
