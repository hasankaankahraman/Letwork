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
    final bool hasLocation = latitude != null && longitude != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              "İşletme Konumu",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          if (hasLocation)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFEEEE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 20,
                          color: Color(0xFFFF0000),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Seçili Konum",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (address != null && address!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.home,
                            size: 18,
                            color: Color(0xFFFF0000),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              address!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pin_drop, size: 16, color: Colors.grey.shade700),
                        const SizedBox(width: 4),
                        Text(
                          "${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}",
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.location_off, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    "Henüz konum seçilmedi",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "İşletmenizin konumunu belirlemek için haritadan konum seçiniz",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

          InkWell(
            onTap: () async {
              final result = await Navigator.pushNamed(context, '/map') as Map<String, dynamic>?;
              if (result != null) {
                final latLng = result['latlng'] as LatLng;
                final address = result['address'] as String?;
                onPickLocation(latLng, address);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: hasLocation ? Colors.grey.shade100 : const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasLocation ? Colors.grey.shade300 : const Color(0xFFFFCCCC),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasLocation ? Icons.edit_location : Icons.add_location,
                    size: 24,
                    color: const Color(0xFFFF0000),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    hasLocation ? "Konumu Değiştir" : "Haritadan Konum Seç",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF0000),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
