import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:finance_manager/providers/transaction_provider.dart';

class AdviceScreen extends StatelessWidget {
  const AdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '家計簿アドバイス',
          style: GoogleFonts.notoSansJp(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthlySummary(context),
            const SizedBox(height: 24),
            _buildSpendingAnalysis(context),
            const SizedBox(height: 24),
            _buildSavingTips(context),
            const SizedBox(height: 24),
            _buildBudgetRecommendations(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final monthlyIncome = provider.getMonthlyIncome();
    final monthlyExpense = provider.getMonthlyExpense();
    final balance = monthlyIncome - monthlyExpense;
    final savingsRate = monthlyIncome > 0 ? ((balance / monthlyIncome) * 100).toDouble() : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今月の家計状況',
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('収入', monthlyIncome, Colors.green),
            const SizedBox(height: 8),
            _buildSummaryRow('支出', monthlyExpense, Colors.red),
            const Divider(),
            _buildSummaryRow('残高', balance, balance >= 0 ? Colors.blue : Colors.orange),
            const SizedBox(height: 8),
            _buildSummaryRow('貯蓄率', savingsRate, Colors.purple, isPercentage: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingAnalysis(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final expenseByCategory = provider.getExpenseByCategory();
    final totalExpense = expenseByCategory.values.fold(0.0, (sum, amount) => sum + amount);
    
    // 支出が多いカテゴリーを特定
    final topExpenseCategory = expenseByCategory.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    final topExpensePercentage = (topExpenseCategory.value / totalExpense) * 100;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '支出分析',
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (topExpensePercentage > 40) ...[
              _buildAnalysisItem(
                Icons.warning_amber_rounded,
                Colors.orange,
                '${topExpenseCategory.key}への支出が${topExpensePercentage.toStringAsFixed(1)}%を占めています',
                'このカテゴリーの支出を見直すことをお勧めします',
              ),
            ] else ...[
              _buildAnalysisItem(
                Icons.check_circle,
                Colors.green,
                'カテゴリー別の支出バランスは良好です',
                '現在の支出配分を維持しましょう',
              ),
            ],
            const SizedBox(height: 16),
            ...expenseByCategory.entries.map((entry) {
              final percentage = (entry.value / totalExpense) * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: GoogleFonts.notoSansJp(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentage > 40 ? Colors.orange : Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingTips(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final monthlyExpense = provider.getMonthlyExpense();
    final expenseByCategory = provider.getExpenseByCategory();
    
    // 節約のヒントを生成
    final tips = <String>[];
    
    if (expenseByCategory.containsKey('食費') && 
        expenseByCategory['食費']! > monthlyExpense * 0.3) {
      tips.add('外食の頻度を見直してみましょう');
    }
    
    if (expenseByCategory.containsKey('交通費') && 
        expenseByCategory['交通費']! > monthlyExpense * 0.2) {
      tips.add('公共交通機関の利用を検討してみましょう');
    }
    
    if (expenseByCategory.containsKey('娯楽') && 
        expenseByCategory['娯楽']! > monthlyExpense * 0.15) {
      tips.add('無料の趣味や活動を探してみましょう');
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '節約のヒント',
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (tips.isEmpty)
              _buildAnalysisItem(
                Icons.check_circle,
                Colors.green,
                '現在の支出バランスは良好です',
                'このままの支出習慣を維持しましょう',
              )
            else
              ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.notoSansJp(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }
  Widget _buildBudgetRecommendations(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final monthlyExpense = provider.getMonthlyExpense();
    final expenseByCategory = provider.getExpenseByCategory();
    
    // 予算の推奨値を計算
    final recommendations = <Map<String, dynamic>>[];
    
    expenseByCategory.forEach((category, amount) {
      final percentage = (amount / monthlyExpense) * 100;
      String recommendation;
      Color color;
      
      if (percentage > 40) {
        recommendation = '${(amount * 0.8).toStringAsFixed(0)}円';
        color = Colors.red;
      } else if (percentage > 30) {
        recommendation = '${(amount * 0.9).toStringAsFixed(0)}円';
        color = Colors.orange;
      } else {
        recommendation = '現状維持';
        color = Colors.green;
      }
      
      recommendations.add({
        'category': category,
        'current': amount,
        'recommendation': recommendation,
        'color': color,
      });
    });

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '予算の推奨値',
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      rec['category'],
                      style: GoogleFonts.notoSansJp(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '¥${rec['current'].toStringAsFixed(0)}',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      rec['recommendation'],
                      style: GoogleFonts.notoSansJp(
                        fontSize: 14,
                        color: rec['color'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, Color color, {bool isPercentage = false}) {
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
          isPercentage
              ? '${value.toStringAsFixed(1)}%'
              : '¥${value.toStringAsFixed(0)}',
          style: GoogleFonts.notoSansJp(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisItem(IconData icon, Color color, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansJp(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
  }
} 