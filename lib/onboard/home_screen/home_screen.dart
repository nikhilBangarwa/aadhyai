import 'package:aadhyai/onboard/subject/subject_section/subject_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

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

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<String> _classes = [
    '1st','2nd','3rd','4th','5th','6th',
    '7th','8th','9th','10th','11th','12th',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
            CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name     = prefs.getString('user_name') ?? '';
      _classNum = prefs.getInt('user_class') ?? 0;
      _photo    = prefs.getString('user_photo') ?? '';
    });
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String get _classLabel =>
      (_classNum >= 1 && _classNum <= 12) ? '${_classes[_classNum - 1]} Class' : '';

  String get _initials {
    final p = _name.trim().split(' ');
    if (p.isEmpty || p[0].isEmpty) return '?';
    return p.length == 1
        ? p[0][0].toUpperCase()
        : (p[0][0] + (p[1].isNotEmpty ? p[1][0] : '')).toUpperCase();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────

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
                  padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeBanner(),
                      SizedBox(height: 2.h),
                      _buildStreakAndGoal(),
                      SizedBox(height: 2.5.h),
                      _buildSectionTitle('Quick Access'),
                      SizedBox(height: 1.2.h),
                      _buildQuickAccess(),
                      SizedBox(height: 2.5.h),
                      _buildSectionTitle('Continue Learning'),
                      SizedBox(height: 1.2.h),
                      _buildContinueCards(),
                      SizedBox(height: 2.5.h),
                      _buildSectionTitle('Weekly Performance'),
                      SizedBox(height: 1.2.h),
                      _buildWeeklyPerformance(),
                      SizedBox(height: 2.5.h),
                      _buildSectionTitle('Recommended'),
                      SizedBox(height: 1.2.h),
                      _buildRecommendedSubjects(),
                      SizedBox(height: 2.5.h),
                      _buildSectionTitle('Achievements'),
                      SizedBox(height: 1.2.h),
                      _buildAchievements(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFFF7F4FF),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      toolbarHeight: 8.h,
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              _buildAvatar(radius: 5.8.w),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name.isEmpty ? 'Welcome!' : 'Hi, $_name 👋',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A0535),
                      ),
                    ),
                    if (_classLabel.isNotEmpty)
                      Text(
                        _classLabel,
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color: const Color(0xFF9B7DC0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              _IconBtn(icon: Icons.notifications_outlined, badge: true),
              SizedBox(width: 2.w),
              _IconBtn(icon: Icons.settings_outlined),
            ],
          ),
        ),
      ),
    );
  }

  // ── AVATAR ─────────────────────────────────────────────────────────────

  Widget _buildAvatar({double radius = 24}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF7B2FBE),
      backgroundImage: _photo.isNotEmpty ? NetworkImage(_photo) : null,
      child: _photo.isEmpty
          ? Text(_initials,
          style: TextStyle(
            fontSize: radius * 0.65,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ))
          : null,
    );
  }

  // ── WELCOME BANNER ─────────────────────────────────────────────────────

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B2FBE), Color(0xFF5B1F9E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B2FBE).withOpacity(0.38),
            blurRadius: 25,
            offset: const Offset(0, 10),
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
                  _name.isEmpty ? "Let's start learning!" : "Let's go, $_name!",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 0.6.h),
                Text(
                  _classLabel.isEmpty
                      ? 'Your AI study partner'
                      : '$_classLabel • AI-powered learning',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white.withOpacity(0.80),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                // AI Search bar
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 4.w, vertical: 1.4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.25), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome,
                          color: Colors.white, size: 4.5.w),
                      SizedBox(width: 2.w),
                      Text(
                        'Ask AadhyaAI anything',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          _buildAvatar(radius: 9.w),
        ],
      ),
    );
  }

  // ── STREAK + GOAL (side by side) ───────────────────────────────────────

  Widget _buildStreakAndGoal() {
    return Row(
      children: [
        // Streak card
        Expanded(
          child: Container(
            padding: EdgeInsets.all(3.8.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
              ),
              borderRadius: BorderRadius.circular(4.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Text('🔥', style: TextStyle(fontSize: 18.sp)),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '3 Day Streak!',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Don't break it!",
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 3.w),
        // Today's goal card
        Expanded(
          child: Container(
            padding: EdgeInsets.all(3.8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.w),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B2FBE).withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('🎯', style: TextStyle(fontSize: 13.sp)),
                    SizedBox(width: 1.5.w),
                    Text(
                      "Today's Goal",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A0535),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.2.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.70,
                    minHeight: 0.8.h,
                    backgroundColor:
                    const Color(0xFF7B2FBE).withOpacity(0.12),
                    valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF7B2FBE)),
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  '15 Math Problems',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A0535),
                  ),
                ),
                Text(
                  '70% Completed',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9B7DC0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── QUICK ACCESS ───────────────────────────────────────────────────────

  Widget _buildQuickAccess() {
    final items = [
      _QuickItem(emoji: '🧠', label: 'AI Tutor',  color: const Color(0xFF7B2FBE),
          onTap: () => Navigator.of(context).pushNamed('/ai-tutor')),
      _QuickItem(emoji: '📝', label: 'Practice',  color: const Color(0xFF5B4FCF),
          onTap: () => Navigator.of(context).pushNamed('/practice')),
      _QuickItem(emoji: '📊', label: 'Progress',  color: const Color(0xFF2D9CDB),
          onTap: () => Navigator.of(context).pushNamed('/progress')),
      _QuickItem(emoji: '📚', label: 'Subjects',  color: const Color(0xFF27AE60),
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SubjectScreen()))),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: GestureDetector(
            onTap: item.onTap,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              padding: EdgeInsets.symmetric(vertical: 1.8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.w),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 11.w,
                    height: 11.w,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    child: Center(
                      child: Text(item.emoji,
                          style: TextStyle(fontSize: 8.w)),
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A0535),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── CONTINUE LEARNING ──────────────────────────────────────────────────

  Widget _buildContinueCards() {
    final cards = [
      _LearnCard(subject: 'Mathematics', topic: 'Quadratic Equations',
          progress: 0.65, emoji: '📐', color: const Color(0xFF7B2FBE)),
      _LearnCard(subject: 'Science', topic: 'Laws of Motion',
          progress: 0.40, emoji: '⚗️', color: const Color(0xFF2D9CDB)),
      _LearnCard(subject: 'English', topic: 'Grammar & Writing',
          progress: 0.80, emoji: '✍️', color: const Color(0xFF27AE60)),
    ];

    return Column(
      children: cards.map((card) {
        return Container(
          margin: EdgeInsets.only(bottom: 1.8.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.w),
            boxShadow: [
              BoxShadow(
                color: card.color.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 13.w,
                height: 13.w,
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(3.5.w),
                ),
                child: Center(
                  child: Text(card.emoji,
                      style: TextStyle(fontSize: 8.w)),
                ),
              ),
              SizedBox(width: 3.5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.subject,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: card.color,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      card.topic,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A0535),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: card.progress,
                        minHeight: 0.65.h,
                        backgroundColor: card.color.withOpacity(0.12),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(card.color),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow_rounded,
                    color: card.color, size: 6.w),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── WEEKLY PERFORMANCE ─────────────────────────────────────────────────

  Widget _buildWeeklyPerformance() {
    final days   = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final values = [0.35, 0.60, 0.80, 0.45, 0.90, 0.70, 0.30];
    final today  = DateTime.now().weekday - 1;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B2FBE).withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Week',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A0535),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B2FBE).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '4.2 hrs avg',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF7B2FBE),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final isToday = i == today;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isToday)
                    Padding(
                      padding: EdgeInsets.only(bottom: 0.4.h),
                      child: Container(
                        width: 1.5.w,
                        height: 1.5.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7B2FBE),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  Container(
                    width: 7.w,
                    height: 8.h * values[i],
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isToday
                            ? [const Color(0xFF9B4DFF), const Color(0xFF7B2FBE)]
                            : [const Color(0xFFE0D5F5), const Color(0xFFCDBFE8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  SizedBox(height: 0.8.h),
                  Text(
                    days[i],
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: isToday
                          ? FontWeight.bold
                          : FontWeight.bold,
                      color: isToday
                          ? const Color(0xFF7B2FBE)
                          : const Color(0xFF9B7DC0),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── RECOMMENDED SUBJECTS ───────────────────────────────────────────────

  Widget _buildRecommendedSubjects() {
    final subjects = [
      {'name': 'Physics',   'emoji': '⚡', 'color': const Color(0xFF2D9CDB)},
      {'name': 'Chemistry', 'emoji': '🧪', 'color': const Color(0xFF9C27B0)},
      {'name': 'Biology',   'emoji': '🧬', 'color': const Color(0xFF4CAF50)},
      {'name': 'History',   'emoji': '📜', 'color': const Color(0xFF795548)},
      {'name': 'Geography', 'emoji': '🗺️', 'color': const Color(0xFF00BCD4)},
    ];

    return SizedBox(
      height: 17.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        itemBuilder: (_, i) {
          final sub   = subjects[i];
          final color = sub['color'] as Color;
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: 28.w,
              margin: EdgeInsets.only(right: 3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.w),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    child: Center(
                      child: Text(sub['emoji'] as String,
                          style: TextStyle(fontSize: 16.sp)),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    sub['name'] as String,
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A0535),
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    'Recommended',
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── ACHIEVEMENTS ───────────────────────────────────────────────────────

  Widget _buildAchievements() {
    final badges = [
      _Badge(emoji: '🏆', label: 'Top Scorer',  earned: true),
      _Badge(emoji: '🔥', label: '7-Day Streak', earned: true),
      _Badge(emoji: '📚', label: 'Bookworm',     earned: true),
      _Badge(emoji: '⚡', label: 'Speed Solver', earned: false),
      _Badge(emoji: '🌟', label: 'Perfect Quiz', earned: false),
    ];

    return SizedBox(
      height: 14.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        itemBuilder: (_, i) {
          final b = badges[i];
          return Container(
            width: 22.w,
            margin: EdgeInsets.only(right: 3.w),
            decoration: BoxDecoration(
              color: b.earned ? Colors.white : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4.w),
              border: Border.all(
                color: b.earned
                    ? const Color(0xFF7B2FBE).withOpacity(0.20)
                    : Colors.grey.shade200,
                width: 1.5,
              ),
              boxShadow: b.earned
                  ? [
                BoxShadow(
                  color: const Color(0xFF7B2FBE).withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: b.earned ? 1.0 : 0.35,
                  child: Text(b.emoji,
                      style: TextStyle(fontSize: 16.sp)),
                ),
                SizedBox(height: 0.6.h),
                Text(
                  b.label,
                  style: TextStyle(
                    fontSize: 12.8.sp,
                    fontWeight: FontWeight.w700,
                    color: b.earned
                        ? const Color(0xFF1A0535)
                        : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!b.earned)
                  Text(
                    'Locked 🔒',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── SECTION TITLE ──────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1A0535),
        letterSpacing: -0.3,
      ),
    );
  }
}

// ─── Models ────────────────────────────────────────────────────────────────

class _QuickItem {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _QuickItem({
    required this.emoji, required this.label,
    required this.color, required this.onTap,
  });
}

class _LearnCard {
  final String subject, topic, emoji;
  final double progress;
  final Color color;
  const _LearnCard({
    required this.subject, required this.topic, required this.progress,
    required this.emoji,   required this.color,
  });
}

class _Badge {
  final String emoji, label;
  final bool earned;
  const _Badge({required this.emoji, required this.label, required this.earned});
}

// ─── Icon Button ───────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool badge;
  const _IconBtn({required this.icon, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.5.w,
      height: 10.5.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B2FBE).withOpacity(0.09),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: const Color(0xFF7B2FBE), size: 6.w),
          if (badge)
            Positioned(
              top: 2.w,
              right: 2.w,
              child: Container(
                width: 2.2.w,
                height: 2.2.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}