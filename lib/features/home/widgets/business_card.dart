import 'package:flutter/material.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/features/business/view/business_detail_screen.dart';

class BusinessCard extends StatelessWidget {
  final BusinessModel bModel;
  const BusinessCard({super.key, required this.bModel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BusinessDetailScreen(businessId: bModel.id),
          ),
        );
      },
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
            // Profil Resmi
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: bModel.profileImage.isNotEmpty
                  ? Image.network(
                "https://letwork.hasankaan.com/${bModel.profileImage}",
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

            // İsim ve Kategori
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bModel.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bModel.category,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Kalp ikonu (favori için)
            IconButton(
              icon: const Icon(
                Icons.favorite_border,
                color: Color(0xFFFF0000), // Temaya uygun
              ),
              onPressed: () {
                // TODO: Favorilere ekleme işlemi burada olacak
              },
            ),
          ],
        ),
      ),
    );
  }
}
