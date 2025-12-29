import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_property_inspection/loginscreen.dart';

void main() {
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

// SPLASH SCREEN
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // SPLASH DELAY → LOGIN SCREEN
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
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
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: screenHeight * 0.18,
                width: screenHeight * 0.18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2F3E46).withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.home_work,
                  size: 90,
                  color: Color(0xFF2F3E46),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Smart Property Inspection",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F3E46),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Record inspections efficiently",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 35),

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
