import 'package:brainjourney/collection.dart';
import 'package:brainjourney/homeMentalHealth.dart';
import 'package:flutter/material.dart';
import 'package:brainjourney/start.dart';
import 'package:brainjourney/home.dart'; // Importiere deine Zielseiten

class BrainNavigationBar extends StatelessWidget {
  final int currentIndex;
  // Optional: Falls du trotzdem von außen auf Klicks reagieren willst
  final Function(int)? onCustomTap;

  final Color _inkColor = const Color(0xFF3E2723);
  final Color _paperColor = const Color(0xFFFDFBD4);

  final bool mental;

  BrainNavigationBar({
    super.key,
    required this.currentIndex,
    required this.mental,
    this.onCustomTap,
  });

  void _handleNavigation(BuildContext context, int index, bool mental) {
    if (index == currentIndex) return;

    // Führe optionalen Callback aus
    if (onCustomTap != null) onCustomTap!(index);

    // Zentrale Navigations-Logik
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StartScreen()));
        break;
      case 1:
        if (mental){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MentalMapScreen()));
        }
        else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BrainMapScreen()));
        }

        break;
      case 2:
        print("Aktion für Zentral-Button");
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Collection(fromPage: mental)));

        break;
      case 4:
        print("Gehe zu Profil");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: _paperColor,
        border: Border(top: BorderSide(color: _inkColor, width: 2)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(context, Icons.home_outlined, "Start", 0),
            _navItem(context, Icons.map, "Map", 1),

            // Zentraler Action-Button
            GestureDetector(
              onTap: () => _handleNavigation(context, 2, mental),
              child: Container(
                width: 50,
                height: 50,

                child: Image.asset("assets/images/logo.png", fit: BoxFit.fitHeight,),
              ),
            ),

            _navItem(context, Icons.menu_book_outlined, "Collection", 3),
            _navItem(context, Icons.person_outline, "Profile", 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, int index) {
    final bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => _handleNavigation(context, index, mental),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? _inkColor : Colors.grey[600], size: 26),
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