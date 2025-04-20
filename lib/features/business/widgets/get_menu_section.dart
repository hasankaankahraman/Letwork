import 'package:flutter/material.dart';
import 'package:letwork/data/model/business_detail_model.dart';

class MenuSection extends StatefulWidget {
  final BusinessDetailModel business;

  const MenuSection({super.key, required this.business});

  @override
  State<MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  bool _showAllServices = false;
  final int _initialServiceCount = 4; // Başlangıçta gösterilecek hizmet sayısı

  @override
  Widget build(BuildContext context) {
    // Menü verisini önce menu'den al, yoksa services'tan
    final List menu = widget.business.menu.isNotEmpty
        ? widget.business.menu
        : widget.business.services;

    if (menu.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(
          "Bu işletme henüz hizmet eklememiş.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Gösterilecek servis sayısını belirle
    final int itemCount = _showAllServices ? menu.length : _initialServiceCount.clamp(0, menu.length);
    final bool hasMoreServices = menu.length > _initialServiceCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hizmetler",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color(0xFFFF0000),
            ),
          ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3 / 2,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final item = menu[index];

              final name = item['name'] ??
                  item['service_name'] ?? ''; // menu vs services
              final price = item['price'] ?? '';

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF0000), width: 0.8),
                  color: const Color(0xFFF9F5FB),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.spa_outlined, // Genel bir hizmet ikonu
                      color: Color(0xFFFF0000),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$price₺",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFFFF0000),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (hasMoreServices)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAllServices = !_showAllServices;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0000),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _showAllServices ? "Daha Az Göster" : "Tüm Hizmetleri Göster (${menu.length})",
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}