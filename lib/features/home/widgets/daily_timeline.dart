import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/activity_model.dart';
import '../../../core/widgets/glass_card.dart';

class DailyTimeline extends ConsumerWidget {
  const DailyTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);
    final notifier = ref.read(activitiesProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Timeline Hari Ini',
          subtitle: 'Aktivitas yang terencana hari ini',
        ),
        ...activities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          return _TimelineItem(
            activity: activity,
            isLast: index == activities.length - 1,
            onToggle: () {
              HapticFeedback.lightImpact();
              notifier.toggleComplete(activity.id);
            },
            onDelete: () => notifier.deleteActivity(activity.id),
          ).animate().fadeIn(
                delay: Duration(milliseconds: 50 * index),
                duration: 300.ms,
              );
        }),
      ],
    );
  }
}

class _TimelineItem extends StatefulWidget {
  final ActivityModel activity;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TimelineItem({
    required this.activity,
    required this.isLast,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<_TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<_TimelineItem> {
  double _dragOffset = 0;
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dx;
          _dragOffset = _dragOffset.clamp(-80.0, 80.0);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragOffset > 50) {
          // Swipe right = complete
          widget.onToggle();
        } else if (_dragOffset < -50) {
          // Swipe left = reveal actions
          setState(() {
            _revealed = true;
            _dragOffset = -60;
          });
          return;
        }
        setState(() {
          _dragOffset = 0;
          _revealed = false;
        });
      },
      child: Stack(
        children: [
          // Action buttons behind
          if (_revealed)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _dragOffset = 0;
                        _revealed = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.orange.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.edit_outlined,
                          color: AppColors.orange, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          // Main content
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time column
                SizedBox(
                  width: 52,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      widget.activity.time,
                      style: AppTypography.timeLabel,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Timeline line + dot
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 14),
                      decoration: BoxDecoration(
                        color: widget.activity.isCompleted
                            ? AppColors.emerald
                            : AppColors.textMuted,
                        shape: BoxShape.circle,
                        boxShadow: widget.activity.isCompleted
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.emerald.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                    ),
                    if (!widget.isLast)
                      Container(
                        width: 1.5,
                        height: 48,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              widget.activity.isCompleted
                                  ? AppColors.emerald.withValues(alpha: 0.4)
                                  : AppColors.cardBorder,
                              AppColors.cardBorder,
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Activity card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: widget.onToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: widget.activity.isCompleted
                              ? AppColors.emeraldGlow
                              : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: widget.activity.isCompleted
                                ? AppColors.emerald.withValues(alpha: 0.4)
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              widget.activity.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.activity.title,
                                style: AppTypography.titleMedium.copyWith(
                                  color: widget.activity.isCompleted
                                      ? AppColors.emeraldLight
                                      : AppColors.textPrimary,
                                  decoration: widget.activity.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: AppColors.emerald,
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: widget.activity.isCompleted
                                    ? AppColors.emerald
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: widget.activity.isCompleted
                                      ? AppColors.emerald
                                      : AppColors.textMuted
                                          .withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: widget.activity.isCompleted
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
