import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:letwork/features/business/view/business_detail_screen.dart';
import 'package:letwork/features/favorites/cubit/favorites_cubit.dart';
import 'package:letwork/features/favorites/cubit/favorites_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with AutomaticKeepAliveClientMixin {
  String? userId;
  final Color primaryColor = const Color(0xFFFF0000);

  // Favori listesini state içinde tutmak için
  List _favorites = [];
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("userId")?.toString();

    if (id != null && mounted) {
      setState(() {
        userId = id;
      });
      _loadFavorites();
    }
  }

  void _loadFavorites() {
    if (userId != null && mounted) {
      context.read<FavoritesCubit>().loadFavorites(userId!);
    }
  }

  void _confirmDeleteFavorite(String businessId, String businessName, int index) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Favorilerden Çıkar',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        content: Text('$businessName işletmesini favorilerinizden çıkarmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              // Dialog context'inden çıkış
              Navigator.pop(dialogContext);

              // Ögeyi animasyonlu şekilde kaldır
              _removeItem(index, businessId);
            },
            child: const Text('Evet, Çıkar'),
          ),
        ],
      ),
    );
  }

  void _removeItem(int index, String businessId) {
    if (userId == null || !mounted) return;

    // State'deki listeden kaldır
    setState(() {
      _favorites.removeAt(index);
    });

    // Backend'den kaldır
    context.read<FavoritesCubit>().removeFavorite(userId!, businessId);

    // Snackbar ile bildirim göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('İşletme favorilerden kaldırıldı'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'TAMAM',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // İşletme kartını oluşturan metot
  Widget _buildBusinessCard(dynamic business, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BusinessDetailScreen(businessId: business.id),
            ),
          );
          if (mounted && userId != null) {
            _loadFavorites();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button
            Stack(
              children: [
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Hero(
                    tag: 'business_${business.id}',
                    child: Image.network(
                      business.profileImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.store, size: 40, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),

                // Category badge
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      business.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Favorite button
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.white),
                      iconSize: 20,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () => _confirmDeleteFavorite(
                        business.id,
                        business.name,
                        index,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business name
                    Text(
                      business.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Address with icon
                    if (business.address != null && business.address.isNotEmpty)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                business.address,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 28,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BusinessDetailScreen(businessId: business.id),
                      ),
                    );
                    if (mounted && userId != null) {
                      _loadFavorites();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text("Detaylar"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favori İşletmeler",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadFavorites,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: BlocConsumer<FavoritesCubit, FavoritesState>(
          listener: (context, state) {
            if (state is FavoritesLoaded) {
              if (!_isInitialized) {
                setState(() {
                  _favorites = state.favorites;
                  _isInitialized = true;
                });
              } else {
                setState(() {
                  _favorites = state.favorites;
                });
              }
            }
          },
          builder: (context, state) {
            if (state is FavoritesLoading && !_isInitialized) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      "Favorileriniz yükleniyor...",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              );
            } else if (state is FavoritesError && !_isInitialized) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: primaryColor.withOpacity(0.7)),
                    const SizedBox(height: 16),
                    Text(
                      "Hata: ${state.message}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadFavorites,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text("Tekrar Dene"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Favori listesi boşsa
            if (_isInitialized && _favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: primaryColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Henüz favori işletmeniz yok",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "İşletme detay sayfalarında kalp ikonuna tıklayarak favorilerinize ekleyebilirsiniz.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Ana sayfaya yönlendirme
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text("İşletmeleri Keşfet"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Liste dolu ve initialized - Grid Layout
            return RefreshIndicator(
              color: primaryColor,
              onRefresh: () async {
                if (userId != null) {
                  context.read<FavoritesCubit>().loadFavorites(userId!);
                }
              },
              child: _isInitialized
                  ? Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _favorites.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildBusinessCard(_favorites[index], index);
                  },
                ),
              )
                  : const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}