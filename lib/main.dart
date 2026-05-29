import 'package:aadhyai/onboard/login_screen/login_screen.dart';
import 'package:aadhyai/onboard/onboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'dash_board/dash_board_screen.dart';
import 'firebase_options.dart';

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
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AadhyaAI',

          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: const Color(0xff0F172A),

            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff6366F1),
              brightness: Brightness.dark,
            ),
          ),

          home: const DashboardScreen(),

          routes: {
            '/onboard': (context) => const OnboardScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const DashboardScreen(),
          },
        );
      },
    );
  }
}