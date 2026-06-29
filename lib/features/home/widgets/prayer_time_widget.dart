import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/glass_card.dart';

class PrayerTimeWidget extends ConsumerWidget {
  const PrayerTimeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(prayerProvider);
    final notifier = ref.read(prayerProvider.notifier);

    final prayerColors = {
      'Subuh': AppColors.prayerSubuh,
      'Dzuhur': AppColors.prayerDzuhur,
      'Ashar': AppColors.prayerAshar,
      'Maghrib': AppColors.prayerMaghrib,
      'Isya': AppColors.prayerIsya,
    };

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🕌', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Waktu Sholat', style: AppTypography.titleLarge),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emeraldGlow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${prayers.where((p) => p.isCompleted).length}/${prayers.length}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: prayers.map((prayer) {
              final color = prayerColors[prayer.name] ?? AppColors.emerald;
              return Expanded(
                child: GestureDetector(
                  onTap: () => notifier.toggleCompleted(prayer.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(
                      color: prayer.isCompleted
                          ? color.withValues(alpha: 0.15)
                          : AppColors.navyLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: prayer.isCompleted
                            ? color.withValues(alpha: 0.5)
                            : AppColors.cardBorder,
                        width: prayer.isCompleted ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          prayer.emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prayer.name,
                          style: AppTypography.labelSmall.copyWith(
                            color: prayer.isCompleted ? color : AppColors.textMuted,
                            fontWeight: prayer.isCompleted
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          prayer.time,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: prayer.isCompleted ? color : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: prayer.isCompleted
                                  ? color
                                  : AppColors.textMuted.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: prayer.isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ).animate(target: prayer.isCompleted ? 1 : 0).scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.02, 1.02),
                      duration: 200.ms,
                    ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
