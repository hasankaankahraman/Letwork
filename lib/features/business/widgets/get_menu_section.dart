import 'package:flutter/material.dart';
import 'package:letwork/data/model/business_detail_model.dart';

class MenuSection extends StatelessWidget {
  final BusinessDetailModel business;

  const MenuSection({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔴 Başlık
        Row(
          children: const [
            Icon(Icons.restaurant_menu, color: Color(0xFFFF0000)),
            SizedBox(width: 8),
            Text(
              "Menü",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        /// 🔴 Menü Listesi
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: business.menu.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = business.menu[index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              shadowColor: Colors.black12,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.fastfood, color: Color(0xFFFF0000)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      "${item['price']}₺",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFFF0000),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
