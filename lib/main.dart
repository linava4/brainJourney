import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Deine Imports
import 'package:brainjourney/intro.dart'; // Hier drin ist die Klasse "HomeScreen"
import 'package:brainjourney/start.dart'; // Hier drin ist die Klasse "StartScreen"

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prüfen, ob schon registriert
  final prefs = await SharedPreferences.getInstance();
  final bool isRegistered = prefs.getBool('isRegistered') ?? false;

  // Entscheidung treffen:
  // Wenn registriert -> StartScreen (Login)
  // Wenn NICHT registriert -> HomeScreen (Dein Intro aus intro.dart)
  Widget initialScreen = isRegistered ? const StartScreen() : const HomeScreen();

  runApp(BrainJourneyApp(screen: initialScreen));
}

class BrainJourneyApp extends StatelessWidget {
  final Widget screen;

  const BrainJourneyApp({super.key, required this.screen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainJourney',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Courier', // Damit die Schriftart überall passt
      ),
      home: screen, // Hier wird die ausgewählte Seite geladen
    );
  }
}





