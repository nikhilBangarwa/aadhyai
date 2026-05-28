import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_PageData> _pages = const [
    _PageData(image: 'assets/onboard/ONboard1.png', isDark: false),
    _PageData(image: 'assets/onboard/ONboard2.png', isDark: true),
    _PageData(image: 'assets/onboard/ONboard3.png', isDark: false),
  ];

  @override
  void initState() {
    super.initState();
    _updateStatusBar(0);
  }

  void _updateStatusBar(int page) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
      _pages[page].isDark ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // TODO: Navigate to home/login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    final isDark = _pages[_currentPage].isDark;
    final dotColor = isDark ? Colors.white : const Color(0xFF7B2FBE);

    return Scaffold(
      body: Stack(
        children: [
          // Full screen page view
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              _updateStatusBar(i);
            },
            itemCount: _pages.length,
            itemBuilder: (_, index) => Image.asset(
              _pages[index].image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Bottom overlay — dots + button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 28,
                right: 28,
                bottom: MediaQuery.of(context).padding.bottom + 28,
                top: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(isDark ? 0.5 : 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left spacer — same width as button for centering dots
                  const SizedBox(width: 56),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? dotColor
                              : dotColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Next / Get Started button
                  GestureDetector(
                    onTap: _nextPage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: isLast ? 22 : 18,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B2FBE),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7B2FBE).withOpacity(0.45),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLast) ...[
                            TextButton(onPressed: (){
                              Navigator.of(context).pushReplacementNamed('/login');
                            }, child: Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),)
                            ),
                            const SizedBox(width: 6),
                          ],
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top right mein
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // directly last page pe jao
                _pageController.animateToPage(
                  _pages.length - 1,
                  duration: Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  color: isDark ? Colors.black : Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  final String image;
  final bool isDark;
  const _PageData({required this.image, required this.isDark});
}