import 'package:aadhyai/onboard/subject/subject_section/subject_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _name = '';
  int _classNum = 0;
  String _photo = '';
  String _email = '';

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? '';
      _classNum = prefs.getInt('user_class') ?? 0;
      _photo = prefs.getString('user_photo') ?? '';
      _email = prefs.getString('user_email') ?? '';
    });
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String get _classLabel {
    if (_classNum < 1 || _classNum > 12) return '';
    return '${_classes[_classNum - 1]} Class';
  }

  String get _initials {
    final parts = _name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeBanner(),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Quick Access'),

                      _buildQuickAccess(),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Continue Learning'),
                      const SizedBox(height: 14),
                      _buildContinueCards(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFFF7F4FF),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      expandedHeight: 0,
      toolbarHeight: 68,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(radius: 22),

              const SizedBox(width: 12),

              // Name + Class
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name.isEmpty ? 'Welcome!' : 'Hi, $_name 👋',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A0535),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_classLabel.isNotEmpty)
                      Text(
                        _classLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9B7DC0),
                        ),
                      ),
                  ],
                ),
              ),

              // Notification icon
              _IconBtn(
                icon: Icons.notifications_outlined,
                badge: true,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              // Settings icon
              _IconBtn(
                icon: Icons.settings_outlined,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Avatar ──────────────────────────────────────────────────────────────

  Widget _buildAvatar({double radius = 24}) {
    if (_photo.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(_photo),
        backgroundColor: const Color(0xFFE8E0F5),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF7B2FBE),
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0,
        ),
      ),
    );
  }

  // ── Welcome Banner ──────────────────────────────────────────────────────

  Widget _buildWelcomeBanner() {
    return Container(
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
            color: const Color(0xFF7B2FBE).withOpacity(0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name.isEmpty
                      ? "Let's start learning!"
                      : "Let's go, $_name!",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _classLabel.isEmpty
                      ? 'Your AI study partner'
                      : '$_classLabel • AI-powered learning',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.78),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '✨  Ask AadhyaAI anything',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildAvatar(radius: 32),
        ],
      ),
    );
  }

  // ── Section Title ───────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A0535),
        letterSpacing: -0.3,
      ),
    );
  }

  // ── Quick Access Grid ───────────────────────────────────────────────────

  Widget _buildQuickAccess() {
    final items = [
      _QuickItem(
        emoji: '🧠',
        label: 'AI Tutor',
        color: const Color(0xFF7B2FBE),
        onTap: () => Navigator.of(context).pushNamed('/ai-tutor'),
      ),
      _QuickItem(
        emoji: '📝',
        label: 'Practice',
        color: const Color(0xFF5B4FCF),
        onTap: () => Navigator.of(context).pushNamed('/practice'),
      ),
      _QuickItem(
        emoji: '📊',
        label: 'Progress',
        color: const Color(0xFF2D9CDB),
        onTap: () => Navigator.of(context).pushNamed('/progress'),
      ),
      _QuickItem(
        emoji: '📚',
        label: 'Subjects',
        color: const Color(0xFF27AE60),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SubjectScreen()),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return GestureDetector(
          onTap: item.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(item.emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A0535),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Continue Learning Cards ─────────────────────────────────────────────

  Widget _buildContinueCards() {
    final cards = [
      _LearnCard(
        subject: 'Mathematics',
        topic: 'Quadratic Equations',
        progress: 0.65,
        emoji: '📐',
        color: const Color(0xFF7B2FBE),
      ),
      _LearnCard(
        subject: 'Science',
        topic: 'Laws of Motion',
        progress: 0.40,
        emoji: '⚗️',
        color: const Color(0xFF2D9CDB),
      ),
      _LearnCard(
        subject: 'English',
        topic: 'Grammar & Writing',
        progress: 0.80,
        emoji: '✍️',
        color: const Color(0xFF27AE60),
      ),
    ];

    return Column(
      children: cards.map((card) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: card.color.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child:
                  Text(card.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.subject,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: card.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.topic,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A0535),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: card.progress,
                        minHeight: 5,
                        backgroundColor: card.color.withOpacity(0.12),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(card.color),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow_rounded,
                    color: card.color, size: 20),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Bottom Nav ──────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B2FBE).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Home', selected: true),
              _NavItem(icon: Icons.auto_stories_outlined, label: 'Learn'),
              _NavItem(icon: Icons.quiz_outlined, label: 'Practice'),
              _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper Models ────────────────────────────────────────────────────────

class _QuickItem {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickItem({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _LearnCard {
  final String subject, topic, emoji;
  final double progress;
  final Color color;

  const _LearnCard({
    required this.subject,
    required this.topic,
    required this.progress,
    required this.emoji,
    required this.color,
  });
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool badge;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B2FBE).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: const Color(0xFF7B2FBE), size: 22),
            if (badge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem(
      {required this.icon, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final color =
    selected ? const Color(0xFF7B2FBE) : const Color(0xFFB0A0C8);
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF7B2FBE).withOpacity(0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}