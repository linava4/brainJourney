import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//WOOD BUTTON
class WoodButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const WoodButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Standard Holz-Button
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 220,
        height: 70,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Planks.png"),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
            fontFamily: 'Courier',
          ),
        ),
      ),
    );
  }
}

//WOOD BUTTON WIDE
class WoodButtonWide extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const WoodButtonWide({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Breiter Holz-Button
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 320,
        height: 70,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Planks.png"),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
            fontFamily: 'Courier',
          ),
        ),
      ),
    );
  }
}

// Widget für Karten-Schilder
Widget brainMapSignResponsive({
  required double width, required double height,
  required double x, required double y,
  required String label, required String id,
  required bool completed, required VoidCallback onTap,
}) {
  return Positioned(
    left: width * x,
    top: height * y,
    child: GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/SignMap.png',
                width: 80, height: 60, fit: BoxFit.contain,
                errorBuilder: (c, o, s) => const Icon(Icons.location_on, size: 50, color: Colors.brown),
              ),
              if (completed)
                const Positioned(
                  top: 5, right: 5,
                  child: Icon(Icons.check_circle, color: Color(0xFF3F9067), size: 24),
                ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Serif', fontSize: 11, fontWeight: FontWeight.bold,
                color: Colors.black87, height: 1.1,
              ),
            ),
          )
        ],
      ),
    ),
  );
}


// Platzhalter Screen
void openPlaceholder(BuildContext ctx, String title, String id) {
  Navigator.push(ctx, MaterialPageRoute(builder: (_) => Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Colors.black54,
      elevation: 0,
      foregroundColor: Colors.white24,
    ),
    body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/doNotEnter.png'),
          fit: BoxFit.cover,
        ),
      ),
    ),
  )));
}

// Text-Hilfsklasse
class AutoSizeText extends StatelessWidget {
  final String text;
  const AutoSizeText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontFamily: 'Courier',
        ),
      ),
    );
  }
}

void markLevelComplete(String name) async {
  // Fortschritt speichern
  final prefs = await SharedPreferences.getInstance();
  List<String> completed = prefs.getStringList('completedLevels') ?? [];
  if (!completed.contains(name)) {
    completed.add(name);
    await prefs.setStringList('completedLevels', completed);
  }
}


