import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:brainjourney/home.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

// ------------------------------------------------------
// MAIN FLOW / ROUTER
// ------------------------------------------------------
class TemporalLobeFlow extends StatelessWidget {
  const TemporalLobeFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const TemporalLobeIntro()),
    );
  }
}

// ------------------------------------------------------
// HELPER WIDGET: WOOD BUTTON (Planks.png)
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
        padding: const EdgeInsets.only(bottom: 5), // Text optisch mittig auf dem Holz
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723), // Dunkelbraun
            fontFamily: 'Courier',
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// INTRO SCREEN
// ------------------------------------------------------
class TemporalLobeIntro extends StatefulWidget {
  const TemporalLobeIntro({super.key});

  @override
  State<TemporalLobeIntro> createState() => _TemporalLobeIntroState();
}

class _TemporalLobeIntroState extends State<TemporalLobeIntro> {
  int textStep = 0;

  final List<String> explanationText = [
    "Das ist der Temporallappen, der coole Alleskönner in deinem Kopf.",
    "Er verarbeitet Geräusche, Musik und hilft dir, Sprache zu verstehen.",
    "Er speichert neue Erinnerungen.",
    "Er erkennt Gesichter, Gegenstände und Wörter.",
    "Zeit, seine Wort-Such-Skills zu testen!"
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => const WordSearchGame()));
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
          // 1. HINTERGRUND
          Positioned.fill(
            child: Image.asset(
              "assets/images/WoodBackground.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // 3. GROSSE PAPIERROLLE (Mitte)
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

          // 4. SCHILD (Oben drauf) - DYNAMISCHE BREITE (70%)
          Positioned(
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7, // 70% der Breite
                height: 120, // Höhe fixiert, damit es gut aussieht
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                        "assets/images/woodPlank.png",
                        width: double.infinity, // Füllt die 70% Box
                        fit: BoxFit.fill // Streckt das Holz auf die Box
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0), // TEXT NACH UNTEN GESCHOBEN
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isTaskPhase ? "Wort-Suchspiel:" : "Die Gehirn-Region:",
                            style: handStyle.copyWith(fontSize: 18, color: const Color(0xFF3E2723)),
                          ),
                          Text(
                            isTaskPhase ? "Die Aufgabe" : "Temporallappen",
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

          // 6. ACTION BUTTON - JETZT MITTIG & PLANKS DESIGN
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
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
            'assets/images/braintemporallobe1.png',
            height: 180,
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
          "Finde aus den Buchstaben eines Wortes so viele neue Wörter wie möglich!",
          textAlign: TextAlign.center,
          style: handStyle.copyWith(fontSize: 18, height: 1.3),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.brown[900]!, width: 3))
          ),
          child: Text(
            "VERSTANDEN",
            style: handStyle.copyWith(fontSize: 32, letterSpacing: 2),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildArrowWord("STAND", -0.3, handStyle),
            _buildArrowWord("TEE", 0, handStyle),
            _buildArrowWord("SAND", 0.3, handStyle),
          ],
        ),
      ],
    );
  }

  Widget _buildArrowWord(String word, double rotation, TextStyle style) {
    return Column(
      children: [
        Transform.rotate(
          angle: rotation,
          child: Icon(Icons.arrow_downward, size: 40, color: Colors.brown[800]),
        ),
        const SizedBox(height: 5),
        Text(
          word,
          style: style.copyWith(fontSize: 20),
        ),
      ],
    );
  }
}

