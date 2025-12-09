import 'dart:async';
import 'dart:math';
import 'package:brainjourney/cerebellum.dart';
import 'package:brainjourney/homeMentalHealth.dart';
import 'package:flutter/material.dart';
import 'package:brainjourney/MentalHealthIntro.dart';

// HINWEIS: Stelle sicher, dass du deine WoodButton Komponente importierst
// oder die untenstehende Mock-Klasse verwendest.
// import 'package:brainjourney/home.dart';
// ---------------------------------------------------------------------------
// INTRO WRAPPER (Diese startest du jetzt statt der Games direkt)
// ---------------------------------------------------------------------------

class AnxietyIntro extends StatelessWidget {
  const AnxietyIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return MentalHealthIntro(
      title: "Der Atem-Anker",
      conditionName: "Angst & Emotion",
      imageAsset: "assets/images/brain_amygdala.png",
      gameWidget: const AnxietyGame(), // Dein Atem-Spiel
      texts: const [
        "Angst fühlt sich oft eng, schnell und flach an.",
        "Wenn der innere Alarm losgeht, vergessen wir oft, richtig zu atmen.",
        "Wir wollen dem Körper signalisieren: Du bist sicher.",
        "Nutze deinen Atem als Anker gegen die Unruhe.",
        "Deine Aufgabe: Tippe und halte beim Einatmen – und lass beim Ausatmen los."
      ],
    );
  }
}

class DepressionIntro extends StatelessWidget {
  const DepressionIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return MentalHealthIntro(
      title: "Der Lichtfänger",
      conditionName: "Depression",
      imageAsset: "assets/images/brain_hippocampus.png",
      gameWidget: const DepressionGame(), // Dein Sammel-Spiel
      texts: const [
        "Bei einer Depression legt sich oft ein grauer Nebel über die Welt.",
        "Es fällt schwer, Freude oder Hoffnung wahrzunehmen.",
        "Doch selbst im dichtesten Nebel gibt es kleine Funken.",
        "Wir üben, den Blick wieder auf das Leuchten zu richten.",
        "Deine Aufgabe: Bewege dich durch das Dunkel und sammle jeden Lichtblick ein."
      ],
    );
  }
}

class AdhsIntro extends StatelessWidget {
  const AdhsIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return MentalHealthIntro(
      title: "Das Goldene Blatt",
      conditionName: "Konzentration",
      imageAsset: "assets/images/brain_frontal.png",
      gameWidget: const AdhsGame(), // Dein Fokus-Spiel
      texts: const [
        "In deinem Kopf herrscht oft ein kreativer Sturm.",
        "Tausend Gedanken und Reize wollen gleichzeitig deine Aufmerksamkeit.",
        "Die Kunst ist nicht, den Sturm zu stoppen, sondern im Auge des Sturms ruhig zu bleiben.",
        "Lass die Ablenkungen an dir vorbeiziehen.",
        "Deine Aufgabe: Fixiere das goldene Blatt und lass es nicht aus den Augen."
      ],
    );
  }
}

// Falls du Sucht und Trauma auch noch brauchst (angepasst ohne Regionen):

class AddictionIntro extends StatelessWidget {
  const AddictionIntro({super.key});
  @override
  Widget build(BuildContext context) {
    return MentalHealthIntro(
      title: "Der Widerstand",
      conditionName: "Sucht",
      imageAsset: "assets/images/brain_reward.png",
      gameWidget: const AddictionGame(),
      texts: const [
        "Sucht täuscht unserem Gehirn vor, dass wir eine bestimmte Substanz zum Überleben brauchen.",
        "Das Verlangen (Craving) kann sich übermächtig anfühlen.",
        "Andere, kleine Freuden des Alltags werden dabei oft übersehen.",
        "Es geht darum, diesem starken Impuls nicht sofort nachzugeben.",
        "Deine Aufgabe: Weiche den Verlockungen aus und sammle stattdessen gesunde Ressourcen."
      ],
    );
  }
}

