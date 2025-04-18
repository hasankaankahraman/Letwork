import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:letwork/core/utils/location_helper.dart';
import 'package:letwork/data/services/location_service.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;

  const MapLocationPickerScreen({Key? key, this.initialPosition}) : super(key: key);

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng? _selectedPosition;
  String? _address;
  bool _isLoading = false;
  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    if (_selectedPosition != null) {
      _getAddressFromCoordinates(_selectedPosition!);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchError = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final coordinates = await LocationHelper.getCoordinatesFromCity(query);

      if (coordinates == null) {
        setState(() {
          _searchError = "Konum bulunamadı";
          _isSearching = false;
        });
        return;
      }

      setState(() {
        _selectedPosition = coordinates;
        _isSearching = false;
      });

      _mapController.move(coordinates, 13);
      _getAddressFromCoordinates(coordinates);
    } catch (e) {
      setState(() {
        _searchError = "Arama sırasında bir hata oluştu";
        _isSearching = false;
      });
      debugPrint("Konum arama hatası: $e");
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng position) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final city = await LocationHelper.getCityFromCoordinates(
          position.latitude,
          position.longitude
      );

      setState(() {
        _address = city;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _address = null;
        _isLoading = false;
      });
      debugPrint("Adres alma hatası: $e");
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedPosition = point;
    });
    _getAddressFromCoordinates(point);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konum Seç"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Şehir, ilçe veya semt ara",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFFF0000),
                      ),
                    )
                        : (_searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchError = null;
                        });
                      },
                    )
                        : null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF0000)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: _searchLocation,
                ),
                if (_searchError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _searchError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),

          // Map Area
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedPosition ?? const LatLng(39.925533, 32.866287),
                    initialZoom: 13,
                    onTap: _onMapTap,
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
                    if (_selectedPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPosition!,
                            width: 60,
                            height: 60,
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFFFF0000),
                              size: 40,
                              shadows: [
                                Shadow(color: Colors.black38, blurRadius: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Center button
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: "centerMap",
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: _isLoading ? null : () async {
                      try {
                        // Use LocationService instead of LocationHelper
                        final position = await LocationService.getCurrentLocation();
                        final latLng = LatLng(position.latitude, position.longitude);
                        _mapController.move(latLng, 15);
                        setState(() {
                          _selectedPosition = latLng;
                        });
                        _getAddressFromCoordinates(latLng);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Konum alınamadı')),
                        );
                      }
                    },
                    child: Icon(
                      Icons.my_location,
                      color: _isLoading ? Colors.grey : const Color(0xFFFF0000),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom action area
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedPosition != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFFF0000), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isLoading ? "Adres alınıyor..." : (_address ?? "Adres bilgisi alınamadı"),
                            style: TextStyle(
                              fontSize: 16,
                              color: _isLoading ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}, Lng: ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

            ElevatedButton(
              onPressed: _selectedPosition == null || _isLoading
                  ? null
                  : () {
                Navigator.pop(context, {
                  'latlng': _selectedPosition,
                  'address': _address,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0000),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: Text(
                _isLoading ? "Adres Bilgileri Alınıyor..." : "Bu Konumu Kullan",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}