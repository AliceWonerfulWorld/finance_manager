import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_manager/models/savings_model.dart';

class SavingsProvider with ChangeNotifier {
  List<SavingsModel> _savings = [];
  static const String _storageKey = 'savings_data';

  List<SavingsModel> get savings => _savings;

  SavingsProvider() {
    _loadSavings();
  }

  Future<void> _loadSavings() async {
    final prefs = await SharedPreferences.getInstance();
    final savingsJson = prefs.getStringList(_storageKey) ?? [];
    _savings = savingsJson
        .map((json) => SavingsModel.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveSavings() async {
    final prefs = await SharedPreferences.getInstance();
    final savingsJson = _savings
        .map((saving) => jsonEncode(saving.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, savingsJson);
  }

  Future<void> addSaving(SavingsModel saving) async {
    _savings.add(saving);
    await _saveSavings();
    notifyListeners();
  }

  Future<void> updateSaving(SavingsModel saving) async {
    final index = _savings.indexWhere((s) => s.id == saving.id);
    if (index != -1) {
      _savings[index] = saving;
      await _saveSavings();
      notifyListeners();
    }
  }

  Future<void> deleteSaving(String id) async {
    _savings.removeWhere((saving) => saving.id == id);
    await _saveSavings();
    notifyListeners();
  }

  Future<void> addAmount(String id, double amount) async {
    final index = _savings.indexWhere((s) => s.id == id);
    if (index != -1) {
      final saving = _savings[index];
      final updatedSaving = saving.copyWith(
        currentAmount: saving.currentAmount + amount,
      );
      _savings[index] = updatedSaving;
      await _saveSavings();
      notifyListeners();
    }
  }

  double getTotalSavings() {
    return _savings.fold(0.0, (sum, saving) => sum + saving.currentAmount);
  }

  double getTotalTargetAmount() {
    return _savings.fold(0.0, (sum, saving) => sum + saving.targetAmount);
  }
} 