// ------------------------------------------------------
// WORT-SUCHSPIEL
// ------------------------------------------------------
class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key});

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  static const int _timerDurationSeconds = 5 * 60;
  late Timer _timer;
  int _timeRemaining = _timerDurationSeconds;
  bool _gameActive = true;
  bool _showGiveUpButton = false;
  bool _showContinueButton = false;

  final String baseWord = "VERSTANDEN";
  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final Set<String> foundWords = {};

  final Set<String> validWords = {
    "verstand", "anders", "tarnen", "stranden", "tanne", "adern", "strand",
    "rasten", "stand", "teer", "ader", "rest", "rede", "rast", "rand", "rasen",
    "raten", "reste", "erst", "erste", "ersten", "reden", "sterne", "stern",
    "vater", "sand", "ende", "dran", "erde", "nest", "nester", "nerv", "seen",
    "dann", "anden", "denn", "senden", "vers", "verse", "nerven", "star",
    "rate", "see", "ast", "art", "arten", "ernten", "ernte", "tee", "rat",
    "den", "der", "das", "an", "er", "da"
  };

  String feedback = "";

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
          if (_timeRemaining == 0) {
            _timer.cancel();
            _giveUpOrTimeOut(isTimeout: true);
          } else if (_timeRemaining <= _timerDurationSeconds - 5 * 60) {
            _showGiveUpButton = true;
          }
        }
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _giveUpOrTimeOut({required bool isTimeout}) {
    if (!_gameActive) return;
    _timer.cancel();
    _gameActive = false;
    setState(() {
      if (isTimeout) {
        feedback = "Die Zeit ist abgelaufen!";
        _timeRemaining = 0;
      } else {
        feedback = "Hier sind die fehlenden Wörter.";
      }
      _showContinueButton = true;
    });
    _focusNode.unfocus();
  }

  void _continueToGlitch() {
    final list = validWords.toList();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PreGlitchDialog(foundWords: list)),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void checkWordFromInput(String input) {
    if (!_gameActive) return;
    final w = input.trim().toLowerCase();
    _focusNode.requestFocus();
    if (w.isEmpty) return;

    if (validWords.contains(w) && !foundWords.contains(w)) {
      setState(() {
        foundWords.add(w);
        feedback = "✔️ korrekt!";
      });
      if (foundWords.length == validWords.length) {
        _timer.cancel();
        _gameActive = false;
        _continueToGlitch();
        return;
      }
    } else if (foundWords.contains(w)) {
      setState(() => feedback = "✔️ bereits gefunden");
    } else {
      setState(() => feedback = "❌ nicht gültig");
    }
    controller.clear();
  }

  void checkWord() {
    checkWordFromInput(controller.text);
  }

  Set<String> _getMissingWords() {
    return validWords.difference(foundWords);
  }

  @override
  Widget build(BuildContext context) {
    final Set<String> missingWords = _getMissingWords();

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown[900], size: 40,),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BrainMapScreen()),
            );
          },
        ),
        title: Text("Wort-Suchspiel", style: TextStyle(color: Colors.brown[900], fontWeight: FontWeight.bold, fontSize: 28, fontFamily: 'Cursive')),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/WoodBackground.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 60.0, 12.0, 12.0),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/PaperBackground.png"),
                    fit: BoxFit.fill,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 280,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/woodPlank.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                alignment: const Alignment(0.0, 0.6),
                child: Text(
                  _gameActive
                      ? "Verbleibende Zeit: ${_formatTime(_timeRemaining)}"
                      : "Zeit abgelaufen!",
                  style: woodTextStyle.copyWith(fontSize: 20),
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/Planks.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Aus dem Wort: $baseWord",
                                  style: woodTextStyle.copyWith(fontSize: 22),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Finde so viele neue Wörter wie möglich!",
                                  style: woodTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.normal),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          Container(
                            height: 55,
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFDF5E6),
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: Colors.brown, width: 2),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2,2))
                                ]
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    focusNode: _focusNode,
                                    enabled: _gameActive,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => checkWord(),
                                    style: const TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      hintText: _gameActive ? "Wort..." : "Ende",
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.only(bottom: 5),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.black54),
                                  onPressed: _gameActive ? checkWord : null,
                                  padding: EdgeInsets.zero,
                                ),
                                if (_gameActive)
                                  IconButton(
                                    icon: const Icon(Icons.check_circle, color: Colors.green),
                                    onPressed: checkWord,
                                    padding: EdgeInsets.zero,
                                  ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 0),
                            child: Text(
                              feedback,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.brown[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.40,
                                  width: double.infinity,
                                  child: Image.asset(
                                    "assets/images/paperRoll.png",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(40, 75, 40, 40),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Gefundene Wörter: (${foundWords.length}/${validWords.length})",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87
                                          ),
                                        ),
                                        const Divider(color: Colors.black54, height: 10),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Text(
                                                  foundWords.isEmpty ? "..." : foundWords.join(', '),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black87,
                                                    fontStyle: FontStyle.italic,
                                                    height: 1.4,
                                                  ),
                                                ),
                                                if (!_gameActive && missingWords.isNotEmpty) ...[
                                                  const SizedBox(height: 15),
                                                  const Text(
                                                    "Fehlende Wörter:",
                                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
                                                  ),
                                                  Text(
                                                    missingWords.join(', '),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontSize: 13, color: Colors.red),
                                                  ),
                                                ]
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 10,
            right: 10,
            child: Image.asset(
              "assets/images/brainDetective.png",
              width: 120,
            ),
          ),

          // --- WEITER BUTTON (Overlay bei Spielende) ---
          if (_showContinueButton)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: WoodButton(
                  text: "Weiter",
                  onPressed: _continueToGlitch,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------
// PRE-GLITCH DIALOG
// ------------------------------------------------------
class PreGlitchDialog extends StatelessWidget {
  final List<String> foundWords;
  const PreGlitchDialog({super.key, required this.foundWords});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Hmm...'), backgroundColor: const Color(0xFF3F9067), foregroundColor: Colors.white,),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/braintemporallobe1.png', errorBuilder: (c,o,s) => const Icon(Icons.psychology, size: 80, color: Colors.green)),
              const Text(
                "Super! Du hast alle Wörter gefunden!",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "Aber… warte… irgendwas stimmt nicht…",
                style: TextStyle(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Button mittig und Planks
              WoodButton(
                text: "Oh oh…",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TemporalLobeGlitchScene(foundWords: foundWords),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// GLITCH SCENE (MONOLOG NUN IM INTRO-STYLE)
// ------------------------------------------------------
class _WordData {
  final Offset pos;
  final double baseAngle;
  final double phase;
  final int colorIndex;
  final double scale;

  _WordData({
    required this.pos,
    required this.baseAngle,
    required this.phase,
    required this.colorIndex,
    required this.scale,
  });
}

class TemporalLobeGlitchScene extends StatefulWidget {
  final List<String> foundWords;

  const TemporalLobeGlitchScene({super.key, required this.foundWords});

  @override
  _TemporalLobeGlitchSceneState createState() => _TemporalLobeGlitchSceneState();
}

class _TemporalLobeGlitchSceneState extends State<TemporalLobeGlitchScene>
    with SingleTickerProviderStateMixin {
  bool glitchActive = true;
  AnimationController? _controller;
  List<_WordData>? wordData;
  late final List<String> words;

  final List<String> dialogAfterGlitch = [
    "Bei Schizophrenie habe ich Empfangsstörungen:",
    "Ich verarbeite Geräusche – aber das Gehirn erzeugt falsche Töne (Halluzinationen).",
    "Auch die Realität verschwimmt, und neue Informationen zu speichern wird schwer.",
    "Mit Hilfe kann das Signal wieder klarer werden.",
  ];

  int dialogIndex = 0;
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    words = widget.foundWords.isNotEmpty ? List.from(widget.foundWords) : ["..."];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateWordData();
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat();

      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        _controller?.stop();
        setState(() {
          glitchActive = false;
        });
      });
    });
  }

  void _generateWordData() {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 40;
    final maxX = size.width * 0.42;
    final maxY = size.height * 0.36;
    final r = _rand;

    final list = List<_WordData>.generate(words.length, (i) {
      final rx = (r.nextDouble() * 2 - 1) * maxX;
      final ry = (r.nextDouble() * 2 - 1) * maxY;
      final pos = Offset(centerX + rx, centerY + ry);
      final baseAngle = (r.nextDouble() - 0.5) * 0.6;
      final phase = r.nextDouble() * 2 * math.pi;
      final colorIndex = i % Colors.primaries.length;
      final scale = 0.9 + r.nextDouble() * 0.4;
      return _WordData(pos: pos, baseAngle: baseAngle, phase: phase, colorIndex: colorIndex, scale: scale);
    });

    wordData = list;
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void nextDialog() {
    setState(() {
      if (dialogIndex < dialogAfterGlitch.length - 1) {
        dialogIndex++;
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TemporalLobeEndScreen()));
      }
    });
  }

  Widget _glitchText(String text, TextStyle baseStyle, double offsetX, double offsetY, Color color) {
    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: Text(text, style: baseStyle.copyWith(color: color, shadows: const [])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = wordData != null && wordData!.length == words.length;

    // Wenn Glitch aktiv ist: Zeige Glitch-Screen
    if (glitchActive) {
      return Scaffold(
        backgroundColor: const Color(0xFF3F9067).withOpacity(0.1),
        body: Stack(
          children: [
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                child: Container(color: const Color(0xFF3F9067).withOpacity(0.1)),
              ),
            ),
            if (ready)
              LayoutBuilder(builder: (_, constraints) {
                final count = math.min(words.length, wordData!.length);
                return Stack(
                  children: [
                    for (int i = 0; i < count; i++)
                      AnimatedBuilder(
                        animation: _controller ?? const AlwaysStoppedAnimation(0),
                        builder: (_, __) {
                          final d = wordData![i];
                          final animVal = (_controller?.value ?? 0) * 2 * math.pi;
                          final wobble = math.sin(animVal + d.phase) * 8;
                          final rot = d.baseAngle + math.sin(animVal * 0.9 + d.phase) * 0.15;
                          final dxR = math.sin(animVal * 1.3 + d.phase) * 3.5;
                          final dyG = math.cos(animVal * 1.1 + d.phase) * 2.5;
                          final left = (d.pos.dx + dxR).clamp(8.0, constraints.maxWidth - 80.0);
                          final top = (d.pos.dy + wobble).clamp(60.0, constraints.maxHeight - 80.0);

                          final baseStyle = TextStyle(
                            fontSize: 26 * d.scale,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(blurRadius: 6, color: Colors.black.withOpacity(0.25))],
                          );

                          return Positioned(
                            left: left,
                            top: top,
                            child: Transform.rotate(
                              angle: rot,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  _glitchText(words[i], baseStyle, -dxR, 0, Colors.blue.withOpacity(0.9)),
                                  _glitchText(words[i], baseStyle, dxR, -dyG, Colors.red.withOpacity(0.85)),
                                  _glitchText(words[i], baseStyle, 0, dyG * 0.6, Colors.green.withOpacity(0.7)),
                                  Text(words[i], style: baseStyle.copyWith(color: Colors.white.withOpacity(0.95)))
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              })
            else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    // --- MONOLOG IM GLEICHEN STIL WIE DAS INTRO ---
    else {
      final TextStyle handStyle = TextStyle(
        fontFamily: 'Courier',
        color: Colors.brown[900],
        fontWeight: FontWeight.bold,
      );

      return Scaffold(
        body: Stack(
          children: [
            // 1. Hintergrund
            Positioned.fill(
              child: Image.asset(
                "assets/images/WoodBackground.jpg",
                fit: BoxFit.cover,
              ),
            ),

            // 2. Papierrolle Mitte
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                margin: const EdgeInsets.only(top: 80),
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
                              'assets/images/braintemporallobe1.png',
                              height: 180,
                              fit: BoxFit.contain,
                              errorBuilder: (c, o, s) => const Icon(Icons.psychology, size: 100, color: Colors.green)
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

            // 3. Schild Oben (Dynamisch 70%)
            Positioned(
              top: 40, left: 0, right: 0,
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset("assets/images/woodPlank.png", width: double.infinity, fit: BoxFit.fill),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Die Diagnose:",
                              style: handStyle.copyWith(fontSize: 18, color: const Color(0xFF3E2723)),
                            ),
                            Text(
                              "Schizophrenie",
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

            // 4. Brain Avatar
            Positioned(
              bottom: 10,
              left: 10,
              child: Image.asset("assets/images/brainPointing.png", width: 180),
            ),

            // 5. Button Mittig
            Positioned(
              bottom: 30,
              left: 0, right: 0,
              child: Center(
                child: WoodButton(
                  text: "Weiter",
                  onPressed: nextDialog,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

// ------------------------------------------------------
// END SCREEN
// ------------------------------------------------------
class TemporalLobeEndScreen extends StatelessWidget {
  const TemporalLobeEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auch der Endscreen wird an den Style angepasst
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFDF5E6),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)]
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Temporallappen-Quest abgeschlossen!",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Bereit für die nächste Gehirnregion?",
                        style: TextStyle(fontSize: 20, color: Color(0xFF3E2723)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                WoodButton(
                  text: "Zur Karte",
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop(true);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}