import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/glass_card.dart';

// Finance providers
final financeProvider = StateNotifierProvider<FinanceNotifier, FinanceState>((ref) {
  return FinanceNotifier();
});

class FinanceState {
  final double income;
  final double expense;
  final double savings;
  final double investment;
  final double emergencyFund;
  final List<TransactionItem> transactions;

  FinanceState({
    required this.income,
    required this.expense,
    required this.savings,
    required this.investment,
    required this.emergencyFund,
    required this.transactions,
  });

  double get netWorth => savings + investment + emergencyFund;
  double get savingsRate => income > 0 ? (savings / income) * 100 : 0;
}

class TransactionItem {
  final String emoji;
  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final DateTime date;

  TransactionItem({
    required this.emoji,
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}

class FinanceNotifier extends StateNotifier<FinanceState> {
  FinanceNotifier()
      : super(FinanceState(
          income: 8500000,
          expense: 4200000,
          savings: 2000000,
          investment: 1500000,
          emergencyFund: 15000000,
          transactions: [
            TransactionItem(
              emoji: '💼',
              title: 'Gaji Bulanan',
              category: 'Income',
              amount: 8500000,
              isIncome: true,
              date: DateTime.now().subtract(const Duration(days: 2)),
            ),
            TransactionItem(
              emoji: '🏠',
              title: 'Kos / Sewa',
              category: 'Housing',
              amount: 1500000,
              isIncome: false,
              date: DateTime.now().subtract(const Duration(days: 3)),
            ),
            TransactionItem(
              emoji: '🍽️',
              title: 'Makan & Minum',
              category: 'Food',
              amount: 900000,
              isIncome: false,
              date: DateTime.now().subtract(const Duration(days: 4)),
            ),
            TransactionItem(
              emoji: '📈',
              title: 'Reksa Dana',
              category: 'Investment',
              amount: 1500000,
              isIncome: false,
              date: DateTime.now().subtract(const Duration(days: 5)),
            ),
            TransactionItem(
              emoji: '🚗',
              title: 'Transportasi',
              category: 'Transport',
              amount: 300000,
              isIncome: false,
              date: DateTime.now().subtract(const Duration(days: 6)),
            ),
            TransactionItem(
              emoji: '💊',
              title: 'Gym & Kesehatan',
              category: 'Health',
              amount: 250000,
              isIncome: false,
              date: DateTime.now().subtract(const Duration(days: 7)),
            ),
          ],
        ));
}

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(finance)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: SliverToBoxAdapter(child: _buildIncomeExpenseCards(finance)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(child: _buildDonutChart(finance)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(child: _buildSavingsInvestment(finance)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverToBoxAdapter(child: _buildTransactions(finance)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(FinanceState finance) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Finance', style: AppTypography.headlineLarge),
                  Text('Juni 2025', style: AppTypography.bodySmall),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Transaksi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  textStyle: AppTypography.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Net Worth card
          GlassCard(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B3A2D), Color(0xFF0D2419)],
            ),
            borderColor: AppColors.emerald.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Net Worth', style: AppTypography.bodySmall),
                const SizedBox(height: 4),
                Text(
                  'Rp ${_formatCurrency(finance.netWorth)}',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.emerald,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded,
                        color: AppColors.emerald, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Savings Rate: ${finance.savingsRate.toStringAsFixed(1)}%',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.emerald),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseCards(FinanceState finance) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            backgroundColor: AppColors.emeraldGlow,
            borderColor: AppColors.emerald.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_downward_rounded,
                        color: AppColors.emerald, size: 16),
                    const SizedBox(width: 4),
                    Text('Pemasukan',
                        style: AppTypography.labelMedium.copyWith(color: AppColors.emerald)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp ${_formatCurrency(finance.income)}',
                  style: AppTypography.titleLarge.copyWith(color: AppColors.emerald),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            backgroundColor: AppColors.orangeGlow,
            borderColor: AppColors.orange.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded,
                        color: AppColors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text('Pengeluaran',
                        style: AppTypography.labelMedium.copyWith(color: AppColors.orange)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Rp ${_formatCurrency(finance.expense)}',
                  style: AppTypography.titleLarge.copyWith(color: AppColors.orange),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
        ),
      ],
    );
  }

  Widget _buildDonutChart(FinanceState finance) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Alokasi Keuangan'),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                SizedBox(
                  width: 160,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = response.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sections: [
                        _pieSection(finance.savings, AppColors.emerald, 'Tabungan', 0),
                        _pieSection(finance.investment, AppColors.prayerSubuh, 'Investasi', 1),
                        _pieSection(finance.expense, AppColors.orange, 'Pengeluaran', 2),
                        _pieSection(finance.emergencyFund * 0.1, AppColors.prayerIsya, 'Dana Darurat', 3),
                      ],
                      centerSpaceRadius: 45,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendItem('Tabungan', AppColors.emerald,
                          'Rp ${_formatCurrency(finance.savings)}'),
                      _LegendItem('Investasi', AppColors.prayerSubuh,
                          'Rp ${_formatCurrency(finance.investment)}'),
                      _LegendItem('Pengeluaran', AppColors.orange,
                          'Rp ${_formatCurrency(finance.expense)}'),
                      _LegendItem('Dana Darurat', AppColors.prayerIsya,
                          'Rp ${_formatCurrency(finance.emergencyFund)}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  PieChartSectionData _pieSection(double value, Color color, String title, int idx) {
    final isTouched = idx == _touchedIndex;
    return PieChartSectionData(
      color: color,
      value: value,
      title: '',
      radius: isTouched ? 55 : 45,
    );
  }

  Widget _buildSavingsInvestment(FinanceState finance) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💰 Dana Darurat', style: AppTypography.titleSmall),
                const SizedBox(height: 6),
                Text(
                  'Rp ${_formatCurrency(finance.emergencyFund)}',
                  style: AppTypography.titleLarge.copyWith(color: AppColors.prayerIsya),
                ),
                const SizedBox(height: 6),
                Text('≈ 4 bulan pengeluaran',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.emerald)),
              ],
            ),
          ).animate().fadeIn(delay: 250.ms),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📈 Investasi', style: AppTypography.titleSmall),
                const SizedBox(height: 6),
                Text(
                  'Rp ${_formatCurrency(finance.investment)}',
                  style: AppTypography.titleLarge.copyWith(color: AppColors.prayerSubuh),
                ),
                const SizedBox(height: 6),
                Text('+12.4% YTD',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.emerald)),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
        ),
      ],
    );
  }

  Widget _buildTransactions(FinanceState finance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Transaksi Terbaru'),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Column(
            children: finance.transactions.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: t.isIncome
                            ? AppColors.emeraldGlow
                            : AppColors.orangeGlow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(t.emoji, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title, style: AppTypography.titleMedium),
                          Text(t.category, style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      '${t.isIncome ? '+' : '-'} Rp ${_formatCurrency(t.amount)}',
                      style: AppTypography.titleMedium.copyWith(
                        color: t.isIncome ? AppColors.emerald : AppColors.orange,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}jt';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return amount.toStringAsFixed(0);
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final String value;

  const _LegendItem(this.label, this.color, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelSmall),
                Text(value,
                    style: AppTypography.labelSmall.copyWith(
                        color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
