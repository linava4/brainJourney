import 'dart:async';
import 'dart:math';
import 'package:brainjourney/cerebellum.dart';
import 'package:brainjourney/homeMentalHealth.dart';
import 'package:flutter/material.dart';
import 'package:brainjourney/MentalHealthIntro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers.dart';

// INTRO WRAPPER

class AnxietyIntro extends StatelessWidget {
  const AnxietyIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return MentalHealthIntro(
      title: "The Breath Anchor",
      conditionName: "Anxiety & Emotion",
      imageAsset: "assets/images/brain_amygdala.png",
      gameWidget: const AnxietyGame(), // Atem-Spiel
      texts: const [
        "Anxiety often feels tight, fast, and shallow.",
        "When the inner alarm goes off, we often forget to breathe properly.",
        "We want to signal to the body: You are safe.",
        "Use your breath as an anchor against restlessness.",
        "Your task: Tap and hold while inhaling – and let go while exhaling."
      ],
    );
  }
}

class DepressionIntro extends StatelessWidget {
  const DepressionIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return MentalHealthIntro(
      title: "The Light Catcher",
      conditionName: "Depression",
      imageAsset: "assets/images/brain_hippocampus.png",
      gameWidget: const DepressionGame(), // Sammel-Spiel
      texts: const [
        "In depression, a grey fog often settles over the world.",
        "It is hard to perceive joy or hope.",
        "But even in the densest fog, there are small sparks.",
        "We practice turning our gaze back to the glow.",
        "Your task: Move through the darkness and collect every glimmer of light."
      ],
    );
  }
}

class AdhsIntro extends StatelessWidget {
  const AdhsIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return MentalHealthIntro(
      title: "The Golden Leaf",
      conditionName: "Concentration",
      imageAsset: "assets/images/brain_frontal.png",
      gameWidget: const AdhsGame(), // Fokus-Spiel
      texts: const [
        "A creative storm often reigns in your head.",
        "A thousand thoughts and stimuli want your attention at the same time.",
        "The art is not to stop the storm, but to remain calm in the eye of the storm.",
        "Let the distractions pass you by.",
        "Your task: Fixate on the golden leaf and don't lose sight of it."
      ],
    );
  }
}

class AddictionIntro extends StatelessWidget {
  const AddictionIntro({super.key});
  @override
  Widget build(BuildContext context) {
    return MentalHealthIntro(
      title: "The Resistance",
      conditionName: "Addiction",
      imageAsset: "assets/images/brain_reward.png",
      gameWidget: const AddictionGame(),
      texts: const [
        "Addiction tricks our brain into thinking we need a certain substance to survive.",
        "The craving can feel overwhelming.",
        "Other small joys of everyday life are often overlooked.",
        "It's about not giving in to this strong impulse immediately.",
        "Your task: Evade the temptations(glasses) and collect healthy resources(apples) instead."
      ],
    );
  }
}

class PtbsIntro extends StatelessWidget {
  const PtbsIntro({super.key});
  @override
  Widget build(BuildContext context) {
    return MentalHealthIntro(
      title: "The Time Puzzle",
      conditionName: "Trauma",
      imageAsset: "assets/images/brain_hippocampus.png",
      gameWidget: const PtbsGame(),
      texts: const [
        "After a trauma, memories often feel like they are happening right now.",
        "Past and present blur together.",
        "The experience hasn't been properly sorted as 'past' yet.",
        "We help the mind bring order to the images.",
        "Your task: Put the fragments together to complete the picture."
      ],
    );
  }
}

// 1. QUIZ MODULE
class QuizData {
  final String question;
  final String correctAnswer;
  final List<String> wrongAnswers;
  final String explanation; // Lern-Effekt

  QuizData({
    required this.question,
    required this.correctAnswer,
    required this.wrongAnswers,
    required this.explanation,
  });
}

class QuizScreen extends StatefulWidget {
  final List<QuizData> questions;
  final void Function(BuildContext) onQuizCompleted;

  const QuizScreen({super.key, required this.questions, required this.onQuizCompleted});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0; // Aktueller Index
  bool answered = false; // Beantwortet-Status
  bool wasCorrect = false; // Korrekt-Status

