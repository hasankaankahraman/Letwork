import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:letwork/data/model/business_model.dart';

class SearchMapWidget extends StatefulWidget {
  final List<BusinessModel> businesses;

  const SearchMapWidget({super.key, required this.businesses});

  @override
  State<SearchMapWidget> createState() => _SearchMapWidgetState();
}

class _SearchMapWidgetState extends State<SearchMapWidget> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(37.872734, 32.4924376),
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.letwork.app',
        ),
        MarkerLayer(
          markers: widget.businesses.map((business) {
            return Marker(
              point: LatLng(business.latitude, business.longitude),
              width: 80,
              height: 80,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      business.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Icon(Icons.location_on, color: Colors.red, size: 40),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
