import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:letwork/features/home/widgets/business_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:letwork/data/services/business_service.dart';
import 'package:letwork/data/services/profile_service.dart';
import 'package:letwork/features/profile/repository/profile_repository.dart';
import 'package:letwork/features/profile/cubit/profile_cubit.dart';
import 'package:letwork/features/profile/view/profile_edit_screen.dart';
import 'package:letwork/features/business/repository/business_repository.dart';
import 'package:letwork/features/business/cubit/update_business_cubit.dart';
import 'package:letwork/features/business/view/update_business_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "fullname": prefs.getString("fullname"),
      "email": prefs.getString("email"),
      "userId": prefs.getInt("userId"),
    };
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFF0000);

    return BlocProvider(
      create: (_) => ProfileCubit(
        BusinessService(),
        ProfileRepository(ProfileService(Dio())),
      )..fetchMyBusinesses(),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _loadUserInfo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            );
          }

          final fullname = snapshot.data?["fullname"] ?? "İsimsiz";
          final email = snapshot.data?["email"] ?? "E-posta bulunamadı";
          final userId = snapshot.data?["userId"];

          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: const Text(
                "Profil",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Çıkış Yap"),
                        content: const Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Çıkış Yap", style: TextStyle(color: primaryColor)),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                      }
                    }
                  },
                  icon: const Icon(Icons.logout, color: primaryColor),
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil bilgileri kartı
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 35,
                          backgroundColor: primaryColor,
                          child: Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullname,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<ProfileCubit>(),
                                      child: const ProfileEditScreen(),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Profili Düzenle",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Başlık ve yenileme butonu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Eklediğin İşletmeler",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => context.read<ProfileCubit>().fetchMyBusinesses(),
                        icon: const Icon(Icons.refresh, color: primaryColor),
                      ),
                    ],
                  ),
                ),

                // İşletmeler listesi
                Expanded(
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      if (state is ProfileLoading) {
                        return const Center(child: CircularProgressIndicator(color: primaryColor));
                      } else if (state is ProfileError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: primaryColor, size: 48),
                              const SizedBox(height: 16),
                              Text("Hata: ${state.message}", style: const TextStyle(color: Colors.grey)),
                              TextButton(
                                onPressed: () => context.read<ProfileCubit>().fetchMyBusinesses(),
                                child: const Text("Tekrar Dene", style: TextStyle(color: primaryColor)),
                              ),
                            ],
                          ),
                        );
                      } else if (state is ProfileLoaded) {
                        final businesses = state.businesses;

                        if (businesses.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  "Hiç işletme eklememişsin",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/add-business');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                  child: const Text("İşletme Ekle"),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: businesses.length,
                          itemBuilder: (context, index) {
                            final business = businesses[index];
                            // İşletme kartının altına işlemler için butonlar ekleyelim
                            return Column(
                              children: [
                                BusinessCard(
                                  bModel: business,
                                  showFavoriteButton: false,
                                ),
                                // İşlem butonları
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Düzenleme butonu
                                      TextButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BlocProvider(
                                                create: (_) => UpdateBusinessCubit(
                                                  BusinessRepository(),
                                                ),
                                                child: UpdateBusinessScreen(
                                                  businessId: (business.id),
                                                ),
                                              ),
                                            ),
                                          ).then((_) {
                                            // İşletme güncellendikten sonra listeyi yenile
                                            context.read<ProfileCubit>().fetchMyBusinesses();
                                          });
                                        },
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        label: const Text(
                                          "Düzenle",
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),

                                      // Dikey ayırıcı çizgi
                                      Container(
                                        height: 25,
                                        width: 1,
                                        color: Colors.grey[300],
                                      ),

                                      // Silme butonu
                                      TextButton.icon(
                                        onPressed: () {
                                          _showDeleteConfirmation(context, business.id, userId);
                                        },
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        label: const Text(
                                          "Sil",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // İşletme silme onay dialogu
  Future<void> _showDeleteConfirmation(BuildContext context, String businessId, int? userId) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kullanıcı bilgileri bulunamadı"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("İşletmeyi Sil"),
        content: const Text(
          "Bu işletmeyi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sil", style: TextStyle(color: Color(0xFFFF0000))),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Verdiğin API'ye göre BusinessService'i kullanarak işletmeyi siliyoruz
        final result = await BusinessService().deleteBusiness(int.parse(businessId), userId);

        if (result['status'] == 'success') {
          // Liste güncelleniyor
          if (context.mounted) {
            context.read<ProfileCubit>().fetchMyBusinesses();

            // Başarılı mesajı gösteriliyor
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? "İşletme başarıyla silindi"),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? "İşletme silinemedi"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("İşletme silinemedi: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}