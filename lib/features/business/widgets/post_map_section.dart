import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class PostMapSection extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? address;
  final void Function(LatLng, String?) onPickLocation;

  const PostMapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.onPickLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            // Sayfaya git, LatLng ve adres döner
            final result = await Navigator.pushNamed(context, '/map') as Map<String, dynamic>?;
            if (result != null) {
              final latLng = result['latlng'] as LatLng;
              final address = result['address'] as String?;
              onPickLocation(latLng, address);
            }
          },
          icon: const Icon(Icons.map),
          label: const Text("Konum Seç"),
        ),
        const SizedBox(height: 8),
        if (latitude != null && longitude != null)
          Text("📍 Konum: ($latitude, $longitude)"),

        if (address != null && address!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.home, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(address!, style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}
