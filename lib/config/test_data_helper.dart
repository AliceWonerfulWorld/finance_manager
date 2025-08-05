import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TestDataHelper {
  static List<TransactionModel> generateSampleTransactions() {
    return [
      TransactionModel(
        amount: 300000,
        category: '給与',
        memo: '月給',
        date: DateTime.now().subtract(const Duration(days: 5)),
        type: 'income',
      ),
      TransactionModel(
        amount: 80000,
        category: '食費',
        memo: '食材購入',
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: 'expense',
      ),
      TransactionModel(
        amount: 15000,
        category: '交通費',
        memo: '電車代',
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: 'expense',
      ),
      TransactionModel(
        amount: 50000,
        category: '光熱費',
        memo: '電気代',
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'expense',
      ),
      TransactionModel(
        amount: 25000,
        category: 'その他収入',
        memo: '副業収入',
        date: DateTime.now(),
        type: 'income',
      ),
    ];
  }
}
