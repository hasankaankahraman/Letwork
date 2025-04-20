import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letwork/data/model/business_detail_model.dart';
import 'package:letwork/data/services/business_service.dart';
import 'package:letwork/data/services/favorites_service.dart';
import 'package:letwork/features/business/widgets/get_businessinfo_section.dart';
import 'package:letwork/features/business/widgets/get_map_section.dart';
import 'package:letwork/features/business/widgets/get_menu_section.dart';
import 'package:letwork/features/business/widgets/get_photos_section.dart';
import 'package:letwork/features/chat/view/chat_detail_screen.dart';
import 'package:letwork/features/review/cubit/review_cubit.dart';
import 'package:letwork/features/review/repository/review_repository.dart';
import 'package:letwork/features/review/widgets/review_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessDetailScreen extends StatefulWidget {
  final String businessId;

  const BusinessDetailScreen({super.key, required this.businessId});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  late Future<BusinessDetailModel> _future;
  String? userId;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _future = BusinessService().fetchBusinessDetail(widget.businessId);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("userId");

    if (id != null) {
      debugPrint("✅ SharedPreferences'ten gelen userId: $id");

      setState(() {
        userId = id.toString();
      });

      await _checkFavoriteStatus(); // setState sonrası çağırmak daha doğru
    } else {
      debugPrint("❌ SharedPreferences'ten userId alınamadı!");
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final status = await FavoritesService().isFavorite(userId!, widget.businessId);
      setState(() {
        isFavorite = status;
      });
    } catch (e) {
      debugPrint("Favori durumu alınamadı: $e");
    }
  }

  Future<void> _toggleFavorite() async {
    debugPrint("❤️ Favori butonuna basıldı. userId: $userId");

    if (userId == null) {
      debugPrint("❗ userId null olduğu için işlem yapılmadı.");
      return;
    }

    setState(() => isFavorite = !isFavorite);

    try {
      if (isFavorite) {
        await FavoritesService().addToFavorites(userId!, widget.businessId);
        debugPrint("✅ Favoriye eklendi");
      } else {
        await FavoritesService().removeFromFavorites(userId!, widget.businessId);
        debugPrint("✅ Favoriden çıkarıldı");
      }
    } catch (e) {
      debugPrint("❌ Favori işlemi başarısız: $e");
    }
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
                        // Her zaman MenuSection kullan - hem menu hem de services verisini alabilir
                        MenuSection(business: business),
                        const SizedBox(height: 24),
                        if (business.images.isNotEmpty) ...[
                          PhotosSection(business: business),
                          const SizedBox(height: 24),
                        ],
                        ReviewSection(businessId: widget.businessId),
                        const SizedBox(height: 24),
                        // İşletme ile iletişime geç butonu
                        Padding(
                          padding: const EdgeInsets.only(top: 0, bottom: 32), // Alt boşluk
                          child: Center(
                            child: SizedBox(
                              width: double.infinity, // Ekranı kaplasın
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatDetailScreen(businessId: widget.businessId),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF0000), // Kırmızı tema
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "İşletme ile İletişime Geç",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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
      backgroundColor: Colors.white, // Beyaz arka plan
      foregroundColor: Colors.black, // Siyah metin rengi
      scrolledUnderElevation: 0,
      // Geri tuşu
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white, // Beyaz icon rengi
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.black54,
              offset: Offset(0, 0),
            ),
          ],
        ),
        onPressed: () => Navigator.pop(context),
      ),
      // Favori ikonu
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white, // Beyaz icon rengi (favori değilse)
            shadows: const [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black54,
                offset: Offset(0, 0),
              ),
            ],
          ),
          onPressed: _toggleFavorite,
        ),
      ],
      // Başlangıçta beyaz bir çizgi ekleyerek appbar ve içerik arasında sınır oluşturuyoruz
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      // Esnek bölüm
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Bu daha güvenilir bir yöntem - yükseklik doğrudan ölçülüyor
          final double currentExtent = constraints.biggest.height;
          // Minimum yükseklik (daralmış durumda)
          final double minExtent = kToolbarHeight + MediaQuery.of(context).padding.top;
          // Maksimum yükseklik (genişletilmiş durumda)
          final double maxExtent = 200;

          // 0.0 (tamamen daralmış) ile 1.0 (tamamen genişletilmiş) arasında değer
          final double expansionRatio = (currentExtent - minExtent) / (maxExtent - minExtent);
          // Limit değerleri 0.0 ile 1.0 arasında
          final double clampedExpansionRatio = expansionRatio.clamp(0.0, 1.0);

          // 0.3'ten küçükse siyah metin göster (neredeyse tamamen daralmış)
          final bool useBlackText = clampedExpansionRatio < 0.3;

          return FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(bottom: 16),
            title: Text(
              business.name,
              style: TextStyle(
                color: useBlackText ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: useBlackText
                    ? [] // Daraldığında gölge yok
                    : [  // Genişletildiğinde metin gölgesi ekle
                  const Shadow(
                    blurRadius: 10.0,
                    color: Colors.black54,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
            background: Stack(
              children: [
                // Arka plan resmi
                business.images.isNotEmpty
                    ? Image.network(
                  "https://letwork.hasankaan.com/${business.images[0]['image_url']}",
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
                    : const Center(child: Icon(Icons.business, size: 80, color: Colors.grey)),

                // Metin için gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
// _buildServicesSection metodu kaldırıldı çünkü bu işlevi artık MenuSection yapacak
}