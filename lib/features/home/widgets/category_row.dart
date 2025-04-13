import 'package:flutter/material.dart';

class CategoryRow extends StatelessWidget {
  final String selected;
  final List<String> categories;
  final Function(String) onSelected;

  const CategoryRow({
    super.key,
    required this.selected,
    required this.categories,
    required this.onSelected,
  });

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'restoran':
      case 'kafe':
        return Icons.restaurant;
      case 'market':
        return Icons.shopping_cart;
      case 'kuaför':
        return Icons.cut;
      case 'teknoloji':
        return Icons.devices;
      case 'oto servis':
        return Icons.car_repair;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selected == cat;

          return GestureDetector(
            onTap: () => onSelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: isSelected ? 80 : 72,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF0000) : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: const Color(0xFFFF0000).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      _getIconForCategory(cat),
                      size: 28,
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
