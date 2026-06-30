import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';

class CareerScreen extends StatelessWidget {
  const CareerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        title: const Text('Career Roadmap'),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: _buildRoleCard(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _buildSkillTree(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard() {
    return GlassCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.prayerDzuhur, AppColors.orange],
      ),
      borderColor: AppColors.orange.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('👨‍💻', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target Role',
                        style: AppTypography.labelMedium
                            .copyWith(color: Colors.white70)),
                    Text('Senior Backend Engineer',
                        style: AppTypography.headlineMedium
                            .copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.45,
              backgroundColor: Colors.black26,
              valueColor: AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text('45% menuju target. Kamu butuh menguasai System Design dan AWS.',
              style: AppTypography.bodySmall.copyWith(color: Colors.white)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildSkillTree() {
    final categories = [
      (
        'Core Language & Framework',
        '☕',
        [
          ('Java 21', 1.0, true),
          ('Spring Boot 3', 0.8, false),
          ('Hibernate / JPA', 0.85, false),
        ],
      ),
      (
        'Architecture & Design',
        '🏛️',
        [
          ('Domain-Driven Design (DDD)', 0.5, false),
          ('Microservices', 0.6, false),
          ('System Design', 0.4, false),
        ],
      ),
      (
        'DevOps & Cloud',
        '☁️',
        [
          ('Docker', 0.7, false),
          ('Kubernetes', 0.2, false),
          ('AWS (EC2, S3, RDS)', 0.3, false),
          ('CI/CD (GitHub Actions)', 0.6, false),
        ],
      ),
      (
        'Database & Cache',
        '💾',
        [
          ('PostgreSQL', 0.9, false),
          ('Redis', 0.6, false),
          ('Kafka / RabbitMQ', 0.3, false),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Skill Tree'),
        ...categories.asMap().entries.map((entry) {
          final cat = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(cat.$2, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(cat.$1, style: AppTypography.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...cat.$3.map((skill) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (skill.$3)
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.emerald, size: 16)
                              else
                                const Icon(Icons.circle_outlined,
                                    color: AppColors.textMuted, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  skill.$1,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: skill.$3
                                        ? AppColors.emerald
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${(skill.$2 * 100).toInt()}%',
                                style: AppTypography.labelSmall.copyWith(
                                  color: skill.$3
                                      ? AppColors.emerald
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: skill.$2),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, val, child) {
                                return LinearProgressIndicator(
                                  value: val,
                                  backgroundColor: AppColors.navyLight,
                                  valueColor: AlwaysStoppedAnimation(skill.$3
                                      ? AppColors.emerald
                                      : AppColors.prayerDzuhur),
                                  minHeight: 4,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ).animate().fadeIn(
                delay: Duration(milliseconds: 200 + (entry.key * 100)),
                duration: 400.ms),
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }
}
