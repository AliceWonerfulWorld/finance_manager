import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:finance_manager/providers/transaction_provider.dart';
import 'package:finance_manager/models/transaction_model.dart';
import 'package:finance_manager/ui/add_income/add_income_screen.dart';
import 'package:finance_manager/ui/add_expense/add_expense_screen.dart';
import 'package:finance_manager/ui/budget/budget_screen.dart';
import 'package:finance_manager/ui/analytics/analytics_screen.dart';
import 'package:finance_manager/ui/transactions/transactions_screen.dart';
import 'package:finance_manager/ui/transactions/transaction_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:finance_manager/providers/budget_provider.dart';
import 'package:finance_manager/providers/savings_provider.dart';
import 'package:finance_manager/models/savings_model.dart';
import 'package:finance_manager/ui/savings/savings_screen.dart';
import 'package:uuid/uuid.dart';

final currencyFormat = NumberFormat.currency(
  locale: 'ja_JP',
  symbol: '¥',
  decimalDigits: 0,
);

// パターンペインタークラス
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey[800]!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final spacing = 30.0;
    for (var i = 0.0; i < size.width; i += spacing) {
      for (var j = 0.0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ホーム',
          style: GoogleFonts.notoSansJp(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final monthlyIncome = provider.getMonthlyIncome();
          final monthlyExpense = provider.getMonthlyExpense();
          final recentTransactions = provider.getRecentTransactions();
          final expenseByCategory = provider.getExpenseByCategory();

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                _buildHeader(context, monthlyIncome, monthlyExpense),
                const SizedBox(height: 16),
                _buildQuickActions(context),
                _buildRecentTransactions(context, recentTransactions),
                _buildExpenseBreakdown(context, expenseByCategory),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double monthlyIncome,
    double monthlyExpense,
  ) {
    return Container(
      padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '今月の収支',
                style: GoogleFonts.notoSansJp(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${DateTime.now().month}月',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              _buildBalanceCard(
                '収入',
                monthlyIncome,
                Colors.green,
              ),
              _buildBalanceCard(
                '支出',
                monthlyExpense,
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '総収入',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (monthlyIncome - monthlyExpense) >= 0
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                        child: Text(
                        (monthlyIncome - monthlyExpense) >= 0 ? '黒字' : '赤字',
                        style: GoogleFonts.notoSansJp(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: (monthlyIncome - monthlyExpense) >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '¥${(monthlyIncome - monthlyExpense).toStringAsFixed(0)}',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: (monthlyIncome - monthlyExpense) >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '収入: ¥${monthlyIncome.toStringAsFixed(0)} - 支出: ¥${monthlyExpense.toStringAsFixed(0)}',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
                                    ),
                                  ],
                                ),
                              );
  }

  Widget _buildBalanceCard(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
                                style: GoogleFonts.notoSansJp(
                                  fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¥${amount.toStringAsFixed(0)}',
              style: GoogleFonts.notoSansJp(
                fontSize: 24,
                                  fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                '収入を追加',
                Icons.add_circle_outline,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddIncomeScreen(),
                  ),
                ),
              ),
              _buildActionButton(
                context,
                '支出を追加',
                Icons.remove_circle_outline,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddExpenseScreen(),
                                ),
                              ),
                            ),
              _buildActionButton(
                context,
                '貯金目標',
                Icons.savings,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavingsScreen(),
                  ),
                      ),
              ),
            ],
      ),
    ],
   ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
        Text(
              label,
              style: GoogleFonts.notoSansJp(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    List<TransactionModel> transactions,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                Text(
                  '最近の取引',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'すべて見る',
                    style: GoogleFonts.notoSansJp(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '取引がありません',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.type == 'income'
                          ? Colors.green[100]
                          : Colors.red[100],
                      child: Icon(
                        transaction.type == 'income'
                            ? Icons.account_balance_wallet
                            : Icons.shopping_cart,
                        color: transaction.type == 'income'
                            ? Colors.green[800]
                            : Colors.red[800],
                      ),
                    ),
                    title: Text(
                      transaction.category,
                      style: GoogleFonts.notoSansJp(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      transaction.memo ?? '',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Text(
                      transaction.formattedAmount,
                      style: GoogleFonts.notoSansJp(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: transaction.amountColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailScreen(
                            transaction: transaction,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseBreakdown(
    BuildContext context,
    Map<String, double> expenseByCategory,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'カテゴリー別支出',
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (expenseByCategory.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '支出がありません',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenseByCategory.length,
              itemBuilder: (context, index) {
                final category = expenseByCategory.keys.elementAt(index);
                final amount = expenseByCategory[category]!;
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      category,
                      style: GoogleFonts.notoSansJp(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      '¥${amount.toStringAsFixed(0)}',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildIncomeByCategory(BuildContext context) {
    final now = DateTime.now();
    final monthlyIncome = Provider.of<TransactionProvider>(context)
        .transactions
        .where((t) =>
            t.type == 'income' &&
            t.date.year == now.year &&
            t.date.month == now.month);

    final Map<String, double> categoryTotals = {};
    for (var income in monthlyIncome) {
      categoryTotals[income.category] =
          (categoryTotals[income.category] ?? 0) + income.amount;
    }

    if (categoryTotals.isEmpty) {
      return const Center(
        child: Text(
          '今月の収入データがありません',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'カテゴリー別収入',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categoryTotals.length,
          itemBuilder: (context, index) {
            final category = categoryTotals.keys.elementAt(index);
            final amount = categoryTotals[category]!;
            final percentage = amount / categoryTotals.values.reduce((a, b) => a + b) * 100;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: Colors.white.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currencyFormat.format(amount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
 }
}
