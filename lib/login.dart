import 'package:brainjourney/start.dart';
import 'package:flutter/material.dart';
import 'package:brainjourney/home.dart';

import 'cerebellum.dart'; // Deine Home-Datei importieren

// ------------------------------------------------------
// LOGIN SCREEN
// ------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  // Für Feedback (Fehlermeldungen)
  String _errorMessage = "";
  bool _isLoading = false;

  final TextStyle handStyle = TextStyle(
    fontFamily: 'Courier',
    color: Colors.brown[900],
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  void _performLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    // SIMULIERTER LOGIN (Hier später dein echtes Backend einfügen)
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    // Einfache Validierung als Beispiel
    if (_userController.text.isNotEmpty && _pwController.text.isNotEmpty) {
      if (!mounted) return;
      // Weiterleitung zur Brain Map (Home)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StartScreen()), // Deine Hauptklasse
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "Benutzername oder Code fehlt!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Verhindert, dass Hintergrund verzerrt wird
      body: Stack(
        children: [
          // 1. HINTERGRUND (Holz)
          Positioned.fill(
            child: Image.asset(
              "assets/images/WoodBackground.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // 2. PAPIERROLLE (Formular Container)
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.65,
              margin: const EdgeInsets.only(top: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Das Papier-Bild
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.asset(
                        "assets/images/paperRoll.png",
                        fit: BoxFit.fill
                    ),
                  ),

                  // Der Inhalt auf dem Papier
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45.0, vertical: 60.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                            'assets/images/brainCard.png',
                            height: 80,
                            fit: BoxFit.contain,
                            errorBuilder: (c, o, s) => Icon(Icons.lock_outline, size: 50, color: Colors.brown[800])
                        ),
                        // Kleines Icon oben auf dem Papier

                        const SizedBox(height: 10),

                        Text(
                          "Identifiziere dich,",
                          style: handStyle.copyWith(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Reisender!",
                          style: handStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 30),

                        // USERNAME FELD
                        _buildRetroTextField(
                          controller: _userController,
                          hint: "Name / Forscher-ID",
                          icon: Icons.person,
                        ),

                        const SizedBox(height: 15),

                        // PASSWORD FELD
                        _buildRetroTextField(
                          controller: _pwController,
                          hint: "Geheimcode",
                          icon: Icons.vpn_key,
                          obscure: true,
                        ),

                        const SizedBox(height: 15),

                        // ERROR MESSAGE
                        if (_errorMessage.isNotEmpty)
                          Text(
                            _errorMessage,
                            style: handStyle.copyWith(color: Colors.red[900], fontSize: 14),
                            textAlign: TextAlign.center,
                          ),

                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.all(0.0),
                            child: CircularProgressIndicator(color: Colors.brown),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. SCHILD (Header "ZUGANG")
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,

                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                        "assets/images/woodPlank.png",
                        width: double.infinity,
                        fit: BoxFit.fill
                    ),
                    Positioned(
                      top: 55,
                      child:
                        Text(
                          "Zugang",
                          style: handStyle.copyWith(
                              fontSize: 32,
                              color: const Color(0xFF3E2723),
                              letterSpacing: 3,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                const Shadow(blurRadius: 2, color: Colors.white38, offset: Offset(1,1))
                              ]
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),



          // 5. LOGIN BUTTON (Unten Mitte)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: WoodButton(
                text: "Eintreten",
                onPressed: _performLogin,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hilfswidget für die Textfelder im "alten Stil"
  Widget _buildRetroTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFFDF5E6), // Papierfarbe
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown[800]!, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))
          ]
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
            color: Colors.brown[900],
            fontSize: 18
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.brown.withOpacity(0.5), fontFamily: 'Courier'),
          prefixIcon: Icon(icon, color: Colors.brown[700]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

