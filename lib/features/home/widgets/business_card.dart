import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/features/favorites/cubit/favorites_cubit.dart';
import 'package:letwork/features/business/view/business_detail_screen.dart';

class BusinessCard extends StatefulWidget {
  final BusinessModel bModel;
  final bool showFavoriteButton;

  const BusinessCard({
    super.key,
    required this.bModel,
    this.showFavoriteButton = true,
  });

  @override
  State<BusinessCard> createState() => _BusinessCardState();
}

class _BusinessCardState extends State<BusinessCard> {
  late bool isFav;
  final Color primaryColor = const Color(0xFFFF0000); // Kırmızı renk

  @override
  void initState() {
    super.initState();
    isFav = widget.bModel.isFavorite;
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId')?.toString();

    if (userId == null) return;

    final favoritesCubit = context.read<FavoritesCubit>();

    setState(() {
      isFav = !isFav;
      widget.bModel.isFavorite = isFav;
    });

    if (isFav) {
      await favoritesCubit.addFavorite(userId, widget.bModel);
      _showFeedback("İşletme favorilere eklendi");
    } else {
      await favoritesCubit.removeFavorite(userId, widget.bModel.id);
      _showFeedback("İşletme favorilerden çıkarıldı");
    }
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BusinessDetailScreen(businessId: widget.bModel.id),
            ),
          ),
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Resim
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: widget.bModel.profileImage.isNotEmpty
                      ? Image.network(
                    widget.bModel.profileImageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade100,
                    child: Icon(Icons.storefront_outlined, size: 40, color: Colors.grey.shade400),
                  ),
                ),

                const SizedBox(width: 16),

                // Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.bModel.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Adres
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              widget.bModel.address,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Mesafe (isteğe bağlı)
                      if (widget.bModel.distance != null)
                        Row(
                          children: [
                            Icon(Icons.directions, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 3),
                            Text(
                              "${widget.bModel.distance!.toStringAsFixed(1)} km",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),

                      // Etiketler
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Text(
                              widget.bModel.subCategory,
                              style: TextStyle(fontSize: 10, color: Colors.green.shade800),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: primaryColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              "Detaylar",
                              style: TextStyle(fontSize: 10, color: primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Favori
                if (widget.showFavoriteButton)
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: isFav ? primaryColor.withOpacity(0.1) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isFav ? primaryColor : Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? primaryColor : Colors.grey.shade400,
                        size: 22,
                      ),
                      onPressed: _toggleFavorite,
                      tooltip: isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
