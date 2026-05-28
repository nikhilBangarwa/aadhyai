import 'package:aadhyai/onboard/home_screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'onboard/login_screen/login_screen.dart';
import 'onboard/onboard_screen.dart';
import 'onboard/splash_screen/splash_screen.dart';

// import 'home_screen.dart'; // apna home screen import karo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AadhyaApp());
}

class AadhyaApp extends StatelessWidget {
  const AadhyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AadhyaAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF7B2FBE),
        useMaterial3: true,
        fontFamily: 'Poppins', // optional
      ),
      // Splash hamesha pehle
      home: const SplashScreen(),
      routes: {
        '/onboard': (_) => const OnboardScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}


