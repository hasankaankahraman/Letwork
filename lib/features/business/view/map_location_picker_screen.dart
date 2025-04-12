import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

class MapLocationPickerScreen extends StatefulWidget {
  const MapLocationPickerScreen({super.key});

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  LatLng _pickedLocation = LatLng(41.0082, 28.9784); // İstanbul
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  Future<void> _searchLocation(String query) async {
    final url = Uri.parse("https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1");

    final response = await http.get(url, headers: {
      'User-Agent': 'letwork-app'
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() {
          _pickedLocation = LatLng(lat, lon);
          _mapController.move(_pickedLocation, 15);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Konum bulunamadı")),
        );
      }
    }
  }

  Future<void> _selectLocation() async {
    final address = await _getAddressFromCoordinates(
      _pickedLocation.latitude,
      _pickedLocation.longitude,
    );

    if (!mounted) return;

    Navigator.pop(context, {
      "latlng": _pickedLocation,
      "address": address,
    });
  }

  Future<String?> _getAddressFromCoordinates(double lat, double lon) async {
    final dio = Dio();
    final url = "https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon";

    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'User-Agent': 'letwork-app/1.0 (letwork@example.com)',
          },
        ),
      );

      final address = response.data['address'];
      print("📍 [Koordinat]: ($lat, $lon)");
      print("🌍 [Adres verisi]: $address");

      final parts = [
        address['suburb'],
        address['road'],
        address['amenity'],
        address['town'] ?? address['city'],
        address['province'],
      ];

      return parts.whereType<String>().join(', ');
    } catch (e) {
      print("❌ Adres alınamadı: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Konum Seç")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Konum ara...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final query = _searchController.text.trim();
                    if (query.isNotEmpty) {
                      _searchLocation(query);
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pickedLocation,
                initialZoom: 13,
                onTap: (tapPosition, latlng) {
                  setState(() {
                    _pickedLocation = latlng;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickedLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Konumu Seç"),
              onPressed: _selectLocation,
            ),
          ),
        ],
      ),
    );
  }
}
