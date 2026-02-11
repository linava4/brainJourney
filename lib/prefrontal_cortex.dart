import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart'; // Für BrainMapScreen
import 'cerebellum.dart'; // Für WoodButton

// ------------------------------------------------------
// MAIN FLOW / ROUTER
// ------------------------------------------------------
class PrefrontalFlow extends StatelessWidget {
  const PrefrontalFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const PrefrontalIntro()),
    );
  }
}

// ------------------------------------------------------
// 1. INTRO SCREEN
// ------------------------------------------------------
class PrefrontalIntro extends StatefulWidget {
  const PrefrontalIntro({super.key});

  @override
  State<PrefrontalIntro> createState() => _PrefrontalIntroState();
}

class _PrefrontalIntroState extends State<PrefrontalIntro> {
  int textStep = 0;

  final List<String> explanationText = [
    "Willkommen im Präfrontalen Cortex!",
    "Das ist das Chef-Büro deines Gehirns.",
    "Hier werden Pläne geschmiedet, Impulse kontrolliert und Entscheidungen getroffen.",
    "Er ist der Dirigent, der das Orchester deiner Gedanken leitet.",
    "Zeig uns, wie gut du dich konzentrieren kannst!"
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrefrontalGame()));
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
                            isTaskPhase ? "Die Aufgabe:" : "Die Gehirn-Region:",
                            style: handStyle.copyWith(fontSize: 18, color: const Color(0xFF3E2723)),
                          ),
                          Text(
                            isTaskPhase ? "Farb-Code" : "Präfrontaler Cortex",
                            style: handStyle.copyWith(fontSize: 22, color: const Color(0xFF3E2723), fontWeight: FontWeight.w900),
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
            'assets/images/brainMain.png', // "Brain Main" passt gut zum Chef
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
          "Merke dir die Sequenz!",
          textAlign: TextAlign.center,
          style: handStyle.copyWith(fontSize: 18, height: 1.3),
        ),
        const SizedBox(height: 20),
        const Icon(Icons.traffic, size: 60, color: Colors.brown),
        const SizedBox(height: 20),
        Text(
          "Beobachte die Lichter und tippe sie in der gleichen Reihenfolge nach.",
          textAlign: TextAlign.center,
          style: handStyle.copyWith(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

// ------------------------------------------------------
// 2. DAS SPIEL (SIMON SAYS / SEQUENZ)
// ------------------------------------------------------
class PrefrontalGame extends StatefulWidget {
  const PrefrontalGame({super.key});

  @override
  State<PrefrontalGame> createState() => _PrefrontalGameState();
}

class _PrefrontalGameState extends State<PrefrontalGame> {
  final List<Color> _colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow];
  
  List<int> _sequence = []; 
  int _currentStep = 0; 
  bool _isPlayerTurn = false;
  int? _activeLightIndex; 
  
  String _statusText = "Achtung...";
  int _level = 1;
  final int _maxLevels = 5; // Ziel: 5 Runden schaffen

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), _startNextRound);
  }

  void _startNextRound() async {
    setState(() {
      _isPlayerTurn = false;
      _statusText = "Beobachte...";
      _currentStep = 0;
      // Neue Farbe zur Sequenz hinzufügen
      _sequence.add(Random().nextInt(4));
    });

    // Sequenz abspielen
    for (int index in _sequence) {
      await Future.delayed(const Duration(milliseconds: 500)); 
      if (!mounted) return;
      
      setState(() => _activeLightIndex = index);
      
      await Future.delayed(const Duration(milliseconds: 600)); 
      if (!mounted) return;
      
      setState(() => _activeLightIndex = null);
    }

    setState(() {
      _statusText = "Du bist dran!";
      _isPlayerTurn = true;
    });
  }

  void _onButtonTap(int index) {
    if (!_isPlayerTurn) return;

    // Feedback (kurzes Aufleuchten)
    setState(() => _activeLightIndex = index);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _activeLightIndex = null);
    });

    if (index == _sequence[_currentStep]) {
      // Richtig!
      _currentStep++;
      if (_currentStep >= _sequence.length) {
        // Runde geschafft
        if (_level >= _maxLevels) {
          _gameWin();
        } else {
          setState(() {
            _level++;
            _statusText = "Gut gemacht!";
            _isPlayerTurn = false;
          });
          Future.delayed(const Duration(seconds: 1), _startNextRound);
        }
      }
    } else {
      // Falsch!
      _handleGameOver();
    }
  }

  void _handleGameOver() {
     setState(() {
       _statusText = "Falsch! Neustart...";
       _sequence.clear();
       _level = 1;
       _isPlayerTurn = false;
     });
     Future.delayed(const Duration(seconds: 2), _startNextRound);
  }

  void _gameWin() {
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PrefrontalGlitchScene()));
    });
  }

  void _restartFull() {
    setState(() {
      _sequence.clear();
      _level = 1;
      _isPlayerTurn = false;
      _statusText = "Bereit...";
    });
    Future.delayed(const Duration(seconds: 1), _startNextRound);
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
        title: Text("Farb-Sequenz", style: TextStyle(color: Colors.brown[900], fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'Courier')),
        centerTitle: true,
        // RESTART BUTTON
        actions: [
           Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(Icons.refresh, color: Colors.brown[900], size: 35),
              onPressed: _restartFull,
              tooltip: "Neustart",
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/WoodBackground.jpg",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Status Panel
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.brown, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text("Level $_level / $_maxLevels", style: headerStyle),
                      const SizedBox(height: 5),
                      Text(_statusText, style: headerStyle.copyWith(color: Colors.brown[900], fontSize: 22)),
                    ],
                  ),
                ),

                const Spacer(),

                // Die 4 Buttons im Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(4, (index) {
                      return GestureDetector(
                        onTapDown: (_) => _onButtonTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            // Wenn aktiv: Volle Farbe + Leuchten. Wenn inaktiv: Transparent/Dunkel
                            color: (_activeLightIndex == index) 
                                ? _colors[index] 
                                : _colors[index].withOpacity(0.3), 
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.brown[800]!, width: 4),
                            boxShadow: (_activeLightIndex == index) 
                              ? [BoxShadow(color: _colors[index], blurRadius: 30, spreadRadius: 5)]
                              : [const BoxShadow(color: Colors.black26, offset: Offset(2,2), blurRadius: 2)],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const Spacer(),
                const SizedBox(height: 40),
              ],
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
class PrefrontalGlitchScene extends StatefulWidget {
  const PrefrontalGlitchScene({super.key});

