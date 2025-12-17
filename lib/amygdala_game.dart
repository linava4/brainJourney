import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
// Wir importieren deine existierende Datei, um MentalHealthIntro und QuizScreen wiederzuverwenden:
import 'package:brainjourney/mentalhealthGames.dart'; 
import 'package:brainjourney/homeMentalHealth.dart'; // Für den Rückweg zur Karte

class AmygdalaIntro extends StatelessWidget {
  const AmygdalaIntro({super.key});

  @override
  Widget build(BuildContext context) {
    // MentalHealthIntro kommt aus deiner existierenden mentalhealthGames.dart (oder MentalHealthIntro.dart)
    // Falls MentalHealthIntro in einer eigenen Datei ist, importiere diese. 
    // Basierend auf deinem Upload scheint es in mentalhealthGames.dart oder MentalHealthIntro.dart zu sein.
    return MentalHealthIntro(
      title: "Der Wächter",
      conditionName: "Angst & Emotion",
      imageAsset: "assets/images/brain_amygdala.png", 
      gameWidget: const AmygdalaGame(),
      texts: const [
        "Die Amygdala ist der Rauchmelder deines Gehirns.",
        "Sie scannt die Umgebung permanent nach Gefahren.",
        "Bei Angststörungen ist dieser Alarm zu empfindlich eingestellt.",
        "Wir üben nun, echte Gefahren zu erkennen und Fehlalarme zu ignorieren.",
        "Deine Aufgabe: Finde alle Gefahrensymbole (Blitze) und tippe sie an."
      ],
    );
  }
}

class AmygdalaGame extends StatefulWidget {
  const AmygdalaGame({super.key});

  @override
  State<AmygdalaGame> createState() => _AmygdalaGameState();
}

class _TargetItem {
  final int id;
  final Offset position;
  final bool isThreat; // True = Blitz (Ziel), False = Neutral
  final IconData icon;

  _TargetItem(this.id, this.position, this.isThreat, this.icon);
}

class _AmygdalaGameState extends State<AmygdalaGame> {
  final List<_TargetItem> _items = [];
  int _foundThreats = 0;
  final int _totalThreats = 8; 
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _spawnItems();
  }

  void _spawnItems() {
    final rnd = Random();
    _items.clear();
    // 8 Bedrohungen (Blitze)
    for (int i = 0; i < _totalThreats; i++) {
      _items.add(_createRandomItem(rnd, true, i));
    }
    // 12 Ablenkungen (Wolken, Blumen, Sonne)
    for (int i = 0; i < 12; i++) {
      _items.add(_createRandomItem(rnd, false, i + 100));
    }
    _items.shuffle();
    setState(() {});
  }

  _TargetItem _createRandomItem(Random rnd, bool isThreat, int id) {
    // Zufällige Position auf dem Screen (prozentual)
    final dx = 0.05 + rnd.nextDouble() * 0.8; 
    final dy = 0.15 + rnd.nextDouble() * 0.6; 

    IconData icon;
    if (isThreat) {
      icon = Icons.flash_on; 
    } else {
      final neutrals = [Icons.cloud, Icons.wb_sunny, Icons.local_florist, Icons.water_drop];
      icon = neutrals[rnd.nextInt(neutrals.length)];
    }

    return _TargetItem(id, Offset(dx, dy), isThreat, icon);
  }

  void _handleTap(_TargetItem item) {
    if (_gameOver) return;

    if (item.isThreat) {
      setState(() {
        _items.removeWhere((it) => it.id == item.id);
        _foundThreats++;
      });
      
      if (_foundThreats >= _totalThreats) {
        _finishGame();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Das ist keine Gefahr, nur eine Ablenkung!"), 
          duration: Duration(milliseconds: 500),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _finishGame() {
    setState(() { _gameOver = true; });
    
    // QuizScreen und QuizData kommen aus deiner mentalhealthGames.dart
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizScreen(
        questions: [
          QuizData(
              question: "Was ist die Hauptaufgabe der Amygdala?",
              correctAnswer: "Gefahrenerkennung",
              wrongAnswers: ["Sprachsteuerung", "Verdauung"],
              explanation: "Sie entscheidet blitzschnell über 'Kampf oder Flucht'."
          ),
          QuizData(
              question: "Warum ist sie bei Angst problematisch?",
              correctAnswer: "Zu viele Fehlalarme",
              wrongAnswers: ["Sie schläft ein", "Sie wächst unendlich"],
              explanation: "Sie reagiert auf neutrale Reize (wie die Wolken) so, als wären es Gefahren."
          )
        ],
        onQuizCompleted: (quizContext) {
          Navigator.pushReplacement(
              quizContext,
              MaterialPageRoute(builder: (_) => const MentalMapScreen())
          );
        },
      )));
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset("assets/images/WoodBackgroundNight.jpg", fit: BoxFit.cover, height: double.infinity, width: double.infinity),
          
          // Infotafel oben
           Positioned(
            top: 0, left: 0, right: 0,
            child: Center(
              child: SizedBox(
                width: size.width * 0.8,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset("assets/images/woodPlank.png", fit: BoxFit.fill),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Finde die Blitze!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Courier')),
                          Text("Gefunden: $_foundThreats / $_totalThreats", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Courier')),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // Die Symbole
          ..._items.map((item) {
            return Positioned(
              left: item.position.dx * size.width,
              top: item.position.dy * size.height,
              child: GestureDetector(
                onTap: () => _handleTap(item),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1), 
                    boxShadow: item.isThreat 
                      ? [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)] 
                      : [],
                  ),
                  child: Icon(
                    item.icon,
                    size: 40,
                    color: item.isThreat ? Colors.yellow : Colors.white70,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}