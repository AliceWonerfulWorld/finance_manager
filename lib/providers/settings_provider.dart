import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isLoaded = false;

  // アプリ設定
  bool _enableNotifications = true;
  bool _enableBudgetAlerts = true;
  String _currency = '¥';
  ThemeMode _themeMode = ThemeMode.system;
  
  // ゲッター
  bool get isLoaded => _isLoaded;
  bool get enableNotifications => _enableNotifications;
  bool get enableBudgetAlerts => _enableBudgetAlerts;
  String get currency => _currency;
  ThemeMode get themeMode => _themeMode;
  // 利用可能な通貨リスト
  final List<Map<String, dynamic>> availableCurrencies = [
    {'symbol': '¥', 'name': '日本円 (JPY)'},
    {'symbol': r'$', 'name': '米ドル (USD)'},
    {'symbol': '€', 'name': 'ユーロ (EUR)'},
    {'symbol': '£', 'name': '英ポンド (GBP)'},
    {'symbol': '₩', 'name': '韓国ウォン (KRW)'},
    {'symbol': '₹', 'name': 'インドルピー (INR)'},
  ];

  // テーマモード名のマップ
  final Map<ThemeMode, String> themeModeNames = {
    ThemeMode.system: 'システム設定に従う',
    ThemeMode.light: 'ライトモード',
    ThemeMode.dark: 'ダークモード',
  };

  // 初期化
  Future<void> initialize() async {
    if (_isLoaded) return;
    
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
    _isLoaded = true;
    notifyListeners();
  }

  // 設定の読み込み
  void _loadSettings() {
    _enableNotifications = _prefs.getBool('enableNotifications') ?? true;
    _enableBudgetAlerts = _prefs.getBool('enableBudgetAlerts') ?? true;
    _currency = _prefs.getString('currency') ?? '¥';
    
    final String themeName = _prefs.getString('themeMode') ?? 'system';
    switch (themeName) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
  }

  // 通知設定の更新
  Future<void> setEnableNotifications(bool value) async {
    _enableNotifications = value;
    await _prefs.setBool('enableNotifications', value);
    notifyListeners();
  }

  // 予算アラート設定の更新
  Future<void> setEnableBudgetAlerts(bool value) async {
    _enableBudgetAlerts = value;
    await _prefs.setBool('enableBudgetAlerts', value);
    notifyListeners();
  }

  // 通貨設定の更新
  Future<void> setCurrency(String value) async {
    _currency = value;
    await _prefs.setString('currency', value);
    notifyListeners();
  }

  // テーマ設定の更新
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String themeName;
    
    switch (mode) {
      case ThemeMode.light:
        themeName = 'light';
        break;
      case ThemeMode.dark:
        themeName = 'dark';
        break;
      default:
        themeName = 'system';
    }
    
    await _prefs.setString('themeMode', themeName);
    notifyListeners();
  }
}
