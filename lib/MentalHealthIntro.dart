import 'dart:ui'; // Wichtig für ImageFilter
import 'package:flutter/material.dart';
import 'helpers.dart';

import 'cerebellum.dart';
// GENERIC INTRO SCREEN
class MentalHealthIntro extends StatefulWidget {
  final String title;           // z.B. "Der Lichtfänger"
  final String conditionName;   // z.B. "Depression"
  final List<String> texts;     // Die Erklärungen
  final Widget gameWidget;      // Das Spiel, das danach startet
  final String imageAsset;      // Optional: Bild der Hirnregion

  const MentalHealthIntro({
    super.key,
    required this.title,
    required this.conditionName,
    required this.texts,
    required this.gameWidget,
    this.imageAsset = "assets/images/brainPointing.png", // Fallback
  });

  @override
  State<MentalHealthIntro> createState() => _MentalHealthIntroState();
}

class _MentalHealthIntroState extends State<MentalHealthIntro> {
  int textStep = 0;

  void _nextStep() {
    if (textStep < widget.texts.length - 1) {
      setState(() {
        textStep++;
      });
    } else {
      // Intro fertig -> Spiel starten
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => widget.gameWidget),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nacht-Stil Styles
    final TextStyle handStyle = TextStyle(
      fontFamily: 'Courier',
      color: Colors.brown[900],
      fontSize: 18,
      fontWeight: FontWeight.bold,
      height: 1.4,
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1. Hintergrund
          Positioned.fill(
            child: Image.asset("assets/images/WoodBackgroundNight.jpg", fit: BoxFit.cover),
          ),

          // 2. Papierrolle
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.65,
              margin: const EdgeInsets.only(top: 40),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Hintergrund Bild der Rolle
                  SizedBox(
                    width: double.infinity, height: double.infinity,
                    child: Image.asset("assets/images/paperRoll.png", fit: BoxFit.fill),
                  ),

                  // Text Inhalt
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 60.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Kleines Icon/Bild der Region (optional)
                        Image.asset(
                            'assets/images/brainPointing.png',
                            height: 160,
                            fit: BoxFit.contain,
                            errorBuilder: (c, o, s) => const Icon(Icons.psychology, size: 100, color: Colors.green)
                        ),
                        const SizedBox(height: 20),

                        // Der eigentliche Text (animiert wechselnd)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            widget.texts[textStep],
                            key: ValueKey<int>(textStep),
                            textAlign: TextAlign.center,
                            style: handStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Holz-Schild (Header)
          Positioned(
            left: 0, right: 0,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset("assets/images/woodPlank.png", fit: BoxFit.fill, width: double.infinity),
                    Padding(
                      padding: const EdgeInsets.only(top: 35.0),
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(widget.conditionName,
                            style: TextStyle(color: const Color(0xFF3E2723), fontSize: 26, fontFamily: 'Courier', fontWeight: FontWeight.w900)),
                      ],
                    ),
                    ),
                  ],
                ),
              ),
            ),
          ),



          // 5. Button (Weiter / Start)
          Positioned(
            bottom: 40,
            left: 0, right: 0,
            child: Center(
              child: WoodButton( // Nutzt deinen existierenden Button
                text: textStep < widget.texts.length - 1 ? "Weiter" : "Starten",
                onPressed: _nextStep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}