  @override
  State<PrefrontalGlitchScene> createState() => _PrefrontalGlitchSceneState();
}

class _PrefrontalGlitchSceneState extends State<PrefrontalGlitchScene> {
  final List<String> dialogAfterGlitch = [
    "Das erforderte viel Konzentration!",
    "Bei ADHS sind die Botenstoffe (Dopamin) hier oft zu niedrig.",
    "Der 'Dirigent' wird müde und das Orchester spielt durcheinander.",
    "Ablenkungen können nicht mehr ausgeblendet werden (Reizüberflutung).",
    "Das Planen und Dranbleiben wird extrem anstrengend.",
    "Aber: Unser Gehirn ist plastisch – man kann den Fokus trainieren!"
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
            MaterialPageRoute(builder: (context) => const PrefrontalEndScreen())
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
              Image.asset("assets/images/MapBackground.png", fit: BoxFit.cover, color: Colors.green.withOpacity(0.6), colorBlendMode: BlendMode.modulate),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 0),
                child: Container(color: Colors.transparent),
              ),
              const Center(
                child: Text(
                    "SIGNAL VERLOREN...",
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
                            "ADHS", // oder Reizfilter
                            style: handStyle.copyWith(fontSize: 26, color: Colors.green[900], fontWeight: FontWeight.w900),
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
class PrefrontalEndScreen extends StatelessWidget {
  const PrefrontalEndScreen({super.key});

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
                          "Fokus wiederhergestellt!",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3E2723), fontFamily: 'Courier'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Der Dirigent hat das Orchester wieder fest im Griff.",
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