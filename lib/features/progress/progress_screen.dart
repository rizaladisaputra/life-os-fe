import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/glass_card.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(tabController: _tabController),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _StatsTab(),
            _AchievementsTab(),
            _ReflectionTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress', style: AppTypography.headlineLarge),
          Text('Pantau perjalananmu', style: AppTypography.bodySmall),
          const SizedBox(height: 16),
          // Monthly score card
          GlassCard(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyMid, AppColors.navyLight],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ScoreStat(label: 'Monthly Score', value: '87', unit: 'pts', color: AppColors.emerald),
                ),
                Container(width: 1, height: 50, color: AppColors.cardBorder),
                Expanded(
                  child: _ScoreStat(label: 'Longest Streak', value: '22', unit: 'hari', color: AppColors.orange),
                ),
                Container(width: 1, height: 50, color: AppColors.cardBorder),
                Expanded(
                  child: _ScoreStat(label: 'Level', value: 'Lv.8', unit: 'Builder', color: AppColors.prayerSubuh),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _ScoreStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(color: color),
          ),
          Text(unit, style: AppTypography.labelSmall.copyWith(color: color.withValues(alpha: 0.7))),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _TabBarDelegate({required this.tabController});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.navyDeep,
      child: TabBar(
        controller: tabController,
        indicatorColor: AppColors.emerald,
        indicatorWeight: 2,
        labelColor: AppColors.emerald,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Statistik'),
          Tab(text: 'Achievement'),
          Tab(text: 'Refleksi'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 46;
  @override
  double get minExtent => 46;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

// ─── Stats Tab ─────────────────────────────────────────────────────────────────

class _StatsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Stat cards grid
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(emoji: '📚', label: 'Jam Belajar', value: '48h', color: AppColors.prayerSubuh),
            _StatCard(emoji: '🇬🇧', label: 'Jam Bahasa Inggris', value: '12h', color: AppColors.emerald),
            _StatCard(emoji: '💪', label: 'Sesi Workout', value: '18x', color: AppColors.orange),
            _StatCard(emoji: '📖', label: 'Jam Membaca', value: '9h', color: AppColors.prayerIsya),
          ],
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
        const SizedBox(height: 20),
        // Habit completion chart
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Habit Completion'),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                            return Text(
                              days[value.toInt() % 7],
                              style: AppTypography.labelSmall,
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppColors.cardBorder,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _bar(0, 85),
                      _bar(1, 92),
                      _bar(2, 78),
                      _bar(3, 95),
                      _bar(4, 88),
                      _bar(5, 60),
                      _bar(6, 72),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
        const SizedBox(height: 20),
        // Prayer stats
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Prayer Completion'),
              _PrayerStatRow('Subuh Tepat Waktu', 0.85, AppColors.prayerSubuh),
              _PrayerStatRow('Dzuhur Tepat Waktu', 0.92, AppColors.prayerDzuhur),
              _PrayerStatRow('Ashar Tepat Waktu', 0.78, AppColors.prayerAshar),
              _PrayerStatRow('Maghrib Tepat Waktu', 0.95, AppColors.prayerMaghrib),
              _PrayerStatRow('Isya Tepat Waktu', 0.88, AppColors.prayerIsya),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
      ],
    );
  }

  BarChartGroupData _bar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [AppColors.emerald, AppColors.emeraldLight],
          ),
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: AppColors.habitEmpty,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.headlineMedium.copyWith(color: color),
              ),
              Text(label, style: AppTypography.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerStatRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _PrayerStatRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodySmall)),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.navyLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(value * 100).toInt()}%',
            style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Achievements Tab ──────────────────────────────────────────────────────────

