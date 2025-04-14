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
    } else {
      await favoritesCubit.removeFavorite(userId, widget.bModel.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BusinessDetailScreen(businessId: widget.bModel.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.bModel.profileImage.isNotEmpty
                  ? Image.network(
                widget.bModel.profileImageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: const Icon(Icons.store, size: 32, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bModel.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.bModel.category,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (widget.showFavoriteButton)
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: const Color(0xFFFF0000),
                ),
                onPressed: _toggleFavorite,
              ),
          ],
        ),
      ),
    );
  }
}
