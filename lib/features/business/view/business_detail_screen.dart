import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:letwork/data/model/business_detail_model.dart';
import 'package:letwork/data/services/business_service.dart';
import 'package:letwork/features/review/cubit/review_cubit.dart';
import 'package:letwork/features/review/repository/review_repository.dart';
import 'package:letwork/features/review/widgets/review_section.dart';

class BusinessDetailScreen extends StatefulWidget {
  final String businessId;

  const BusinessDetailScreen({super.key, required this.businessId});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  late Future<BusinessDetailModel> _future;

  @override
  void initState() {
    super.initState();
    _future = BusinessService().fetchBusinessDetail(widget.businessId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // 💡 fetchReviews fonksiyonunu burada zincirle
      create: (_) => ReviewCubit(ReviewRepository())..fetchReviews(widget.businessId),
      child: Scaffold(
        appBar: AppBar(title: const Text("İşletme Detayı")),
        body: FutureBuilder<BusinessDetailModel>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Hata: ${snapshot.error}"));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("İşletme bulunamadı"));
            }

            final business = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  business.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Kategori: ${business.category} > ${business.subCategory}"),
                const SizedBox(height: 8),
                Text("Açıklama: ${business.description}"),
                const SizedBox(height: 8),
                Text("Adres: ${business.address}"),
                const SizedBox(height: 8),
                Text("Saatler: ${business.openTime} - ${business.closeTime}"),
                const SizedBox(height: 16),

                // 🗺️ Harita
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Konum", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(business.latitude, business.longitude),
                          initialZoom: 15,
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
                                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 🧾 Menü
                if (business.menu.isNotEmpty) ...[
                  const Text("Menü", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...business.menu.map((item) => Text("- ${item['name']} (${item['price']}₺)")),
                  const SizedBox(height: 16),
                ],

                // ✅ Verilen Hizmetler
                if (business.services.isNotEmpty) ...[
                  const Text("Verilen Hizmetler", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...business.services.map((service) => Text("- ${service['service_name']} (${service['price']}₺)")),
                  const SizedBox(height: 16),
                ],

                // 🖼️ Fotoğraflar
                if (business.images.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Fotoğraflar", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: business.images.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final imageUrl = business.images[index]['image_url'];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                "https://letwork.hasankaan.com/$imageUrl",
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // 💬 Yorumlar
                ReviewSection(businessId: widget.businessId),
              ],
            );
          },
        ),
      ),
    );
  }
}
