import 'dart:async';
import 'dart:math';
import 'dart:ui';
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
// INTRO SCREEN
// ------------------------------------------------------
class TemporalLobeIntro extends StatefulWidget {
  const TemporalLobeIntro({super.key});

  @override
  State<TemporalLobeIntro> createState() => _TemporalLobeIntroState();
}

class _TemporalLobeIntroState extends State<TemporalLobeIntro> {
  int step = 0;

  final List<String> text = [
    "Das ist der Temporallappen, der coole Alleskönner in deinem Kopf.",
    "Er verarbeitet Geräusche, Musik und hilft dir, Sprache zu verstehen.",
    "Er speichert neue Erinnerungen.",
    "Er erkennt Gesichter, Gegenstände und Wörter.",
    "Zeit, seine Wort-Such-Skills zu testen!",
    "Los geht's!"
  ];

  void next() {
    if (step < text.length - 1) {
      setState(() => step++);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const WordSearchGame()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Temporallappen'),
        backgroundColor: const Color(0xFF3F9067),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/braintemporallobe1.png', errorBuilder: (c, o, s) => const Icon(Icons.psychology, size: 100, color: Colors.green)),
              const SizedBox(height: 24),
              Text(
                text[step],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F9067),
                  foregroundColor: Colors.white,
                ),
                child: Text(step < text.length - 1 ? "Weiter" : "Start"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// WORT-SUCHSPIEL (UPDATED DESIGN)
// ------------------------------------------------------
class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key});

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  // Timer-Variablen
  static const int _timerDurationSeconds = 5 * 60; // 5 Minuten
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

    // Style für Texte auf Holzschildern
    const TextStyle woodTextStyle = TextStyle(
      color: Color(0xFF3E2723), // Dunkelbraun
      fontWeight: FontWeight.bold,
      fontSize: 18,
      fontFamily: "Courier",
    );

    return Scaffold(
      extendBodyBehindAppBar: false, // true, damit Appbar transparent über dem Hintergrund liegt
      appBar: AppBar(
        backgroundColor: Colors.brown, // Transparent
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.brown[900], size: 40,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Wort-Suchspiel", style: TextStyle(color: Colors.brown[900], fontWeight: FontWeight.bold, fontSize: 28, fontFamily: 'Cursive')),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ------------------------------------------------
          // LAYER 1: WALD HINTERGRUND (Ganz unten)
          // ------------------------------------------------
          Positioned.fill(
            child: Image.asset(
              "assets/images/WoodBackground.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // ------------------------------------------------
          // LAYER 2: PAPIER HINTERGRUND (Darüber)
          // ------------------------------------------------
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 60.0, 12.0, 12.0), // Oben mehr Platz lassen für Holz-Look
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

          // ------------------------------------------------
          // LAYER 3: SPIEL INHALT (Ganz oben)
          // ------------------------------------------------
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      // --- ZEIT BALKEN (woodPlank.png) ---
                      Container(
                        width: 280,
                        height: 60,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/woodPlank.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                        // ÄNDERUNG: Alignment(0.0, 0.3) schiebt den Text etwas tiefer als Center
                        alignment: const Alignment(0.0, 0.6),
                        child: Text(
                          _gameActive
                              ? "Verbleibende Zeit: ${_formatTime(_timeRemaining)}"
                              : "Zeit abgelaufen!",
                          style: woodTextStyle.copyWith(fontSize: 20),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- ZIELWORT BRETT (Planks.png) ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
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

                      // --- EINGABE ---
                      // ÄNDERUNG: margin horizontal hinzugefügt, damit es schmaler ist
                      Container(
                        height: 55, // Höhe fixiert für kompakteren Look
                        margin: const EdgeInsets.symmetric(horizontal: 30), // Macht das Feld schmaler
                        decoration: BoxDecoration(
                            color: const Color(0xFFFDF5E6), // Papierfarbe
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
                                  contentPadding: const EdgeInsets.only(bottom: 5), // Text vertikal zentrieren
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



                      // --- LISTE (paperRoll.png) ---
                      // ÄNDERUNG: Padding um den Stack, damit die Rolle kleiner/schmaler wirkt
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Image.asset(
                              "assets/images/paperRoll.png",
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                            ),
                            Positioned.fill(
                              child: Padding(
                                // Padding anpassen (oben etwas mehr wegen Rolle, seitlich wegen schmaler)
                                padding: const EdgeInsets.fromLTRB(60, 75, 60, 40),
                                child: Column(
                                  children: [
                                    Text(
                                      "Gefundene Wörter: (${foundWords.length}/${validWords.length})",
                                      style: const TextStyle(
                                          fontSize: 16, // Etwas kleiner, damit es passt
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

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- AVATAR (Ganz oben, rechts unten) ---
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
              left: 20,
              child: ElevatedButton(
                onPressed: _continueToGlitch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F9067),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  elevation: 10,
                ),
                child: const Text("Weiter", style: TextStyle(fontSize: 20)),
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F9067), foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TemporalLobeGlitchScene(foundWords: foundWords),
                    ),
                  );
                },
                child: const Text("Oh oh…"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// GLITCH SCENE
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

    return Scaffold(
      backgroundColor: const Color(0xFF3F9067).withOpacity(0.1),
      body: Stack(
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: glitchActive ? 7.0 : 0.0, sigmaY: glitchActive ? 7.0 : 0.0),
              child: Container(color: const Color(0xFF3F9067).withOpacity(0.1)),
            ),
          ),
          if (glitchActive)
            Positioned.fill(
              child: ready
                  ? LayoutBuilder(builder: (_, constraints) {
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
                  : const Center(child: CircularProgressIndicator()),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/braintemporallobe1.png', errorBuilder: (c,o,s) => const SizedBox()),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                      ),
                      child: Text(
                        dialogAfterGlitch[dialogIndex],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: nextDialog,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F9067), foregroundColor: Colors.white),
                      child: const Text('Weiter'),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------
// END SCREEN
// ------------------------------------------------------
class TemporalLobeEndScreen extends StatelessWidget {
  const TemporalLobeEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3F9067).withOpacity(0.1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Temporallappen-Quest abgeschlossen!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "Bereit für die nächste Gehirnregion?",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F9067), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(true);
              },
              child: const Text("Zurück zur Gehirn-Karte"),
            ),
          ],
        ),
      ),
    );
  }
}