  void _checkAnswer(String answer) {
    if (answered) return;
    setState(() {
      answered = true;
      wasCorrect = answer == widget.questions[currentQuestionIndex].correctAnswer;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        answered = false;
        wasCorrect = false;
      });
    } else {
      widget.onQuizCompleted(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];
    final allAnswers = [...question.wrongAnswers, question.correctAnswer]..shuffle();

    return Scaffold(
      body: Stack(
        children: [
          // Hintergrund
          Positioned.fill(child: Image.asset("assets/images/WoodBackgroundNight.jpg", fit: BoxFit.cover)),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/images/paperRoll.png"), fit: BoxFit.fill),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Insight ${currentQuestionIndex + 1}",
                        style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, color: Colors.brown[900])),
                    const SizedBox(height: 20),
                    Text(question.question,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),

                    if (!answered) ...allAnswers.map((ans) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: WoodButtonWide(
                        onPressed: () => _checkAnswer(ans),
                        text: ans,
                      ),
                    ))
                    else ...[
                      Icon(wasCorrect ? Icons.check_circle : Icons.info,
                          size: 60, color: wasCorrect ? Colors.green : Colors.orange),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(wasCorrect ? "Correct! ${question.explanation}" : "Not quite. ${question.explanation}",
                            textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 20),
                      WoodButtonWide(
                        onPressed: _nextQuestion,
                        text: currentQuestionIndex < widget.questions.length - 1
                            ? "Next Question"
                            : "Finish",
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A. DEPRESSION
class DepressionGame extends StatefulWidget {
  const DepressionGame({super.key});
  @override
  State<DepressionGame> createState() => _DepressionGameState();
}

class _DepressionGameState extends State<DepressionGame> {
  final List<Offset> _sparks = []; // Licht-Punkte
  final Random _rnd = Random();
  Timer? _gameLoop;
  int _score = 0; // Punktestand
  double _opacity = 0.8; // Nebel-Stärke

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _gameLoop = Timer.periodic(Duration(milliseconds: 800), (timer) {
      if (!mounted) return;
      if (_score >= 10) { // Sieg-Bedingung
        timer.cancel();
        _finishGame();
      }
      setState(() {
        // Funken-Spawn
        double x = _rnd.nextDouble() * (MediaQuery.of(context).size.width - 50);
        _sparks.add(Offset(x, 0));
      });
    });

    // Fall-Simulation
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!mounted || _score >= 10) { timer.cancel(); return; }
      setState(() {
        for (int i = 0; i < _sparks.length; i++) {
          _sparks[i] = Offset(_sparks[i].dx, _sparks[i].dy + 3);
        }
        _sparks.removeWhere((pos) => pos.dy > MediaQuery.of(context).size.height);
      });
    });
  }

  void _catchSpark(int index) {
    setState(() {
      _sparks.removeAt(index);
      _score++;
      _opacity = (_opacity - 0.08).clamp(0.0, 0.8);
    });
  }

