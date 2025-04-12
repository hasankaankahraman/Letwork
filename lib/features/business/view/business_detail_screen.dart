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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _future = BusinessService().fetchBusinessDetail(widget.businessId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      "Bir hata oluştu",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${snapshot.error}",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _future = BusinessService().fetchBusinessDetail(widget.businessId);
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Tekrar Dene"),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business_rounded, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("İşletme bulunamadı"),
                  ],
                ),
              );
            }

            final business = snapshot.data!;
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Başlık ve Resim
                _buildAppBar(business),

                // İçerik
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Temel Bilgiler
                        _buildBusinessInfoSection(business),

                        const SizedBox(height: 24),

                        // Harita
                        _buildMapSection(business),

                        const SizedBox(height: 24),

                        // Menü
                        if (business.menu.isNotEmpty)
                          _buildMenuSection(business),

                        if (business.menu.isNotEmpty)
                          const SizedBox(height: 24),

                        // Hizmetler
                        if (business.services.isNotEmpty)
                          _buildServicesSection(business),

                        if (business.services.isNotEmpty)
                          const SizedBox(height: 24),

                        // Fotoğraflar
                        if (business.images.isNotEmpty)
                          _buildPhotosSection(business),

                        const SizedBox(height: 24),

                        // Yorumlar
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
      floating: false,
      backgroundColor: Theme.of(context).primaryColor,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
        title: Text(
          business.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black45,
              ),
            ],
          ),
        ),
        background: business.images.isNotEmpty
            ? Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              "https://letwork.hasankaan.com/${business.images[0]['image_url']}",
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        )
            : Container(
          color: Theme.of(context).primaryColor,
          alignment: Alignment.center,
          child: const Icon(
            Icons.business,
            size: 72,
            color: Colors.white60,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.red),
            onPressed: () {
              // Favorilere ekleme işlevi
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Favorilere eklendi")),
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.black87),
            onPressed: () {
              // Paylaşma işlevi
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Paylaşılıyor...")),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessInfoSection(BusinessDetailModel business) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(business.category),
                  backgroundColor: Colors.blue.shade100,
                  avatar: const Icon(Icons.category, size: 16),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(business.subCategory),
                  backgroundColor: Colors.green.shade100,
                  avatar: const Icon(Icons.category_outlined, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Açıklama",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(business.description),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(business.address)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange),
                const SizedBox(width: 8),
                Text("${business.openTime} - ${business.closeTime}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(BusinessDetailModel business) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Konum",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.directions),
              label: const Text("Yol Tarifi"),
              onPressed: () {
                // Yol tarifi açma işlevi
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
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
        ),
      ],
    );
  }

  Widget _buildMenuSection(BusinessDetailModel business) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Menü",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: business.menu.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final item = business.menu[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                item['name'],
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: Text(
                "${item['price']}₺",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServicesSection(BusinessDetailModel business) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Verilen Hizmetler",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: business.services.length,
          itemBuilder: (context, index) {
            final service = business.services[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        service['service_name'],
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Text(
                      "${service['price']}₺",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPhotosSection(BusinessDetailModel business) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Fotoğraflar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (business.images.length > 3)
              TextButton(
                onPressed: () {
                  // Tüm fotoğrafları gösterme işlevi
                  _showAllPhotos(context, business.images);
                },
                child: const Text("Tümünü Gör"),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: business.images.length,
            itemBuilder: (context, index) {
              final imageUrl = business.images[index]['image_url'];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 160,
                child: GestureDetector(
                  onTap: () {
                    _showFullImage(
                      context,
                      "https://letwork.hasankaan.com/$imageUrl",
                      index,
                      business.images,
                    );
                  },
                  child: Hero(
                    tag: "image_$index",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        "https://letwork.hasankaan.com/$imageUrl",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFullImage(BuildContext context, String imageUrl, int initialIndex, List<dynamic> images) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final imgUrl = "https://letwork.hasankaan.com/${images[index]['image_url']}";
                return GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Hero(
                    tag: "image_$index",
                    child: InteractiveViewer(
                      child: Center(
                        child: Image.network(imgUrl),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllPhotos(BuildContext context, List<dynamic> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Tüm Fotoğraflar")),
          body: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageUrl = images[index]['image_url'];
              return GestureDetector(
                onTap: () {
                  _showFullImage(
                    context,
                    "https://letwork.hasankaan.com/$imageUrl",
                    index,
                    images,
                  );
                },
                child: Hero(
                  tag: "grid_image_$index",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "https://letwork.hasankaan.com/$imageUrl",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}