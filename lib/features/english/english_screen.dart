import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';

class EnglishScreen extends StatelessWidget {
  const EnglishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        title: const Text('English Learning'),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: _buildStreakCard(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _buildVocabularyToday(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverToBoxAdapter(
              child: _buildModules(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return GlassCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.orangeDark, AppColors.orange],
      ),
      borderColor: AppColors.orange.withValues(alpha: 0.3),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '18 Hari Beruntun!',
                  style: AppTypography.headlineMedium
                      .copyWith(color: Colors.white),
                ),
                Text(
                  'Pertahankan streak belajarmu',
                  style:
                      AppTypography.bodySmall.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildVocabularyToday() {
    final words = [
      (
        'Resilience',
        'Ketahanan / keuletan',
        'Her resilience in facing challenges is inspiring.'
      ),
      ('Ubiquitous', 'Ada di mana-mana', 'Smartphones have become ubiquitous.'),
      (
        'Ephemeral',
        'Berumur pendek',
        'Fame in the internet age can be ephemeral.'
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Vocabulary of the Day'),
        ...words.map((w) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(w.$1,
                          style: AppTypography.titleLarge
                              .copyWith(color: AppColors.emerald)),
                      const Spacer(),
                      const Icon(Icons.volume_up_rounded,
                          color: AppColors.textMuted, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(w.$2, style: AppTypography.bodySmall),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.navyLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            w.$3,
                            style: AppTypography.bodySmall
                                .copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
        }),
      ],
    );
  }

  Widget _buildModules() {
    final modules = [
      ('🎧', 'Listening', 'Podcast & percakapan', AppColors.info),
      ('🗣️', 'Speaking', 'Latihan intonasi', AppColors.orange),
      ('📖', 'Reading', 'Artikel & cerita', AppColors.emerald),
      ('✍️', 'Writing', 'Grammar & essay', AppColors.prayerIsya),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Modul Belajar'),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: modules.map((m) {
            return GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: m.$4.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m.$1, style: const TextStyle(fontSize: 24)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.$2, style: AppTypography.titleMedium),
                      Text(m.$3, style: AppTypography.labelSmall),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
      ],
    );
  }
}
