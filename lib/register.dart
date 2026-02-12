import 'package:brainjourney/helpers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brainjourney/start.dart'; // To go to Login after registration
import 'package:brainjourney/cerebellum.dart'; // For WoodButton

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final pass = _passController.text.trim();
    final confirm = _confirmPassController.text.trim();

    if (name.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields!")),
      );
      return;
    }

    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    // Save Data
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userPass', pass);
    await prefs.setBool('isRegistered', true); // Mark as registered

    if (mounted) {
      // Go to Login Screen
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const StartScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // Bright Background
          Positioned.fill(
            child: Image.asset("assets/images/WoodBackground.jpg", fit: BoxFit.cover),
          ),
          
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                      border: Border.all(color: Colors.brown, width: 4),
                    ),
                    child: const Icon(Icons.person_add, size: 60, color: Colors.brown),
                  ),
                  const SizedBox(height: 30),
                  
                  // Title
                  const Text(
                    "NEW RESEARCHER",
                    style: TextStyle(
                      fontFamily: 'Courier', 
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.brown,
                      shadows: [Shadow(blurRadius: 2, color: Colors.white, offset: Offset(1,1))]
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Input Fields
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFBD4), // Paper color
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.brown, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(Icons.person, "Researcher Name", _nameController, false),
                        const SizedBox(height: 15),
                        _buildTextField(Icons.vpn_key, "Secret Code (Password)", _passController, true),
                        const SizedBox(height: 15),
                        _buildTextField(Icons.lock_reset, "Repeat Code", _confirmPassController, true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Register Button
                  WoodButton(
                    text: "REGISTER", 
                    onPressed: _register,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, TextEditingController controller, bool isObscure) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.brown),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.brown.withOpacity(0.5)),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.brown)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.brown, width: 2)),
      ),
    );
  }
}