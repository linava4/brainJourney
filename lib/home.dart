import 'dart:ui';
// import 'package:brainjourney/temporallobe.dart';
import 'package:brainjourney/cerebellum.dart';
import 'package:brainjourney/start.dart';
import 'package:brainjourney/temporallobe.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'brain_bottom_navigation.dart';

// Falls du die NavigationBar in eine eigene Datei ausgelagert hast:
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

  // Der aktuelle Index für die Karte ist 1
  final int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadCompleted();
  }

  Future<void> _loadCompleted() async {
    _prefs = await SharedPreferences.getInstance();
    final list = _prefs.getStringList('completedLevels') ?? [];
    setState(() {
      _completed.addAll(list);
      _loading = false;
    });
  }

  Future<void> _markCompleted(String id) async {
    setState(() {
      _completed.add(id);
    });
    await _prefs.setStringList('completedLevels', _completed.toList());
  }

  // --- NEU: Funktion zum Wechseln der Seiten ---
  void _onNavTap(int index) {
    if (index == _currentIndex) return; // Wenn wir schon auf der Karte sind, nichts tun.

    // Beispielhafte Navigation (Du musst hier deine Ziel-Screens einfügen)
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StartScreen()));
    } else if (index == 3) {
      print("Gehe zu Sammelbuch");
    } else if (index == 4) {
      print("Gehe zu Profil");
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

          // ------------------------------------------------
          // HAUPTBEREICH: Karte + Schilder
          // ------------------------------------------------
          Positioned(
            top: 60,
            bottom: 90, // Platz für die BottomBar lassen
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
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: Image.asset(
                          'assets/images/MapBackground.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),

                    // --- SCHILDER ---

                    // PFC
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.20, y: 0.15,
                      label: 'Lichtung der\nVernunft\n(PFC)',
                      id: 'pfc',
                      completed: _completed.contains('pfc'),
                      onTap: () => _openPlaceholder(context, 'PFC', 'pfc'),
                    ),

                    // Amygdala
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.70, y: 0.30,
                      label: 'Höhle der\nGefühle\n(Amygdala)',
                      id: 'amygdala',
                      completed: _completed.contains('amygdala'),
                      onTap: () => _openPlaceholder(context, 'Amygdala', 'amygdala'),
                    ),

                    // Temporallappen
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.10, y: 0.55,
                      label: 'Wald der\nSprache',
                      id: 'temporal',
                      completed: _completed.contains('temporal'),
                      onTap: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const TemporalLobeIntro()),
                        );
                        if (completed == true) _markCompleted('temporal');
                      },
                    ),

                    // Kleinhirn
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.30, y: 0.35,
                      label: 'Fluss der Bewegung',
                      id: 'kleinhirn',
                      completed: _completed.contains('temporal'), // Achtung: Hier prüfst du temporal, evtl. kleinhirn ID nutzen?
                      onTap: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const CerebellumFlow()),
                        );
                        if (completed == true) _markCompleted('kleinhirn'); // ID angepasst
                      },
                    ),

                    // Hippocampus
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.75, y: 0.75,
                      label: 'Pfad der\nErinnerung \n Hippocampus',
                      id: 'hippocampus',
                      completed: _completed.contains('hippocampus'),
                      onTap: () => _openPlaceholder(context, 'Hippocampus', 'hippocampus'),
                    ),
                  ],
                );
              },
            ),
          ),

          // ------------------------------------------------
          // TOP BAR
          // ------------------------------------------------
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
                      'Gehirnkarte',
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

          // ------------------------------------------------
          // BOTTOM BAR (Hier ist jetzt das neue Widget!)
          // ------------------------------------------------
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: BrainNavigationBar(
              currentIndex: _currentIndex, // Hier übergeben wir 1 (für Karte)
              onTap: _onNavTap,            // Die Funktion zum Umschalten
            ),
          ),
        ],
      ),
    );
  }

  // Helper für die Top Bar Icons
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

  // --- RESPONSIVE WIDGET ---
  Widget _brainMapSignResponsive({
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

  void _openPlaceholder(BuildContext ctx, String title, String id) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => Scaffold(
      // Optional: AppBar transparent machen, damit das Bild bis oben geht
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black54, // Halbtransparent für Lesbarkeit
        elevation: 0,
        foregroundColor: Colors.white24,
      ),
      body: Container(
        // Hier wird das Hintergrundbild gesetzt
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/doNotEnter.png'),
            fit: BoxFit.cover, // Bild füllt den ganzen Screen
          ),
        ),
      ),
    )));
  }
}

