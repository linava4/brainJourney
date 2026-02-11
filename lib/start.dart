import 'dart:ui'; // Wichtig für ImageFilter
import 'package:brainjourney/home.dart';
import 'package:brainjourney/homeMentalHealth.dart';
import 'package:flutter/material.dart';
import 'helpers.dart';


void main() {
  runApp(const BrainJourneyApp());
}

class BrainJourneyApp extends StatelessWidget {
  const BrainJourneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial', // Falls du eine handgeschriebene Font hast, hier ändern
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definieren der Farben aus dem Bild
    const Color darkBrown = Color(0xFF3E2723); // Dunkelbraun für Text
    const Color forestGreen = Color(0xFF2E7D32); // Grün für Icons

    return Scaffold(
      body: Stack(
        children: [
          // 1. HINTERGRUND
          // Füllt den gesamten Screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/WoodBackground.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 2. INHALT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // LOGO BEREICH
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 150, // Größe anpassen je nach Logo-Auflösung
                      fit: BoxFit.contain,
                    ),
                  ),

                  // avatar

                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/brainHike.png',
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  //BUTTONS
                  SizedBox(
                    // Breite auf 70% des Bildschirms
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WoodButton(
                          text: "Explore the paths\n(Brain regions)",
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const BrainMapScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        WoodButton(
                          text: "Understand the forest\n(Mental health)",
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const MentalMapScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),



                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




//Progressbar
class ProgressBarRow extends StatelessWidget {
  final Color textColor;

  const ProgressBarRow({super.key, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Progress",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 10),
        // Der eigentliche Balken
        Container(
          width: 100,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black54, width: 1.5),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.5),
            child: Row(
              children: [
                // Gefüllter Teil (Gradient)
                Container(
                  width: 50, // 50% Fortschritt
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE57373), Color(0xFFAED581)], // Rot zu Grün
                    ),
                  ),
                ),
                // Leerer Teil (Weiß)
                Expanded(child: Container(color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Kleines Tannenbaum Icon
        const Icon(Icons.park, color: Color(0xFF2E7D32)),
      ],
    );
  }
}