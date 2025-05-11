import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_manager/providers/transaction_provider.dart';

class BudgetProvider with ChangeNotifier {
  double _monthlyBudget = 0;
  double _monthlyGoal = 0;
  final Map<String, double> _categoryBudgets = {};
  final SharedPreferences _prefs;
  final TransactionProvider _transactionProvider;

  BudgetProvider(this._prefs, this._transactionProvider) {
    _loadBudget();
    _loadGoal();
    _loadCategoryBudgets();
  }

  double get monthlyBudget => _monthlyBudget;
  double get monthlyGoal => _monthlyGoal;
  Map<String, double> get categoryBudgets => _categoryBudgets;

  // 月間予算の達成率を計算
  double getMonthlyBudgetAchievementRate() {
    if (_monthlyBudget == 0) return 0;
    final monthlyExpense = _transactionProvider.getMonthlyExpense();
    return (monthlyExpense / _monthlyBudget) * 100;
  }

  // カテゴリー別予算の達成率を計算
  double getCategoryBudgetAchievementRate(String category) {
    if (!_categoryBudgets.containsKey(category) || _categoryBudgets[category] == 0) {
      return 0;
    }
    
    final now = DateTime.now();
    final monthlyExpenses = _transactionProvider.transactions
        .where((t) =>
            t.type == 'expense' &&
            t.category == category &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount.abs());

    return (monthlyExpenses / _categoryBudgets[category]!) * 100;
  }

  // 予算オーバーのカテゴリーを取得
  List<String> getOverBudgetCategories() {
    final overBudgetCategories = <String>[];
    for (var category in _categoryBudgets.keys) {
      if (getCategoryBudgetAchievementRate(category) > 100) {
        overBudgetCategories.add(category);
      }
    }
    return overBudgetCategories;
  }

  // 予算の残り金額を計算
  double getRemainingBudget() {
    return _monthlyBudget - _transactionProvider.getMonthlyExpense();
  }

  // カテゴリー別の予算残額を計算
  double getRemainingCategoryBudget(String category) {
    if (!_categoryBudgets.containsKey(category)) return 0;
    
    final now = DateTime.now();
    final monthlyExpenses = _transactionProvider.transactions
        .where((t) =>
            t.type == 'expense' &&
            t.category == category &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount.abs());

    return _categoryBudgets[category]! - monthlyExpenses;
  }

  Future<void> setMonthlyBudget(double amount) async {
    _monthlyBudget = amount;
    await _prefs.setDouble('monthly_budget', amount);
    notifyListeners();
  }

  Future<void> setMonthlyGoal(double amount) async {
    _monthlyGoal = amount;
    await _prefs.setDouble('monthly_goal', amount);
    notifyListeners();
  }

  Future<void> setCategoryBudget(String category, double amount) async {
    _categoryBudgets[category] = amount;
    await _prefs.setDouble('category_budget_$category', amount);
    notifyListeners();
  }

  Future<void> deleteMonthlyGoal() async {
    _monthlyGoal = 0;
    await _prefs.remove('monthly_goal');
    notifyListeners();
  }

  void _loadBudget() {
    _monthlyBudget = _prefs.getDouble('monthly_budget') ?? 0;
  }

  void _loadGoal() {
    _monthlyGoal = _prefs.getDouble('monthly_goal') ?? 0;
  }

  void _loadCategoryBudgets() {
    final categories = [
      '食費',
      '交通費',
      '住居費',
      '光熱費',
      '通信費',
      '医療費',
      '教育費',
      '娯楽費',
    ];

    for (var category in categories) {
      final amount = _prefs.getDouble('category_budget_$category');
      if (amount != null) {
        _categoryBudgets[category] = amount;
      }
    }
  }
} 