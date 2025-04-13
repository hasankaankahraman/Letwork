import 'package:flutter/material.dart';
import 'package:letwork/data/model/business_detail_model.dart';

class BusinessInfoSection extends StatelessWidget {
  final BusinessDetailModel business;

  const BusinessInfoSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔴 Kategori > Alt Kategori
            Text(
              "${business.category} > ${business.subCategory}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFFFF0000), // kırmızı tema
              ),
            ),

            const SizedBox(height: 12),

            /// 🔴 Açıklama Başlığı
            const Text(
              "Açıklama",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFFFF0000), // kırmızı tema
              ),
            ),
            const SizedBox(height: 4),
            Text(
              business.description,
              style: const TextStyle(color: Colors.black87),
            ),

            const Divider(height: 24),

            /// 🔴 Adres
            Row(
              children: const [
                Icon(Icons.location_on, color: Color(0xFFFF0000)),
                SizedBox(width: 8),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                business.address,
                style: const TextStyle(color: Colors.black87),
              ),
            ),

            const SizedBox(height: 8),

            /// 🔴 Açılış / Kapanış Saatleri
            Row(
              children: const [
                Icon(Icons.access_time, color: Color(0xFFFF0000)),
                SizedBox(width: 8),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                "${business.openTime} - ${business.closeTime}",
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
