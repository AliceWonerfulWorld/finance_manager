import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:finance_manager/providers/transaction_provider.dart';
import 'package:finance_manager/providers/budget_provider.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _monthlyBudgetController = TextEditingController();
  final Map<String, TextEditingController> _categoryControllers = {};
  final _formKey = GlobalKey<FormState>();

  final List<String> _categories = [
    '食費',
    '交通費',
    '住居費',
    '光熱費',
    '通信費',
    '医療費',
    '教育費',
    '娯楽費',
  ];

  @override
  void initState() {
    super.initState();
    for (var category in _categories) {
      _categoryControllers[category] = TextEditingController();
    }
    _loadExistingBudgets();
  }

  void _loadExistingBudgets() {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    // 月間予算の読み込み
    _monthlyBudgetController.text = budgetProvider.monthlyBudget.toInt().toString();
    
    // カテゴリー別予算の読み込み
    for (var category in _categories) {
      final budget = budgetProvider.categoryBudgets[category];
      if (budget != null) {
        _categoryControllers[category]!.text = budget.toInt().toString();
      }
    }
  }

  @override
  void dispose() {
    _monthlyBudgetController.dispose();
    for (var controller in _categoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '予算設定',
          style: GoogleFonts.notoSansJp(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthlyBudget(context),
              const SizedBox(height: 24),
              _buildCategoryBudgets(context),
              const SizedBox(height: 24),
              _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyBudget(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '月間予算',
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
            const SizedBox(height: 20),
            TextFormField(
              controller: _monthlyBudgetController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.notoSansJp(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: '予算額を入力',
                hintStyle: GoogleFonts.notoSansJp(
                  fontSize: 24,
                  color: Colors.white.withOpacity(0.7),
                ),
                prefixText: '¥',
                prefixStyle: GoogleFonts.notoSansJp(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBudgets(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'カテゴリー別予算',
          style: GoogleFonts.notoSansJp(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final budget = budgetProvider.categoryBudgets[category] ?? 0;
            final monthlyExpense = transactionProvider.getMonthlyExpenseByCategory(category);
            final achievementRate = budget > 0 ? (monthlyExpense / budget) * 100 : 0;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          color: _getCategoryColor(category),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category,
                                style: GoogleFonts.notoSansJp(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '支出: ${NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0).format(monthlyExpense)}',
                                style: GoogleFonts.notoSansJp(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: achievementRate > 100 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${achievementRate.toStringAsFixed(1)}%',
                            style: GoogleFonts.notoSansJp(
                              fontSize: 12,
                              color: achievementRate > 100 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: achievementRate / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        achievementRate > 100 ? Colors.red : Colors.green,
                      ),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _categoryControllers[category],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '予算額',
                        prefixText: '¥',
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.notoSansJp(),
                        helperText: '残り予算: ${NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0).format(budget - monthlyExpense)}',
                        helperStyle: GoogleFonts.notoSansJp(
                          fontSize: 12,
                          color: (budget - monthlyExpense) < 0 ? Colors.red : Colors.green,
                        ),
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

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
            
            // 月間予算の保存
            if (_monthlyBudgetController.text.isNotEmpty) {
              final monthlyBudget = double.parse(_monthlyBudgetController.text);
              await budgetProvider.setMonthlyBudget(monthlyBudget);
            }

            // カテゴリー別予算の保存
            for (var category in _categories) {
              if (_categoryControllers[category]!.text.isNotEmpty) {
                final amount = double.parse(_categoryControllers[category]!.text);
                await budgetProvider.setCategoryBudget(category, amount);
              }
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('予算を保存しました'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pop(context);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '保存',
          style: GoogleFonts.notoSansJp(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '食費':
        return Icons.restaurant;
      case '交通費':
        return Icons.directions_bus;
      case '住居費':
        return Icons.home;
      case '光熱費':
        return Icons.power;
      case '通信費':
        return Icons.phone_android;
      case '医療費':
        return Icons.medical_services;
      case '教育費':
        return Icons.school;
      case '娯楽費':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '食費':
        return Colors.orange;
      case '交通費':
        return Colors.blue;
      case '住居費':
        return Colors.brown;
      case '光熱費':
        return Colors.yellow[700]!;
      case '通信費':
        return Colors.purple;
      case '医療費':
        return Colors.red;
      case '教育費':
        return Colors.green;
      case '娯楽費':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
} 