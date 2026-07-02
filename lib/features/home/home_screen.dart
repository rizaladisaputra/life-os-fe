import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/circular_progress.dart';
import 'widgets/prayer_time_widget.dart';
import 'widgets/daily_timeline.dart';
import 'widgets/habit_tracker_grid.dart';
import 'widgets/weekly_goals_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(todayProgressProvider);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: RefreshIndicator(
        color: AppColors.emerald,
        backgroundColor: AppColors.navyMid,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: _buildHeader(now, progress),
            ),
            // Prayer Times
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: const PrayerTimeWidget()
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
              ),
            ),
            // Today's Mission
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _buildTodaysMission()
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
              ),
            ),
            // Timeline
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: const DailyTimeline()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
              ),
            ),
            // Habit Tracker
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: const HabitTrackerGrid()
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
              ),
            ),
            // Weekly Goals
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              sliver: SliverToBoxAdapter(
                child: const WeeklyGoalsCard()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DateTime now, double progress) {
    final greeting = _getGreeting(now.hour);
    final dateStr = DateFormat('EEEE, d MMMM', 'id_ID').format(now);
    final user = ref.watch(authProvider).user;
    final userName = user?.displayName ?? 'User';

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.navyDeep, AppColors.navyDeep],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: greeting + notifications
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $userName 👋',
                      style: AppTypography.greeting,
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideX(begin: -0.05, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.navyMid,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ],
          ),
          const SizedBox(height: 20),
          // Progress row
          GlassCard(
            padding: const EdgeInsets.all(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyMid, AppColors.navyLight],
            ),
            child: Row(
              children: [
                CircularProgressWidget(
                  progress: progress,
                  size: 100,
                  subText: 'Hari Ini',
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Mission',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._missionItems(progress, context),
                      const SizedBox(height: 8),
                      // Quote
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldGlow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.emerald.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '"Disiplin hari ini adalah\ninvestasi masa depan."',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.emeraldLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 500.ms).scale(
                begin: const Offset(0.97, 0.97),
                end: const Offset(1, 1),
              ),
        ],
      ),
    );
  }

  List<Widget> _missionItems(double progress, BuildContext context) {
    final missions = [
      ('🇬🇧', 'Belajar Inggris', progress >= 0.3, '/english'),
      ('💪', 'Workout', progress >= 0.5, null),
      ('🕌', 'Sholat Tepat Waktu', progress >= 0.2, null),
      ('📖', 'Belajar Skill', progress >= 0.7, '/career'),
      ('🌙', 'Tidur Sebelum 22.00', false, null),
    ];
    return missions.take(4).map((m) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: GestureDetector(
          onTap: () {
            if (m.$4 != null) {
              context.push(m.$4!);
            }
          },
          child: Row(
            children: [
              Icon(
                m.$3
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 14,
                color: m.$3 ? AppColors.emerald : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${m.$1} ${m.$2}',
                  style: AppTypography.bodySmall.copyWith(
                    color:
                        m.$3 ? AppColors.textPrimary : AppColors.textSecondary,
                    decoration: m.$3 ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTodaysMission() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Aktivitas Hari Ini'),
      ],
    );
  }

  String _getGreeting(int hour) {
    if (hour < 5) return 'Selamat Pagi';
    if (hour < 10) return 'Selamat Pagi';
    if (hour < 14) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }
}
