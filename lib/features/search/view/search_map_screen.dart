import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:letwork/core/utils/location_helper.dart';
import 'package:letwork/data/services/location_service.dart';
import 'package:letwork/features/business/view/business_detail_screen.dart';
import 'package:letwork/features/search/cubit/search_cubit.dart';
import 'package:letwork/features/search/cubit/search_state.dart';
import 'package:letwork/data/model/business_model.dart';

class SearchMapScreen extends StatefulWidget {
  const SearchMapScreen({super.key});

  @override
  State<SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _cityController = TextEditingController();
  Timer? _debounce;

  LatLng _center = LatLng(38.4237, 27.1428); // Default: İzmir

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      final center = LatLng(position.latitude, position.longitude);
      setState(() => _center = center);
      _mapController.move(center, 13);

      final cubit = context.read<SearchCubit>();
      cubit.fetchBusinessesByRadius(
        latitude: center.latitude,
        longitude: center.longitude,
      );
    } catch (e) {
      debugPrint("❌ Konum alınamadı: $e");
    }
  }

  Future<void> _searchByCity(String city) async {
    final location = await LocationHelper.getCoordinatesFromCity(city);
    if (location != null) {
      setState(() => _center = location);
      _mapController.move(location, 13);

      final cubit = context.read<SearchCubit>();
      cubit.fetchBusinessesByRadius(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şehir bulunamadı")),
      );
    }
  }

  void _onMarkerTap(BusinessModel business) {
    final center = LatLng(business.latitude, business.longitude);
    _mapController.move(center, 15);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.grey.shade100,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          runSpacing: 16,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(
                    business.profileImage.isNotEmpty
                        ? "https://letwork.hasankaan.com/${business.profileImage}"
                        : "https://letwork.hasankaan.com/assets/default_profile.png",
                  ),
                  onBackgroundImageError: (_, __) {
                    debugPrint('🖼️ Profil resmi yüklenemedi');
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        business.category,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Text(
              business.description,
              style: const TextStyle(fontSize: 15),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFFFF0000)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    business.address,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0000), // 🔴 Kırmızı
                foregroundColor: Colors.white, // 🤍 İkon ve yazı rengi
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.arrow_forward, color: Colors.white), // İkon rengi beyaz
              label: const Text("Detaylara Git"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BusinessDetailScreen(businessId: business.id),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Haritadan Ara"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    backgroundColor: const Color(0xFFFF0000), // 🔴 Kırmızı
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Git"),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 13,
                onPositionChanged: (pos, hasGesture) {
                  if (_debounce?.isActive ?? false) _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    final center = pos.center;
                    if (center != null) {
                      cubit.fetchBusinessesByRadius(
                        latitude: center.latitude,
                        longitude: center.longitude,
                      );
                    }
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.letwork',
                ),
                BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    return MarkerLayer(
                      markers: state.businesses.map((b) {
                        return Marker(
                          point: LatLng(b.latitude, b.longitude),
                          width: 20,
                          height: 20,
                          child: GestureDetector(
                            onTap: () => _onMarkerTap(b),
                            child: Image.asset("assets/pin.png", fit: BoxFit.contain),
                          ),
                        );
                      }).toList(),
                    );
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
