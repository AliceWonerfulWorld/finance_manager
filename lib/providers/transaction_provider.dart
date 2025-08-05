import 'package:flutter/material.dart';
import 'package:finance_manager/models/transaction_model.dart';
import 'package:finance_manager/config/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

/// 取引データの管理を行うプロバイダークラス
/// 
/// このクラスは以下の機能を提供します：
/// - 取引データの追加、更新、削除
/// - 収入・支出の集計
/// - 残高の計算
/// - カテゴリ別集計
/// - データベースとの同期
/// - Webストレージ対応
class TransactionProvider with ChangeNotifier {
  final List<TransactionModel> _transactions = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  double _balance = 0.0; // **合計残高**
  final _uuid = Uuid();
  final String _storageKey = 'transactions';
  
  List<TransactionModel> get transactions => _transactions;
  double get balance => _balance; // **バランスを取得**
  
  double get totalIncome => _transactions
      .where((txn) => txn.type == "income")
      .fold(0.0, (sum, txn) => sum + txn.amount);

  double get totalExpense => _transactions
      .where((txn) => txn.type == "expense")
      .fold(0.0, (sum, txn) => sum + txn.amount.abs());

  /// **合計残高を更新**
  void _updateBalance() {
    _balance = totalIncome - totalExpense;
    notifyListeners();
  }

  /// **コンストラクタでデータをロード**
  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _dbHelper.getAllTransactions();
      _transactions.clear();
      _transactions.addAll(transactions);
      _updateBalance();
      notifyListeners();
      debugPrint('取引を${transactions.length}件読み込みました');
    } catch (e) {
      debugPrint('取引の読み込みに失敗しました: $e');
    }
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = _transactions
        .map((transaction) => jsonEncode(transaction.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, transactionsJson);
  }

  /// **取引を追加**
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _dbHelper.addTransaction(transaction);
      _transactions.add(transaction);
      _updateBalance();
      await _saveTransactions();
      notifyListeners();
      debugPrint('取引を追加しました: ${transaction.category} - ${transaction.amount}円');
    } catch (e) {
      debugPrint('取引の追加に失敗しました: $e');
      rethrow;
    }
  }

  /// **取引を削除**
  Future<void> deleteTransaction(String id) async {
    try {
      await _dbHelper.deleteTransaction(id);
      _transactions.removeWhere((transaction) => transaction.id == id);
      _updateBalance();
      await _saveTransactions();
      notifyListeners();
      debugPrint('取引を削除しました: $id');
    } catch (e) {
      debugPrint('取引の削除に失敗しました: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _dbHelper.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('取引の更新に失敗しました: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index != -1) {
        final transaction = _transactions[index];
        final updatedTransaction = transaction.copyWith(
          isFavorite: !transaction.isFavorite,
        );
        await _dbHelper.updateTransaction(updatedTransaction);
        _transactions[index] = updatedTransaction;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('お気に入りの切り替えに失敗しました: $e');
      rethrow;
    }
  }

  double getMonthlyIncome() {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == 'income' &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getMonthlyExpense() {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == 'expense' &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  List<TransactionModel> getRecentTransactions() {
    return List.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, double> getExpenseByCategory() {
    final now = DateTime.now();
    final monthlyExpenses = _transactions.where((t) =>
        t.type == 'expense' &&
        t.date.year == now.year &&
        t.date.month == now.month);

    final Map<String, double> categoryTotals = {};
    for (var expense in monthlyExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount.abs();
    }
    return categoryTotals;
  }

  Map<String, double> getMonthlyTrend() {
    final now = DateTime.now();
    final Map<String, double> monthlyTrend = {};
    
    // 過去6ヶ月分のデータを取得
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthKey = '${date.year}/${date.month}';
      
      final monthlyIncome = _transactions
          .where((t) =>
              t.type == 'income' &&
              t.date.year == date.year &&
              t.date.month == date.month)
          .fold(0.0, (sum, t) => sum + t.amount);

      final monthlyExpense = _transactions
          .where((t) =>
              t.type == 'expense' &&
              t.date.year == date.year &&
              t.date.month == date.month)
          .fold(0.0, (sum, t) => sum + t.amount.abs());

      monthlyTrend[monthKey] = monthlyIncome - monthlyExpense;
    }
    
    return monthlyTrend;
  }

  double getBudgetAchievementRate(String category) {
    // 予算データの実装後に更新予定
    return 0.0;
  }

  double getMonthlyExpenseByCategory(String category) {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == 'expense' &&
            t.category == category &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  String generateId() {
    return _uuid.v4();
  }

  List<TransactionModel> getTransactions() {
    return _transactions;
  }
}
