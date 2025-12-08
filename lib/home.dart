import 'dart:ui';
// import 'package:brainjourney/temporallobe.dart'; // Deinen Import hier einkommentieren
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Platzhalter für den Flow
class TemporalLobeFlow extends StatelessWidget {
  const TemporalLobeFlow({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Temporallappen Flow")),
      body: Center(
        child: ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Level abschließen")),
      ),
    );
  }
}

class BrainMapScreen extends StatefulWidget {
  const BrainMapScreen({super.key});

  @override
  State<BrainMapScreen> createState() => _BrainMapScreenState();
}

class _BrainMapScreenState extends State<BrainMapScreen> {
  final Set<String> _completed = {};
  late SharedPreferences _prefs;
  bool _loading = true;

  // Design-Farben
  final Color _inkColor = const Color(0xFF3E2723);
  final Color _paperColor = const Color(0xFFFDFBD4); // Das Beige für den Hintergrund

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
      // 1. BEIGER HINTERGRUND FÜR DEN GANZEN SCREEN
      backgroundColor: _paperColor,

      body: Stack(
        children: [

          // ------------------------------------------------
          // 2. DAS KARTEN-BILD (Eingepasst zwischen die Leisten)
          // ------------------------------------------------
          Positioned(
            // Wir lassen oben Platz für die TopBar und unten Platz für die BottomBar
            top: 40,
            bottom: 90, // Die BottomBar ist 90 hoch, wir lassen 10px Luft -> Karte endet darüber
            left: 15,    // Kleiner Rand links
            right: 15,   // Kleiner Rand rechts
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Fallback Hintergrund
                // Schatten, damit die Karte sich vom beigen Hintergrund abhebt

                // Optional: Ecken leicht abrunden für Papier-Look
                // borderRadius: BorderRadius.circular(2),
              ),
              child: Image.asset(
                'assets/images/MapBackground.png',
                fit: BoxFit.fill, // Zerrt das Bild auf die verfügbare Größe
              ),
            ),
          ),

          // ------------------------------------------------
          // 3. ORTE / BUTTONS
          // (Positionen liegen "über" der Karte)
          // ------------------------------------------------

          // Lichtung der Vernunft (PFC)
          _brainMapSign(
            left: 120, top: 150,
            label: 'Lichtung der\nVernunft\n(PFC)',
            id: 'pfc',
            completed: _completed.contains('pfc'),
            onTap: () => _openPlaceholder(context, 'Präfrontaler Cortex', 'pfc'),
          ),

          // Höhle der Gefühle (Amygdala)
          _brainMapSign(
            left: 30, top: 330,
            label: 'Höhle der\nGefühle\n(Amygdala)',
            id: 'amygdala',
            completed: _completed.contains('amygdala'),
            onTap: () => _openPlaceholder(context, 'Amygdala', 'amygdala'),
          ),

          // Temporallappen
          _brainMapSign(
            left: 230, top: 230,
            label: 'Wald der\nKlänge\n(Temporal)',
            id: 'temporal',
            completed: _completed.contains('temporal'),
            onTap: () async {
              final completed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const TemporalLobeFlow()),
              );
              if (completed == true) {
                _markCompleted('temporal');
              }
            },
          ),

          // Pfad der Erinnerung (Hippocampus)
          _brainMapSign(
            left: 200, top: 450,
            label: 'Pfad der\nErinnerung',
            id: 'hippocampus',
            completed: _completed.contains('hippocampus'),
            onTap: () => _openPlaceholder(context, 'Hippocampus', 'hippocampus'),
          ),

          // ------------------------------------------------
          // 4. TOP BAR (Oben fixiert)
          // ------------------------------------------------
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Linkes Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _inkColor, width: 2),
                        color: _paperColor, // Füllt den Kreis beige
                      ),
                      child: Icon(Icons.hiking, color: _inkColor, size: 20),
                    ),

                    // Titel
                    Text(
                      'Gehirnkarte',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _inkColor,
                        letterSpacing: 1.0,
                      ),
                    ),

                    // Rechtes Icon
                    Icon(Icons.settings, color: _inkColor, size: 28),
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------
          // 5. BOTTOM BAR (Unten fixiert)
          // ------------------------------------------------
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                  color: _paperColor, // Gleiches Beige wie Hintergrund
                  border: Border(
                    top: BorderSide(color: _inkColor, width: 2),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                  ]
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _navItem(Icons.home_outlined, "Start"),
                    _navItem(Icons.map, "Karte", isActive: true),

                    // Zentraler Button
                    Container(
                      width: 50,
                      height: 50,
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

  Widget _navItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? _inkColor : Colors.grey[600],
          size: 26,
        ),
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

  Widget _brainMapSign({
    required double left,
    required double top,
    required String label,
    required String id,
    required bool completed,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      top: top,
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
                  width: 80,
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
                  fontFamily: 'Serif',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.1,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _openPlaceholder(BuildContext ctx, String title, String id) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFFFdfBF7),
          appBar: AppBar(
            title: Text(title, style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF3F9067),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 200, width: 200,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                            image: AssetImage('assets/images/brain.webp'),
                            fit: BoxFit.cover
                        )
                    ),
                    child: const Icon(Icons.psychology, size: 80, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Dieser Bereich ist noch verschlossen.',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F9067),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _markCompleted(id);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Test: Als erledigt markieren'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}