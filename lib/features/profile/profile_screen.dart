import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, user?.displayName ?? 'User', user?.email ?? '')),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(child: _buildXpCard()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(child: _buildStats()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(child: _buildYearlyGoals()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(child: _buildCareerSkills(context)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverToBoxAdapter(child: _buildSettings(context, ref)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String displayName, String email) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.navyMid, AppColors.navyDeep],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Profile', style: AppTypography.headlineLarge),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.navyLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(Icons.settings_outlined,
                      color: AppColors.textSecondary, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.emerald, AppColors.navyMid],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.emerald, width: 2),
                    ),
                    child: const Center(
                      child: Text('🧑‍💻', style: TextStyle(fontSize: 36)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.navyDeep, width: 2),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          size: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: AppTypography.headlineMedium),
                    const SizedBox(height: 4),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.orangeGlow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
                      ),
                      child: Text('⚡ Level 8 — The Builder',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.orange)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded,
                            color: AppColors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text('22 hari streak',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.orange)),
                        const SizedBox(width: 16),
                        const Icon(Icons.star_rounded, color: AppColors.prayerDzuhur, size: 16),
                        const SizedBox(width: 4),
                        Text('4,280 XP',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.prayerDzuhur)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildXpCard() {
    return GlassCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.navyMid, AppColors.navyLight],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Progress ke Level 9', style: AppTypography.titleMedium),
              const Spacer(),
              Text('4,280 / 5,000 XP',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.prayerDzuhur)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 0.856),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.navyLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.prayerDzuhur),
                  minHeight: 8,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text('720 XP lagi untuk naik level!',
              style: AppTypography.bodySmall.copyWith(color: AppColors.emerald)),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildStats() {
    return Row(
      children: [
        _ProfileStat('🔥', '22', 'Streak'),
        _ProfileStat('✅', '847', 'Task Done'),
        _ProfileStat('🕌', '143', 'Sholat'),
        _ProfileStat('📚', '48h', 'Belajar'),
      ].asMap().entries.map((e) {
        return Expanded(
          child: e.value
              .animate()
              .fadeIn(delay: Duration(milliseconds: 50 * e.key + 150), duration: 300.ms),
        );
      }).toList(),
    );
  }

  Widget _buildYearlyGoals() {
    final goals = [
      ('🇬🇧', 'Kursus Bahasa Inggris', 0.65),
      ('🏋', 'Berat Badan Ideal', 0.40),
      ('💰', 'Dana Darurat 6 Bulan', 0.72),
      ('💻', 'AWS Certified', 0.30),
      ('📖', 'Baca 12 Buku', 0.42),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Goal Tahun 2025'),
          ...goals.map((g) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(g.$1, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(g.$2, style: AppTypography.titleMedium)),
                      Text('${(g.$3 * 100).toInt()}%',
                          style: AppTypography.bodySmall.copyWith(
                              color: g.$3 >= 0.7 ? AppColors.emerald : AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: g.$3),
                      duration: const Duration(milliseconds: 800),
                      builder: (_, v, __) => LinearProgressIndicator(
                        value: v,
                        backgroundColor: AppColors.navyLight,
                        valueColor: AlwaysStoppedAnimation(
                            v >= 0.7 ? AppColors.emerald : AppColors.orange),
                        minHeight: 5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms, duration: 400.ms);
  }

  Widget _buildCareerSkills(BuildContext context) {
    final skills = [
      ('☕', 'Spring Boot', 0.75, AppColors.prayerDzuhur),
      ('🏛️', 'DDD', 0.50, AppColors.prayerSubuh),
      ('⚙️', 'System Design', 0.40, AppColors.emerald),
      ('🐳', 'Docker', 0.70, AppColors.info),
      ('☁️', 'AWS', 0.30, AppColors.orange),
      ('☸️', 'Kubernetes', 0.20, AppColors.prayerIsya),
    ];

    return GlassCard(
      onTap: () => context.push('/career'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const SectionHeader(
          title: 'Career Roadmap',
          trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: skills.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: s.$4.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: s.$4.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(s.$1, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            s.$2,
                            style: AppTypography.labelMedium.copyWith(color: s.$4),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(s.$3 * 100).toInt()}%',
                          style: AppTypography.labelSmall.copyWith(
                              color: s.$4, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: s.$3,
                        backgroundColor: AppColors.navyLight,
                        valueColor: AlwaysStoppedAnimation(s.$4),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildSettings(BuildContext context, WidgetRef ref) {
    final items = [
      (Icons.person_outline_rounded, 'Edit Profile', AppColors.emerald, false),
      (Icons.notifications_outlined, 'Notifikasi', AppColors.orange, false),
      (Icons.dark_mode_outlined, 'Tampilan', AppColors.prayerSubuh, false),
      (Icons.backup_outlined, 'Backup Data', AppColors.info, false),
      (Icons.logout_rounded, 'Keluar', AppColors.error, true),
    ];

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: items.map((item) {
          return GestureDetector(
            onTap: () async {
              if (item.$4) {
                // Logout
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.navyMid,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: Text('Keluar?', style: AppTypography.headlineSmall),
                    content: Text(
                      'Kamu akan keluar dari akunmu.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textMuted),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Batal',
                            style: AppTypography.titleMedium
                                .copyWith(color: AppColors.textMuted)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Keluar',
                            style: AppTypography.titleMedium
                                .copyWith(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await ref.read(authProvider.notifier).logout();
                  // Router redirect akan otomatis ke /auth
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1)),
              ),
              child: Row(
                children: [
                  Icon(item.$1, color: item.$3, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item.$2, style: AppTypography.titleMedium),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted, size: 18),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 400.ms);
  }
}

class _ProfileStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _ProfileStat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(value,
              style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary)),
          Text(label, style: AppTypography.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
