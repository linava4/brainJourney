import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart'; // Für BrainMapScreen
import 'cerebellum.dart'; // Für WoodButton

// ------------------------------------------------------
// MAIN FLOW / ROUTER FÜR HIPPOCAMPUS
// ------------------------------------------------------
class HippocampusFlow extends StatelessWidget {
  const HippocampusFlow({super.key});

  @override
  Widget build(BuildContext context) {
    // Ein eigener Navigator, um den Flow zu steuern
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
    "Willkommen im Hippocampus, dem Pfad der Erinnerung!",
    "Der Hippocampus ist wie die Bibliothek deines Gehirns: Er speichert neue Informationen ab.",
    "Er ist entscheidend, um dir zu merken, wann und wo etwas passiert ist.",
    "Nur wenn du die Informationen wieder abrufst, werden sie dauerhaft gespeichert.",
    "Zeig uns, wie gut dein Arbeitsgedächtnis funktioniert!"
  ];

  bool get isTaskPhase => textStep == explanationText.length;

  void nextStep() {
    setState(() {
      if (textStep < explanationText.length) {
        textStep++;
      } else {
        startGame();
      }
    });
  }

  void startGame() {
    // Startet das Memory-Spiel
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
          Positioned.fill(
            child: Image.asset(
              "assets/images/WoodBackground.jpg",
              fit: BoxFit.cover,
            ),
          ),
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
                            isTaskPhase ? "Das Gedächtnis" : "Hippocampus",
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
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: Center(
              child: WoodButton(
                text: isTaskPhase ? "Los geht's!" : "Weiter",
                onPressed: nextStep,
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
        // Wiederverwendung eines Gehirn-Assets für die Intro-Szene
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
          "Finde die passenden Paare!",
          textAlign: TextAlign.center,
          style: handStyle.copyWith(fontSize: 18, height: 1.3),
        ),
        const SizedBox(height: 20),
        const Icon(Icons.dashboard, size: 80, color: Colors.brown),
        const SizedBox(height: 20),
        Text(
          "Wie schnell kannst du alle Gedächtnis-Paare freilegen?",
          textAlign: TextAlign.center,
          style: handStyle.copyWith(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

// ------------------------------------------------------
// 2. DAS MEMORY SPIEL
// ------------------------------------------------------
class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  // 3x4 Grid (6 Paare)
  static const int _gridSizeX = 4;
  static const int _gridSizeY = 3;
  static const List<IconData> _iconOptions = [
    Icons.star, Icons.ac_unit, Icons.cake, Icons.cloud, Icons.lightbulb, Icons.headphones,
  ];

  late List<int> _cardValues;
  late List<bool> _cardFlips;
  int? _firstFlipIndex;
  int _matchedPairs = 0;
  bool _isProcessing = false;
  int _moves = 0; // Zähler für die Züge

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Erstelle doppelte Werte für 6 Paare (0, 0, 1, 1, ...)
    final List<int> baseValues = List.generate(_iconOptions.length, (index) => index)
      ..addAll(List.generate(_iconOptions.length, (index) => index));

    // Mische die Werte
    baseValues.shuffle(Random());

    setState(() {
      _cardValues = baseValues;
      _cardFlips = List.generate(_gridSizeX * _gridSizeY, (index) => false);
      _firstFlipIndex = null;
      _matchedPairs = 0;
      _isProcessing = false;
      _moves = 0;
    });
  }

  void _onCardTap(int index) async {
    if (_cardFlips[index] || _isProcessing) return;

    setState(() {
      _cardFlips[index] = true;
      _moves++;
    });

    if (_firstFlipIndex == null) {
      // Erster Klick
      _firstFlipIndex = index;
    } else {
      // Zweiter Klick
      _isProcessing = true;
      await Future.delayed(const Duration(milliseconds: 800));

      final firstValue = _cardValues[_firstFlipIndex!];
      final secondValue = _cardValues[index];

      if (firstValue == secondValue) {
        // MATCH!
        _matchedPairs++;
        if (_matchedPairs == _iconOptions.length) {
          _gameWin();
        }
      } else {
        // NO MATCH -> Karten zurückdrehen
        setState(() {
          _cardFlips[_firstFlipIndex!] = false;
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
    // Gehe zur Glitch-Szene
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HippocampusGlitchScene(moves: _moves)));
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle woodTextStyle = TextStyle(
      color: Color(0xFF3E2723),
      fontWeight: FontWeight.bold,
      fontSize: 18,
      fontFamily: "Courier",
    );

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        // Zurück zur Karte
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown[900], size: 40,),
          onPressed: () {
            Navigator.of(context).pop(); // Geht zurück zum Intro/Flow-Start
          },
        ),
        title: Text("Memory-Spiel", style: TextStyle(color: Colors.brown[900], fontWeight: FontWeight.bold, fontSize: 28, fontFamily: 'Courier')),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Hintergrund
          Positioned.fill(
            child: Image.asset(
              "assets/images/WoodBackground.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // 2. Header (Score/Moves)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
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
                          Text("Züge: $_moves", style: woodTextStyle.copyWith(fontSize: 20)),
                          Text("Paare: $_matchedPairs / ${_iconOptions.length}", style: woodTextStyle.copyWith(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Das Grid
          Center(
            child: AspectRatio(
              aspectRatio: _gridSizeX / _gridSizeY,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.brown[700],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.brown[900]!, width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(5, 5))],
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _gridSizeX,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: _gridSizeX * _gridSizeY,
                  itemBuilder: (context, index) {
                    return _buildCard(index);
                  },
                ),
              ),
            ),
          ),

          // 4. Neustart Button
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: Center(
              child: WoodButton(
                text: "Neues Spiel",
                onPressed: _initializeGame,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    bool isFlipped = _cardFlips[index];
    IconData icon = _iconOptions[_cardValues[index]];
    bool isMatchCandidate = _firstFlipIndex == index;

    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Einfache Skalierung als Flip-Effekt
          return ScaleTransition(scale: animation, child: child);
        },
        child: isFlipped
            ? _buildCardFront(icon, index, isMatchCandidate)
            : _buildCardBack(index),
      ),
    );
  }

  Widget _buildCardFront(IconData icon, int index, bool isMatchCandidate) {
    // Überprüft, ob das Paar bereits gefunden wurde (beide Karten aufgedeckt und nicht der aktuelle Kandidat)
    bool isMatched = _cardFlips[index] && !isMatchCandidate && _cardValues.where((val) => val == _cardValues[index]).length == 2;

    return Container(
      key: ValueKey<bool>(true),
      decoration: BoxDecoration(
        color: isMatched ? Colors.green[200] : const Color(0xFFFDF5E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown[800]!, width: 2),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 40,
          color: isMatched ? Colors.green[800] : Colors.brown[900],
        ),
      ),
    );
  }

  Widget _buildCardBack(int index) {
    return Container(
      key: ValueKey<bool>(false),
      decoration: BoxDecoration(
        color: const Color(0xFFBCAAA4), // Dunkle Holzfarbe
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown[900]!, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Colors.brown[900],
            fontSize: 30,
            fontWeight: FontWeight.w900,
            fontFamily: 'Courier',
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// 3. GLITCH / DIAGNOSE SCENE
// ------------------------------------------------------
class HippocampusGlitchScene extends StatefulWidget {
  final int moves;
  const HippocampusGlitchScene({super.key, required this.moves});

  @override
  State<HippocampusGlitchScene> createState() => _HippocampusGlitchSceneState();
}

class _HippocampusGlitchSceneState extends State<HippocampusGlitchScene> {
  final List<String> dialogAfterGlitch = [
    "Das war hervorragende Leistung! Dein Hippocampus arbeitet schnell.",
    "Doch was passiert, wenn diese Region nicht richtig arbeitet?",
    "Der Hippocampus ist sehr anfällig für Stresshormone wie Cortisol.",
    "Bei chronischem Stress und Depressionen kann die Region schrumpfen.",
    "Das erschwert das Speichern neuer Informationen und führt zu Gedächtnisproblemen.",
    "Die gute Nachricht: Der Hippocampus kann sich durch Lernen und Achtsamkeit erholen."
  ];

  int dialogIndex = 0;
  bool showGlitchEffect = true;

  @override
  void initState() {
    super.initState();
    // Glitch nur kurz zeigen (Simuliert kurzzeitige Störung)
    Future.delayed(const Duration(seconds: 1), () {
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
        _finishFlow(); // Gehe zum End-State (pop(true))
      }
    });
  }

  void _finishFlow() async {
    // Speichere den Score/Moves (optional)
    final prefs = await SharedPreferences.getInstance();
    final currentMoves = prefs.getInt('hippocampus_best_moves') ?? 999;
    if (widget.moves < currentMoves) {
      prefs.setInt('hippocampus_best_moves', widget.moves);
    }

    // Navigiere zurück zur BrainMapScreen und signalisiere Erfolg (true)
    // Damit markiert der home.dart die Region als abgeschlossen.
    Navigator.of(context).pop(true);
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
              // Hintergrundbild verschwommen und rot
              Positioned.fill(
                child: Image.asset("assets/images/MapBackground.png", fit: BoxFit.cover, color: Colors.purple.withOpacity(0.6), colorBlendMode: BlendMode.modulate),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.transparent),
              ),
              const Center(
                child: Text(
                    "GEDÄCHTNIS VERZERRT...",
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
                            "Die Lehre:",
                            style: handStyle.copyWith(fontSize: 18, color: const Color(0xFF3E2723)),
                          ),
                          Text(
                            "Speicherzentrale",
                            style: handStyle.copyWith(fontSize: 26, color: Colors.blue[900], fontWeight: FontWeight.w900),
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
                text: (dialogIndex == dialogAfterGlitch.length - 1) ? "Zur Karte" : "Weiter",
                onPressed: nextDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }
}