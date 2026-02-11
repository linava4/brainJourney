import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart'; // Für BrainMapScreen
import 'cerebellum.dart'; // Für WoodButton

// ------------------------------------------------------
// MAIN FLOW / ROUTER FÜR AMYGDALA
// ------------------------------------------------------
class AmygdalaFlow extends StatelessWidget {
  const AmygdalaFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const AmygdalaIntro()),
    );
  }
}

// ------------------------------------------------------
// 1. INTRO SCREEN
// ------------------------------------------------------
class AmygdalaIntro extends StatefulWidget {
  const AmygdalaIntro({super.key});

  @override
  State<AmygdalaIntro> createState() => _AmygdalaIntroState();
}

class _AmygdalaIntroState extends State<AmygdalaIntro> {
  int textStep = 0;

  final List<String> explanationText = [
    "Willkommen in der Amygdala!",
    "Sie ist der 'Rauchmelder' deines Gehirns.",
    "Ihre Aufgabe ist es, Gefahren sofort zu erkennen.",
    "Manchmal ist sie aber zu empfindlich und schlägt Fehlalarm.",
    "Deine Aufgabe: Finde alle echten Gefahren (Blitze)!"
  ];

  bool get isTaskPhase => textStep == explanationText.length;

  void nextStep() {
    setState(() {
      if (textStep < explanationText.length) {
        textStep++;
      }
    });
  }

