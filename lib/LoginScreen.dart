import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_property_inspection/RegisterScreen.dart';
import 'package:smart_property_inspection/MainScreen.dart';

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
  String storedUsername = "";

  static const Color bgDarkBlue = Color(0xFF2F3E46);

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

  // AUTO LOGIN
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    storedUsername = prefs.getString('username') ?? "";
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && storedUsername.isNotEmpty) {
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
      backgroundColor: bgDarkBlue,
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
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.home_work,
                  size: 60,
                  color: bgDarkBlue,
                ),
                const SizedBox(height: 16),

                const Text(
                  "Smart Property Inspection",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: bgDarkBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                const Text(
                  "Login using your registered username",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),

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
                      foregroundColor: Colors.white,
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

                // 🔽 SIMPLE TEXT BUTTON (MATCH REGISTER STYLE)
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Register / Set Username",
                    style: TextStyle(
                      color: bgDarkBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SINGLE USER LOGIN VALIDATION
  Future<void> _handleLogin() async {
    String inputUsername = usernameController.text.trim();

    if (inputUsername.isEmpty) {
      _showMessage("Please enter username");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String savedUsername = prefs.getString('username') ?? "";

    if (savedUsername.isEmpty) {
      _showMessage("No user registered. Please register first.");
      return;
    }

    if (inputUsername != savedUsername) {
      _showMessage("Username does not match registered user");
      return;
    }

    await prefs.setBool('isLoggedIn', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
