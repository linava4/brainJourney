import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
// Wieder Import der bestehenden Dateien für Wiederverwendung
import 'package:brainjourney/mentalhealthGames.dart'; 
import 'package:brainjourney/homeMentalHealth.dart';

class PrefrontalIntro extends StatelessWidget {
  const PrefrontalIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return MentalHealthIntro(
      title: "Der Dirigent",
      conditionName: "Planung & Kontrolle",
      imageAsset: "assets/images/brain_frontal.png", 
      gameWidget: const PrefrontalCortexGame(),
      texts: const [
        "Der präfrontale Cortex ist der Chef deines Gehirns.",
        "Er plant, kontrolliert Impulse und behält Ziele im Blick.",
        "Wir trainieren dein Arbeitsgedächtnis.",
        "Deine Aufgabe: Merke dir die Sequenz aus Lichtern und tippe sie exakt nach."
      ],
    );
  }
}

class PrefrontalCortexGame extends StatefulWidget {
  const PrefrontalCortexGame({super.key});

  @override
  State<PrefrontalCortexGame> createState() => _PrefrontalCortexGameState();
}

class _PrefrontalCortexGameState extends State<PrefrontalCortexGame> {
  final List<Color> _colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow];
  
  List<int> _sequence = []; 
  int _currentStep = 0; 
  bool _isPlayerTurn = false;
  int? _activeLightIndex; 
  
  String _statusText = "Bereit machen...";
  int _level = 1;
  final int _maxLevels = 5;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _startNextRound);
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
      // Hier würde der Ton abgespielt werden
      
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

    // Feedback beim Tippen
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
          _finishGame();
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
       _statusText = "Fehler! Nochmal versuchen.";
       _sequence.clear();
       _level = 1;
       _isPlayerTurn = false;
     });
     Future.delayed(const Duration(seconds: 2), _startNextRound);
  }

  void _finishGame() {
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizScreen(
        questions: [
          QuizData(
              question: "Wofür ist der präfrontale Cortex zuständig?",
              correctAnswer: "Planung & Kontrolle",
              wrongAnswers: ["Atmung", "Reine Emotion"],
              explanation: "Er ermöglicht zielgerichtetes Handeln und Impulskontrolle."
          ),
          QuizData(
              question: "Was passiert bei Stress?",
              correctAnswer: "Er schaltet sich oft ab",
              wrongAnswers: ["Er arbeitet besser", "Er wird grün"],
              explanation: "Bei starker Angst übernimmt die Amygdala und der 'rationale Denker' macht Pause."
          )
        ],
        onQuizCompleted: (quizContext) {
          Navigator.pushReplacement(
              quizContext,
              MaterialPageRoute(builder: (_) => const MentalMapScreen())
          );
        },
      )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset("assets/images/WoodBackground.jpg", fit: BoxFit.cover, height: double.infinity, width: double.infinity),

          // Header
          Positioned(
            top: 40, left: 0, right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(12)),
                  child: Text("Level $_level / $_maxLevels", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Text(_statusText, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown, fontFamily: 'Courier')),
              ],
            ),
          ),

          // Die 4 Buttons
          Center(
            child: SizedBox(
              width: 300, height: 300,
              child: GridView.count(
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
                        color: (_activeLightIndex == index) 
                            ? _colors[index] 
                            : _colors[index].withOpacity(0.3), 
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.brown[800]!, width: 4),
                        boxShadow: (_activeLightIndex == index) 
                          ? [BoxShadow(color: _colors[index], blurRadius: 20, spreadRadius: 2)]
                          : [],
                      ),
                    ),
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}