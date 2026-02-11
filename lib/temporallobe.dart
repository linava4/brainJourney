import 'dart:async';
import 'dart:math';
import 'dart:ui'; // ImageFilter support
import 'package:brainjourney/home.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'helpers.dart';


// MAIN FLOW / ROUTER
class TemporalLobeFlow extends StatelessWidget {
  const TemporalLobeFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const TemporalLobeIntro()),
    );
  }
}

// INTRO SCREEN
class TemporalLobeIntro extends StatefulWidget {
  const TemporalLobeIntro({super.key});

  @override
  State<TemporalLobeIntro> createState() => _TemporalLobeIntroState();
}

class _TemporalLobeIntroState extends State<TemporalLobeIntro> {
  int textStep = 0; // Textfortschritt

  final List<String> explanationText = [
    "This is the temporal lobe, the cool all-rounder in your head.",
    "It processes sounds, music, and helps you understand language.",
    "It stores new memories.",
    "It recognizes faces, objects, and words.",
    "Time to test its word-searching skills!"
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
          // 1. BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/images/WoodBackground.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // 3. PAPER ROLL (Center)
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

          // 4. SIGN (Top)
          Positioned(
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                        "assets/images/woodPlank.png",
                        width: double.infinity,
                        fit: BoxFit.fill
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isTaskPhase ? "Word search game:" : "The brain region:",
                            style: handStyle.copyWith(fontSize: 18, color: const Color(0xFF3E2723)),
                          ),
                          Text(
                            isTaskPhase ? "The task" : "Temporal Lobe",
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



          // 6. ACTION BUTTON
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: WoodButton(
                text: isTaskPhase ? "Let's go!" : "Continue",
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
            'assets/images/brainPointing.png',
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
          "Find as many new words as possible from the letters of one word!",
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
            "TEMPORAL",
            style: handStyle.copyWith(fontSize: 32, letterSpacing: 2),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildArrowWord("LAMP", 0.3, handStyle),
            _buildArrowWord("OR", 0, handStyle),
            _buildArrowWord("TEMPO", -0.3, handStyle),
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
// WORD SEARCH GAME
// ------------------------------------------------------
class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key});

  @override
  State<WordSearchGame> createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  static const int _timerDurationSeconds = 5 * 60; // 5 Minuten

  // --- GOAL DEFINITION ---
  static const int _minWordsToPass = 30;

  late Timer _timer;
  int _timeRemaining = _timerDurationSeconds;
  bool _gameActive = true;
  bool _showGiveUpButton = false;

  // Button controls
  bool _showContinueButton = false;
  bool _showRestartButton = false;

  final String baseWord = "UNDERSTAND";
  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final Set<String> foundWords = {};

  final Set<String> validWords = {
    "understand", "stunned", "unrated", "natured",

     "daunted", "unrest", "unseats", "untread"

    ,"ardent", "daunts", "dander","nature", "nurdle", "nursed", "ranted", "runted", "sanded", "snared", "stared", "strand", "sunder", "tanned", "tanner", "tensed", "traded", "treads", "trends", "truant", "turned",  "unseat"

    , "antes", "aster", "daunt", "deans", "dears", "dents", "darts", "duets", "dunes", "durst", "earns", "nears", "neats", "nerds", "nuder", "nudes", "nurse", "rants", "rated", "rates", "reads", "rends", "rents", "resat", "runes", "runts", "sated", "snare", "stand", "stare", "stead", "stern", "sudra", "tarns", "tears", "tends", "trade", "tread", "trend", "tunas", "tuned", "tuner", "tunes", "turns", "under", "unset"

    ,"ante", "ares", "arts", "dare", "dart", "dean", "dear", "dent", "drat", "dues", "duet", "dune", "duns", "dust", "earn", "ears", "east", "eats", "eras", "ern", "erns", "erst", "etna", "nard", "near", "neat", "nerd", "nest", "nets", "nude", "nuts", "rads", "rand", "rant", "rase", "rate", "rats", "read", "rend", "rent", "rest", "rets", "rude", "rued", "rues", "rune", "runs", "runt", "rust", "ruts", "sand", "sane", "sard", "sate", "sear", "seat", "send", "sent", "seta", "star", "stud", "stun", "suer", "suet", "tans", "tare", "tarn", "tear", "teas", "teds", "tend", "tens", "tern", "true", "tuna", "tune", "turd", "turn", "urea", "urns", "used", "user"

    ,"and", "ant", "are", "art", "ate", "due", "dun", "ear", "eat", "end", "era", "est", "eta", "nan", "net", "nun", "nut", "rad", "ran", "rat", "red", "rue", "run", "rut", "sad", "sat", "sea", "sen", "set", "sue", "sun", "tad", "tan", "tar", "tea", "ted", "ten", "tun", "urn", "use"

    ,"ad", "an", "as", "at", "ed", "us"};

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

    // Word check
    bool passed = foundWords.length >= _minWordsToPass;

    setState(() {
      _timeRemaining = 0;
      if (passed) {
        // PASSED
        if (isTimeout) {
          feedback = "Time's up! But target reached!";
        } else {
          feedback = "Great! Enough words found.";
        }
        _showContinueButton = true;
        _showRestartButton = false;
      } else {
        // FAILED
        feedback = "Failed! ${( _minWordsToPass - foundWords.length)} words missing.";
        _showContinueButton = false;
        _showRestartButton = true;
      }
    });
    _focusNode.unfocus();
  }