class _AchievementsTab extends StatelessWidget {
  final _achievements = const [
    _Achievement('🏅', '30 Hari Konsisten', 'Menjaga streak selama 30 hari penuh', true, AppColors.orange),
    _Achievement('🏆', '100 Jam Belajar', 'Total 100 jam waktu belajar', true, AppColors.prayerDzuhur),
    _Achievement('💪', 'Workout 50x', 'Menyelesaikan 50 sesi workout', false, AppColors.emerald),
    _Achievement('🕌', 'Subuh 100 Hari', 'Sholat Subuh tepat waktu 100 hari', false, AppColors.prayerSubuh),
    _Achievement('🇬🇧', 'English 365 Days', 'Belajar Bahasa Inggris setiap hari selama setahun', false, AppColors.info),
    _Achievement('🌟', 'Perfect Week', 'Menyelesaikan semua habit dalam 1 minggu penuh', true, AppColors.prayerIsya),
    _Achievement('📚', 'Book Worm', 'Membaca 12 buku dalam setahun', false, AppColors.prayerAshar),
    _Achievement('💰', 'Investor', 'Konsisten investasi selama 6 bulan', false, AppColors.emeraldDark),
  ];

  @override
  Widget build(BuildContext context) {
    final earned = _achievements.where((a) => a.earned).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$earned / ${_achievements.length} Achieved',
                      style: AppTypography.headlineSmall.copyWith(color: AppColors.orange)),
                  Text('Keep going!', style: AppTypography.bodySmall),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _achievements.asMap().entries.map((e) {
            return _AchievementCard(achievement: e.value)
                .animate()
                .fadeIn(delay: Duration(milliseconds: 50 * e.key), duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
          }).toList(),
        ),
      ],
    );
  }
}

class _Achievement {
  final String emoji;
  final String title;
  final String description;
  final bool earned;
  final Color color;

  const _Achievement(this.emoji, this.title, this.description, this.earned, this.color);
}

class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: achievement.earned ? achievement.color.withValues(alpha: 0.1) : AppColors.cardSurface,
      borderColor: achievement.earned ? achievement.color.withValues(alpha: 0.4) : AppColors.cardBorder,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.emoji,
            style: TextStyle(
              fontSize: 32,
              color: achievement.earned ? null : null,
            ).copyWith(color: achievement.earned ? null : const Color(0x66FFFFFF)),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: AppTypography.titleSmall.copyWith(
              color: achievement.earned ? achievement.color : AppColors.textMuted,
              fontWeight: achievement.earned ? FontWeight.w700 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!achievement.earned)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('🔒 Terkunci',
                  style: AppTypography.labelSmall.copyWith(fontSize: 9)),
            ),
        ],
      ),
    );
  }
}

// ─── Reflection Tab ────────────────────────────────────────────────────────────

class _ReflectionTab extends StatefulWidget {
  @override
  State<_ReflectionTab> createState() => _ReflectionTabState();
}

class _ReflectionTabState extends State<_ReflectionTab> {
  int _selectedMood = -1;
  final _learnedController = TextEditingController();
  final _gratefulController = TextEditingController();
  final _improveController = TextEditingController();

  final _moods = ['😀', '😄', '😐', '😔', '😴'];
  final _moodLabels = ['Luar Biasa', 'Baik', 'Biasa', 'Kurang', 'Lelah'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Mood selector
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bagaimana perasaanmu?', style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _moods.asMap().entries.map((e) {
                  final isSelected = _selectedMood == e.key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.emeraldGlow
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.emerald
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(e.value, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 4),
                          Text(
                            _moodLabels[e.key],
                            style: AppTypography.labelSmall.copyWith(
                              color: isSelected ? AppColors.emerald : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: 16),
        // Reflection fields
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Refleksi Malam', style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              _ReflectionField(
                icon: '💡',
                label: 'Yang dipelajari hari ini',
                controller: _learnedController,
                hint: 'Apa yang kamu pelajari...',
              ),
              const SizedBox(height: 12),
              _ReflectionField(
                icon: '🙏',
                label: 'Yang disyukuri',
                controller: _gratefulController,
                hint: 'Hal yang kamu syukuri...',
              ),
              const SizedBox(height: 12),
              _ReflectionField(
                icon: '🔧',
                label: 'Yang harus diperbaiki',
                controller: _improveController,
                hint: 'Area yang ingin ditingkatkan...',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Refleksi tersimpan!')),
                    );
                  },
                  child: const Text('Simpan Refleksi'),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
      ],
    );
  }
}

class _ReflectionField extends StatelessWidget {
  final String icon;
  final String label;
  final TextEditingController controller;
  final String hint;

  const _ReflectionField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.titleSmall),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 2,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
