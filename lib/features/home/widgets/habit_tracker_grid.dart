import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/glass_card.dart';

class HabitTrackerGrid extends ConsumerWidget {
  const HabitTrackerGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final notifier = ref.read(habitsProvider.notifier);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Habit Tracker',
            subtitle: 'Tap untuk checklist hari ini',
          ),
          ...habits.map((habit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          notifier.toggleToday(habit.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: habit.completedToday
                                ? AppColors.emerald
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: habit.completedToday
                                  ? AppColors.emerald
                                  : AppColors.cardBorder,
                              width: 1.5,
                            ),
                          ),
                          child: habit.completedToday
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(habit.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(habit.name, style: AppTypography.titleMedium),
                      ),
                      if (habit.currentStreak > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 2),
                              Text(
                                '${habit.currentStreak}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Mini contribution grid (last 21 days)
                  _MiniContributionGrid(completedDays: habit.completedDays),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _MiniContributionGrid extends StatelessWidget {
  final List<DateTime> completedDays;

  const _MiniContributionGrid({required this.completedDays});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(21, (i) => today.subtract(Duration(days: 20 - i)));

    return Row(
      children: days.map((day) {
        final completed = completedDays.any((d) =>
            d.year == day.year && d.month == day.month && d.day == day.day);
        final isToday = day.year == today.year &&
            day.month == today.month &&
            day.day == today.day;

        return Expanded(
          child: Container(
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.emerald
                  : AppColors.habitEmpty,
              borderRadius: BorderRadius.circular(3),
              border: isToday
                  ? Border.all(color: AppColors.orange, width: 1)
                  : null,
              boxShadow: completed
                  ? [
                      BoxShadow(
                        color: AppColors.emerald.withValues(alpha: 0.3),
                        blurRadius: 3,
                      )
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