  void _finishGame() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizScreen(
        questions: [
          QuizData(
              question: "How does depression often feel?",
              correctAnswer: "heavy fog",
              wrongAnswers: ["sunny day", "too much energy"],
              explanation: "Lack of drive is a core symptom."
          ),
          QuizData(
              question: "What is often a helpful first step?",
              correctAnswer: "searching for glimmers of light",
              wrongAnswers: ["isolating yourself", "solving everything at once"],
              explanation: "Small positive activities (behavioral activation) help."
          )
        ],
        onQuizCompleted: (quizContext) {
          markLevelComplete("depression");
          Navigator.of(quizContext, rootNavigator: true).pop(true);
        })));
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset("assets/images/WoodBackgroundNight.jpg", fit: BoxFit.cover, height: double.infinity),
          Container(color: Colors.grey[900]!.withOpacity(_opacity)), // Nebel-Layer

          ..._sparks.asMap().entries.map((entry) {
            return Positioned(
              left: entry.value.dx,
              top: entry.value.dy,
              child: GestureDetector(
                onTap: () => _catchSpark(entry.key),
                child: Icon(Icons.star, color: Colors.yellowAccent, size: 40, shadows: [Shadow(blurRadius: 10, color: Colors.white)]),
              ),
            );
          }),

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
                          const SizedBox(height: 5),
                          Text("Light: $_score / 10", style: TextStyle(color: Colors.black, fontSize: 18,fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(
                            "Collect light points",
                            style: TextStyle(color: Colors.black, fontSize: 14,fontFamily: 'Courier', fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// B. ANXIETY
class AnxietyGame extends StatefulWidget {
  const AnxietyGame({super.key});
  @override
  State<AnxietyGame> createState() => _AnxietyGameState();
}

class _AnxietyGameState extends State<AnxietyGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHolding = false; // Druck-Status

  double _calmPoints = 0.0; // Fortschritt
  String _instruction = "Wait...";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 4))..repeat(reverse: true);

    _controller.addListener(() {
      bool growing = _controller.status == AnimationStatus.forward;

      String newInstruction = growing ? "INHALE (Hold)" : "EXHALE (Release)";
      if (_instruction != newInstruction) {
        setState(() {
          _instruction = newInstruction;
        });
      }

      bool isSuccess = false;

      if (growing && _isHolding) {
        isSuccess = true;
      } else if (!growing && !_isHolding) {
        isSuccess = true;
      }

      if (isSuccess) {
        setState(() {
          _calmPoints += 0.1;
          if (_calmPoints > 100) _calmPoints = 100.0;
        });
      } else {
        setState(() {
          if (_calmPoints > 0) _calmPoints -= 0.1;
          if (_calmPoints < 0) _calmPoints = 0.0;
        });
      }

      if (_calmPoints >= 100) {
        _controller.stop();
        _finishGame();
      }
    });
  }

  void _finishGame() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizScreen(
        questions: [
          QuizData(
              question: "What happens physically during anxiety?",
              correctAnswer: "Heart rate increases",
              wrongAnswers: ["You get tired", "Hunger increases"],
              explanation: "The body goes into 'Fight or Flight' mode."
          ),
          QuizData(
              question: "What helps acutely against panic?",
              correctAnswer: "Controlled breathing",
              wrongAnswers: ["Running fast", "Holding breath"],
              explanation: "Long exhalation activates the parasympathetic nervous system (calming)."
          )
        ],
        onQuizCompleted: (quizContext) {
          markLevelComplete("anxiety");
          Navigator.of(quizContext, rootNavigator: true).pop(true);
        })));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHolding = true),
      onTapUp: (_) => setState(() => _isHolding = false),
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset("assets/images/WoodBackgroundNight.jpg", fit: BoxFit.cover, height: double.infinity),
            Positioned.fill(child: Opacity(opacity: 0.3, child: Container(color: Colors.brown[900]))),

            Positioned(
              top: 0.0,
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
                            const SizedBox(height: 5),
                            Text("Calm the circle", style: TextStyle(color: Colors.black, fontSize: 18,fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(
                              "Calm Level: ${_calmPoints.toInt()}%",
                              style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Courier',fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      width: 100 + (_controller.value * 150),
                      height: 100 + (_controller.value * 150),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isHolding ? Colors.blue[300] : Colors.blue[100],
                          boxShadow: [BoxShadow(blurRadius: 20, color: Colors.blueAccent, spreadRadius: 5)]
                      ),
                      child: Center(child: Text(_instruction, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,)),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// C. ADHD
class AdhsGame extends StatefulWidget {
  const AdhsGame({super.key});
  @override
  State<AdhsGame> createState() => _AdhsGameState();
}

class _AdhsGameState extends State<AdhsGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _targetX = 150; // Blatt Position X
  double _targetY = 300; // Blatt Position Y
  double _score = 0; // Fortschritt
  bool _isFocusing = false; // Fokus-Status

  final List<Offset> _clutter = List.generate(20, (index) => Offset(Random().nextDouble()*300, Random().nextDouble()*600));

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 10))..repeat();
    _controller.addListener(() {
      setState(() {
        final t = _controller.value * 2 * pi;
        _targetX = (MediaQuery.of(context).size.width / 2) + sin(t * 3) * 120;
        _targetY = (MediaQuery.of(context).size.height / 2) + cos(t * 2) * 200;

        if (_isFocusing) {
          _score += 0.5;
        } else {
          _score -= 0.1;
          if (_score < 0) _score = 0;
        }

        if (_score >= 100) {
          _controller.stop();
          _finishGame();
        }
      });
    });
  }

  void _finishGame() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizScreen(
        questions: [
          QuizData(
              question: "What is typical for ADHD?",
              correctAnswer: "impaired stimulus filtering",
              wrongAnswers: ["lack of intelligence", "just laziness"],
              explanation: "The brain has difficulty distinguishing important from unimportant stimuli."
          ),
          QuizData(
              question: "What did the Golden Leaf symbolize?",
              correctAnswer: "Focus thoughts",
              wrongAnswers: ["Wealth", "Autumn"],
              explanation: "It takes effort to stay focused on one thing when everything else is 'loud'."
          )
        ],
        onQuizCompleted: (quizContext) {
          markLevelComplete("adhs");
          Navigator.of(quizContext, rootNavigator: true).pop(true);
        })));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset("assets/images/WoodBackgroundNight.jpg", fit: BoxFit.cover, height: double.infinity),

          ..._clutter.map((pos) => Positioned(
            left: pos.dx + sin(_controller.value * 20 + pos.dy)*20,
            top: pos.dy + cos(_controller.value * 10)*20,
            child: Icon(Icons.eco, color: Colors.green.withOpacity(0.5), size: 30),
          )),

          Positioned(
            top: 0.0,
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
                          const SizedBox(height: 5),
                          Text("Hold the golden leaf!", style: TextStyle(color: Colors.black, fontSize: 18,fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(
                            "Focus: ${_score.toInt()}%",
                            style: TextStyle(color: Colors.black, fontSize: 14,fontFamily: 'Courier', fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
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
            left: _targetX - 40,
            top: _targetY - 40,
            child: GestureDetector(
              onPanStart: (_) => setState(() => _isFocusing = true),
              onPanEnd: (_) => setState(() => _isFocusing = false),
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                    color: _isFocusing ? Colors.amberAccent : Colors.amber,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.amber, blurRadius: 15)]
                ),
                child: Icon(Icons.spa, color: Colors.white, size: 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// D. ADDICTION
class AddictionItem {
  final String iconAsset;
  final bool isBad; // Schädlich oder nicht
  final Offset position;
  final int id;

  AddictionItem(this.iconAsset, this.isBad, this.position, this.id);
}

class AddictionGame extends StatefulWidget {
  const AddictionGame({super.key});
  @override
  State<AddictionGame> createState() => _AddictionGameState();
}

class _AddictionGameState extends State<AddictionGame> {
  final List<AddictionItem> _items = []; // Items Liste
  Timer? _spawner;
  int _willpower = 3; // Leben
  int _resources = 0; // Score
  int _idCounter = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _spawner = Timer.periodic(const Duration(milliseconds: 1600), (t) {
      if (!mounted) return;

      if (_willpower <= 0) {
        t.cancel();
      } else if (_resources >= 10) {
        t.cancel();
        _finishGame();
      }

      setState(() {
        double x = Random().nextDouble() * (MediaQuery.of(context).size.width - 80);
        double y = Random().nextDouble() * (MediaQuery.of(context).size.height * 0.5) + 120;

        bool isBad = Random().nextBool();
        _items.add(AddictionItem(
            isBad ? "Bottle" : "Apple", isBad, Offset(x, y), _idCounter++));

        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() => _items.removeWhere((it) => it.id == _idCounter - 1));
          }
        });
      });
    });
  }

  void _onTapItem(AddictionItem item) {
    setState(() {
      _items.remove(item);
      if (item.isBad) {
        _willpower--;
      } else {
        _resources++;
      }
    });
  }

  void _finishGame() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>
        QuizScreen(
            questions: [
              QuizData(
                  question: "Why is addiction so hard to stop?",
                  correctAnswer: "'hacked' \nreward system",
                  wrongAnswers: ["No desire", "It tastes too good"],
                  explanation: "Dopamine is released artificially, making natural stimuli (apples) seem boring."
              ),
              QuizData(
                  question: "What strengthens 'willpower'?",
                  correctAnswer: "Building healthy\nresources",
                  wrongAnswers: ["Self-punishment", "Repression"],
                  explanation: "Friends, sports, and hobbies refill the reserves."
              )
            ],
            onQuizCompleted: (quizContext) {
              markLevelComplete("addiction");
              Navigator.of(quizContext, rootNavigator: true).pop(true);
            })));
  }

  @override
  void dispose() {
    _spawner?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_willpower <= 0) {
      return Scaffold(
        body: Stack(
          children: [
            Image.asset("assets/images/WoodBackgroundNight.jpg", fit: BoxFit.cover, height: double.infinity, width: double.infinity),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset("assets/images/paperRoll.png", fit: BoxFit.contain),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "The swamp has swallowed you.",
                            style: TextStyle(color: Color(0xFF5D4037), fontSize: 20, fontFamily: 'Courier', fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          WoodButtonWide(
                            onPressed: () {
                              setState(() {
                                _willpower = 3;
                                _resources = 0;
                                _items.clear();
                                _startGame();
                              });
                            },
                            text: 'Try Again',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Image.asset("assets/images/WoodBackgroundNight.jpg", fit: BoxFit.cover, height: double.infinity),

          Positioned(
            top: 0.0,
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
                          const SizedBox(height: 5),
                          Text("Tap on the resources", style: TextStyle(color: Colors.black, fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(
                            "Resources: $_resources / 10",
                            style: TextStyle(color: Colors.black,fontFamily: 'Courier', fontSize: 14, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
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
            top: 130,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Icon(Icons.favorite, color: i < _willpower ? Colors.red : Colors.grey, size: 30)),
            ),
          ),

          ..._items.map((item) => Positioned(
            left: item.position.dx,
            top: item.position.dy,
            child: GestureDetector(
              onTap: () => _onTapItem(item),
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                    color: item.isBad ? Colors.brown.withOpacity(0.8) : Colors.brown,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.brown, blurRadius: 10)]
                ),
                child: Icon(item.isBad ? Icons.wine_bar : Icons.apple, size: 40, color: Colors.white),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// E. PTSD
class PtbsGame extends StatefulWidget {
  const PtbsGame({super.key});
  @override
  State<PtbsGame> createState() => _PtbsGameState();
}

class _PtbsGameState extends State<PtbsGame> {
  final int gridSize = 3; // Rastergröße
  late List<int> pieceRotations; // Rotations-Liste
  bool isWon = false; // Sieg-Status

  @override
  void initState() {
    super.initState();
    _initializePuzzle();
  }

  void _initializePuzzle() {
    pieceRotations = List.generate(gridSize * gridSize, (index) {
      return Random().nextInt(3) + 1; // Zufälliger Start
    });
  }

  void _rotatePiece(int index) {
    if (isWon) return;
    setState(() {
      pieceRotations[index] = (pieceRotations[index] + 1) % 4;
      _checkWin();
    });
  }

  void _checkWin() {
    if (pieceRotations.every((r) => r == 0)) {
      setState(() {
        isWon = true;
      });
      Future.delayed(const Duration(seconds: 1), _finishGame);
    }
  }

  void _finishGame() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizScreen(
        questions: [
          QuizData(
              question: "What are flashbacks?",
              correctAnswer: "Unwanted re-experiencing",
              wrongAnswers: ["Beautiful dreams", "Forgetfulness"],
              explanation: "The trauma is not stored as 'past', but feels like 'now'."
          ),
          QuizData(
              question: "What was the goal of the puzzle?",
              correctAnswer: "Memory integration",
              wrongAnswers: ["Repression", "Distraction"],
              explanation: "In therapy, 'fragments' of memory are ordered so they become a picture of the past."
          )
        ],
        onQuizCompleted: (quizContext) {
          markLevelComplete("trauma");
          Navigator.of(quizContext, rootNavigator: true).pop(true);
        }
    )));
  }

  Alignment _getAlignment(int index) {
    int x = index % gridSize;
    int y = index ~/ gridSize;
    double alignX = -1.0 + (x * 2.0 / (gridSize - 1));
    double alignY = -1.0 + (y * 2.0 / (gridSize - 1));
    return Alignment(alignX, alignY);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset("assets/images/WoodBackgroundNight.jpg", fit: BoxFit.cover, height: double.infinity),

          Positioned(
            top: 0.0,
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
                          const SizedBox(height: 5),
                          Text(
                            isWon ? "Memory integrated." : "Arrange the memory...",
                            style: const TextStyle(fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          const Text("Tap on the pieces.", style: TextStyle(fontSize: 14, fontFamily: 'Courier', fontWeight: FontWeight.bold))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage("assets/images/paperRoll.png"), fit: BoxFit.fill),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.brown[800]!, width: 4),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(4, 4))]
                              ),
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    double boardSize = constraints.maxWidth;
                                    return GridView.builder(
                                      padding: EdgeInsets.zero,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: gridSize,
                                        mainAxisSpacing: 2,
                                        crossAxisSpacing: 2,
                                      ),
                                      itemCount: gridSize * gridSize,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () => _rotatePiece(index),
                                          child: AnimatedRotation(
                                            turns: pieceRotations[index] / 4,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeOutBack,
                                            child: Container(
                                              color: Colors.white,
                                              child: ClipRect(
                                                child: OverflowBox(
                                                  maxWidth: boardSize,
                                                  maxHeight: boardSize,
                                                  minWidth: boardSize,
                                                  minHeight: boardSize,
                                                  alignment: _getAlignment(index),
                                                  child: Image.asset(
                                                    "assets/images/WoodBackground.jpg",
                                                    fit: BoxFit.fill,
                                                    width: boardSize,
                                                    height: boardSize,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

