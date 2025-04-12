import 'package:dio/dio.dart';

class LocationHelper {
  static Future<String?> getCityFromCoordinates(double lat, double lon) async {
    final dio = Dio();
    final url =
        "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon";

    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'letwork-app/1.0 (letwork@example.com)',
          },
        ),
      );

      final data = response.data;
      final address = data['address'];

      print("📍 [Koordinat]: ($lat, $lon)");
      print("🌍 [Adres verisi]: $address");

      final fullCity = [
        address?['city'],
        address?['town'],
        address?['state'],
        address?['province'],
        address?['region'],
      ]
          .whereType<String>()
          .join(" ")
          .toLowerCase();

      return fullCity;
    } catch (e) {
      print("❌ Nominatim hatası: $e");
      return null;
    }
  }
}