  void _restartGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WordSearchGame()),
    );
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
        feedback = "✔️ correct!";
      });
      if (foundWords.length == validWords.length) {
        _timer.cancel();
        _gameActive = false;
        _continueToGlitch();
        return;
      }
    } else if (foundWords.contains(w)) {
      setState(() => feedback = "✔️ already found");
    } else {
      setState(() => feedback = "❌ not valid");
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

    // Status color
    Color statusColor = const Color(0xFF3E2723);
    if (!_gameActive) {
      statusColor = foundWords.length >= _minWordsToPass ? Colors.green[900]! : Colors.red[900]!;
    }

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
        title: Text("Word search game", style: TextStyle(color: Colors.brown[900], fontWeight: FontWeight.bold, fontSize: 28,
            fontFamily: 'Courier')),
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
                      ? "Time: ${_formatTime(_timeRemaining)}"
                      : (foundWords.length >= _minWordsToPass ? "Success!" : "Failed!"),
                  style: woodTextStyle.copyWith(fontSize: 20, color: statusColor),
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
                                  "From the word: $baseWord",
                                  style: woodTextStyle.copyWith(fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Find at least $_minWordsToPass words!",
                                  style: woodTextStyle.copyWith(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "Found: ${foundWords.length} / ${validWords.length}",
                                  style: woodTextStyle.copyWith(fontSize: 16),
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
                                      hintText: _gameActive ? "Word..." : "End",
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
                                color: (!_gameActive && foundWords.length < _minWordsToPass) ? Colors.red : Colors.brown[900],
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
                                          "Found: ${foundWords.length} / ${validWords.length}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: foundWords.length >= _minWordsToPass ? Colors.green[800] : Colors.black87
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
                                                    "Missing words:",
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

          // --- Buttons ---
          if (_showContinueButton)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: WoodButton(
                  text: "Continue",
                  onPressed: _continueToGlitch,
                ),
              ),
            ),

          if (_showRestartButton)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: WoodButton(
                  text: "Retry",
                  onPressed: _restartGame,
                ),
              ),
            ),

          if (_gameActive && _showGiveUpButton)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: WoodButton(
                  text: "Done / Give up",
                  onPressed: () => _giveUpOrTimeOut(isTimeout: false),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// PRE-GLITCH DIALOG
class PreGlitchDialog extends StatelessWidget {
  final List<String> foundWords;
  const PreGlitchDialog({super.key, required this.foundWords});

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
                        Image.asset('assets/images/brainThinking.png',
                            height: 140,
                            fit: BoxFit.contain,
                            errorBuilder: (c,o,s) => const Icon(Icons.psychology, size: 80, color: Colors.green)
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Super! You found many words!",
                          style: handStyle.copyWith(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "But… wait… something's not right…",
                          style: handStyle.copyWith(fontSize: 18, color: Colors.red[900]),
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
                      child: Text(
                        "Hmm...",
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
                text: "Oh oh…",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TemporalLobeGlitchScene(foundWords: foundWords),
                    ),
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

// GLITCH SCENE
class _WordData {
  final Offset pos;
  final double baseAngle;
  final double phase;
  final double scale;

  _WordData({
    required this.pos,
    required this.baseAngle,
    required this.phase,
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
    "With Schizophrenia, I have reception interference:",
    "I process sounds – but the brain creates false tones (hallucinations).",
    "Reality also blurs, and storing new information becomes difficult.",
    "With help, the signal can become clear again.",
  ];

  int dialogIndex = 0;
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    words = widget.foundWords.isNotEmpty ? List.from(widget.foundWords) : ["..."];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateWordData();

      // Floating animation
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat(reverse: true);

      // Duration until diagnosis
      Future.delayed(const Duration(seconds: 5), () {
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
    final maxX = size.width * 0.45;
    final maxY = size.height * 0.40;
    final r = _rand;

    final list = List<_WordData>.generate(words.length, (i) {
      final rx = (r.nextDouble() * 2 - 1) * maxX;
      final ry = (r.nextDouble() * 2 - 1) * maxY;
      final pos = Offset(centerX + rx, centerY + ry);
      final baseAngle = (r.nextDouble() - 0.5) * 0.3;
      final phase = r.nextDouble() * 2 * math.pi;
      final scale = 0.8 + r.nextDouble() * 0.5;
      return _WordData(pos: pos, baseAngle: baseAngle, phase: phase, scale: scale);
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TemporalLobeEndScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ready = wordData != null && wordData!.length == words.length;

    // Blury SCENE
    if (glitchActive) {
      return Scaffold(
        body: Stack(
          children: [
            // 1. Background
            Positioned.fill(
              child: Image.asset(
                "assets/images/WoodBackground.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Opacity(
                opacity: 0.4,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.65,
                  margin: const EdgeInsets.only(top: 40),
                  child: Image.asset("assets/images/paperRoll.png", fit: BoxFit.fill),
                ),
              ),
            ),

            // 2. Backdrop Blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: Container(color: Colors.white.withOpacity(0.1)),
              ),
            ),

            // 3. Floating words
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
                          final animVal = _controller!.value;
                          final sine = math.sin((animVal * 2 * math.pi) + d.phase);

                          final wobbleX = math.cos(animVal * math.pi + d.phase) * 15;
                          final wobbleY = math.sin(animVal * math.pi + d.phase) * 15;
                          final rot = d.baseAngle + (sine * 0.1);

                          final left = (d.pos.dx + wobbleX).clamp(20.0, constraints.maxWidth - 100.0);
                          final top = (d.pos.dy + wobbleY).clamp(80.0, constraints.maxHeight - 100.0);

                          final blurAmount = (sine.abs() * 3.0) + 0.5;
                          final opacity = 0.5 + (sine.abs() * 0.5);

                          final baseStyle = TextStyle(
                            fontSize: 28 * d.scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(opacity),
                            fontFamily: 'Courier',
                          );

                          return Positioned(
                            left: left,
                            top: top,
                            child: Transform.rotate(
                              angle: rot,
                              child: Stack(
                                children: [
                                  // Ghost layer
                                  Transform.translate(
                                    offset: Offset(sine * 5, sine * 5),
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(sigmaX: blurAmount + 2, sigmaY: blurAmount + 2),
                                      child: Text(words[i], style: baseStyle.copyWith(color: Colors.brown.withOpacity(0.4))),
                                    ),
                                  ),
                                  // Main word
                                  ImageFiltered(
                                    imageFilter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
                                    child: Text(words[i], style: baseStyle),
                                  ),
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

    // --- MONOLOGUE / DIAGNOSIS ---
    else {
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                              'assets/images/brainThinking.png',
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
                            Text("The diagnosis:", style: handStyle.copyWith(fontSize: 18, color: const Color(0xFF3E2723))),
                            Text("Schizophrenia", style: handStyle.copyWith(fontSize: 24, color: const Color(0xFF3E2723), fontWeight: FontWeight.w900)),
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
                  text: "Continue",
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

// END SCREEN
class TemporalLobeEndScreen extends StatelessWidget {
  const TemporalLobeEndScreen({super.key});

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
                          "Temporal lobe quest completed!",
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
                text: "Back to map",
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