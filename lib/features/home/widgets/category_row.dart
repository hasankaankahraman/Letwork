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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selected == cat;

          return GestureDetector(
            onTap: () => onSelected(cat),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
