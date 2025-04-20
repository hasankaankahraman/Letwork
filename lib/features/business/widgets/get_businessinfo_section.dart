import 'package:flutter/material.dart';
import 'package:letwork/data/model/business_detail_model.dart';

class BusinessInfoSection extends StatelessWidget {
  final BusinessDetailModel business;

  const BusinessInfoSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final Color themeColor = const Color(0xFFFF0000);

    return Card(
      elevation: 1.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: themeColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori > Alt Kategori
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: themeColor.withOpacity(0.2)),
              ),
              child: Text(
                "${business.category} > ${business.subCategory}",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: themeColor,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Açıklama Bölümü
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: themeColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Açıklama",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  business.description,
                  style: const TextStyle(
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),

            Divider(
              height: 30,
              color: themeColor.withOpacity(0.2),
              thickness: 1,
            ),

            // İletişim Bilgileri
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: themeColor.withOpacity(0.15)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Adres
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: themeColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          business.address,
                          style: const TextStyle(
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Çalışma Saatleri
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.access_time, color: themeColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Çalışma Saatleri",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: themeColor.withOpacity(0.2)),
                              ),
                              child: Text(
                                "${business.openTime} - ${business.closeTime}",
                                style: TextStyle(
                                  color: themeColor.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}