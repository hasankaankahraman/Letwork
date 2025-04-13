import 'package:flutter/material.dart';
import 'package:letwork/features/home/widgets/business_card.dart';
import 'package:letwork/data/model/business_model.dart'; // Modelin yolu buysa

class BusinessList extends StatelessWidget {
  final List<BusinessModel> businesses;

  const BusinessList({super.key, required this.businesses});

  @override
  Widget build(BuildContext context) {
    if (businesses.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "İşletme bulunamadı",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: businesses.map((b) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: BusinessCard(bModel: b),
        );
      }).toList(),
    );
  }
}
