import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:letwork/data/services/location_service.dart';
import 'package:letwork/core/utils/location_helper.dart';
import 'package:letwork/features/search/cubit/search_cubit.dart';
import 'package:letwork/features/search/cubit/search_state.dart';

class SearchMapScreen extends StatefulWidget {
  const SearchMapScreen({super.key});

  @override
  State<SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _cityController = TextEditingController();

  LatLng _center = LatLng(38.4237, 27.1428); // Default: İzmir

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_center, 13);

      context.read<SearchCubit>().fetchBusinessesByRadius(
        latitude: _center.latitude,
        longitude: _center.longitude,
      );
    } catch (e) {
      debugPrint("Konum alınamadı: $e");
    }
  }

  Future<void> _searchByCity(String city) async {
    final location = await LocationHelper.getCoordinatesFromCity(city);

    if (location != null) {
      setState(() {
        _center = location;
      });
      _mapController.move(location, 13);

      context.read<SearchCubit>().fetchBusinessesByRadius(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şehir bulunamadı")),
      );
    }
  }

  void _onMarkerTap(dynamic business) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              business.name ?? 'İşletme',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(business.address ?? 'Adres bilgisi yok'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // detay ekranına yönlendirme
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Detaylara Git"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Haritadan Ara"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // 🔍 Şehir Arama Alanı
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: "Şehir adı gir...",
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _searchByCity,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _searchByCity(_cityController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Git"),
                ),
              ],
            ),
          ),
          // 🌍 Harita Alanı
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 13,
                onPositionChanged: (pos, hasGesture) {
                  if (hasGesture && pos.center != null) {
                    context.read<SearchCubit>().fetchBusinessesByRadius(
                      latitude: pos.center!.latitude,
                      longitude: pos.center!.longitude,
                    );
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.letwork',
                ),
                BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoaded) {
                      return MarkerLayer(
                        markers: state.businesses.map((b) {
                          final lat = double.tryParse(b.latitude.toString());
                          final lng = double.tryParse(b.longitude.toString());

                          if (lat == null || lng == null) return null;

                          return Marker(
                            point: LatLng(lat, lng),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () => _onMarkerTap(b),
                              child: const Icon(Icons.location_on, color: Colors.red),
                            ),
                          );
                        }).whereType<Marker>().toList(),
                      );
                    } else if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
