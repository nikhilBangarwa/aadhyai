import 'package:aadhyai/onboard/onboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _glowController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Text animation controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Glow pulse
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 3000), () async {
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      Navigator.of(context).pushReplacementNamed(
        isLoggedIn ? '/home' : '/onboard',
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0015),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.2,
                colors: [
                  Color(0xFF2D0A5C),
                  Color(0xFF1A0535),
                  Color(0xFF0A0015),
                ],
              ),
            ),
          ),

          // Animated glow blob behind logo
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) {
              return Center(
                child: Transform.translate(
                  offset: const Offset(0, -60),
                  child: Container(
                    width: size.width * 0.7,
                    height: size.width * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7B2FBE)
                              .withOpacity(0.25 * _glowAnim.value),
                          blurRadius: 120,
                          spreadRadius: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Star particles
          ..._buildStars(size),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (_, __) {
                    return FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: size.width * 0.38,
                          height: size.width * 0.38,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // App name + tagline
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        // AadhyAI text
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Aadhya',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                              TextSpan(
                                text: 'AI',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFB46EFF),
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Tagline
                        FadeTransition(
                          opacity: _taglineFade,
                          child: const Text(
                            'Padhai. Practice. Progress.',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFFB89FD4),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom loading dots
          Positioned(
            bottom: size.height * 0.08,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textFade,
              child: const _PulsingDots(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars(Size size) {
    final stars = [
      _StarParticle(top: size.height * 0.12, left: size.width * 0.1, size: 3),
      _StarParticle(top: size.height * 0.18, left: size.width * 0.8, size: 2),
      _StarParticle(top: size.height * 0.25, left: size.width * 0.65, size: 4),
      _StarParticle(top: size.height * 0.35, left: size.width * 0.15, size: 2),
      _StarParticle(top: size.height * 0.72, left: size.width * 0.25, size: 3),
      _StarParticle(top: size.height * 0.78, left: size.width * 0.75, size: 2),
      _StarParticle(top: size.height * 0.85, left: size.width * 0.5, size: 3),
    ];
    return stars
        .map((s) => Positioned(
      top: s.top,
      left: s.left,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (_, __) => Opacity(
          opacity: 0.3 + 0.7 * _glowAnim.value,
          child: Container(
            width: s.size,
            height: s.size,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    ))
        .toList();
  }
}

class _StarParticle {
  final double top, left, size;
  const _StarParticle(
      {required this.top, required this.left, required this.size});
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final delay = i * 0.33;
            final val = ((_ctrl.value - delay) % 1.0).abs();
            final opacity = val < 0.5 ? val * 2 : (1 - val) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                    180, 110, 255, opacity.clamp(0.2, 1.0)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}