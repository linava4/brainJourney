import 'dart:ui';
// import 'package:brainjourney/temporallobe.dart';
import 'package:brainjourney/temporallobe.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



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
          // HAUPTBEREICH: Karte + Schilder (Responsive Container)
          // ------------------------------------------------
          Positioned(
            // Definiert den Bereich zwischen TopBar (ca. 80px Platz lassen) und BottomBar (90px)
            top: 60,
            bottom: 90,
            left: 0,
            right: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Wir holen uns die aktuelle Breite und Höhe dieses Bereichs
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                return Stack(
                  children: [
                    // 1. Das Hintergrundbild (füllt den Bereich)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: Image.asset(
                          'assets/images/MapBackground.png',
                          fit: BoxFit.fill, // Zerrt das Bild passend
                        ),
                      ),
                    ),

                    // 2. Die Schilder (Positioniert mit Prozentwerten)

                    // PFC (Oben Mitte)
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.20,  // 35% von links
                      y: 0.15,  // 15% von oben
                      label: 'Lichtung der\nVernunft\n(PFC)',
                      id: 'pfc',
                      completed: _completed.contains('pfc'),
                      onTap: () => _openPlaceholder(context, 'PFC', 'pfc'),
                    ),

                    // Amygdala (Links Mitte)
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.80,  // 5% von links (ganz links)
                      y: 0.30,  // 45% von oben (fast Mitte)
                      label: 'Höhle der\nGefühle\n(Amygdala)',
                      id: 'amygdala',
                      completed: _completed.contains('amygdala'),
                      onTap: () => _openPlaceholder(context, 'Amygdala', 'amygdala'),
                    ),

                    // Temporallappen (Rechts Oben)
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.10,  // 5% von links (ganz links)
                      y: 0.55,  // 28% von oben
                      label: 'Wald der\nKlänge\n(Temporal)',
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

                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.30,  // 65% von links (eher rechts)
                      y: 0.35,  // 28% von oben
                      label: '(Kleinhirn)',
                      id: 'kleinhirn',
                      completed: _completed.contains('temporal'),
                      onTap: () async {
                        final completed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const TemporalLobeFlow()),
                        );
                        if (completed == true) _markCompleted('temporal');
                      },
                    ),

                    // Hippocampus (Rechts Unten)
                    _brainMapSignResponsive(
                      width: width, height: height,
                      x: 0.75,  // 55% von links
                      y: 0.75,  // 65% von oben
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
          // TOP BAR (Statisch darüber)
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
          // BOTTOM BAR (Statisch darunter)
          // ------------------------------------------------
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                  color: _paperColor,
                  border: Border(top: BorderSide(color: _inkColor, width: 2)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _navItem(Icons.home_outlined, "Start"),
                    _navItem(Icons.map, "Karte", isActive: true),
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7C4A5),
                        shape: BoxShape.circle,
                        border: Border.all(color: _inkColor, width: 2),
                      ),
                      child: Icon(Icons.hiking, color: _inkColor, size: 30),
                    ),
                    _navItem(Icons.menu_book_outlined, "Sammelbuch"),
                    _navItem(Icons.person_outline, "Profil"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper für die Icons oben
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

  Widget _navItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? _inkColor : Colors.grey[600], size: 26),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? _inkColor : Colors.grey[600],
          ),
        )
      ],
    );
  }

  // --- RESPONSIVE WIDGET ---
  Widget _brainMapSignResponsive({
    required double width,    // Die Gesamtbreite der Karte
    required double height,   // Die Gesamthöhe der Karte
    required double x,        // Prozent Horizontal (0.0 bis 1.0)
    required double y,        // Prozent Vertikal (0.0 bis 1.0)
    required String label,
    required String id,
    required bool completed,
    required VoidCallback onTap,
  }) {
    return Positioned(
      // Berechnung: Gesamtbreite * Prozentwert = Pixelposition
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
                  width: 80, // Feste Größe des Schildes
                  height: 60,
                  fit: BoxFit.contain,
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
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("Platzhalter für $title")),
    )));
  }
}