  void startGame() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AmygdalaGame()));
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle handStyle = TextStyle(
      fontFamily: 'Courier',
      color: Colors.brown[900],
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Hintergrund
          Positioned.fill(
            child: Image.asset(
              "assets/images/WoodBackgroundNight.jpg", // Etwas dunkler für Amygdala
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) => Image.asset("assets/images/WoodBackground.jpg", fit: BoxFit.cover),
            ),
          ),
          // Papierrolle
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.65,
              margin: const EdgeInsets.only(top: 40),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: double.infinity, height: double.infinity,
                    child: Image.asset("assets/images/paperRoll.png", fit: BoxFit.fill),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 60.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isTaskPhase
                          ? _buildTaskContent(handStyle)
                          : _buildExplanationContent(handStyle),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Header Planke
          Positioned(
            left: 0, right: 0,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset("assets/images/woodPlank.png", width: double.infinity, fit: BoxFit.fill),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isTaskPhase ? "Die Mission:" : "Die Gehirn-Region:",
                            style: handStyle.copyWith(fontSize: 18, color: const Color(0xFF3E2723)),
                          ),
                          Text(
                            isTaskPhase ? "Gefahrensucher" : "Amygdala",
                            style: handStyle.copyWith(fontSize: 24, color: const Color(0xFF3E2723), fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Button
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: Center(
              child: WoodButton(
                text: isTaskPhase ? "Starten" : "Weiter",
                onPressed: isTaskPhase ? startGame : nextStep,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationContent(TextStyle handStyle) {
    return Column(
      key: ValueKey<int>(textStep),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
            'assets/images/brainDetective.png', // Detektiv passt zum Suchen
            height: 160,
            fit: BoxFit.contain,
            errorBuilder: (c, o, s) => const Icon(Icons.search, size: 100, color: Colors.brown)
        ),
        const SizedBox(height: 30),
        Text(
          explanationText[textStep],
          textAlign: TextAlign.center,
          style: handStyle.copyWith(fontSize: 20, height: 1.3),
        ),
      ],
    );
  }

  Widget _buildTaskContent(TextStyle handStyle) {
    return Column(
      key: const ValueKey<String>("task"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Finde die 8 Blitze!",
          textAlign: TextAlign.center,
          style: handStyle.copyWith(fontSize: 18, height: 1.3),
        ),
        const SizedBox(height: 20),
        const Icon(Icons.flash_on, size: 60, color: Colors.amber),
        const SizedBox(height: 20),
        Text(
          "Tippe nur auf die Gefahren. Lass dich nicht ablenken.",
          textAlign: TextAlign.center,
          style: handStyle.copyWith(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

// ------------------------------------------------------
// 2. DAS SUCHBILD SPIEL (AMYGDALA)
// ------------------------------------------------------
class AmygdalaGame extends StatefulWidget {
  const AmygdalaGame({super.key});

  @override
  State<AmygdalaGame> createState() => _AmygdalaGameState();
}

// Hilfsklasse für die Objekte auf dem Bildschirm
class _GameItem {
  final int id;
  double x; // 0.0 bis 1.0 (Prozent der Breite)
  double y; // 0.0 bis 1.0 (Prozent der Höhe)
  final bool isTarget; // Ist es ein Blitz?
  final IconData icon;
  final Color color;

  _GameItem(this.id, this.x, this.y, this.isTarget, this.icon, this.color);
}

class _AmygdalaGameState extends State<AmygdalaGame> {
  final List<_GameItem> _items = [];
  final int _totalTargets = 8; // Anzahl der zu findenden Blitze
  int _foundTargets = 0;
  
  // Ablenkungen
  final List<IconData> _distractions = [
    Icons.cloud, Icons.wb_sunny, Icons.favorite, Icons.star, Icons.pets, Icons.music_note
  ];

  @override
  void initState() {
    super.initState();
    _spawnItems();
  }

  void _spawnItems() {
    _items.clear();
    _foundTargets = 0;
    final rng = Random();

    // 1. Erzeuge die Ziele (Blitze)
    for (int i = 0; i < _totalTargets; i++) {
      _items.add(_GameItem(
        i,
        rng.nextDouble() * 0.8 + 0.1, // Randabstand halten (10% - 90%)
        rng.nextDouble() * 0.6 + 0.1, // Oben/Unten Abstand (10% - 70%)
        true,
        Icons.flash_on,
        Colors.amber,
      ));
    }

    // 2. Erzeuge Ablenkungen (ca. 10 Stück)
    for (int i = 0; i < 10; i++) {
      _items.add(_GameItem(
        i + 100,
        rng.nextDouble() * 0.8 + 0.1,
        rng.nextDouble() * 0.6 + 0.1,
        false,
        _distractions[rng.nextInt(_distractions.length)],
        Colors.white70,
      ));
    }

    // Mischen, damit die Blitze nicht zuerst gezeichnet werden (Z-Order)
    _items.shuffle(); 
    setState(() {});
  }

  void _onItemTap(_GameItem item) {
    if (item.isTarget) {
      // Treffer!
      setState(() {
        _items.remove(item); // Item verschwindet
        _foundTargets++;
      });

      if (_foundTargets >= _totalTargets) {
        _gameWin();
      }
    } else {
      // Fehlklick (Ablenkung)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Das ist keine Gefahr! Nur ein Fehlalarm."),
          duration: Duration(milliseconds: 600),
          backgroundColor: Colors.brown,
        ),
      );
    }
  }

  void _gameWin() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AmygdalaGlitchScene()));
    });
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle headerStyle = TextStyle(
      color: Color(0xFF3E2723), 
      fontWeight: FontWeight.bold, 
      fontSize: 18, 
      fontFamily: "Courier"
    );

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown[900], size: 40),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BrainMapScreen()),
            );
          },
        ),
        title: Text("Gefahren-Radar", style: TextStyle(color: Colors.brown[900], fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'Courier')),
        centerTitle: true,
        // NEUSTART BUTTON OBEN RECHTS
        actions: [
           Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(Icons.refresh, color: Colors.brown[900], size: 35),
              onPressed: _spawnItems,
              tooltip: "Neu mischen",
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // 1. Hintergrund
          Positioned.fill(
            child: Image.asset(
              "assets/images/WoodBackgroundNight.jpg", // Düsterer Hintergrund
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) => Image.asset("assets/images/WoodBackground.jpg", fit: BoxFit.cover),
            ),
          ),

          // 2. Info-Panel (Gefunden)
          Positioned(
            top: 20, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.brown, width: 2),
                ),
                child: Text("Gefunden: $_foundTargets / $_totalTargets", style: headerStyle),
              ),
            ),
          ),

          // 3. Spielfeld (Items)
          // Wir nutzen einen LayoutBuilder um die Größe zu kennen für prozentuale Positionierung
          Positioned(
            top: 80, bottom: 0, left: 0, right: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: _items.map((item) {
                    return Positioned(
                      left: item.x * constraints.maxWidth,
                      top: item.y * constraints.maxHeight,
                      child: GestureDetector(
                        onTap: () => _onItemTap(item),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            // Leichtes Leuchten für targets damit sie fair zu finden sind? Nein, Suchbild.
                            color: Colors.transparent, 
                          ),
                          child: Icon(
                            item.icon,
                            size: 40,
                            color: item.color,
                            shadows: const [Shadow(blurRadius: 5, color: Colors.black)],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------
// 3. GLITCH / DIAGNOSE SCENE
// ------------------------------------------------------
class AmygdalaGlitchScene extends StatefulWidget {
  const AmygdalaGlitchScene({super.key});

  @override
  State<AmygdalaGlitchScene> createState() => _AmygdalaGlitchSceneState();
}

class _AmygdalaGlitchSceneState extends State<AmygdalaGlitchScene> {
  final List<String> dialogAfterGlitch = [
    "Alarm beendet. Gefahr gebannt!",
    "Die Amygdala reagiert extrem schnell auf Gefahren.",
    "Das ist gut, wenn ein Säbelzahntiger vor dir steht.",
    "Bei einer Angststörung ist dieser Alarm aber zu laut.",
    "Sie feuert 'Gefahr!', obwohl du sicher bist (Fehlalarm).",
    "Mut bedeutet nicht keine Angst zu haben, sondern sie zu überwinden."
  ];

  int dialogIndex = 0;
  bool showGlitchEffect = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if(mounted) {
        setState(() {
          showGlitchEffect = false;
        });
      }
    });
  }

  void nextDialog() {
    setState(() {
      if (dialogIndex < dialogAfterGlitch.length - 1) {
        dialogIndex++;
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AmygdalaEndScreen())
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle handStyle = TextStyle(
      fontFamily: 'Courier',
      color: Colors.brown[900],
      fontWeight: FontWeight.bold,
    );

    if (showGlitchEffect) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            children: [
              Image.asset("assets/images/MapBackground.png", fit: BoxFit.cover, color: Colors.red.withOpacity(0.6), colorBlendMode: BlendMode.modulate),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 0),
                child: Container(color: Colors.transparent),
              ),
              const Center(
                child: Text(
                    "ALARM! ALARM!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontFamily: 'Courier', fontSize: 30, letterSpacing: 5)
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/WoodBackground.jpg", fit: BoxFit.cover),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.60,
              margin: const EdgeInsets.only(top: 40),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: double.infinity, height: double.infinity,
                    child: Image.asset("assets/images/paperRoll.png", fit: BoxFit.fill),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 60.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/brainThinking.png',
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          dialogAfterGlitch[dialogIndex],
                          textAlign: TextAlign.center,
                          style: handStyle.copyWith(fontSize: 20, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset("assets/images/woodPlank.png", width: double.infinity, fit: BoxFit.fill),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Die Diagnose:",
                            style: handStyle.copyWith(fontSize: 18, color: const Color(0xFF3E2723)),
                          ),
                          Text(
                            "Fehlalarm",
                            style: handStyle.copyWith(fontSize: 26, color: Colors.red[900], fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: Center(
              child: WoodButton(
                text: (dialogIndex == dialogAfterGlitch.length - 1) ? "Abschluss" : "Weiter",
                onPressed: nextDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------
// 4. END SCREEN
// ------------------------------------------------------
class AmygdalaEndScreen extends StatelessWidget {
  const AmygdalaEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle handStyle = TextStyle(
      fontFamily: 'Courier',
      color: Colors.brown[900],
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/WoodBackground.jpg", fit: BoxFit.cover),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.50,
              margin: const EdgeInsets.only(top: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: double.infinity, height: double.infinity,
                    child: Image.asset("assets/images/paperRoll.png", fit: BoxFit.fill),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 50.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Gefahr erkannt!",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723), fontFamily: 'Courier'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Du hast gelernt, echte Gefahren von Fehlalarmen zu unterscheiden.",
                          style: TextStyle(fontSize: 18, color: Color(0xFF3E2723), fontFamily: 'Courier'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset("assets/images/woodPlank.png", width: double.infinity, fit: BoxFit.fill),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Text(
                        "Mut bewiesen!",
                        style: handStyle.copyWith(fontSize: 24, color: const Color(0xFF3E2723), fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0, right: 0,
            child: Center(
              child: WoodButton(
                text: "Zur Karte",
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}