import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:letwork/data/model/business_detail_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';

class MapSection extends StatelessWidget {
  final BusinessDetailModel business;

  const MapSection({super.key, required this.business});

  Future<void> _openMap() async {
    try {
      final availableMaps = await MapLauncher.installedMaps;

      if (availableMaps.isNotEmpty) {
        await availableMaps.first.showMarker(
          coords: Coords(business.latitude, business.longitude),
          title: business.name,
        );
      } else {
        // Yüklü harita uygulaması yoksa, varsayılan URL ile aç
        final Uri url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${business.latitude},${business.longitude}',
        );
        if (!await launchUrl(url)) {
          throw Exception('Harita açılamadı');
        }
      }
    } catch (e) {
      debugPrint('Harita açılırken hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = const Color(0xFFFF0000);

    return Card(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: themeColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve Buton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: themeColor,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Konum",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text("Yol Tarifi", style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: themeColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _openMap,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Harita
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: themeColor.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(business.latitude, business.longitude),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.letwork',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(business.latitude, business.longitude),
                              width: 40,
                              height: 40,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  Icons.location_on,
                                  color: themeColor,
                                  size: 40,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Adres - eğer business.address boş değilse göster
            if (business.address.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.home,
                      size: 18,
                      color: themeColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        business.address,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          height: 1.4,
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
}