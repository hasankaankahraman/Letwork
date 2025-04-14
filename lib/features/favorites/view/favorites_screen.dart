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

  @override
  void initState() {
    super.initState();
    _initCubit();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favori İşletmeler"),
        backgroundColor: const Color(0xFFFF0000),
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritesError) {
            return Center(child: Text("Hata: ${state.message}"));
          } else if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("Henüz favori işletmeniz yok.", style: TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final business = state.favorites[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      business.profileImageUrl,
                    ),
                    onBackgroundImageError: (_, __) {
                      debugPrint("📷 Profil resmi yüklenemedi");
                    },
                  ),
                  title: Text(business.name),
                  subtitle: Text(business.category),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      if (userId != null) {
                        // Direkt favori silme işlemi
                        context.read<FavoritesCubit>().removeFavorite(userId!, business.id);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BusinessDetailScreen(businessId: business.id),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox(); // İlk yüklenme veya bilinmeyen durum
        },
      ),
    );
  }
}
