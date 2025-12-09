import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:brainjourney/home.dart'; // Pfad ggf. anpassen
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

// ------------------------------------------------------
// MAIN FLOW / ROUTER FÜR KLEINHIRN
// ------------------------------------------------------
class CerebellumFlow extends StatelessWidget {
  const CerebellumFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const CerebellumIntro()),
    );
  }
}

// ------------------------------------------------------
// HELPER WIDGET: WOOD BUTTON
// ------------------------------------------------------
class WoodButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const WoodButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 220,
        height: 70,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Planks.png"),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
            fontFamily: 'Courier',
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// HELPER WIDGET: WOOD BUTTON
// ------------------------------------------------------
class WoodButtonWide extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const WoodButtonWide({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 320,
        height: 70,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Planks.png"),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
            fontFamily: 'Courier',
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// 1. INTRO SCREEN
// ------------------------------------------------------
class CerebellumIntro extends StatefulWidget {
  const CerebellumIntro({super.key});

  @override
  State<CerebellumIntro> createState() => _CerebellumIntroState();
}

class _CerebellumIntroState extends State<CerebellumIntro> {
  int textStep = 0;

  final List<String> explanationText = [
    "Willkommen im Kleinhirn (Cerebellum)!",
    "Es ist zwar klein, aber oho! Es steuert deine Balance.",
    "Jede Bewegung, die du machst, wird hier fein abgestimmt.",
    "Ohne das Kleinhirn würdest du torkeln wie ein Seemann bei Sturm.",
    "Zeig uns, wie gut deine Reflexe sind!"
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
          Positioned.fill(
            child: Image.asset(
              "assets/images/WaterBackground.jpg",
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
                            isTaskPhase ? "Der Balance-Akt" : "Kleinhirn",
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
          // 5. BRAIN AVATAR
          Positioned(
            bottom: 40,
            left: 5,
            child: Image.asset("assets/images/brainPointing.png", width: 180),
          ),
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: Center(
              child: WoodButton(
                text: isTaskPhase ? "Los geht's!" : "Weiter",
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
            'assets/images/brainBalancing.png',
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
          "Halte die Balance!",
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
                Text("Links", style: handStyle.copyWith(fontSize: 14)),
              ],
            ),
            Container(height: 50, width: 2, color: Colors.brown),
            Column(
              children: [
                const Icon(Icons.touch_app, size: 40, color: Colors.brown),
                Text("Rechts", style: handStyle.copyWith(fontSize: 14)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Nicht ins Wasser fallen!",
          textAlign: TextAlign.center,
          style: handStyle.copyWith(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

// ------------------------------------------------------
// 2. DAS BALANCIER-SPIEL (NOCHMALS VEREINFACHT)
// ------------------------------------------------------
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

  // --- NEUE PHYSIK EINSTELLUNGEN ( EINFACH) ---
  final double _gravity = 0.005;     // Sehr geringe Schwerkraft
  final double _pushStrength = 0.08; // Starker Push zum Korrigieren
  final double _friction = 0.05;      // Hohe Reibung (bremst Bewegung stark ab)
  final double _maxTilt = 0.9;        // Viel Toleranz bevor man fällt
  final double _speed = 0.0005;       // Schnellerer Fortschritt (Spiel dauert kürzer)

  final math.Random _rng = math.Random();
  double _windForce = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_gameLoop)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _gameLoop(Duration elapsed) {
    if (!_gameActive) return;

    setState(() {
      // Sehr sanfter Wind
      if (_rng.nextDouble() < 0.02) {
        _windForce = (_rng.nextDouble() - 0.5) * 0.02;
      }

      // Physik Berechnung
      double instability = _tiltAngle * _gravity;
      _velocity += instability + _windForce;

      // Update Winkel
      _tiltAngle += _velocity;

      // Reibung anwenden (Das ist der Schlüssel zur Stabilisierung)
      _velocity *= _friction;

      // Fortschritt
      _progress += _speed;

      if (_progress >= 1.0) {
        _gameWin();
      }

      if (_tiltAngle.abs() > _maxTilt) {
        _gameOver();
      }
    });
  }

  void _onTapLeft() {
    if (!_gameActive) return;
    setState(() {
      _velocity -= _pushStrength;
    });
  }

  void _onTapRight() {
    if (!_gameActive) return;
    setState(() {
      _velocity += _pushStrength;
    });
  }

  void _gameOver() {
    _gameActive = false;
    _ticker.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent, // Wichtig: Transparent, damit wir die Form des Papiers sehen
          elevation: 0, // Kein Standardschatten, falls das Papier einen eigenen Schatten hat
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // 1. Der Hintergrund (Papierrolle)
              Container(
                width: MediaQuery.of(context).size.width *0.7,
                height: MediaQuery.of(context).size.height *0.6,
                padding: const EdgeInsets.only(
                    top: 170, // Platz für den Avatar oben lassen
                    left: 20,
                    right: 20,
                    bottom: 20
                ),

                decoration: BoxDecoration(
                  // Falls das Papier abgerundete Ecken hat, hier anpassen:
                  // borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: AssetImage('assets/images/paperRoll.png'), // Dein Hintergrundbild
                    fit: BoxFit.fill, // Oder BoxFit.cover, je nach Bildformat
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Dialog passt sich dem Inhalt an
                  children: [
                    // Titel
                    const Text(
                      "Platsch!",
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Inhaltstext
                    const Text(
                      "Gleichgewicht verloren.\nVersuch es noch einmal!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Der Holz-Button (Custom Widget)
                    WoodButton(
                      text: "Neustart", // Ich nehme an, dein Widget nimmt Text entgegen
                      onPressed: () {
                        Navigator.pop(ctx);
                        _restartGame();
                      },
                    ),
                  ],
                ),
              ),

              // 2. Der Avatar (Brain), der oben "herausschaut"
              Positioned(
                top: 30,
                left: 125,
                child: Container(
                  width: 130, // Größe anpassen
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

  void _gameWin() {
    _gameActive = false;
    _ticker.stop();
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CerebellumGlitchScene()));
    });
  }

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
        title: Text("Balance-Spiel", style: TextStyle(color: Colors.brown[900], fontWeight: FontWeight.bold, fontSize: 28, fontFamily: 'Cursive')),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Hintergrund (Füllt den ganzen Screen)
          Positioned.fill(
            child: Image.asset(
              "assets/images/WaterBackground.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // 2. Avatar (Brain) - Ohne Holzbalken
          Positioned(
            bottom: 330, // Etwas vom Boden weg, damit es nicht am Rand klebt
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                angle: _tiltAngle * (math.pi / 2),
                alignment: Alignment.bottomCenter, // Dreht sich um die Füße
                child: Image.asset(
                  "assets/images/brainBalancing.png",
                  width: 180, // Etwas größer
                  height: 180,
                ),
              ),
            ),
          ),

          // 3. Touch Zonen (Unsichtbar über dem ganzen Screen)
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

          // 4. Fortschrittsbalken
          Positioned(
            top: 60,
            left: 40,
            right: 40,
            child: Column(
              children: [
                // Balken
                SizedBox(
                  height: 25,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.white24, // Leicht transparent weiß im Hintergrund
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

// ------------------------------------------------------
// 3. GLITCH / DIAGNOSE SCENE
// ------------------------------------------------------
class CerebellumGlitchScene extends StatefulWidget {
  const CerebellumGlitchScene({super.key});

  @override
  State<CerebellumGlitchScene> createState() => _CerebellumGlitchSceneState();
}

class _CerebellumGlitchSceneState extends State<CerebellumGlitchScene> {
  final List<String> dialogAfterGlitch = [
    "Das war knapp! Hast du das Schwanken bemerkt?",
    "Wenn das Kleinhirn gestört ist, nennt man das 'Ataxie'.",
    "Menschen mit Ataxie haben Probleme, Bewegungen flüssig auszuführen.",
    "Sie wirken oft betrunken, obwohl sie es nicht sind (Schwankschwindel).",
    "Präzises Greifen oder gerade Gehen wird zur großen Herausforderung."
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
            MaterialPageRoute(builder: (context) => CerebellumEndScreen())
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
              Image.asset("assets/images/WaterBackground.jpg", fit: BoxFit.cover, color: Colors.red.withOpacity(0.6), colorBlendMode: BlendMode.modulate),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 0),
                child: Container(color: Colors.transparent),
              ),
              const Center(
                child: Text(
                    "VERBINDUNG GESTÖRT...",
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
                            "Die Störung:",
                            style: handStyle.copyWith(fontSize: 18, color: const Color(0xFF3E2723)),
                          ),
                          Text(
                            "Ataxie",
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
                          "Kleinhirn-Quest abgeschlossen!",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3E2723), fontFamily: 'Courier'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Bereit für die nächste Gehirnregion?",
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
                        "Geschafft!",
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
                text: "Zur Karte",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BrainMapScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}