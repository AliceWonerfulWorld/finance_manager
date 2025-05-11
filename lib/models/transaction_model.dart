import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final String? memo;
  final DateTime date;
  final String type;
  final bool isFavorite;

  TransactionModel({
    String? id,
    required this.amount,
    String? category,
    this.memo,
    required this.date,
    required this.type,
    this.isFavorite = false,
  }) : id = id ?? const Uuid().v4(),
      category = category ?? (type == 'income' ? 'その他収入' : 'その他支出');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'memo': memo,
      'date': date.toIso8601String(),
      'type': type,
      'isFavorite': isFavorite,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: json['amount'] as double,
      category: json['category'] as String,
      memo: json['memo'] as String?,
      date: DateTime.parse(json['date'] as String),
      type: json['type'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  String get formattedAmount {
    final value = type == 'expense' ? amount.abs() : amount;
    return '¥${value.toStringAsFixed(0)}';
  }

  Color get amountColor {
    return type == 'income' ? Colors.green : Colors.red;
  }

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? category,
    String? memo,
    DateTime? date,
    String? type,
    bool? isFavorite,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      memo: memo ?? this.memo,
      date: date ?? this.date,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
} 