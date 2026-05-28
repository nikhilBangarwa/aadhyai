import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Entry Point ───────────────────────────────────────────────────────────
// Usage: Navigator.push(context, MaterialPageRoute(
//   builder: (_) => ChapterScreen(subject: mathSubject)));

class ChapterScreen extends StatefulWidget {
  final SubjectData subject;
  const ChapterScreen({super.key, required this.subject});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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

  int get _completedCount =>
      widget.subject.chapters.where((c) => c.progress >= 1.0).length;

  double get _avgProgress =>
      widget.subject.chapters.fold(0.0, (s, c) => s + c.progress) /
          widget.subject.chapters.length;

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
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBanner(),
                      const SizedBox(height: 28),
                      _buildSectionLabel('All Chapters'),
                      const SizedBox(height: 14),
                      _buildChapterList(context),
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

  // ── AppBar ────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
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
                        color: widget.subject.color.withOpacity(0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: widget.subject.color, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.subject.name,
                  style: const TextStyle(
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
                      color: widget.subject.color.withOpacity(0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(Icons.bookmark_outline_rounded,
                    color: widget.subject.color, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Banner ────────────────────────────────────────────────────────────

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.subject.color,
            widget.subject.color.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: widget.subject.color.withOpacity(0.32),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(widget.subject.emoji,
                      style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.subject.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subject.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _BannerStat(
                  label: 'Chapters',
                  value: '${widget.subject.chapters.length}'),
              const SizedBox(width: 10),
              _BannerStat(
                  label: 'Completed', value: '$_completedCount'),
              const SizedBox(width: 10),
              _BannerStat(
                  label: 'Progress',
                  value: '${(_avgProgress * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _avgProgress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.22),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A0535),
        letterSpacing: -0.3,
      ),
    );
  }

  // ── Chapter List ──────────────────────────────────────────────────────

  Widget _buildChapterList(BuildContext context) {
    return Column(
      children: widget.subject.chapters.asMap().entries.map((entry) {
        final index = entry.key;
        final chapter = entry.value;
        return _ChapterCard(
          chapter: chapter,
          index: index + 1,
          color: widget.subject.color,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => TopicScreen(
                chapter: chapter,
                subjectColor: widget.subject.color,
                subjectEmoji: widget.subject.emoji,
              ),
            ));
          },
        );
      }).toList(),
    );
  }
}

// ─── Chapter Card ──────────────────────────────────────────────────────────

