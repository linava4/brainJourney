import 'dart:math';
import 'dart:ui';
import 'package:brainjourney/login.dart';
import 'package:brainjourney/register.dart';
import 'package:brainjourney/start.dart';
import 'package:flutter/material.dart';
import 'helpers.dart';
import 'home.dart'; // Import Home/Map

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _dialogStep = 0; // Aktueller Dialogschritt

  // Dialogtexte
  final List<String> dialog = [
    "Hey!\nI'm Herbert d. Braini!\nI will accompany you on your\njourney through the brain.\nAre you ready?",
    "Together we will discover\nhow feelings and thoughts\nwork!",
    "Are you ready\nfor an exciting journey?"
  ];

  // Logik für den nächsten Schritt
  void _next() {
    setState(() {
      if (_dialogStep < dialog.length - 1) {
        _dialogStep++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Bildschirmmaße
    final size = MediaQuery.of(context).size;

    // Responsive Abstände
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Nutzbare Höhe
    final double availableHeight = size.height - topPadding - bottomPadding;

    return Scaffold(
      body: Stack(
        children: [
          // Hintergrund
          Positioned.fill(
            child: Image.asset(
              'assets/images/WoodBackground.jpg',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Titelbereich
                SizedBox(height: availableHeight * 0.0),
                SizedBox(
                  width: size.width * 0.9,
                  height: availableHeight * 0.15,
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
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text(
                            "Welcome to BrainJourney!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                // Hauptbereich mit Charakter
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final areaHeight = constraints.maxHeight;
                      final areaWidth = constraints.maxWidth;

                      return Stack(
                        children: [
                          // Sprechblase
                          Positioned(
                            top: areaHeight * 0.05,
                            right: areaWidth * 0.05,
                            width: areaWidth * 0.70,
                            height: areaHeight * 0.45,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/SpeakingBubble.png',
                                  fit: BoxFit.contain,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(35, 10, 35, 45),
                                  child: Center(
                                    child: AutoSizeText(
                                      dialog[_dialogStep],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Charakter Bild
                          Positioned(
                            bottom: 0,
                            left: areaWidth * 0.1,
                            height: areaHeight * 0.5,
                            width: areaWidth * 0.5,
                            child: Image.asset(
                              'assets/images/brainMain.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Interaktions-Button
                GestureDetector(
                  onTap: _next,
                  child: Container(
                    width: size.width * 0.8,
                    height: 80,
                    margin: EdgeInsets.only(
                        bottom: availableHeight * 0.05
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
                          'assets/images/Planks.png',
                          fit: BoxFit.fill,
                          width: double.infinity,
                        ),
                        Text(
                          _dialogStep < dialog.length - 1
                              ? "Next"
                              : "Start the journey!",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'Courier',

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

