import 'dart:ui';
import 'package:flutter/material.dart';

class BrainNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  final Color _inkColor = const Color(0xFF3E2723);
  final Color _paperColor = const Color(0xFFFDFBD4);

  BrainNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: _paperColor,
        border: Border(top: BorderSide(color: _inkColor, width: 2)),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5)
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(Icons.home_outlined, "Start", 0),
            _navItem(Icons.map, "Karte", 1),

            // Zentraler Action-Button
            GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7C4A5),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: currentIndex == 2 ? Colors.brown : _inkColor,
                      width: 2
                  ),
                ),
                child: Icon(Icons.hiking, color: _inkColor, size: 30),
              ),
            ),

            _navItem(Icons.menu_book_outlined, "Sammelbuch", 3),
            _navItem(Icons.person_outline, "Profil", 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
              icon,
              color: isActive ? _inkColor : Colors.grey[600],
              size: 26
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? _inkColor : Colors.grey[600],
            ),
          )
        ],
      ),
    );
  }


}