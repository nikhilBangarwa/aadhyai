import 'package:aadhyai/onboard/subject/chapter_section/chapter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Science', 'Arts', 'Language'];

  final List<_Subject> _subjects = [
    _Subject(
      name: 'Mathematics',
      emoji: '📐',
      topics: 14,
      progress: 0.62,
      color: const Color(0xFF7B2FBE),
      tag: 'Science',
      chapters: ['Integers', 'Fractions & Decimals', 'Algebra', 'Geometry', 'Data Handling'],
    ),
    _Subject(
      name: 'Science',
      emoji: '🔬',
      topics: 16,
      progress: 0.45,
      color: const Color(0xFF2D9CDB),
      tag: 'Science',
      chapters: ['Food: Where Does It Come From?', 'Components of Food', 'Fibre to Fabric', 'Living Organisms'],
    ),
    _Subject(
      name: 'Social Science',
      emoji: '🌍',
      topics: 18,
      progress: 0.30,
      color: const Color(0xFF27AE60),
      tag: 'Arts',
      chapters: ['The Earth in the Solar System', 'Globe: Latitudes & Longitudes', 'Our Country India'],
    ),
    _Subject(
      name: 'English',
      emoji: '📖',
      topics: 12,
      progress: 0.75,
      color: const Color(0xFFE67E22),
      tag: 'Language',
      chapters: ['Honeysuckle', 'A Tale of Two Birds', 'The Friendly Mongoose', 'Grammar'],
    ),
    _Subject(
      name: 'Hindi',
      emoji: '🖊️',
      topics: 10,
      progress: 0.55,
      color: const Color(0xFFE91E63),
      tag: 'Language',
      chapters: ['वह चिड़िया जो', 'बचपन', 'नादान दोस्त', 'चाँद से थोड़ी सी गप्पें'],
    ),
    _Subject(
      name: 'Sanskrit',
      emoji: '📜',
      topics: 8,
      progress: 0.20,
      color: const Color(0xFF9C27B0),
      tag: 'Language',
      chapters: ['शब्द परिचय', 'स्तुतिः', 'बलराम कथा', 'व्याकरण'],
    ),
    _Subject(
      name: 'Computer Science',
      emoji: '💻',
      topics: 10,
      progress: 0.68,
      color: const Color(0xFF00BCD4),
      tag: 'Science',
      chapters: ['Introduction to Computers', 'MS Office', 'Internet Basics', 'Scratch Programming'],
    ),
    _Subject(
      name: 'General Knowledge',
      emoji: '🌟',
      topics: 20,
      progress: 0.50,
      color: const Color(0xFFF39C12),
      tag: 'Arts',
      chapters: ['India & World', 'Science & Tech', 'Sports', 'Current Affairs'],
    ),
  ];

  List<_Subject> get _filtered {
    if (_selectedFilter == 0) return _subjects;
    return _subjects
        .where((s) => s.tag == _filters[_selectedFilter])
        .toList();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBanner(),
                      const SizedBox(height: 24),
                      _buildFilters(),
                      const SizedBox(height: 20),
                      _buildSubjectList(),
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

  // ── AppBar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFFF7F4FF),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
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
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF7B2FBE), size: 18),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'My Subjects',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A0535),
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              Container(
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
                child: const Icon(Icons.search_rounded,
                    color: Color(0xFF7B2FBE), size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Banner ──────────────────────────────────────────────────────────

  Widget _buildBanner() {
    final completed =
        _subjects.where((s) => s.progress >= 1.0).length;
    final total = _subjects.length;
    final avgProgress = _subjects.fold(0.0, (sum, s) => sum + s.progress) / total;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📚', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class 6th Subjects',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'NCERT Curriculum • 2024-25',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$total Subjects',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatChip(label: 'Overall', value: '${(avgProgress * 100).toInt()}%'),
              const SizedBox(width: 10),
              _StatChip(label: 'Completed', value: '$completed/$total'),
              const SizedBox(width: 10),
              _StatChip(label: 'Streak', value: '🔥 5 days'),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: avgProgress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.20),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Chips ────────────────────────────────────────────────────────

  Widget _buildFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final selected = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF7B2FBE) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF7B2FBE)
                      : const Color(0xFFE8E0F5),
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [
                  BoxShadow(
                    color: const Color(0xFF7B2FBE).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : [],
              ),
              child: Text(
                _filters[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : const Color(0xFF9B7DC0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Subject List ────────────────────────────────────────────────────────

  Widget _buildSubjectList() {
    final list = _filtered;
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No subjects found',
              style: TextStyle(color: Color(0xFF9B7DC0), fontSize: 15)),
        ),
      );
    }
    return Column(
      children: list.map((subject) => _SubjectCard(subject: subject)).toList(),
    );
  }
}

// ─── Subject Card ──────────────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  final _Subject subject;
  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChapterScreen(
          subject: subject.name == 'Mathematics' ? mathSubject : hindiSubject,
        ),
      )),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: subject.color.withOpacity(0.09),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Emoji icon
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: subject.color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(subject.emoji,
                          style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subject.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A0535),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: subject.color.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${(subject.progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: subject.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${subject.topics} Topics • ${subject.chapters.length} Chapters',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9B7DC0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: subject.progress,
                            minHeight: 5,
                            backgroundColor:
                            subject.color.withOpacity(0.12),
                            valueColor:
                            AlwaysStoppedAnimation(subject.color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Chapter preview strip
            Container(
              decoration: BoxDecoration(
                color: subject.color.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.menu_book_rounded,
                      size: 14, color: subject.color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      subject.chapters.first,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: subject.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    'View All →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: subject.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}


class _ChapterSheet extends StatelessWidget {
  final _Subject subject;
  const _ChapterSheet({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F4FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0D6F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: subject.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                Center(child: Text(subject.emoji, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A0535),
                    ),
                  ),
                  Text(
                    '${subject.chapters.length} Chapters',
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF9B7DC0)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chapters list
          ...subject.chapters.asMap().entries.map((entry) {
            final i = entry.key;
            final chapter = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: subject.color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: subject.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      chapter,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A0535),
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: subject.color),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Start button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [subject.color, subject.color.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: subject.color.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Start Learning  🚀',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _StatChip extends StatelessWidget {
  final String label, value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.70),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Data Model ────────────────────────────────────────────────────────────

class _Subject {
  final String name, emoji, tag;
  final int topics;
  final double progress;
  final Color color;
  final List<String> chapters;

  const _Subject({
    required this.name,
    required this.emoji,
    required this.topics,
    required this.progress,
    required this.color,
    required this.tag,
    required this.chapters,
  });
}