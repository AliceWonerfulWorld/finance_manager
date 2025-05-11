import 'package:flutter/foundation.dart';
import 'package:finance_manager/models/goal_model.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GoalProvider with ChangeNotifier {
  List<GoalModel> _goals = [];
  final SharedPreferences _prefs;
  static const String _goalsKey = 'goals';
  final _uuid = const Uuid();

  GoalProvider(this._prefs) {
    _loadGoals();
  }

  List<GoalModel> get goals => _goals;

  void _loadGoals() {
    final goalsJson = _prefs.getStringList(_goalsKey) ?? [];
    _goals = goalsJson
        .map((json) => GoalModel.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveGoals() async {
    final goalsJson = _goals
        .map((goal) => jsonEncode(goal.toJson()))
        .toList();
    await _prefs.setStringList(_goalsKey, goalsJson);
  }

  Future<void> addGoal(String name, double targetAmount, DateTime deadline) async {
    final goal = GoalModel(
      id: _uuid.v4(),
      name: name,
      targetAmount: targetAmount,
      currentAmount: 0,
      deadline: deadline,
    );
    _goals.add(goal);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((goal) => goal.id == id);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> updateGoalProgress(String id, double amount) async {
    final index = _goals.indexWhere((goal) => goal.id == id);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(
        currentAmount: _goals[index].currentAmount + amount,
      );
      await _saveGoals();
      notifyListeners();
    }
  }
} 