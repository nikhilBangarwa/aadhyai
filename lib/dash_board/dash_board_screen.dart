import 'package:aadhyai/AI/screen/chat_ai_screen.dart';
import 'package:aadhyai/onboard/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late PageController _pageCtrl;
  final _notchController = AnimationController.unbounded;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  final List<Widget> _screens =  [
    HomeScreen(),
    _PracticeScreen(),
    ChatAiScreen(),
    _ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      extendBody: true,
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Center FAB (AI Tutor) ─────────────────────────────────────────────

  Widget _buildFAB() {
    final isSelected = _currentIndex == 2;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = 2);
        _pageCtrl.jumpToPage(2);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: isSelected
                ? [const Color(0xFF9B4DFF), const Color(0xFF6A1FBE)]
                : [const Color(0xFFEDE7FF), const Color(0xFFD4C5F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B2FBE).withOpacity(isSelected ? 0.50 : 0.20),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          Icons.auto_awesome,
          color: isSelected ? Colors.white : const Color(0xFF7B2FBE),
          size: 28,
        ),
      ),
    );
  }


  Widget _buildBottomBar() {
    return StylishBottomBar(
      option: AnimatedBarOptions(
        iconSize: 2.4.h,
        barAnimation: BarAnimation.fade,
        iconStyle: IconStyle.animated,
        opacity: 0.4,
        inkEffect: true,
        inkColor: const Color(0xFF7B2FBE).withOpacity(0.10),
      ),
      backgroundColor: Colors.white,
      hasNotch: true,
      notchStyle: NotchStyle.circle,
      currentIndex: _currentIndex == 2 ? 0 : _currentIndex > 2 ? _currentIndex - 1 : _currentIndex,
      items: [
        BottomBarItem(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          title: const Text('Home',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF7B2FBE),
          selectedColor: const Color(0xFF7B2FBE),
          unSelectedColor: const Color(0xFFB0A0C8),
        ),
        BottomBarItem(
          icon: const Icon(Icons.menu_book_outlined),
          selectedIcon: const Icon(Icons.menu_book_rounded),
          title: const Text('Practice',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF5B4FCF),
          selectedColor: const Color(0xFF5B4FCF),
          unSelectedColor: const Color(0xFFB0A0C8),
        ),
        BottomBarItem(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          title: const Text('Profile',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF7B2FBE),
          selectedColor: const Color(0xFF7B2FBE),
          unSelectedColor: const Color(0xFFB0A0C8),
        ),
        BottomBarItem(
          icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: const Icon(Icons.bar_chart_rounded),
          title: const Text('Progress',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFF2D9CDB),
          selectedColor: const Color(0xFF2D9CDB),
          unSelectedColor: const Color(0xFFB0A0C8),
        ),
      ],
      onTap: (index) {
        // Map 4-item bar index back to 5-screen index (skip 2 = AI)
        final mapped = index >= 2 ? index + 1 : index;
        setState(() => _currentIndex = mapped);
        _pageCtrl.jumpToPage(mapped);
      },
    );
  }
}

// ─── Placeholder Screens ───────────────────────────────────────────────────

class _PracticeScreen extends StatelessWidget {
  const _PracticeScreen();
  @override
  Widget build(BuildContext context) => const _PlaceholderView(
      emoji: '📝', title: 'Practice',
      subtitle: 'Quizzes & exercises coming soon');
}

class _AIScreen extends StatelessWidget {
  const _AIScreen();
  @override
  Widget build(BuildContext context) => const _PlaceholderView(
      emoji: '🤖', title: 'AI Tutor',
      subtitle: 'Your personal AI tutor coming soon');
}

class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();
  @override
  Widget build(BuildContext context) => const _PlaceholderView(
      emoji: '👤', title: 'Profile',
      subtitle: 'Your profile coming soon');
}


class _PlaceholderView extends StatelessWidget {
  final String emoji, title, subtitle;
  const _PlaceholderView(
      {required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800,
                    color: Color(0xFF1A0535))),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(fontSize: 14, color: Color(0xFF9B7DC0))),
          ],
        ),
      ),
    );
  }
}