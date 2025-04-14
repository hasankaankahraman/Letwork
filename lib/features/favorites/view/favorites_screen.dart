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

class _FavoritesScreenState extends State<FavoritesScreen> {
  String? userId;
  final Color primaryColor = const Color(0xFFFF0000);

  // AnimatedList için global key
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Favori listesini state içinde tutmak için
  var _favorites = [];

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

              // Ögeyı animasyonlu şekilde kaldır
              _removeItem(index, businessId);
            },
            child: const Text('Evet, Çıkar'),
          ),
        ],
      ),
    );
  }

  // Ögeyi animasyonlu bir şekilde kaldırmak için yeni metot
  void _removeItem(int index, String businessId) {
    if (userId == null || !mounted) return;

    final removedItem = _favorites[index];

    // Animasyonlu listeden kaldır
    _listKey.currentState?.removeItem(
      index,
          (context, animation) => _buildItem(removedItem, index, animation),
      duration: const Duration(milliseconds: 300),
    );

    // State'deki listeden kaldır
    setState(() {
      _favorites.removeAt(index);
    });

    // Backend'den kaldır
    context.read<FavoritesCubit>().removeFavorite(userId!, businessId);
  }

  // Animasyonlu öge oluşturma
  Widget _buildItem(dynamic business, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: _buildBusinessCard(business, index),
        ),
      ),
    );
  }

  // İşletme kartını oluşturan metot
  Widget _buildBusinessCard(dynamic business, int index) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BusinessDetailScreen(businessId: business.id),
            ),
          );
          // Reload favorites when returning from detail screen
          if (mounted && userId != null) {
            context.read<FavoritesCubit>().loadFavorites(userId!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'business_${business.id}',
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      business.profileImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint("📷 Profil resmi yüklenemedi");
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.store, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        business.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: primaryColor,
                  size: 28,
                ),
                onPressed: () {
                  if (userId != null) {
                    _confirmDeleteFavorite(business.id, business.name, index);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favori İşletmeler",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
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
            colors: [primaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            } else if (state is FavoritesError) {
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
                      icon: const Icon(Icons.refresh),
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
            } else if (state is FavoritesLoaded) {
              // State güncellemesinde favori listesini kaydet
              _favorites = state.favorites;

              if (_favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey.withOpacity(0.7)),
                      const SizedBox(height: 24),
                      const Text(
                        "Henüz favori işletmeniz yok.",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "İşletme detay sayfalarından favorilerinizi ekleyebilirsiniz.",
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: primaryColor,
                onRefresh: () async {
                  if (userId != null) {
                    context.read<FavoritesCubit>().loadFavorites(userId!);
                  }
                },
                child: AnimatedList(
                  key: _listKey,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  initialItemCount: _favorites.length,
                  itemBuilder: (context, index, animation) {
                    return _buildItem(_favorites[index], index, animation);
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}