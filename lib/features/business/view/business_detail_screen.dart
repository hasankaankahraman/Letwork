import 'package:flutter/material.dart';
import 'package:letwork/data/model/business_detail_model.dart';
import 'package:letwork/data/services/business_service.dart';

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
    return Scaffold(
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
              Text(business.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Kategori: ${business.category} > ${business.subCategory}"),
              const SizedBox(height: 8),
              Text("Açıklama: ${business.description}"),
              const SizedBox(height: 8),
              Text("Adres: ${business.address}"),
              const SizedBox(height: 8),
              Text("Saatler: ${business.openTime} - ${business.closeTime}"),
              const SizedBox(height: 8),
              Text("Hizmetler:"),
              ...business.menu.map((item) => Text("- ${item['name']} (${item['price']}₺)")),
              const SizedBox(height: 12),
              if (business.images.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Fotoğraflar:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: business.images.map((img) {
                        return Image.network(
                          "https://letwork.hasankaan.com/${img['image_url']}",
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        );
                      }).toList(),
                    )
                  ],
                )
            ],
          );
        },
      ),
    );
  }
}
