import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_property_inspection/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔴 IMPORTANT: reset login state so LoginScreen is shown
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', false);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Smart Property Inspection",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Arial",
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F3E46),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ================= SPLASH SCREEN =================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  static const Color bgDarkBlue = Color(0xFF2F3E46);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // SPLASH DELAY → LOGIN SCREEN
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: bgDarkBlue,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO
              Container(
                height: screenHeight * 0.18,
                width: screenHeight * 0.18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.home_work,
                  size: 90,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // TITLE
              const Text(
                "Smart Property Inspection",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              // SUBTITLE
              const Text(
                "Record inspections efficiently",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 35),

              // LOADING
              const CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF4CAF50),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
