import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  final TextEditingController _nameCtrl = TextEditingController();
  int? _selectedClass;
  bool _isLoading = false;
  String? _errorMsg;

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  final List<String> _classes = [
    '1st', '2nd', '3rd', '4th', '5th', '6th',
    '7th', '8th', '9th', '10th', '11th', '12th',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideCtrl, curve: Curves.easeIn),
    );
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    setState(() => _errorMsg = null);
    if (_step == 0 && _nameCtrl.text.trim().isEmpty) {
      setState(() => _errorMsg = 'Please enter your name');
      return;
    }
    if (_step == 1 && _selectedClass == null) {
      setState(() => _errorMsg = 'Please select your class');
      return;
    }
    if (_step < 2) {
      _slideCtrl.reset();
      setState(() => _step++);
      _slideCtrl.forward();
    }
  }

  Future<void> _googleSignIn() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      await GoogleSignIn.instance.initialize();

      // v7.2.0 — authenticate() directly returns GoogleSignInAccount
      final account = await GoogleSignIn.instance.authenticate();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameCtrl.text.trim());
      await prefs.setInt('user_class', _selectedClass!);
      await prefs.setString('user_email', account.email);
      await prefs.setString('user_photo', account.photoUrl ?? '');
      await prefs.setBool('is_logged_in', true);

      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF7B2FBE).withOpacity(0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF9B4DFF).withOpacity(0.08),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 24, 0),
                  child: Row(
                    children: [
                      if (_step > 0)
                        IconButton(
                          onPressed: () {
                            _slideCtrl.reset();
                            setState(() { _step--; _errorMsg = null; });
                            _slideCtrl.forward();
                          },
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFF7B2FBE), size: 20),
                        )
                      else
                        const SizedBox(width: 48),
                      const Spacer(),
                      // Step counter
                      Text(
                        'Step ${_step + 1} of 3',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9B7DC0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / 3,
                      minHeight: 4,
                      backgroundColor: const Color(0xFF7B2FBE).withOpacity(0.12),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF7B2FBE)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildStep(size),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(Size size) {
    switch (_step) {
      case 0: return _buildNameStep();
      case 1: return _buildClassStep(size);
      case 2: return _buildGoogleStep();
      default: return const SizedBox();
    }
  }

  // ── Step 1: Name ──────────────────────────────────────────────────────────

  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EmojiChip(emoji: '👋', color: const Color(0xFF7B2FBE)),
          const SizedBox(height: 20),
          const Text(
            "What's your name?",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A0535),
              height: 1.15,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "We'll personalise your learning experience.",
            style: TextStyle(
              fontSize: 17,
              color: Color(0xFF8A7A9B),
              fontWeight: FontWeight.w800,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Name field
          _InputCard(
            child: TextField(
              controller: _nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A0535),
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Rahul, Priya...',
                hintStyle: TextStyle(
                  color: const Color(0xFF1A0535).withOpacity(0.28),
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
                prefixIcon: const _FieldIcon(icon: Icons.person_outline_rounded),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onSubmitted: (_) => _goNext(),
            ),
          ),

          if (_errorMsg != null) _ErrorText(msg: _errorMsg!),
          const Spacer(),
          _PrimaryButton(label: 'Continue', onTap: _goNext),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Step 2: Class ─────────────────────────────────────────────────────────

  Widget _buildClassStep(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EmojiChip(emoji: '📚', color: const Color(0xFF5B4FCF)),
          const SizedBox(height: 20),
          Text(
            'Hello, ${_nameCtrl.text.trim()}!',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A0535),
              height: 1.15,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Which class are you in?',
            style: TextStyle(
              fontSize: 19,
              color: Color(0xFF8A7A9B),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 28),

          // 4-column class grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.05,
            ),
            itemCount: _classes.length,
            itemBuilder: (_, i) {
              final isSelected = _selectedClass == (i + 1);
              return GestureDetector(
                onTap: () => setState(() => _selectedClass = i + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF7B2FBE)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF7B2FBE)
                          : const Color(0xFFE8E0F5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF7B2FBE).withOpacity(0.30)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 14 : 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _classes[i],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1A0535),
                        ),
                      ),
                      Text(
                        'Class',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white.withOpacity(0.75)
                              : const Color(0xFF9B7DC0),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          if (_errorMsg != null) _ErrorText(msg: _errorMsg!),
          const Spacer(),
          _PrimaryButton(label: 'Continue', onTap: _goNext),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Step 3: Google ────────────────────────────────────────────────────────

  Widget _buildGoogleStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B2FBE), Color(0xFF5B1F9E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B2FBE).withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Logo
                Image.asset(
                  'assets/images/app_logo.png',
                  width: 52,
                  height: 52,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameCtrl.text.trim(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_classes[(_selectedClass ?? 1) - 1]} Class',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Almost there!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A0535),
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sign in with Google to save your\nprogress and start learning.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF8A7A9B),
                height: 1.55,
              ),
            ),
          ),

          const Spacer(),

          // Google button
          GestureDetector(
            onTap: _isLoading ? null : _googleSignIn,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0D6F0), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF7B2FBE),
                  ),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CustomPaint(painter: _GoogleIconPainter()),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A0535),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_errorMsg != null) _ErrorText(msg: _errorMsg!),
          const SizedBox(height: 16),

          Text(
            'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF1A0535).withOpacity(0.35),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────

class _EmojiChip extends StatelessWidget {
  final String emoji;
  final Color color;
  const _EmojiChip({required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 30))),
    );
  }
}

class _InputCard extends StatelessWidget {
  final Widget child;
  const _InputCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B2FBE).withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldIcon extends StatelessWidget {
  final IconData icon;
  const _FieldIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 4),
      child: Icon(icon, color: const Color(0xFF7B2FBE), size: 22),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9B4DFF), Color(0xFF6A1FBE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B2FBE).withOpacity(0.38),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String msg;
  const _ErrorText({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 15, color: Color(0xFFE53935)),
          const SizedBox(width: 6),
          Text(msg,
              style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Google Icon Painter ──────────────────────────────────────────────────

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final sw = size.width * 0.19;

    void arc(double start, double sweep, Color color) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r - sw / 2),
        start, sweep, false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
    }

    arc(-1.57, 3.14, const Color(0xFF4285F4));
    arc(1.57, 1.57, const Color(0xFFEA4335));
    arc(3.14, 0.8, const Color(0xFFFBBC05));
    arc(3.93, 0.8, const Color(0xFF34A853));
  }

  @override
  bool shouldRepaint(_) => false;
}