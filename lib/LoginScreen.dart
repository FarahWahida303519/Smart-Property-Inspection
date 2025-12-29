import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:smart_property_inspection/mainscreen.dart';
import 'package:smart_property_inspection/registerscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final TextEditingController usernameController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fade;

  bool prefsLoaded = false;
  String username = "";

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadPrefs();
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  // LOAD SESSION (AUTO LOGIN)
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username') ?? "";
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && username.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      setState(() => prefsLoaded = true);
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (!prefsLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            width: screenWidth < 500 ? screenWidth * 0.9 : 380,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F8),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.home_work,
                  size: 60,
                  color: Color(0xFF2F3E46),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Smart Property Inspection",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F3E46),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                const Text(
                  "Enter your username to continue",
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 24),

                // USERNAME FIELD
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _handleLogin,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

               
              ],
            ),
          ),
        ),
      ),
    );
  }

  // LOGIN HANDLER (SAME LOGIC PURPOSE)
  Future<void> _handleLogin() async {
    if (usernameController.text.trim().isEmpty) {
      _showMessage("Please enter username");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }
 
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
