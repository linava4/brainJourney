import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:brainjourney/home.dart'; // Pfad ggf. anpassen
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'helpers.dart';

// MAIN FLOW FÜR KLEINHIRN
class CerebellumFlow extends StatelessWidget {
  const CerebellumFlow({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigator für internen Flow
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const CerebellumIntro()),
    );
  }
}




// 1. INTRO SCREEN
class CerebellumIntro extends StatefulWidget {
  const CerebellumIntro({super.key});

  @override
  State<CerebellumIntro> createState() => _CerebellumIntroState();
}

class _CerebellumIntroState extends State<CerebellumIntro> {
  int textStep = 0;

  // Erklärungstexte
  final List<String> explanationText = [
    "Welcome to the Cerebellum!",
    "It might be small, but it's mighty! It controls your balance.",
    "Every move you make is fine-tuned right here.",
    "Without the cerebellum, you'd stagger like a sailor in a storm.",
    "Show us how good your reflexes are!"
  ];

  // Prüft ob Erklärungsphase vorbei
  bool get isTaskPhase => textStep == explanationText.length;

  // Nächster Textschritt
  void nextStep() {
    setState(() {
      if (textStep < explanationText.length) {
        textStep++;
      }
    });
  }

  // Spiel starten
  void startGame() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const BalancingGame()));
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
          // Hintergrundbild
          Positioned.fill(
            child: Image.asset(
              "assets/images/WaterBackground.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // Papierrolle Inhalt
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
          // Holzschild oben
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
                            isTaskPhase ? "The Challenge:" : "Brain Region:",
                            style: handStyle.copyWith(fontSize: 18, color: const Color(0xFF3E2723)),
                          ),
                          Text(
                            isTaskPhase ? "Balancing Act" : "Cerebellum",
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
                text: isTaskPhase ? "Let's go!" : "Next",
                onPressed: isTaskPhase ? startGame : nextStep,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget für Text-Erklärung
  Widget _buildExplanationContent(TextStyle handStyle) {
    return Column(
      key: ValueKey<int>(textStep),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
            'assets/images/brainPointing.png',
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

  // Widget für Spiel-Instruktion
  Widget _buildTaskContent(TextStyle handStyle) {
    return Column(
      key: const ValueKey<String>("task"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Keep your balance!",
          textAlign: TextAlign.center,
          style: handStyle.copyWith(fontSize: 18, height: 1.3),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Icon(Icons.touch_app, size: 40, color: Colors.brown),
                Text("Left", style: handStyle.copyWith(fontSize: 14)),
              ],
            ),
            Container(height: 50, width: 2, color: Colors.brown),
            Column(
              children: [
                const Icon(Icons.touch_app, size: 40, color: Colors.brown),
                Text("Right", style: handStyle.copyWith(fontSize: 14)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Don't fall into the water!",
          textAlign: TextAlign.center,
          style: handStyle.copyWith(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

// 2. DAS BALANCIER-SPIEL
class BalancingGame extends StatefulWidget {
  const BalancingGame({super.key});

  @override
  State<BalancingGame> createState() => _BalancingGameState();
}

class _BalancingGameState extends State<BalancingGame> with SingleTickerProviderStateMixin {
  double _tiltAngle = 0.0;
  double _velocity = 0.0;
  double _progress = 0.0;
  bool _gameActive = true;
  late Ticker _ticker;

  // Physik Parameter
  final double _gravity = 0.005;
  final double _pushStrength = 0.08;
  final double _friction = 0.05;
  final double _maxTilt = 0.9;
  final double _speed = 0.0005;

  final math.Random _rng = math.Random();
  double _windForce = 0.0;

  @override
  void initState() {
    super.initState();
    // Ticker für Game Loop
    _ticker = createTicker(_gameLoop)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // Hauptberechnung Spielmechanik
  void _gameLoop(Duration elapsed) {
    if (!_gameActive) return;

    setState(() {
      // Wind-Zufall
      if (_rng.nextDouble() < 0.02) {
        _windForce = (_rng.nextDouble() - 0.5) * 0.02;
      }

      // Winkel-Physik
      double instability = _tiltAngle * _gravity;
      _velocity += instability + _windForce;
      _tiltAngle += _velocity;

      // Dämpfung
      _velocity *= _friction;

      // Fortschrittsbalken
      _progress += _speed;

      // Sieg/Niederlage Prüfung
      if (_progress >= 1.0) {
        _gameWin();
      }
      if (_tiltAngle.abs() > _maxTilt) {
        _gameOver();
      }
    });
  }

  // Steuerung Links
  void _onTapLeft() {
    if (!_gameActive) return;
    setState(() {
      _velocity -= _pushStrength;
    });
  }

  // Steuerung Rechts
  void _onTapRight() {
    if (!_gameActive) return;
    setState(() {
      _velocity += _pushStrength;
    });
  }

  // Verloren Dialog
  void _gameOver() {
    _gameActive = false;
    _ticker.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.only(top: 170, left: 20, right: 20, bottom: 20),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/paperRoll.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Splash!",
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Balance lost.\nTry again!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    WoodButton(
                      text: "Restart",
                      onPressed: () {
                        Navigator.pop(ctx);
                        _restartGame();
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 30,
                child: SizedBox(
                  width: 130,
                  height: 150,
                  child: Image.asset(
                    'assets/images/brainThinking.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Sieg Übergang
  void _gameWin() {
    _gameActive = false;
    _ticker.stop();
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CerebellumGlitchScene()));
    });
  }

  // Werte zurücksetzen
  void _restartGame() {
    setState(() {
      _tiltAngle = 0.0;
      _velocity = 0.0;
      _progress = 0.0;
      _gameActive = true;
    });
    _ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown[900], size: 40,),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BrainMapScreen()),
            );
          },
        ),
        title: Text("Balancing Game", style: TextStyle(color: Colors.brown[900], fontWeight: FontWeight.bold, fontSize: 28, fontFamily: 'Courier')),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/WaterBackground.jpg",
              fit: BoxFit.cover,
            ),
          ),
          // Balancierender Avatar
          Positioned(
            bottom: 300,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                angle: _tiltAngle * (math.pi / 2),
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  "assets/images/brainBalancing.png",
                  width: 180,
                  height: 180,
                ),
              ),
            ),
          ),
          // Touch-Steuerung
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _onTapLeft,
                  child: Container(color: Colors.transparent),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _onTapRight,
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),
          // Fortschritt
          Positioned(
            top: 60,
            left: 40,
            right: 40,
            child: Column(
              children: [
                SizedBox(
                  height: 25,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF81C784)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 3. DIAGNOSE SCENE
class CerebellumGlitchScene extends StatefulWidget {
  const CerebellumGlitchScene({super.key});

  @override
  State<CerebellumGlitchScene> createState() => _CerebellumGlitchSceneState();
}

class _CerebellumGlitchSceneState extends State<CerebellumGlitchScene> {
  // Info-Texte zur Störung
  final List<String> dialogAfterGlitch = [
    "That was close! Did you notice the swaying?",
    "When the cerebellum is impaired, it's called 'Ataxia'.",
    "People with ataxia struggle to perform fluid movements.",
    "They often appear drunk, even when they aren't (unsteady gait).",
    "Precise reaching or walking straight becomes a huge challenge."
  ];

  int dialogIndex = 0;
  bool showGlitchEffect = true;

  @override
  void initState() {
    super.initState();
    // Kurzer Glitch-Effekt am Anfang
    Future.delayed(const Duration(seconds: 2), () {
      if(mounted) {
        setState(() {
          showGlitchEffect = false;
        });
      }
    });
  }

  // Dialog-Navigation
  void nextDialog() {
    setState(() {
      if (dialogIndex < dialogAfterGlitch.length - 1) {
        dialogIndex++;
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CerebellumEndScreen())
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

    // Glitch-Screen Darstellung
    if (showGlitchEffect) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            children: [
              Image.asset("assets/images/WaterBackground.jpg", fit: BoxFit.cover, color: Colors.red.withOpacity(0.6), colorBlendMode: BlendMode.modulate),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 0),
                child: Container(color: Colors.transparent),
              ),
              const Center(
                child: Text(
                    "CONNECTION INTERRUPTED...",
                    style: TextStyle(color: Colors.white, fontFamily: 'Courier', fontSize: 30, letterSpacing: 5)
                ),
              )
            ],
          ),
        ),
      );
    }

    // Diagnose Screen Darstellung
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
                          'assets/images/brainBalancing.png',
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
                            "The Disorder:",
                            style: handStyle.copyWith(fontSize: 18, color: const Color(0xFF3E2723)),
                          ),
                          Text(
                            "Ataxia",
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
                text: (dialogIndex == dialogAfterGlitch.length - 1) ? "To Map" : "Next",
                onPressed: nextDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// END SCREEN
class CerebellumEndScreen extends StatelessWidget {
  const CerebellumEndScreen({super.key});

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
                          "Cerebellum Quest Complete!",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723), fontFamily: 'Courier'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Ready for the next brain region?",
                          style: TextStyle(fontSize: 20, color: Color(0xFF3E2723), fontFamily: 'Courier'),
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
                        "Success!",
                        style: handStyle.copyWith(fontSize: 28, color: const Color(0xFF3E2723), fontWeight: FontWeight.w900),
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
                text: "To Map",
                onPressed: () {
                  // Zurück zur Karte
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