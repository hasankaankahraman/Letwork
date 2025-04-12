import 'package:flutter/material.dart';
import 'package:letwork/data/model/business_model.dart';
import 'package:letwork/features/business/view/business_detail_screen.dart';

class BusinessCard extends StatelessWidget {
  final BusinessModel bModel;
  const BusinessCard({super.key, required this.bModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: bModel.profileImage.isNotEmpty
            ? Image.network(
          "https://letwork.hasankaan.com/${bModel.profileImage}",
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        )
            : const Icon(Icons.store, size: 40),
        title: Text(bModel.name),
        subtitle: Text(bModel.category),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BusinessDetailScreen(businessId: bModel.id),
            ),
          );
        },
      ),
    );
  }
}
