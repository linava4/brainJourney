import 'dart:ui';
import 'package:brainjourney/hippocampus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- BESTEHENDE IMPORTS ---
import 'package:brainjourney/cerebellum.dart';
import 'package:brainjourney/start.dart';
import 'package:brainjourney/mentalhealthGames.dart';
import 'package:brainjourney/temporallobe.dart'; // Falls du das Temporallappen-Spiel hast
import 'package:brainjourney/brain_bottom_navigation.dart';

// --- NEUE IMPORTS (WICHTIG!) ---
// Damit dein Code die neuen Klassen auch wirklich findet:
import 'package:brainjourney/amygdala.dart';
//import 'package:brainjourney/hippocampus.dart';
import 'package:brainjourney/prefrontal_cortex.dart';

class MentalMapScreen extends StatefulWidget {
  const MentalMapScreen({super.key});

  @override
  State<MentalMapScreen> createState() => MentalMapScreenState();
}

class MentalMapScreenState extends State<MentalMapScreen> {
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
    if (mounted) {
      setState(() {
        _completed.addAll(list);
        _loading = false;
      });
    }
  }

  Future<void> _markCompleted(String id) async {
    setState(() {
      _completed.add(id);
    });
    await _prefs.setStringList('completedLevels', _completed.toList());
  }

  // --- Navigation über die Bottom Bar ---
  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    if (index == 0) {
      // Home / Start
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StartScreen()));
    } else if (index == 3) {
      // Sammelbuch (Platzhalter)
      print("Gehe zu Sammelbuch");
    } else if (index == 4) {
      // Profil Seite
      // Falls du profile.dart erstellt hast, entferne den Kommentar:
      // Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
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
          // 1. HINTERGRUND
          // ------------------------------------------------
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Image.asset(
                'assets/images/MapBackgroundNight.png',
                fit: BoxFit.fill,
                errorBuilder: (c, o, s) => Container(color: Colors.grey), // Fallback
              ),
            ),
          ),

          // ------------------------------------------------
          // 2. HAUPTBEREICH: Schilder auf der Karte
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
                    
                    // --- AMYGDALA (Angst) ---
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.20, y: 0.15,
                      label: 'Das dornige\nDickicht',
                      id: 'anxiety',
                      completed: _completed.contains('anxiety'),
                      onTap: () async {
                        // Startet den Amygdala Flow
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const AmygdalaFlow()),
                        );
                        if (completed == true) _markCompleted('anxiety');
                      },
                    ),

                    // --- PRÄFRONTALER CORTEX (Fokus/ADHS) ---
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.70, y: 0.30,
                      label: 'Die tanzenden\nBlätter',
                      id: 'adhs',
                      completed: _completed.contains('adhs'),
                      onTap: () async {
                        // Startet das Prefrontal Game (früher AdhsIntro)
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const PrefrontalIntro()),
                        );
                        if (completed == true) _markCompleted('adhs');
                      },
                    ),

                    // --- HIPPOCAMPUS (Depression/Gedächtnis) ---
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.10, y: 0.55,
                      label: 'Der dichte\nNebel',
                      id: 'depression',
                      completed: _completed.contains('depression'),
                      onTap: () async {
                        // Startet den Hippocampus Flow (früher DepressionIntro)
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const HippocampusFlow()),
                        );
                        if (completed == true) _markCompleted('depression');
                      },
                    ),

                    // --- KLEINHIRN / SUCHT ---
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.30, y: 0.35,
                      label: 'Der trockene\nFluss',
                      id: 'addiction',
                      completed: _completed.contains('addiction'),
                      onTap: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const AddictionIntro()),
                        );
                        if (completed == true) _markCompleted('addiction');
                      },
                    ),

                    // --- TRAUMA (Platzhalter oder temporal lobe) ---
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.75, y: 0.75,
                      label: 'Das Echo\nTal',
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

          // ------------------------------------------------
          // 3. TOP BAR
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
                    // Kleines Icon für Profil-Zugriff
                    GestureDetector(
                      onTap: () => _onNavTap(4), // Ruft Profil auf
                      child: Icon(Icons.settings, color: _inkColor, size: 28),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------
          // 4. BOTTOM BAR
          // ------------------------------------------------
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: BrainNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
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

  // --- RESPONSIVE WIDGET FÜR SCHILDER ---
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
                // Schild-Bild
                Image.asset(
                  'assets/images/SignMap.png',
                  width: 80, height: 60, fit: BoxFit.contain,
                  errorBuilder: (c, o, s) => const Icon(Icons.location_on, size: 50, color: Colors.brown),
                ),
                // Grüner Haken wenn erledigt
                if (completed)
                  const Positioned(
                    top: 5, right: 5,
                    child: Icon(Icons.check_circle, color: Color(0xFF3F9067), size: 24),
                  ),
              ],
            ),
            // Text unter dem Schild
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
}
