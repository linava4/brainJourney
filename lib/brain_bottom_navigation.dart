import 'package:flutter/material.dart';

// --- DEINE IMPORTS ---
import 'package:brainjourney/start.dart';
import 'package:brainjourney/home.dart';             // BrainMapScreen (Physisch)
import 'package:brainjourney/homeMentalHealth.dart'; // MentalMapScreen (Mental)
import 'package:brainjourney/collection.dart';       // Sammlung
import 'package:brainjourney/profile.dart';          // <-- WICHTIG: Profil Import

class BrainNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onCustomTap; // Optionaler Callback
  final Color _inkColor = const Color(0xFF3E2723);
  final Color _paperColor = const Color(0xFFFDFBD4);
  
  // Wichtig, damit die Bar weiß, ob wir im Mental- oder Körper-Modus sind
  final bool mental;

  BrainNavigationBar({
    super.key,
    required this.currentIndex,
    this.mental = true, // Standardwert true, falls nicht übergeben
    this.onCustomTap,
  });

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;

    // Optionaler Callback von außen (falls benötigt)
    if (onCustomTap != null) onCustomTap!(index);

    // Navigations-Logik
    switch (index) {
      case 0: // STARTSEITE
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StartScreen()));
        break;

      case 1: // KARTE (Unterscheidung Mental vs. Physisch)
        if (mental) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MentalMapScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BrainMapScreen()));
        }
        break;

      case 2: // ZENTRALES LOGO (Führt zur Karte zurück oder macht nichts)
        // Aktuell: Zurück zur entsprechenden Karte
        if (mental) {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MentalMapScreen()));
        } else {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BrainMapScreen()));
        }
        break;

      case 3: // SAMMLUNG
        // Wir übergeben 'mental', damit die Sammlung weiß, wohin 'Zurück' führt
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Collection(fromPage: mental)));
        break;

      case 4: // PROFIL (NEU!)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
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

            // Zentraler Action-Button (Logo)
            GestureDetector(
              onTap: () => _handleNavigation(context, 2),
              child: SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                  "assets/images/logo.png", 
                  fit: BoxFit.contain,
                  errorBuilder: (c,o,s) => Icon(Icons.psychology, size: 40, color: _inkColor), // Fallback falls Bild fehlt
                ),
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
      onTap: () => _handleNavigation(context, index),
      behavior: HitTestBehavior.opaque, // Vergrößert die Klickfläche
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? _inkColor : Colors.grey[600], size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Courier', // Damit es zum Rest passt
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? _inkColor : Colors.grey[600],
            ),
          )
        ],
      ),
    );
  }
}