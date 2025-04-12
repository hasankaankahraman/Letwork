import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/data/model/business_detail_model.dart';
import 'package:letwork/data/services/business_service.dart';
import 'package:letwork/features/review/cubit/review_cubit.dart';
import 'package:letwork/features/review/repository/review_repository.dart';
import 'package:letwork/features/review/widgets/review_section.dart';
import 'package:letwork/features/business/widgets/get_businessinfo_section.dart';
import 'package:letwork/features/business/widgets/get_map_section.dart';
import 'package:letwork/features/business/widgets/get_menu_section.dart';
import 'package:letwork/features/business/widgets/get_photos_section.dart'; // 👈 BURAYI EKLE

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
      create: (_) => ReviewCubit(ReviewRepository())..fetchReviews(widget.businessId),
      child: Scaffold(
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
            return CustomScrollView(
              slivers: [
                _buildAppBar(business),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BusinessInfoSection(business: business),
                        const SizedBox(height: 24),
                        MapSection(business: business),
                        const SizedBox(height: 24),
                        if (business.menu.isNotEmpty) ...[
                          MenuSection(business: business),
                          const SizedBox(height: 24),
                        ],
                        if (business.services.isNotEmpty)
                          _buildServicesSection(business),
                        if (business.images.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          PhotosSection(business: business), // 👈 BURADA YENİ WIDGET KULLANILIYOR
                        ],
                        const SizedBox(height: 24),
                        ReviewSection(businessId: widget.businessId),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BusinessDetailModel business) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          business.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black45),
            ],
          ),
        ),
        background: business.images.isNotEmpty
            ? Image.network(
          "https://letwork.hasankaan.com/${business.images[0]['image_url']}",
          fit: BoxFit.cover,
        )
            : const Center(child: Icon(Icons.business, size: 80, color: Colors.white)),
      ),
    );
  }

  Widget _buildServicesSection(BusinessDetailModel business) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Verilen Hizmetler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: business.services.length,
          itemBuilder: (context, index) {
            final service = business.services[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(service['service_name']),
              trailing: Text("${service['price']}₺", style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          },
        ),
      ],
    );
  }
}
