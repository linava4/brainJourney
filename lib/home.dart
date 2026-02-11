import 'dart:ui';
// import 'package:brainjourney/temporallobe.dart';
import 'package:brainjourney/amygdala.dart';
import 'package:brainjourney/cerebellum.dart';
import 'package:brainjourney/prefrontal_cortex.dart';
import 'package:brainjourney/start.dart';
import 'package:brainjourney/temporallobe.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'brain_bottom_navigation.dart';
// In lib/home.dart
import 'package:brainjourney/hippocampus.dart';

import 'helpers.dart'; // Import Hippocampus


// Navigation Bar Import
// import 'brain_navigation_bar.dart';

class BrainMapScreen extends StatefulWidget {
  const BrainMapScreen({super.key});

  @override
  State<BrainMapScreen> createState() => _BrainMapScreenState();
}

class _BrainMapScreenState extends State<BrainMapScreen> {
  final Set<String> _completed = {};
  late SharedPreferences _prefs;
  bool _loading = true;

  final Color _inkColor = const Color(0xFF3E2723);
  final Color _paperColor = const Color(0xFFFDFBD4);

  // Index fuer Karte
  final int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadCompleted();
  }

  // Lade abgeschlossene Level
  Future<void> _loadCompleted() async {
    _prefs = await SharedPreferences.getInstance();
    final list = _prefs.getStringList('completedLevels') ?? [];
    setState(() {
      _completed.addAll(list);
      _loading = false;
    });
  }

  // Markiere Level als fertig
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StartScreen()));
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
        body: const Center(child: CircularProgressIndicator(color: Colors.brown)),
      );
    }

    return Scaffold(
      backgroundColor: _paperColor,
      body: Stack(
        children: [

          // Hauptbereich: Karte
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
                    // Hintergrund
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: Image.asset(
                          'assets/images/MapBackground.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),

                    // PFC Schild
                    brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.20, y: 0.15,
                      label: 'Clearing of\nReason',
                      id: 'pfc',
                      completed: _completed.contains('pfc'),
                      onTap: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const PrefrontalFlow()),
                        );
                        if (completed == true) _markCompleted('pfc');
                      },
                    ),

                    // Amygdala Schild
                    brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.70, y: 0.30,
                      label: 'Cave of\nEmotions',
                      id: 'amygdala',
                      completed: _completed.contains('amygdala'),
                      onTap: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const AmygdalaFlow()),
                        );
                        if (completed == true) _markCompleted('amygdala');
                      },
                    ),

                    // Temporallappen Schild
                    brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.10, y: 0.55,
                      label: 'Forest of\nLanguage',
                      id: 'temporal',
                      completed: _completed.contains('temporal'),
                      onTap: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const TemporalLobeFlow()),
                        );
                        if (completed == true) _markCompleted('temporal');
                      },
                    ),

                    // Kleinhirn Schild
                    brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.30, y: 0.35,
                      label: 'River of Movement',
                      id: 'kleinhirn',
                      completed: _completed.contains('kleinhirn'),
                      onTap: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const CerebellumFlow()),
                        );
                        if (completed == true) _markCompleted('kleinhirn');
                      },
                    ),

                    // Hippocampus Schild
                    brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.75, y: 0.75,
                      label: 'Path of\nMemory',
                      id: 'hippocampus',
                      completed: _completed.contains('hippocampus'),
                      onTap: () async {
                        final completed = await Navigator.push<bool?>(
                          context,
                          MaterialPageRoute(builder: (_) => const HippocampusFlow()),
                        );
                        if (completed == true) _markCompleted('hippocampus');
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleIcon(Icons.hiking, 20),
                    Text(
                      'Brain Map',
                      style: TextStyle(
                        fontFamily: 'Serif', fontSize: 28, fontWeight: FontWeight.bold,
                        color: _inkColor, letterSpacing: 1.0,
                      ),
                    ),
                    Icon(Icons.settings, color: _inkColor, size: 28),
                  ],
                ),
              ),
            ),
          ),

          // Untere Leiste
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: BrainNavigationBar(
              currentIndex: _currentIndex,
              mental: false,
            ),
          ),
        ],
      ),
    );
  }

  // Icon Hilfsmethode
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