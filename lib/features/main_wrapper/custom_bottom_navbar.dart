import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(icon: Icons.home, index: 0),
          _buildItem(icon: Icons.chat_bubble_outline, index: 1),
          _buildItem(icon: Icons.add_circle, index: 2),
          _buildItem(icon: Icons.favorite_border, index: 3),
          _buildItem(icon: Icons.person_outline, index: 4),
        ],
      ),
    );
  }

  Widget _buildItem({required IconData icon, required int index}) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: isSelected ? 30 : 24,
          color: isSelected ? Colors.indigo : Colors.grey,
        ),
      ),
    );
  }
}
