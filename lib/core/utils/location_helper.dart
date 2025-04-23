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
  static Future<String> getCityFromCoordinates(double lat, double lon) async {
    final url =
        "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon";

    try {
      final response = await _dio.get(url);
      final data = response.data;
      final address = data['address'];

      print("📍 [Koordinat]: ($lat, $lon)");
      print("🌍 [Adres verisi]: $address");

      // Şehir, ilçe, köy, eyalet gibi bilgileri alıyoruz
      final fullCity = [
        address?['city'],
        address?['town'],
        address?['village'],
        address?['state'],
        address?['province'],
        address?['region'],
      ].whereType<String>().toSet().join(" ");

      // Eğer şehir adı varsa, onu döndür, yoksa "Şehir adı alınamadı" döndür
      return fullCity.isNotEmpty ? fullCity : "Şehir adı alınamadı";
    } catch (e) {
      print("❌ [getCityFromCoordinates] Hata: $e");
      return "Şehir adı alınamadı"; // Hata durumunda "Şehir adı alınamadı" döndürüyoruz
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
          return LatLng(lat, lon); // Koordinatları döndür
        }
      }
    } catch (e) {
      print("❌ [getCoordinatesFromCity] Hata: $e");
    }

    return null; // Şehir bulunamadıysa null döndür
  }

  /// 📍 Mevcut konumdan koordinat alır
  static Future<Position> getCurrentLocation() async {
    // Konum iznini kontrol et
    LocationPermission permission = await Geolocator.checkPermission();

    // Eğer izin verilmediyse, kullanıcıdan izin iste
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Eğer kalıcı olarak reddedildiyse, hata fırlat
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      throw Exception('Konum izni reddedildi');
    }

    // Koordinatları al
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
