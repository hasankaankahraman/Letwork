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

class _FavoritesScreenState extends State<FavoritesScreen> with WidgetsBindingObserver {
  String? userId;
  final Color primaryColor = const Color(0xFFFF0000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCubit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload favorites when dependencies change (like navigation)
    _loadFavorites();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload when app returns to foreground
    if (state == AppLifecycleState.resumed) {
      _loadFavorites();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initCubit() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("userId")?.toString();

    if (id != null && mounted) {
      setState(() {
        userId = id;
      });
      context.read<FavoritesCubit>().loadFavorites(id);
    }
  }

  void _loadFavorites() {
    if (userId != null && mounted) {
      context.read<FavoritesCubit>().loadFavorites(userId!);
    }
  }

  void _confirmDeleteFavorite(String businessId, String businessName) {
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

              // Ana context'te işlem yapma - önemli: mounted kontrolü
              if (userId != null && mounted) {
                context.read<FavoritesCubit>().removeFavorite(userId!, businessId);
              }
            },
            child: const Text('Evet, Çıkar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This ensures favorites are reloaded when the screen is focused
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });

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
              if (state.favorites.isEmpty) {
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
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  itemCount: state.favorites.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final business = state.favorites[index];

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
                                    _confirmDeleteFavorite(business.id, business.name);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
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