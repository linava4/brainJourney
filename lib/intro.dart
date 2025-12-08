import 'dart:math';
import 'dart:ui';
import 'package:brainjourney/start.dart';
import 'package:flutter/material.dart';
import 'home.dart'; // Deine Home/Map Datei

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _dialogStep = 0;

  final List<String> dialog = [
    "Hey!\nIch bin Herbert d. Braini!\nIch begleite dich auf deiner\nReise durch das Gehirn.\nBist du bereit?",
    "Wir entdecken gemeinsam,\nwie Gefühle und Gedanken\nfunktionieren!",
    "Klicke unten,\num die Karte zu öffnen!"
  ];

  void _next() {
    setState(() {
      if (_dialogStep < dialog.length - 1) {
        _dialogStep++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StartScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Bildschirmgröße abfragen
    final size = MediaQuery.of(context).size;

    // Hilfsvariablen für responsive Skalierung
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Verfügbare Höhe berechnen (Screen - SafeAreas)
    final double availableHeight = size.height - topPadding - bottomPadding;

    return Scaffold(
      body: Stack(
        children: [
          // Hintergrundbild (füllt alles aus)
          Positioned.fill(
            child: Image.asset(
              'assets/images/WoodBackground.jpg',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ------------------------------------------
                // OBERER BEREICH: TITEL
                // ------------------------------------------
                SizedBox(height: availableHeight * 0.0), // 2% Abstand oben
                SizedBox(
                  width: size.width * 0.9,
                  height: availableHeight * 0.15, // Nimmt 15% der verfügbaren Höhe ein (max ca 100-120px)
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/woodPlank.png',
                        fit: BoxFit.fill,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0, top: 30.0),
                        // FittedBox sorgt dafür, dass der Text kleiner wird, wenn der Platz nicht reicht
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text(
                            "Willkommen bei BrainJourney!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24, // Basisgröße, skaliert runter wenn nötig
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'ComicSans',
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // ------------------------------------------
                // MITTLERER BEREICH: BRAINI & BLASE
                // ------------------------------------------
                // Expanded sorgt dafür, dass dieser Bereich allen Platz nimmt, der übrig ist.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // constraints.maxHeight ist die exakte Höhe dieses freien Bereichs
                      final areaHeight = constraints.maxHeight;
                      final areaWidth = constraints.maxWidth;

                      return Stack(
                        children: [
                          // SPRECHBLASE (Oben Rechts im Bereich)
                          Positioned(
                            top: areaHeight * 0.05, // 5% von oben
                            right: areaWidth * 0.05, // 5% von rechts
                            width: areaWidth * 0.65, // Breite der Blase
                            height: areaHeight * 0.45, // Darf max 45% der Höhe einnehmen
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/Speakingbubble.png',
                                  fit: BoxFit.contain,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(25, 10, 25, 45),
                                  // Center Widget hilft hier bei der Ausrichtung im Bild
                                  child: Center(
                                    child: AutoSizeText( // Optional: Wenn Text zu lang, lieber FittedBox nutzen
                                      dialog[_dialogStep],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // BRAINI CHARAKTER (Unten Links im Bereich)
                          // Wir verankern ihn am BOTTOM (0), damit er nicht schwebt.
                          Positioned(
                            bottom: 0,
                            left: areaWidth * 0.1, // 10% von links
                            height: areaHeight * 0.5, // Braini ist halb so hoch wie der mittlere Bereich
                            width: areaWidth * 0.5,   // Braini darf 50% der Breite nehmen
                            child: Image.asset(
                              'assets/images/brainMain.png',
                              fit: BoxFit.contain, // Verhindert Verzerren
                              alignment: Alignment.bottomCenter, // Wichtig: Bild sitzt unten am Rand
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // ------------------------------------------
                // UNTERER BEREICH: BUTTON
                // ------------------------------------------
                GestureDetector(
                  onTap: _next,
                  child: Container(
                    width: size.width * 0.8,
                    height: 80, // Feste Höhe für Button ist okay, oder relativ machen (z.B. availableHeight * 0.1)
                    margin: EdgeInsets.only(
                        bottom: availableHeight * 0.05 // 5% Abstand vom unteren Rand
                    ),
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/planks.png',
                          fit: BoxFit.fill,
                          width: double.infinity,
                        ),
                        Text(
                          _dialogStep < dialog.length - 1
                              ? "Weiter"
                              : "Starten wir die Reise!",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Kleines Hilfs-Widget um den Text in der Blase sicher anzuzeigen
// ohne extra Packages zu benötigen
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
          fontSize: 16, // Max Größe
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
}