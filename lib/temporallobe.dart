import 'dart:async'; // NEU: Für den Timer
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class TemporalLobeFlow extends StatelessWidget {
  const TemporalLobeFlow({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a single route that pushes the Intro as the first page.
    // At the very end we'll call Navigator.of(context, rootNavigator: true).pop(true)
    // so the BrainMapScreen receives 'true'.
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const TemporalLobeIntro()),
    );
  }
}

// Intro
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
      appBar: AppBar(title: const Text('Temporallappen'), backgroundColor: Color(0xFF3F9067), foregroundColor: Colors.white,),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/braintemporallobe1.png'),
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
                  backgroundColor: Color(0xFF3F9067),
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
// WORT-SUCHSPIEL
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
  bool _showContinueButton = false; // Neu: "Weiter" Button nach Aufgeben/Timeout

  final String baseWord = "VERSTANDEN";
  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final Set<String> foundWords = {};

  final Set<String> validWords = {
    "verstand",
    "anders",
    "tarnen",
    "stranden",
    "tanne",
    "adern",
    "strand",
    "rasten",
    "stand",
    "teer",
    "ader",
    "rest",
    "rede",
    "rast",
    "rand",
    "rasen",
    "raten",
    "reste",
    "erst",
    "erste",
    "ersten",
    "reden",
    "sterne",
    "stern",
    "vater",
    "sand",
    "ende",
    "dran",
    "erde",
    "nest",
    "nester",
    "nerv",
    "seen",
    "dann",
    "anden",
    "denn",
    "senden",
    "vers",
    "verse",
    "nerven",
    "star",
    "rate",
    "see",
    "ast",
    "art",
    "arten",
    "ernten",
    "ernte",
    "tee",
    "rat",
    "den",
    "der",
    "das",
    "an",
    "er",
    "da"
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
          // Nach 5 Minuten (wenn _timeRemaining 0 erreicht) den Aufgeben-Button anzeigen
          if (_timeRemaining == 0) {
            _timer.cancel(); // Timer stoppen, da Zeit abgelaufen
            _giveUpOrTimeOut(isTimeout: true); // Timeout-Logik ausführen
          } else if (_timeRemaining <= _timerDurationSeconds - 5 * 60) {

            _showGiveUpButton = true;
          }
        }
      });
    });
  }

  // Hilfsmethode, um die verbleibende Zeit schön zu formatieren
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // NEU: Logik für Aufgeben oder Timeout
  void _giveUpOrTimeOut({required bool isTimeout}) {
    if (!_gameActive) return; // Nur einmal ausführen

    _timer.cancel(); // Timer stoppen
    _gameActive = false; // Spiel deaktivieren

    setState(() {
      if (isTimeout) {
        feedback = "Die Zeit ist abgelaufen!";
        _timeRemaining = 0; // Sicherstellen, dass 0:00 angezeigt wird
      } else {
        feedback = "Hier sind die fehlenden Wörter.";
      }
      _showContinueButton = true; // Weiter-Button anzeigen
    });
    // Fokus wegnehmen und Tastatur verstecken
    _focusNode.unfocus();
  }

  void _continueToGlitch() {
    // Liste der gefundenen Wörter für den nächsten Screen übergeben
    final list = validWords.toList();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PreGlitchDialog(foundWords: list)),
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // Wichtig: Timer aufräumen
    controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void checkWordFromInput(String input) {
    if (!_gameActive) return;

    final w = input.trim().toLowerCase();

    // Unabhängig davon, ob erfolgreich oder leer, Fokus zurücksetzen
    _focusNode.requestFocus();

    if (w.isEmpty) return;

    if (validWords.contains(w) && !foundWords.contains(w)) {
      setState(() {
        foundWords.add(w);
        feedback = "✔️ korrekt!";
      });

      if (foundWords.length == validWords.length) {
        // Alle Wörter gefunden -> Spiel beenden
        _timer.cancel(); // Timer stoppen
        _gameActive = false;
        _continueToGlitch(); // Direkter Übergang zum nächsten Screen
        return; // Frühzeitig beenden
      }
    } else if (foundWords.contains(w)) {
      setState(() => feedback = "✔️ bereits gefunden");
    } else {
      setState(() => feedback = "❌ nicht gültig");
    }

    // Clear Input
    controller.clear();
  }

  void checkWord() {
    checkWordFromInput(controller.text);
  }

  // NEU: Hilfsmethode, um fehlende Wörter zu finden
  Set<String> _getMissingWords() {
    return validWords.difference(foundWords);
  }

  @override
  Widget build(BuildContext context) {
    final Set<String> missingWords = _getMissingWords();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF3F9067),
        foregroundColor: Colors.white,
        title: const Text("Wort-Suchspiel"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // NEU: Timer-Anzeige
              Text(
                _gameActive ? "Verbleibende Zeit: ${_formatTime(_timeRemaining)}" : "Zeit abgelaufen!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _timeRemaining < 60 && _gameActive ? Colors.red : Color(0xFF3F9067),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Aus dem Wort: $baseWord",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Finde so viele neue Wörter wie möglich!",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              // Eingabe nur aktiv, wenn Spiel aktiv
              TextField(
                controller: controller,
                focusNode: _focusNode,
                enabled: _gameActive,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  checkWord();
                },
                decoration: InputDecoration(
                  labelText: _gameActive ? "Wort eingeben" : "Spiel beendet",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _gameActive ? checkWord : null,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(feedback, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 30),


              // Weiter-Button nach Aufgeben/Timeout
              if (_showContinueButton)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    onPressed: _continueToGlitch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3F9067),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Weiter"),
                  ),
                ),

              const SizedBox(height: 30),

              // Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Gefundene Wörter:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "(${foundWords.length}/${validWords.length})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F9067),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Gefundene Wörter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  foundWords.join(', '),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 20),

              // NEU: Fehlende Wörter anzeigen nach Aufgeben/Timeout
              if (!_gameActive && missingWords.isNotEmpty)
                Column(
                  children: [
                    const Divider(),
                    const Text(
                      "Fehlende Wörter:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        missingWords.join(', '),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// VOR-GLITCH-DIALOG ("Super...")
// ------------------------------------------------------
class PreGlitchDialog extends StatelessWidget {
  final List<String> foundWords;
  const PreGlitchDialog({super.key, required this.foundWords});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Hmm...'), backgroundColor: Color(0xFF3F9067)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/temporallobe.webp'),
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
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3F9067), foregroundColor: Colors.white),
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
// GLITCH + DIALOG SEQUENZ (maximal glitchy, stabil)
// ------------------------------------------------------

// helper class for per-word data
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

  // per-word data generated once
  List<_WordData>? wordData;

  // stable copy of words (so rebuilds can't change order)
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

    // stable copy
    words = widget.foundWords.isNotEmpty ? List.from(widget.foundWords) : ["..."];

    // generate once after first layout (we need MediaQuery size)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateWordData();

      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat();

      // stop glitch after a moment and show dialog
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
      final baseAngle = (r.nextDouble() - 0.5) * 0.6; // radians, small tilt
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
      // ✅ KORREKTUR: Die Index-Prüfung wurde korrigiert, um RangeError zu vermeiden.
      if (dialogIndex < dialogAfterGlitch.length - 1) {
        dialogIndex++;
      } else {
        // Wenn keine Dialoge mehr, navigiere zum Endbildschirm
        Navigator.push(context, MaterialPageRoute(builder: (_) => const TemporalLobeEndScreen()));
      }
    });
  }

  // small utility to draw RGB-shifted layered text for "glitch" look
  Widget _glitchText(String text, TextStyle baseStyle, double offsetX, double offsetY, Color color) {
    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: Text(text, style: baseStyle.copyWith(color: color, shadows: const [])),
    );
  }

  // scanline overlay (subtle)
  Widget _buildScanlines() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.06,
        child: Column(
          children: List.generate(40, (i) {
            return Container(
              height: 2,
              color: i % 2 == 0 ? Colors.black : Colors.transparent,
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // safety: ensure wordData has been generated and lengths match
    final ready = wordData != null && wordData!.length == words.length;

    return Scaffold(
      backgroundColor: Color(0xFF3F9067).withOpacity(0.1),
      body: Stack(
        children: [
          // blurred background while glitch is active
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: glitchActive ? 7.0 : 0.0, sigmaY: glitchActive ? 7.0 : 0.0),
              child: Container(color: Color(0xFF3F9067).withOpacity(0.1)),
            ),
          ),

          // glitch area
          if (glitchActive)
            Positioned.fill(
              child: ready
                  ? LayoutBuilder(builder: (_, constraints) {
                // ensure we never iterate past available data
                final count = math.min(words.length, wordData!.length);

                return Stack(
                  children: [
                    // for each word, draw layered colored text with animated offsets
                    for (int i = 0; i < count; i++)
                      AnimatedBuilder(
                        animation: _controller ?? const AlwaysStoppedAnimation(0),
                        builder: (_, __) {
                          final d = wordData![i];
                          final animVal = (_controller?.value ?? 0) * 2 * math.pi;
                          // wobble derived from controller + phase
                          final wobble = math.sin(animVal + d.phase) * 8;
                          // rotation slight oscillation
                          final rot = d.baseAngle + math.sin(animVal * 0.9 + d.phase) * 0.15;
                          // small RGB shifts
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
                                  // Blue layer (shifted left)
                                  _glitchText(words[i], baseStyle, -dxR, 0, Colors.blue.withOpacity(0.9)),
                                  // Red layer (shifted right & slightly up)
                                  _glitchText(words[i], baseStyle, dxR, -dyG, Colors.red.withOpacity(0.85)),
                                  // Green subtle layer (shifted down)
                                  _glitchText(words[i], baseStyle, 0, dyG * 0.6, Colors.green.withOpacity(0.7)),
                                  // top white (main) with slight blending
                                  Text(
                                    words[i],
                                    style: baseStyle.copyWith(color: Colors.white.withOpacity(0.95)),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    // optional subtle scanlines/noise overlay
                    Positioned.fill(child: _buildScanlines()),

                    // small center flicker/overlay to add depth (semi-transparent)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _controller ?? const AlwaysStoppedAnimation(0),
                          builder: (_, __) {
                            final a = 0.02 + (math.sin((_controller?.value ?? 0) * 10 * 2 * math.pi).abs() * 0.03);
                            return Container(
                              color: Colors.black.withOpacity(a),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              })
                  : const Center(child: CircularProgressIndicator()),
            )

          else
          // dialog after glitch
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Image.asset('assets/images/temporallobe.webp'),
                    ),
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
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3F9067), foregroundColor: Colors.white),
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
// END SCREEN - user returns to brain map on finish
// ------------------------------------------------------
class TemporalLobeEndScreen extends StatelessWidget {
  const TemporalLobeEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF3F9067).withOpacity(0.1),
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
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3F9067), foregroundColor: Colors.white),
              onPressed: () {
                // IMPORTANT: pop the ROOT navigator with result 'true' so BrainMapScreen receives it
                // (requires the context of the outer Navigator, usually main App)
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