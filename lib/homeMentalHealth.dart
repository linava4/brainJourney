import 'dart:ui';
import 'package:brainjourney/hippocampus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:brainjourney/start.dart';
import 'package:brainjourney/mentalhealthGames.dart';
import 'package:brainjourney/temporallobe.dart';
import 'package:brainjourney/brain_bottom_navigation.dart';

import 'helpers.dart';



class MentalMapScreen extends StatefulWidget {
  const MentalMapScreen({super.key});

  @override
  State<MentalMapScreen> createState() => MentalMapScreenState();
}

class MentalMapScreenState extends State<MentalMapScreen> {
  final Set<String> _completed = {};
  late SharedPreferences _prefs;
  bool _loading = true;

  // Farben für Design
  final Color _inkColor = const Color(0xFF3E2723);
  final Color _paperColor = const Color(0xFFFDFBD4);

  // Aktueller Seitenindex
  final int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadCompleted();
  }

  // Abgeschlossene Level laden
  Future<void> _loadCompleted() async {
    _prefs = await SharedPreferences.getInstance();
    final list = _prefs.getStringList('completedLevels') ?? [];
    if (mounted) {
      setState(() {
        _completed.addAll(list);
        _loading = false;
      });
    }
  }

  // Level als erledigt markieren
  Future<void> _markCompleted(String id) async {
    setState(() {
      _completed.add(id);
    });
    await _prefs.setStringList('completedLevels', _completed.toList());
  }

  // Navigation Logik
  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const StartScreen()));
    } else if (index == 3) {
      print("Go to Collection Book");
    } else if (index == 4) {
      print("Go to Profile");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _paperColor,
        body: const Center(
            child: CircularProgressIndicator(color: Colors.brown)),
      );
    }

    return Scaffold(
      backgroundColor: _paperColor,
      body: Stack(
        children: [

          // Hauptbereich Karte
          Positioned(
            top: 60,
            bottom: 90,
            left: 0,
            right: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return Stack(
                  children: [

                    // Hintergrundbild
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          boxShadow: [BoxShadow(
                              color: Colors.black12, blurRadius: 10)
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/MapBackgroundNight.png',
                          fit: BoxFit.fill,
                          errorBuilder: (c, o, s) =>
                              Container(color: Colors.grey),
                        ),
                      ),
                    ),

                    // Amygdala
                    brainMapSignResponsive(
                      width: width,
                      height: height,
                      x: 0.20,
                      y: 0.15,
                      label: 'The Thorny\nThicket',
                      id: 'anxiety',
                      completed: _completed.contains('anxiety'),
                      onTap: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AnxietyIntro()),
                        );
                        if (completed == true) _markCompleted('anxiety');
                      },
                    ),

                    // Präfrontaler Cortex
                    brainMapSignResponsive(
                      width: width,
                      height: height,
                      x: 0.70,
                      y: 0.30,
                      label: 'The Dancing\nLeaves',
                      id: 'adhs',
                      completed: _completed.contains('adhs'),
                      onTap: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const AdhsIntro()),
                        );
                        if (completed == true) _markCompleted('adhs');
                      },
                    ),

                    // Hippocampus
                    brainMapSignResponsive(
                      width: width,
                      height: height,
                      x: 0.10,
                      y: 0.55,
                      label: 'The Dense\nFog',
                      id: 'depression',
                      completed: _completed.contains('depression'),
                      onTap: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DepressionIntro()),
                        );
                        print("test");
                        print("$completed");
                        if (completed == true) _markCompleted('depression');
                      },
                    ),

                    // Kleinhirn
                    brainMapSignResponsive(
                      width: width,
                      height: height,
                      x: 0.30,
                      y: 0.35,
                      label: 'The Dry\nRiver',
                      id: 'addiction',
                      completed: _completed.contains('addiction'),
                      onTap: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddictionIntro()),
                        );
                        if (completed == true) _markCompleted('addiction');
                      },
                    ),

                    // Temporallappen
                    brainMapSignResponsive(
                      width: width,
                      height: height,
                      x: 0.75,
                      y: 0.75,
                      label: 'The Echo\nValley',
                      id: 'trauma',
                      completed: _completed.contains('trauma'),
                      onTap: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const PtbsIntro()),
                        );
                        if (completed == true) _markCompleted('trauma');
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // Obere Leiste
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleIcon(Icons.hiking, 20),
                    Text(
                      'Mental Health Map',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _inkColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onNavTap(4),
                      child: Icon(Icons.settings, color: _inkColor, size: 28),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Untere Navigationsleiste
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: BrainNavigationBar(
              currentIndex: _currentIndex,
              mental: true,
            ),
          ),
        ],
      ),
    );
  }

  // Icon Container Widget
  Widget _circleIcon(IconData icon, double size) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _inkColor, width: 2),
        color: _paperColor,
      ),
      child: Icon(icon, color: _inkColor, size: size),
    );
  }
}