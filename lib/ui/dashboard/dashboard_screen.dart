import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:finance_manager/providers/transaction_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' show max;
import 'package:finance_manager/ui/budget/budget_screen.dart';
import 'package:finance_manager/ui/advice/advice_screen.dart';
import 'package:finance_manager/ui/calendar/calendar_screen.dart';
import 'package:finance_manager/providers/budget_provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ステータスバーの色を設定
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ダッシュボード',
          style: GoogleFonts.notoSansJp(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildExpenseChart(context),
            const SizedBox(height: 24),
            _buildMonthlyTrend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final monthlyIncome = provider.getMonthlyIncome();
    final monthlyExpense = provider.getMonthlyExpense();
    final balance = monthlyIncome - monthlyExpense;
    final budgetAchievementRate = budgetProvider.getMonthlyBudgetAchievementRate();
    final remainingBudget = budgetProvider.getRemainingBudget();

    return Column(
      children: [
        _buildBalanceCard(context, balance),
        const SizedBox(height: 16),
        _buildBudgetStatusCard(context, budgetAchievementRate, remainingBudget),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance) {
    final provider = Provider.of<TransactionProvider>(context);
    final monthlyIncome = provider.getMonthlyIncome();
    final monthlyExpense = provider.getMonthlyExpense();
    final color = balance >= 0 ? Colors.green : Colors.orange;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今月の概況',
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('収入', monthlyIncome, Colors.green),
            const SizedBox(height: 8),
            _buildStatRow('支出', monthlyExpense, Colors.red),
            const Divider(),
            _buildStatRow('総収入', balance, color),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetStatusCard(BuildContext context, double achievementRate, double remainingBudget) {
    final color = achievementRate > 100 ? Colors.red : Colors.green;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '予算使用状況',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${achievementRate.toStringAsFixed(1)}%',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: achievementRate / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Text(
              '残り予算: ${NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0).format(remainingBudget)}',
              style: GoogleFonts.notoSansJp(
                fontSize: 16,
                color: remainingBudget < 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (remainingBudget < 0) ...[
              const SizedBox(height: 8),
              Text(
                '予算をオーバーしています！',
                style: GoogleFonts.notoSansJp(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSansJp(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '¥${amount.toStringAsFixed(0)}',
          style: GoogleFonts.notoSansJp(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'クイックアクション',
          style: GoogleFonts.notoSansJp(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              context,
              '予算設定',
              Icons.account_balance_wallet,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetScreen()),
              ),
            ),
            _buildActionCard(
              context,
              '家計簿アドバイス',
              Icons.lightbulb_outline,
              Colors.amber,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdviceScreen()),
              ),
            ),
            _buildActionCard(
              context,
              '家計簿カレンダー',
              Icons.calendar_today,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              ),
            ),
            _buildActionCard(
              context,
              'レポート',
              Icons.bar_chart,
              Colors.teal,
              () {
                // TODO: レポート画面の実装
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('準備中です')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.notoSansJp(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseChart(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final expenseByCategory = provider.getExpenseByCategory();

    if (expenseByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalExpense = expenseByCategory.values.fold(0.0, (sum, amount) => sum + amount);
    final categories = expenseByCategory.keys.toList();
    
    // 固定の色リストを定義
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    final sections = categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final amount = expenseByCategory[category]!;
      final percentage = amount / totalExpense;
      final color = colors[index % colors.length];

      return PieChartSectionData(
        color: color,
        value: amount,
        title: '${(percentage * 100).toStringAsFixed(1)}%',
        radius: 65,
        titleStyle: GoogleFonts.notoSansJp(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'カテゴリー別支出',
            style: GoogleFonts.notoSansJp(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 1,
                      centerSpaceRadius: 25,
                      startDegreeOffset: -90,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                SizedBox(
                  width: 140,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      final amount = expenseByCategory[category]!;
                      final color = colors[index % colors.length];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category,
                                    style: GoogleFonts.notoSansJp(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '¥${amount.toStringAsFixed(0)}',
                                    style: GoogleFonts.notoSansJp(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrend(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final monthlyTrend = provider.getMonthlyTrend();

    if (monthlyTrend.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = monthlyTrend.entries.map((entry) {
      return FlSpot(
        monthlyTrend.keys.toList().indexOf(entry.key).toDouble(),
        entry.value,
      );
    }).toList();

    final maxY = spots.map((spot) => spot.y).reduce(max).abs();
    final minY = -maxY;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '月間収支推移',
          style: GoogleFonts.notoSansJp(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '¥${value.toInt()}',
                        style: GoogleFonts.notoSansJp(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < monthlyTrend.length) {
                        final date = monthlyTrend.keys.elementAt(index).split('/');
                        return Text(
                          '${date[1]}月',
                          style: GoogleFonts.notoSansJp(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 