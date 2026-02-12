import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brainjourney/brain_bottom_navigation.dart'; // Deine Nav-Bar
import 'package:brainjourney/start.dart'; // Für Logout
import 'package:brainjourney/homeMentalHealth.dart'; // Für Navigation

class ProfilePage extends StatefulWidget {
  final bool mental; 

  const ProfilePage({super.key, this.mental = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "Loading...";
  int completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Unknown Researcher";
      final list = prefs.getStringList('completedLevels') ?? [];
      completedCount = list.length;
    });
  }

  Future<void> _logout() async {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const StartScreen()),
      (route) => false,
    );
  }

  // --- NEU: PASSWORT ÄNDERN LOGIK ---
  void _showChangePasswordDialog() {
    final TextEditingController oldPassCtrl = TextEditingController();
    final TextEditingController newPassCtrl = TextEditingController();
    final TextEditingController confirmPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFDFBD4), // Papier-Farbe
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.brown, width: 3),
          ),
          title: const Text("SECURITY UPDATE", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, color: Colors.brown)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField("Current Code", oldPassCtrl),
                const SizedBox(height: 10),
                _buildDialogTextField("New Code", newPassCtrl),
                const SizedBox(height: 10),
                _buildDialogTextField("Confirm New Code", confirmPassCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _updatePassword(oldPassCtrl.text, newPassCtrl.text, confirmPassCtrl.text),
              child: const Text("UPDATE"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePassword(String oldPass, String newPass, String confirm) async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedPass = prefs.getString('userPass');

    if (oldPass != storedPass) {
      _showSnack("Current code is incorrect!");
      return;
    }
    if (newPass.isEmpty || newPass.length < 3) {
      _showSnack("New code is too short!");
      return;
    }
    if (newPass != confirm) {
      _showSnack("New codes do not match!");
      return;
    }

    // Speichern
    await prefs.setString('userPass', newPass);
    Navigator.pop(context); // Dialog schließen
    _showSnack("Secret code updated successfully!", isSuccess: true);
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isSuccess ? Colors.green[700] : Colors.red[800],
    ));
  }

  Widget _buildDialogTextField(String hint, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      style: const TextStyle(color: Colors.brown),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: Colors.brown.withOpacity(0.6)),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.brown)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.brown, width: 2)),
      ),
    );
  }
  // -------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BrainNavigationBar(
        currentIndex: 4, 
        mental: widget.mental, 
      ),
      body: Stack(
        children: [
          // 1. HELLER HINTERGRUND
          Positioned.fill(
            child: Image.asset("assets/images/WoodBackground.jpg", fit: BoxFit.cover),
          ),
          
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // PROFILBILD
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.brown, width: 4),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/brainThinking.png"), 
                        fit: BoxFit.contain,
                      ),
                      color: const Color(0xFFFDFBD4),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0,5))],
                    ),
                  ),
                  const SizedBox(height: 30),
            
                  // AUSWEIS-KARTE
                  Container(
                    width: 320,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFBD4), // Papier-Farbe
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.brown, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        const Text("RESEARCHER ID", style: TextStyle(fontFamily: 'Courier', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
                        const Divider(color: Colors.brown, thickness: 2, height: 30),
                        
                        // Name Zeile
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.brown, size: 28),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("NAME", style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Courier')),
                                  Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Courier')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Statistik Zeile
                        Row(
                          children: [
                            const Icon(Icons.military_tech, color: Colors.amber, size: 30), 
                            const SizedBox(width: 15),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("BADGES EARNED", style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Courier')),
                                  Text("$completedCount", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown, fontFamily: 'Courier')),
                                ],
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 25),
                        // BUTTON: PASSWORT ÄNDERN (Innerhalb der Karte für sauberes Layout)
                        OutlinedButton.icon(
                          onPressed: _showChangePasswordDialog,
                          icon: const Icon(Icons.lock_reset, size: 18),
                          label: const Text("CHANGE SECRET CODE"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.brown,
                            side: const BorderSide(color: Colors.brown),
                            textStyle: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
            
                  // LOGOUT BUTTON
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800], // Dunkelrot
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 5,
                    ),
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("LOGOUT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}