class _ChapterCard extends StatelessWidget {
  final ChapterData chapter;
  final int index;
  final Color color;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.index,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = chapter.progress >= 1.0;
    final isStarted = chapter.progress > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
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
                  // Chapter number badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDone
                          ? color
                          : color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 22)
                        : Center(
                      child: Text(
                        '$index',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Chapter info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chapter $index',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          chapter.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A0535),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${chapter.topics.length} Topics',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9B7DC0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status chip
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDone
                              ? const Color(0xFF27AE60).withOpacity(0.12)
                              : isStarted
                              ? color.withOpacity(0.10)
                              : const Color(0xFFE8E0F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isDone
                              ? '✅ Done'
                              : isStarted
                              ? '▶ Resume'
                              : '🔒 Start',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDone
                                ? const Color(0xFF27AE60)
                                : isStarted
                                ? color
                                : const Color(0xFF9B7DC0),
                          ),
                        ),
                      ),
                      if (isStarted && !isDone) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${(chapter.progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Progress bar strip (only if started)
            if (isStarted)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                child: LinearProgressIndicator(
                  value: chapter.progress,
                  minHeight: 4,
                  backgroundColor: color.withOpacity(0.10),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Topic Screen ──────────────────────────────────────────────────────────

class TopicScreen extends StatefulWidget {
  final ChapterData chapter;
  final Color subjectColor;
  final String subjectEmoji;

  const TopicScreen({
    super.key,
    required this.chapter,
    required this.subjectColor,
    required this.subjectEmoji,
  });

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
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
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
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
                                color: widget.subjectColor.withOpacity(0.10),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              color: widget.subjectColor, size: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.chapter.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A0535),
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chapter header card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.subjectColor,
                            widget.subjectColor.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: widget.subjectColor.withOpacity(0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(widget.subjectEmoji,
                              style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.chapter.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${widget.chapter.topics.length} Topics to learn',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.78),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Topics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A0535),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Topics list
                    ...widget.chapter.topics.asMap().entries.map((entry) {
                      final i = entry.key;
                      final topic = entry.value;
                      return _TopicTile(
                        index: i + 1,
                        topic: topic,
                        color: widget.subjectColor,
                      );
                    }),

                    const SizedBox(height: 24),

                    // Start / Continue button
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.subjectColor,
                              widget.subjectColor.withOpacity(0.75),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: widget.subjectColor.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_outline_rounded,
                                color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Start Learning',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
    );
  }
}

// ─── Topic Tile ────────────────────────────────────────────────────────────

class _TopicTile extends StatelessWidget {
  final int index;
  final TopicData topic;
  final Color color;

  const _TopicTile(
      {required this.index, required this.topic, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A0535),
                  ),
                ),
                if (topic.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    topic.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9B7DC0),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────

class _BannerStat extends StatelessWidget {
  final String label, value;
  const _BannerStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 1),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.72),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Data Models ───────────────────────────────────────────────────────────

class TopicData {
  final String name;
  final String description;
  const TopicData({required this.name, this.description = ''});
}

class ChapterData {
  final String name;
  final double progress;
  final List<TopicData> topics;
  const ChapterData(
      {required this.name, this.progress = 0.0, required this.topics});
}

class SubjectData {
  final String name;
  final String emoji;
  final String subtitle;
  final Color color;
  final List<ChapterData> chapters;
  const SubjectData({
    required this.name,
    required this.emoji,
    required this.subtitle,
    required this.color,
    required this.chapters,
  });
}

// ─── NCERT Class 6 Data ────────────────────────────────────────────────────

final SubjectData mathSubject = SubjectData(
  name: 'Mathematics',
  emoji: '📐',
  subtitle: 'NCERT Class 6 • 14 Chapters',
  color: const Color(0xFF7B2FBE),
  chapters: [
    ChapterData(
      name: 'Knowing Our Numbers',
      progress: 1.0,
      topics: [
        TopicData(name: 'Introduction to Large Numbers', description: 'Lakhs, crores and beyond'),
        TopicData(name: 'Comparing Numbers', description: 'Ascending & descending order'),
        TopicData(name: 'Estimation', description: 'Rounding off numbers'),
        TopicData(name: 'Roman Numerals', description: 'I, V, X, L, C, D, M'),
      ],
    ),
    ChapterData(
      name: 'Whole Numbers',
      progress: 0.75,
      topics: [
        TopicData(name: 'Natural Numbers & Whole Numbers', description: 'Number line basics'),
        TopicData(name: 'Properties of Whole Numbers', description: 'Closure, commutativity'),
        TopicData(name: 'Patterns in Whole Numbers', description: 'Triangular & square numbers'),
      ],
    ),
    ChapterData(
      name: 'Playing with Numbers',
      progress: 0.50,
      topics: [
        TopicData(name: 'Factors and Multiples', description: 'Finding factors of a number'),
        TopicData(name: 'Prime & Composite Numbers', description: 'Sieve of Eratosthenes'),
        TopicData(name: 'HCF and LCM', description: 'Highest common factor'),
        TopicData(name: 'Tests of Divisibility', description: 'Rules for 2, 3, 5, 9, 10'),
      ],
    ),
    ChapterData(
      name: 'Basic Geometrical Ideas',
      progress: 0.0,
      topics: [
        TopicData(name: 'Point, Line and Line Segment', description: 'Basic geometry concepts'),
        TopicData(name: 'Rays and Angles', description: 'Types of angles'),
        TopicData(name: 'Curves and Polygons', description: 'Open & closed figures'),
        TopicData(name: 'Circles', description: 'Radius, diameter, chord'),
      ],
    ),
    ChapterData(
      name: 'Understanding Elementary Shapes',
      progress: 0.0,
      topics: [
        TopicData(name: 'Measuring Line Segments', description: 'Using ruler and compass'),
        TopicData(name: 'Angles – Acute, Obtuse, Reflex', description: 'Classifying angles'),
        TopicData(name: '3D Shapes', description: 'Cube, cuboid, cylinder, cone'),
      ],
    ),
    ChapterData(
      name: 'Integers',
      progress: 0.0,
      topics: [
        TopicData(name: 'Introduction to Integers', description: 'Negative numbers'),
        TopicData(name: 'Integers on Number Line', description: 'Representation'),
        TopicData(name: 'Addition & Subtraction of Integers', description: 'Operations'),
      ],
    ),
    ChapterData(
      name: 'Fractions',
      progress: 0.0,
      topics: [
        TopicData(name: 'A Fraction', description: 'Numerator and denominator'),
        TopicData(name: 'Proper, Improper & Mixed Fractions', description: 'Types'),
        TopicData(name: 'Equivalent Fractions', description: 'Simplest form'),
        TopicData(name: 'Addition & Subtraction of Fractions', description: 'Like & unlike'),
      ],
    ),
    ChapterData(
      name: 'Decimals',
      progress: 0.0,
      topics: [
        TopicData(name: 'Tenths and Hundredths', description: 'Decimal place value'),
        TopicData(name: 'Comparing Decimals', description: 'Greater & smaller'),
        TopicData(name: 'Using Decimals', description: 'Money and measurement'),
        TopicData(name: 'Addition & Subtraction of Decimals'),
      ],
    ),
    ChapterData(
      name: 'Data Handling',
      progress: 0.0,
      topics: [
        TopicData(name: 'Recording Data', description: 'Tally marks'),
        TopicData(name: 'Organisation of Data', description: 'Frequency table'),
        TopicData(name: 'Pictograph', description: 'Reading pictographs'),
        TopicData(name: 'Bar Graph', description: 'Drawing bar graphs'),
      ],
    ),
    ChapterData(
      name: 'Mensuration',
      progress: 0.0,
      topics: [
        TopicData(name: 'Perimeter', description: 'Perimeter of rectangle & square'),
        TopicData(name: 'Area', description: 'Area of rectangle & square'),
        TopicData(name: 'Area of Irregular Figures', description: 'Using graph paper'),
      ],
    ),
    ChapterData(
      name: 'Algebra',
      progress: 0.0,
      topics: [
        TopicData(name: 'Introduction to Algebra', description: 'Variables and constants'),
        TopicData(name: 'Expressions', description: 'Forming algebraic expressions'),
        TopicData(name: 'Simple Equations', description: 'Solving equations'),
      ],
    ),
    ChapterData(
      name: 'Ratio and Proportion',
      progress: 0.0,
      topics: [
        TopicData(name: 'Ratio', description: 'Comparing two quantities'),
        TopicData(name: 'Proportion', description: 'Four quantities in proportion'),
        TopicData(name: 'Unitary Method', description: 'Finding unit value'),
      ],
    ),
    ChapterData(
      name: 'Symmetry',
      progress: 0.0,
      topics: [
        TopicData(name: 'Line Symmetry', description: 'Mirror image'),
        TopicData(name: 'Lines of Symmetry', description: 'Multiple lines'),
        TopicData(name: 'Rotational Symmetry', description: 'Rotation and symmetry'),
      ],
    ),
    ChapterData(
      name: 'Practical Geometry',
      progress: 0.0,
      topics: [
        TopicData(name: 'Circle with Compass', description: 'Drawing circles'),
        TopicData(name: 'Line Segment', description: 'Constructing line segments'),
        TopicData(name: 'Perpendicular Lines', description: 'Using set squares'),
        TopicData(name: 'Angles with Protractor', description: 'Drawing angles'),
      ],
    ),
  ],
);

final SubjectData hindiSubject = SubjectData(
  name: 'Hindi',
  emoji: '🖊️',
  subtitle: 'NCERT Class 6 • Vasant & Durva',
  color: const Color(0xFFE91E63),
  chapters: [
    ChapterData(
      name: 'वह चिड़िया जो',
      progress: 1.0,
      topics: [
        TopicData(name: 'कविता का सारांश', description: 'केदारनाथ अग्रवाल की कविता'),
        TopicData(name: 'शब्द अर्थ', description: 'कठिन शब्दों के अर्थ'),
        TopicData(name: 'प्रश्न-उत्तर', description: 'पाठ के प्रश्न'),
        TopicData(name: 'व्याकरण अभ्यास', description: 'संज्ञा और सर्वनाम'),
      ],
    ),
    ChapterData(
      name: 'बचपन',
      progress: 0.60,
      topics: [
        TopicData(name: 'पाठ का परिचय', description: 'कृष्णा सोबती की रचना'),
        TopicData(name: 'मुख्य बिंदु', description: 'बचपन की यादें'),
        TopicData(name: 'शब्द-भंडार', description: 'नए शब्द सीखें'),
        TopicData(name: 'प्रश्न-उत्तर', description: 'लेखिका के बचपन की बातें'),
      ],
    ),
    ChapterData(
      name: 'नादान दोस्त',
      progress: 0.30,
      topics: [
        TopicData(name: 'कहानी का सारांश', description: 'प्रेमचंद की कहानी'),
        TopicData(name: 'पात्र परिचय', description: 'केशव और श्यामा'),
        TopicData(name: 'नैतिक शिक्षा', description: 'कहानी से सीख'),
        TopicData(name: 'व्याकरण', description: 'क्रिया और काल'),
      ],
    ),
    ChapterData(
      name: 'चाँद से थोड़ी सी गप्पें',
      progress: 0.0,
      topics: [
        TopicData(name: 'कविता पठन', description: 'शमशेर बहादुर सिंह'),
        TopicData(name: 'भावार्थ', description: 'कविता का अर्थ'),
        TopicData(name: 'काव्य सौंदर्य', description: 'अलंकार और छंद'),
        TopicData(name: 'अभ्यास प्रश्न'),
      ],
    ),
    ChapterData(
      name: 'अक्षरों का महत्व',
      progress: 0.0,
      topics: [
        TopicData(name: 'पाठ परिचय', description: 'गुणाकर मुले का निबंध'),
        TopicData(name: 'लेखन की खोज', description: 'लिपि का इतिहास'),
        TopicData(name: 'मुख्य विचार', description: 'अक्षरों का महत्व'),
        TopicData(name: 'अभ्यास', description: 'प्रश्न-उत्तर'),
      ],
    ),
    ChapterData(
      name: 'पार नज़र के',
      progress: 0.0,
      topics: [
        TopicData(name: 'कहानी सारांश', description: 'जयंत विष्णु नार्लीकर'),
        TopicData(name: 'विज्ञान और कल्पना', description: 'विज्ञान कथा'),
        TopicData(name: 'पात्र और घटनाएँ'),
        TopicData(name: 'प्रश्न-उत्तर'),
      ],
    ),
    ChapterData(
      name: 'साथी हाथ बढ़ाना',
      progress: 0.0,
      topics: [
        TopicData(name: 'गीत का परिचय', description: 'साहिर लुधियानवी'),
        TopicData(name: 'गीत का भावार्थ', description: 'एकता और मेहनत'),
        TopicData(name: 'शब्द अर्थ'),
        TopicData(name: 'अभ्यास प्रश्न'),
      ],
    ),
    ChapterData(
      name: 'ऐसे–ऐसे',
      progress: 0.0,
      topics: [
        TopicData(name: 'एकांकी परिचय', description: 'विष्णु प्रभाकर'),
        TopicData(name: 'पात्र और संवाद', description: 'मोहन और माँ'),
        TopicData(name: 'हास्य रस', description: 'नाटक की विशेषता'),
        TopicData(name: 'अभ्यास'),
      ],
    ),
    ChapterData(
      name: 'टिकट एल्बम',
      progress: 0.0,
      topics: [
        TopicData(name: 'कहानी सारांश', description: 'सुंदरा रामस्वामी'),
        TopicData(name: 'मुख्य पात्र', description: 'राजप्पा और नागराजन'),
        TopicData(name: 'ईर्ष्या और मित्रता', description: 'नैतिक मूल्य'),
        TopicData(name: 'प्रश्न-उत्तर'),
      ],
    ),
    ChapterData(
      name: 'झाँसी की रानी',
      progress: 0.0,
      topics: [
        TopicData(name: 'कविता परिचय', description: 'सुभद्राकुमारी चौहान'),
        TopicData(name: 'वीर रस', description: 'रानी लक्ष्मीबाई की वीरता'),
        TopicData(name: 'ऐतिहासिक पृष्ठभूमि', description: '1857 का स्वतंत्रता संग्राम'),
        TopicData(name: 'कविता कंठस्थ करें'),
      ],
    ),
    ChapterData(
      name: 'जो देखकर भी नहीं देखते',
      progress: 0.0,
      topics: [
        TopicData(name: 'निबंध परिचय', description: 'हेलन केलर का अनुभव'),
        TopicData(name: 'मुख्य विचार', description: 'देखने की शक्ति'),
        TopicData(name: 'संदेश', description: 'प्रकृति की सुंदरता'),
        TopicData(name: 'अभ्यास प्रश्न'),
      ],
    ),
    ChapterData(
      name: 'संसार पुस्तक है',
      progress: 0.0,
      topics: [
        TopicData(name: 'पत्र का परिचय', description: 'जवाहरलाल नेहरू का पत्र'),
        TopicData(name: 'मुख्य बातें', description: 'प्रकृति से ज्ञान'),
        TopicData(name: 'इंदिरा को पत्र', description: 'पिता का संदेश'),
        TopicData(name: 'प्रश्न-उत्तर'),
      ],
    ),
    ChapterData(
      name: 'मैं सबसे छोटी होऊँ',
      progress: 0.0,
      topics: [
        TopicData(name: 'कविता पठन', description: 'सुमित्रानंदन पंत'),
        TopicData(name: 'माँ का प्यार', description: 'कविता का भाव'),
        TopicData(name: 'काव्य सौंदर्य'),
        TopicData(name: 'अभ्यास'),
      ],
    ),
    ChapterData(
      name: 'लोकगीत',
      progress: 0.0,
      topics: [
        TopicData(name: 'लोकगीत क्या हैं?', description: 'भगवतशरण उपाध्याय'),
        TopicData(name: 'विभिन्न क्षेत्रों के लोकगीत', description: 'भारत की विविधता'),
        TopicData(name: 'लोकगीतों का महत्व'),
        TopicData(name: 'अभ्यास प्रश्न'),
      ],
    ),
    ChapterData(
      name: 'नौकर',
      progress: 0.0,
      topics: [
        TopicData(name: 'पाठ परिचय', description: 'अनु बंद्योपाध्याय'),
        TopicData(name: 'मुख्य विचार', description: 'सेवा भाव'),
        TopicData(name: 'प्रश्न-उत्तर'),
        TopicData(name: 'व्याकरण अभ्यास'),
      ],
    ),
    ChapterData(
      name: 'वन के मार्ग में',
      progress: 0.0,
      topics: [
        TopicData(name: 'कविता परिचय', description: 'तुलसीदास की पंक्तियाँ'),
        TopicData(name: 'राम वनगमन', description: 'सीता का वन में जाना'),
        TopicData(name: 'अवधी भाषा', description: 'पुरानी हिंदी का रूप'),
        TopicData(name: 'अभ्यास'),
      ],
    ),
  ],
);