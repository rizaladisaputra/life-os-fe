import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/glass_card.dart';

class WeeklyGoalsCard extends ConsumerWidget {
  const WeeklyGoalsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(weeklyGoalsProvider);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Weekly Goals',
            subtitle: 'Progress minggu ini',
          ),
          ...goals.map((goal) => _GoalItem(goal: goal)),
        ],
      ),
    );
  }
}

class _GoalItem extends StatelessWidget {
  final WeeklyGoalModel goal;

  const _GoalItem({required this.goal});

  @override
  Widget build(BuildContext context) {
    final Color barColor = goal.progress >= 1.0
        ? AppColors.emerald
        : goal.progress >= 0.7
            ? AppColors.emeraldLight
            : goal.progress >= 0.4
                ? AppColors.orange
                : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(goal.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(goal.title, style: AppTypography.titleMedium),
              ),
              Text(
                '${goal.current} / ${goal.target} ${goal.unit}',
                style: AppTypography.bodySmall.copyWith(
                  color: barColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: goal.progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.navyLight,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  minHeight: 6,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