class PtbsIntro extends StatelessWidget {
  const PtbsIntro({super.key});
  @override
  Widget build(BuildContext context) {
    return MentalHealthIntro(
      title: "Das Zeit-Puzzle",
      conditionName: "Trauma",
      imageAsset: "assets/images/brain_hippocampus.png",
      gameWidget: const PtbsGame(),
      texts: const [
        "Nach einem Trauma fühlen sich Erinnerungen oft an, als würden sie jetzt gerade passieren.",
        "Vergangenheit und Gegenwart vermischen sich.",
        "Das Erlebnis wurde noch nicht richtig als 'vergangen' einsortiert.",
        "Wir helfen dem Kopf, Ordnung in die Bilder zu bringen.",
        "Deine Aufgabe: Setze die Bruchstücke zusammen, um das Bild zu vervollständigen."
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 1. DAS QUIZ-MODUL (Der "Loot" nach dem Kampf)
// ---------------------------------------------------------------------------
class QuizData {
  final String question;
  final String correctAnswer;
  final List<String> wrongAnswers;
  final String explanation; // Kurzer Lern-Effekt nach Antwort

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
  int currentQuestionIndex = 0;
  bool answered = false;
  bool wasCorrect = false;

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
          // Hintergrund (Wood Style reuse)
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
                    Text("Erkenntnis ${currentQuestionIndex + 1}",
                        style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, color: Colors.brown[900])),
                    const SizedBox(height: 20),
                    Text(question.question,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),

                    if (!answered) ...allAnswers.map((ans) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                        child: Text(wasCorrect ? "Richtig! ${question.explanation}" : "Nicht ganz. ${question.explanation}",
                            textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 20),
                      WoodButtonWide(
                        onPressed: _nextQuestion,
                        text: currentQuestionIndex < widget.questions.length - 1
                            ? "Nächste Frage"
                            : "Abschließen",
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

// ---------------------------------------------------------------------------
// A. DEPRESSION ("Der Lichtfänger")
// ---------------------------------------------------------------------------
class DepressionGame extends StatefulWidget {
  const DepressionGame({super.key});
  @override
  State<DepressionGame> createState() => _DepressionGameState();
}

class _DepressionGameState extends State<DepressionGame> {
  final List<Offset> _sparks = [];
  final Random _rnd = Random();
  Timer? _gameLoop;
  int _score = 0;
  double _opacity = 0.8; // Der "Nebel"

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _gameLoop = Timer.periodic(Duration(milliseconds: 800), (timer) {
      if (!mounted) return;
      if (_score >= 10) { // WIN CONDITION
        timer.cancel();
        _finishGame();
      }
      setState(() {
        // Neuen Funken spawnen
        double x = _rnd.nextDouble() * (MediaQuery.of(context).size.width - 50);
        _sparks.add(Offset(x, 0));
      });
    });

    // Fall-Logik (Simulation)
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!mounted || _score >= 10) { timer.cancel(); return; }
      setState(() {
        for (int i = 0; i < _sparks.length; i++) {
          _sparks[i] = Offset(_sparks[i].dx, _sparks[i].dy + 3); // Geschwindigkeit
        }
        // Entferne Funken die unten rausfallen
        _sparks.removeWhere((pos) => pos.dy > MediaQuery.of(context).size.height);
      });
    });
  }

  void _catchSpark(int index) {
    setState(() {
      _sparks.removeAt(index);
      _score++;
      // Je mehr Licht man fängt, desto heller wird der Bildschirm (Nebel lichtet sich)
      _opacity = (_opacity - 0.08).clamp(0.0, 0.8);
    });
  }

  void _finishGame() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizScreen(
      questions: [
        QuizData(
            question: "Wie fühlt sich Depression oft an?",
            correctAnswer: "schwerer Nebel",
            wrongAnswers: ["sonniger Tag", "zu viel Energie"],
            explanation: "Antriebslosigkeit ist ein Kernsymptom."
        ),
        QuizData(
            question: "Was hilft oft als erster Schritt?",
            correctAnswer: "Lichtblicke suchen",
            wrongAnswers: ["Sich isolieren", "Alles gleichzeitg lösen"],
            explanation: "Kleine positive Aktivitäten (Verhaltensaktivierung) helfen."
        )
      ],
      onQuizCompleted: (quizContext) {
      Navigator.pushReplacement(
      quizContext, // <--- WICHTIG: Nicht mehr 'context', sondern 'quizContext'
      MaterialPageRoute(builder: (_) => const MentalMapScreen()) // Oder wie deine Home-Klasse heißt
      );
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
          // Der Nebel (Overlay)
          Container(color: Colors.grey[900]!.withOpacity(_opacity)),

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
                          Text("Licht: $_score / 10", style: TextStyle(color: Colors.black, fontSize: 18,fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(
                            "Sammle Lichtpunkte",
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

// ---------------------------------------------------------------------------
// B. ANGST ("Das Dornen-Dickicht" / Atem-Kreis)
// ---------------------------------------------------------------------------
class AnxietyGame extends StatefulWidget {
  const AnxietyGame({super.key});
  @override
  State<AnxietyGame> createState() => _AnxietyGameState();
}

class _AnxietyGameState extends State<AnxietyGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHolding = false;

  // WICHTIG: double statt int für weiche Animation
  double _calmPoints = 0.0;
  String _instruction = "Warte...";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 4))..repeat(reverse: true);

    _controller.addListener(() {
      bool growing = _controller.status == AnimationStatus.forward;

      // Text-Optimierung: Nur updaten, wenn sich der Text ändert
      String newInstruction = growing ? "EINATMEN (Halten)" : "AUSATMEN (Loslassen)";
      if (_instruction != newInstruction) {
        setState(() {
          _instruction = newInstruction;
        });
      }

      // --- LOGIK ---
      bool isSuccess = false;

      if (growing && _isHolding) {
        // Richtig: Einatmen & Halten
        isSuccess = true;
      } else if (!growing && !_isHolding) {
        // Richtig: Ausatmen & Loslassen
        isSuccess = true;
      }

      // Punkte Logik
      if (isSuccess) {
        setState(() {
          // HIER ANPASSEN FÜR GESCHWINDIGKEIT:
          // += 0.1 -> sehr langsam (ca. 16 Sek bis voll)
          // += 0.2 -> mittel (ca. 8 Sek bis voll)
          // += 0.5 -> schnell (ca. 3 Sek bis voll)
          _calmPoints += 0.1;

          // Sicherheitshalber deckeln, damit es nicht über 100 geht
          if (_calmPoints > 100) _calmPoints = 100.0;
        });
      } else {
        // Bei Fehler langsam abziehen (optional)
        setState(() {
          if (_calmPoints > 0) _calmPoints -= 0.1;
          if (_calmPoints < 0) _calmPoints = 0.0;
        });
      }

      // Win Condition: Jetzt wieder glatt 100, da wir double nutzen
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
            question: "Was passiert körperlich bei Angst?",
            correctAnswer: "Der Puls steigt",
            wrongAnswers: ["Man wird müde", "Der Hunger steigt"],
            explanation: "Der Körper geht in den 'Fight or Flight' Modus."
        ),
        QuizData(
            question: "Was hilft akut gegen Panik?",
            correctAnswer: "Kontrollierte Atmung",
            wrongAnswers: ["Schnell rennen", "Luft anhalten"],
            explanation: "Langes Ausatmen aktiviert den Parasympathikus (Beruhigung)."
        )
      ],
        onQuizCompleted: (quizContext) {
          Navigator.pushReplacement(
              quizContext, // <--- WICHTIG: Nicht mehr 'context', sondern 'quizContext'
              MaterialPageRoute(builder: (_) => const MentalMapScreen()) // Oder wie deine Home-Klasse heißt
          );
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
            // Dornen-Hintergrund (Symbolisch)
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
                            Text("Beruhige den Kreis", style: TextStyle(color: Colors.black, fontSize: 18,fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(
                              "Ruhe-Level: ${_calmPoints.toInt()}%",
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
                          color: _isHolding ? Colors.blue[300] : Colors.blue[100], // Feedback Farbe
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

// ---------------------------------------------------------------------------
// C. ADHS ("Der Fokus-Sturm")
// ---------------------------------------------------------------------------
class AdhsGame extends StatefulWidget {
  const AdhsGame({super.key});
  @override
  State<AdhsGame> createState() => _AdhsGameState();
}

class _AdhsGameState extends State<AdhsGame> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _targetX = 150;
  double _targetY = 300;
  double _score = 0;
  bool _isFocusing = false; // Hat der User den Finger drauf?

  // Background clutter
  final List<Offset> _clutter = List.generate(20, (index) => Offset(Random().nextDouble()*300, Random().nextDouble()*600));

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 10))..repeat();
    _controller.addListener(() {
      setState(() {
        // Das "Goldene Blatt" bewegt sich chaotisch (Lissajous-Kurve ähnlich)
        final t = _controller.value * 2 * pi;
        _targetX = (MediaQuery.of(context).size.width / 2) + sin(t * 3) * 120;
        _targetY = (MediaQuery.of(context).size.height / 2) + cos(t * 2) * 200;

        if (_isFocusing) {
          _score += 0.5;
        } else {
          _score -= 0.1; // Strafe fürs Loslassen
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
            question: "Was ist typisch für ADHS?",
            correctAnswer: "gestörte Reizfilterung",
            wrongAnswers: ["Mangelnde Intelligenz", "Nur Faulheit"],
            explanation: "Das Gehirn kann wichtige von unwichtigen Reizen schwer unterscheiden."
        ),
        QuizData(
            question: "Was symbolisierte das Goldene Blatt?",
            correctAnswer: "Fokus-Gedanken",
            wrongAnswers: ["Reichtum", "Herbst"],
            explanation: "Es kostet Kraft, den Fokus auf einer Sache zu halten, wenn alles andere 'laut' ist."
        )
      ],
        onQuizCompleted: (quizContext) {
          Navigator.pushReplacement(
              quizContext, // <--- WICHTIG: Nicht mehr 'context', sondern 'quizContext'
              MaterialPageRoute(builder: (_) => const MentalMapScreen()) // Oder wie deine Home-Klasse heißt
          );
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

          // Hintergrund-Ablenkungen (Clutter)
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
                          Text("Halte das goldene Blatt!", style: TextStyle(color: Colors.black, fontSize: 18,fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(
                            "Fokus: ${_score.toInt()}%",
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
          // Anleitung

          // Das Ziel (Goldenes Blatt)
          Positioned(
            left: _targetX - 40, // Zentrieren (Größe 80)
            top: _targetY - 40,
            child: GestureDetector(
              onPanStart: (_) => setState(() => _isFocusing = true),
              onPanEnd: (_) => setState(() => _isFocusing = false),
              // Hier wichtig: Der User muss den Finger BEWEGEN, um drauf zu bleiben.
              // Wir nutzen einen Container mit HitTestBehavior
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                    color: _isFocusing ? Colors.amberAccent : Colors.amber, // Feedback
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

// ---------------------------------------------------------------------------
// D. SUCHT ("Der schillernde Sumpf")
// ---------------------------------------------------------------------------
class AddictionItem {
  final String iconAsset; // oder IconData
  final bool isBad; // True = Suchtmittel
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
  final List<AddictionItem> _items = [];
  Timer? _spawner;
  int _willpower = 3; // Lebensbalken
  int _resources = 0; // Score
  int _idCounter = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    // ÄNDERUNG 1: Timer von 900ms auf 1600ms erhöht (langsamer)
    _spawner = Timer.periodic(const Duration(milliseconds: 1600), (t) {
      if (!mounted) return;

      // Win/Lose Logic wie zuvor...
      if (_willpower <= 0) {
        t.cancel();
      } else if (_resources >= 10) {
        t.cancel();
        _finishGame();
      }

      setState(() {
        double x = Random().nextDouble() * (MediaQuery
            .of(context)
            .size
            .width - 80);
        // Etwas tiefer starten, damit es nicht im Header hängt
        double y = Random().nextDouble() * (MediaQuery
            .of(context)
            .size
            .height * 0.5) + 120;

        bool isBad = Random().nextBool();
        _items.add(AddictionItem(
            isBad ? "Flasche" : "Apfel", isBad, Offset(x, y), _idCounter++));

        // ÄNDERUNG 2: Items bleiben 4 Sekunden statt 2 (mehr Zeit zum Reagieren)
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
        _willpower--; // Schaden

      } else {
        _resources++; // Score
      }
    });
  }

  void _finishGame() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>
        QuizScreen(
          questions: [
            QuizData(
                question: "Warum ist Sucht so schwer zu stoppen?",
                correctAnswer: "'gehacktes' \nBelohnungssystem",
                wrongAnswers: ["Man hat keine Lust", "Es schmeckt zu gut"],
                explanation: "Dopamin wird künstlich ausgeschüttet, natürliche Reize (Äpfel) wirken langweilig."
            ),
            QuizData(
                question: "Was stärkt die 'Willenskraft'?",
                correctAnswer: "Gesunde\nRessourcen aufbauen",
                wrongAnswers: ["Sich selbst bestrafen", "Verdrängung"],
                explanation: "Freunde, Sport und Hobbys füllen den Speicher wieder auf."
            )
          ],
            onQuizCompleted: (quizContext) {
              Navigator.pushReplacement(
                  quizContext, // <--- WICHTIG: Nicht mehr 'context', sondern 'quizContext'
                  MaterialPageRoute(builder: (_) => const MentalMapScreen()) // Oder wie deine Home-Klasse heißt
              );
            })));
  }

  @override
  void dispose() {
    _spawner?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- FAIL SCREEN / GAME OVER ---
    if (_willpower <= 0) {
      return Scaffold(
        body: Stack(
          children: [
            // 1. Hintergrund (Wald)
            Image.asset(
              "assets/images/WoodBackgroundNight.jpg",
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),

            // 2. Inhalt auf Paperroll
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                // Höhe automatisch oder fest, je nach Grafik
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Die Papierrolle
                    Image.asset(
                      "assets/images/paperRoll.png",
                      fit: BoxFit.contain,
                    ),

                    // Der Text und Button auf dem Papier
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Der Sumpf hat dich verschlungen.",
                            style: TextStyle(
                                color: Color(0xFF5D4037), // Dunkelbraun für Text auf Papier
                                fontSize: 20,
                                fontFamily: 'Courier',
                                fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          WoodButtonWide(
                            onPressed: () {
                              setState(() {
                                _willpower = 3; // ÄNDERUNG: Reset auf 3
                                _resources = 0;
                                _items.clear();
                                _startGame();
                              });
                            },
                            text: 'Nochmal versuchen',
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
          Image.asset("assets/images/WoodBackgroundNight.jpg", fit: BoxFit.cover,
              height: double.infinity),


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
                          Text("Tippe auf die Ressourcen", style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Courier',
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(
                            "Ressourcen: $_resources / 10",
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
            left: 0,  // Wichtig: Streckt den Bereich von links...
            right: 0, // ...nach rechts, damit die Mitte berechnet werden kann.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Zentriert die Herzen in der Zeile
              children: List.generate(3, (i) =>
                  Icon(
                    Icons.favorite,
                    color: i < _willpower ? Colors.red : Colors.grey,
                    size: 30, // Optional: Größe anpassen
                  )
              ),
            ),
          ),


          ..._items.map((item) =>
              Positioned(
                left: item.position.dx,
                top: item.position.dy,
                child: GestureDetector(
                  onTap: () => _onTapItem(item),
                  child: Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                        color: item.isBad
                            ? Colors.brown.withOpacity(0.8)
                            : Colors.brown,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: item.isBad ? Colors.brown : Colors.brown,
                              blurRadius: 10)
                        ]
                    ),
                    child: Icon(
                        item.isBad ? Icons.wine_bar : Icons.apple, size: 40,
                        color: Colors.white),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// E. PTBS ("Das Echo-Tal" / Rotations-Puzzle)
// ---------------------------------------------------------------------------
class PtbsGame extends StatefulWidget {
  const PtbsGame({super.key});

  @override
  State<PtbsGame> createState() => _PtbsGameState();
}

class _PtbsGameState extends State<PtbsGame> {
  // Wir machen ein 3x3 Raster = 9 Teile
  final int gridSize = 3;

  // Speichert die Rotation für jedes Teil (0 = korrekt, 1 = 90°, 2 = 180°, 3 = 270°)
  late List<int> pieceRotations;
  bool isWon = false;

  @override
  void initState() {
    super.initState();
    _initializePuzzle();
  }

  void _initializePuzzle() {
    // Zufällige Rotationen setzen
    pieceRotations = List.generate(gridSize * gridSize, (index) {
      return Random().nextInt(3) + 1; // Generiert 1, 2 oder 3 (also immer verdreht am Anfang)
    });
  }

  void _rotatePiece(int index) {
    if (isWon) return;

    setState(() {
      // Dreht das Teil um 90 Grad weiter (Modulo 4, damit es 0-3 bleibt)
      pieceRotations[index] = (pieceRotations[index] + 1) % 4;
      _checkWin();
    });
  }

  void _checkWin() {
    // Wenn ALLE Rotationen 0 sind, ist das Bild heil
    if (pieceRotations.every((r) => r == 0)) {
      setState(() {
        isWon = true;
      });
      // Kurze Verzögerung, damit der Spieler das fertige Bild sieht
      Future.delayed(const Duration(seconds: 1), _finishGame);
    }
  }

  void _finishGame() {
    // Navigiert zum QuizScreen (Code aus deiner Vorlage übernommen)
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizScreen(
        questions: [
          QuizData(
              question: "Was sind Flashbacks?",
              correctAnswer: "Ungefragtes Wiedererleben",
              wrongAnswers: ["Schöne Träume", "Vergesslichkeit"],
              explanation: "Das Trauma ist nicht als 'Vergangenheit' abgespeichert, sondern fühlt sich an wie 'jetzt'."
          ),
          QuizData(
              question: "Was war das Ziel des Puzzles?",
              correctAnswer: "Erinnerungsintegration",
              wrongAnswers: ["Verdrängung", "Ablenkung"],
              explanation: "In der Therapie werden die 'Splitter' der Erinnerung geordnet, damit sie ein Bild der Vergangenheit werden."
          )
        ],
        onQuizCompleted: (quizContext) {
          Navigator.pushReplacement(
              quizContext,
              MaterialPageRoute(builder: (_) => const MentalMapScreen())
          );
        }
    )));
  }

  // Hilfsfunktion: Berechnet den Bildausschnitt für das Grid
  Alignment _getAlignment(int index) {
    int x = index % gridSize;
    int y = index ~/ gridSize;

    // Alignment geht von -1.0 bis +1.0
    double alignX = -1.0 + (x * 2.0 / (gridSize - 1));
    double alignY = -1.0 + (y * 2.0 / (gridSize - 1));

    return Alignment(alignX, alignY);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Hintergrund
          Image.asset("assets/images/WoodBackgroundNight.jpg", fit: BoxFit.cover, height: double.infinity),

          // Überschrift auf Holzbrett
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
                          Text(
                            isWon ? "Erinnerung integriert." : "Ordne die Erinnerung...",
                            style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Tippe auf die Teile.",
                            style: TextStyle(fontSize: 14, fontFamily: 'Courier', fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Papierrolle als Rahmen
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

                      // 3. Das PUZZLE GRID
                      Expanded(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1, // Erzwingt quadratische Form
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.brown[800]!, width: 4),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(4, 4))]
                              ),
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    double boardSize = constraints.maxWidth;

                                    return GridView.builder(
                                      // *** HIER IST DER FIX ***
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
                                                    "assets/images/WoodBackground.jpg", // Dein Puzzle-Bild
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