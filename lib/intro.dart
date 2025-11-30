// intro.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import 'home.dart';

// ------------------------------------------------------
// INTRO
// ------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _dialogStep = 0;

  final List<String> dialog = [
    "Hey! Ich bin dein Gehirn! Willkommen bei BrainJourney!",
    "Ich begleite dich auf einer Reise durch meine verschiedenen Regionen...",
    "Gemeinsam entdecken wir, wie Gefühle, Sprache, Gedächtnis & vieles mehr funktionieren!",
    "Bist du bereit? Dann komm zur Gehirn-Karte und wähle eine Station!",
  ];

  void _next() {
    setState(() {
      if (_dialogStep < dialog.length - 1) {
        _dialogStep++;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BrainMapScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F2F8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.webp'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Text(
                  dialog[_dialogStep],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF200D0B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _dialogStep < dialog.length - 1 ? "Weiter" : "Zur Gehirn-Karte",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}