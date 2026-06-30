import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/glass_card.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),
          // Calendar
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2027, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: AppTypography.bodySmall,
                    weekendTextStyle: AppTypography.bodySmall.copyWith(
                      color: AppColors.orange,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.emeraldGlow,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.emerald),
                    ),
                    todayTextStyle: AppTypography.bodySmall.copyWith(
                      color: AppColors.emerald,
                      fontWeight: FontWeight.w700,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.emerald,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    outsideDaysVisible: false,
                    cellMargin: const EdgeInsets.all(4),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    titleTextStyle: AppTypography.titleLarge,
                    formatButtonDecoration: BoxDecoration(
                      color: AppColors.emeraldGlow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.emerald.withValues(alpha: 0.4)),
                    ),
                    formatButtonTextStyle: AppTypography.labelMedium.copyWith(
                      color: AppColors.emerald,
                    ),
                    leftChevronIcon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textSecondary,
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: AppTypography.labelMedium,
                    weekendStyle: AppTypography.labelMedium.copyWith(
                      color: AppColors.orange,
                    ),
                  ),
                  eventLoader: _getEventsForDay,
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return null;
                      return Positioned(
                        bottom: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: events.take(3).map((_) {
                            return Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: const BoxDecoration(
                                color: AppColors.emerald,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),
          // Selected day activities
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverToBoxAdapter(
              child: _buildDayActivities(),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getEventsForDay(DateTime day) {
    // Simulated events - in real app, fetch from DB
    if (day.weekday == 2 || day.weekday == 4) return ['Gym'];
    if (day.weekday == 6) return ['Badminton'];
    if (day.weekday == 0) return ['Komunitas'];
    return [];
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Planner', style: AppTypography.headlineLarge),
              Text('Rencanakan harimu', style: AppTypography.bodySmall),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.emeraldGlow,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.today_rounded,
                      color: AppColors.emerald, size: 16),
                  const SizedBox(width: 4),
                  Text('Hari Ini',
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.emerald)),
                ],
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildDayActivities() {
    final activities = ref.watch(activitiesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Aktivitas'),
        GlassCard(
          child: Column(
            children: [
              ...activities.map((a) => _PlannerActivityItem(activity: a)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.navyLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.cardBorder, style: BorderStyle.solid),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded,
                          color: AppColors.emerald, size: 18),
                      const SizedBox(width: 6),
                      Text('Tambah Aktivitas',
                          style: AppTypography.labelLarge
                              .copyWith(color: AppColors.emerald)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlannerActivityItem extends StatelessWidget {
  final dynamic activity;

  const _PlannerActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.emerald,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(activity.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: AppTypography.titleMedium),
                Text(activity.time, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Icon(
            activity.isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color:
                activity.isCompleted ? AppColors.emerald : AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}
