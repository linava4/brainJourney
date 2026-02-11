import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart'; // Pfad ggf. anpassen (für BrainMapScreen)
import 'cerebellum.dart'; // Wir nutzen den WoodButton von hier wieder

// ------------------------------------------------------
// MAIN FLOW / ROUTER FÜR HIPPOCAMPUS
// ------------------------------------------------------
class HippocampusFlow extends StatelessWidget {
  const HippocampusFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const HippocampusIntro()),
    );
  }
}

// ------------------------------------------------------
// 1. INTRO SCREEN
// ------------------------------------------------------
class HippocampusIntro extends StatefulWidget {
  const HippocampusIntro({super.key});

  @override
  State<HippocampusIntro> createState() => _HippocampusIntroState();
}

class _HippocampusIntroState extends State<HippocampusIntro> {
  int textStep = 0;

  final List<String> explanationText = [
    "Willkommen im Hippocampus!",
    "Das ist die Bibliothek deines Gehirns.",
    "Hier werden Erinnerungen sortiert und abgelegt.",
    "Ohne ihn wüsstest du nicht, was du gestern gegessen hast.",
    "Zeig uns, wie gut dein Arbeitsgedächtnis funktioniert!"
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGame()));
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
              "assets/images/WoodBackground.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // Papierrolle Container
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
                            isTaskPhase ? "Die Herausforderung:" : "Die Gehirn-Region:",
                            style: handStyle.copyWith(fontSize: 18, color: const Color(0xFF3E2723)),
                          ),
                          Text(
                            isTaskPhase ? "Merk dir alles!" : "Hippocampus",
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
          // Button unten
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
            'assets/images/brainCard.png',
            height: 160,
            fit: BoxFit.contain,
            errorBuilder: (c, o, s) => const Icon(Icons.psychology, size: 100, color: Colors.green)
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
          "Finde alle Paare!",
          textAlign: TextAlign.center,
          style: handStyle.copyWith(fontSize: 18, height: 1.3),
        ),
        const SizedBox(height: 20),
        const Icon(Icons.grid_view, size: 60, color: Colors.brown),
        const SizedBox(height: 20),
        Text(
          "Decke die Karten auf und merke dir die Positionen.",
          textAlign: TextAlign.center,
          style: handStyle.copyWith(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

// ------------------------------------------------------
// 2. DAS MEMORY SPIEL (Optimiertes Layout)
// ------------------------------------------------------
class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  // --- SPIEL LOGIK ---
  static const int _gridSizeX = 4;
  static const int _gridSizeY = 4; // 16 Karten = 8 Paare
  
  static const List<IconData> _iconOptions = [
    Icons.star, Icons.ac_unit, Icons.cake, Icons.cloud, 
    Icons.lightbulb, Icons.headphones, Icons.eco, Icons.anchor
  ];

  late List<int> _cardValues;
  late List<bool> _cardFlips;
  late Set<int> _solvedIndices;
  
  int? _firstFlipIndex;
  bool _isProcessing = false;
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final List<int> baseValues = List.generate(_iconOptions.length, (index) => index)
      ..addAll(List.generate(_iconOptions.length, (index) => index));
    baseValues.shuffle(Random());

    setState(() {
      _cardValues = baseValues;
      _cardFlips = List.generate(_gridSizeX * _gridSizeY, (index) => false);
      _solvedIndices = {};
      _firstFlipIndex = null;
      _isProcessing = false;
      _moves = 0;
    });
  }

  void _onCardTap(int index) async {
    if (_cardFlips[index] || _isProcessing || _solvedIndices.contains(index)) return;

    setState(() {
      _cardFlips[index] = true;
      _moves++;
    });

    if (_firstFlipIndex == null) {
      _firstFlipIndex = index;
    } else {
      _isProcessing = true;
      final firstIndex = _firstFlipIndex!;
      
      await Future.delayed(const Duration(milliseconds: 800));

      if (_cardValues[firstIndex] == _cardValues[index]) {
        setState(() {
          _solvedIndices.add(firstIndex);
          _solvedIndices.add(index);
        });
        
        if (_solvedIndices.length == _cardValues.length) {
          _gameWin();
        }
      } else {
        setState(() {
          _cardFlips[firstIndex] = false;
          _cardFlips[index] = false;
        });
      }

      setState(() {
        _firstFlipIndex = null;
        _isProcessing = false;
      });
    }
  }

  void _gameWin() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HippocampusGlitchScene()));
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
        title: Text("Memory", style: TextStyle(color: Colors.brown[900], fontWeight: FontWeight.bold, fontSize: 28, fontFamily: 'Courier')),
        centerTitle: true,
        // --- HIER IST DER NEUE BUTTON OBEN RECHTS ---
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(Icons.refresh, color: Colors.brown[900], size: 35),
              onPressed: _initializeGame,
              tooltip: "Neues Spiel",
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // 1. Hintergrund
          Positioned.fill(
            child: Image.asset("assets/images/WoodBackground.jpg", fit: BoxFit.cover),
          ),

          // 2. Inhalt in einer Column (verhindert Überlappen)
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                
                // Info-Panel (Züge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.brown, width: 2),
                  ),
                  child: Text("Züge: $_moves", style: headerStyle),
                ),

                const SizedBox(height: 10),

                // Das Spielfeld - nutzt den verfügbaren Platz optimal
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _gridSizeX / _gridSizeY, // Das Verhältnis halten
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(), // Scrollt nicht
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _gridSizeX,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: _gridSizeX * _gridSizeY,
                          itemBuilder: (context, index) => _buildCard(index),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Unten etwas Abstand lassen
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    bool isSolved = _solvedIndices.contains(index);
    bool isFlipped = _cardFlips[index];
    IconData icon = _iconOptions[_cardValues[index]];

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: (isFlipped || isSolved) 
              ? (isSolved ? Colors.green[200] : const Color(0xFFFDF5E6)) 
              : const Color(0xFF8D6E63),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown[900]!, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(2, 2))],
        ),
        child: Center(
          child: (isFlipped || isSolved)
              ? Icon(icon, size: 32, color: isSolved ? Colors.green[900] : Colors.brown[900])
              : Text('?', style: TextStyle(color: Colors.brown[900], fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// 3. GLITCH / DIAGNOSE SCENE
// ------------------------------------------------------
class HippocampusGlitchScene extends StatefulWidget {
  const HippocampusGlitchScene({super.key});

  @override
  State<HippocampusGlitchScene> createState() => _HippocampusGlitchSceneState();
}

class _HippocampusGlitchSceneState extends State<HippocampusGlitchScene> {
  final List<String> dialogAfterGlitch = [
    "Puh, das war viel Arbeit für den Speicher!",
    "Wenn wir gestresst sind, schüttet der Körper Cortisol aus.",
    "Zu viel Cortisol wirkt wie Gift für den Hippocampus.",
    "Er kann dann keine neuen Informationen mehr speichern.",
    "Das fühlt sich an wie ein Blackout in einer Prüfung.",
    "Aber: Entspannung und Schlaf reparieren den Speicher wieder!"
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
            MaterialPageRoute(builder: (context) => const HippocampusEndScreen())
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
              Image.asset("assets/images/MapBackground.png", fit: BoxFit.cover, color: Colors.purple.withOpacity(0.6), colorBlendMode: BlendMode.modulate),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 0),
                child: Container(color: Colors.transparent),
              ),
              const Center(
                child: Text(
                    "SPEICHER ÜBERLASTET...",
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
                            "Die Störung:",
                            style: handStyle.copyWith(fontSize: 18, color: const Color(0xFF3E2723)),
                          ),
                          Text(
                            "Blackout",
                            style: handStyle.copyWith(fontSize: 26, color: Colors.purple[900], fontWeight: FontWeight.w900),
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
class HippocampusEndScreen extends StatelessWidget {
  const HippocampusEndScreen({super.key});

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
                          "Erinnerung gesichert!",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723), fontFamily: 'Courier'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Du hast deinen Hippocampus erfolgreich trainiert.",
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
                        "Level Complete!",
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