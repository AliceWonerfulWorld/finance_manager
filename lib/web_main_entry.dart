// Web特化型のエントリポイント
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// アプリのUI画面
import 'package:finance_manager/ui/home/home_screen.dart';
import 'package:finance_manager/ui/dashboard/dashboard_screen.dart';
import 'package:finance_manager/ui/transactions/transactions_screen.dart';
import 'package:finance_manager/ui/settings/settings_screen.dart';
import 'package:finance_manager/ui/splash/splash_screen.dart'; // スプラッシュ画面を追加

// プロバイダー
import 'package:finance_manager/providers/transaction_provider.dart';
import 'package:finance_manager/providers/goal_provider.dart';
import 'package:finance_manager/providers/budget_provider.dart';
import 'package:finance_manager/providers/savings_provider.dart';

// Web環境用のシンプルなエントリポイント
class WebApp extends StatelessWidget {
  final SharedPreferences prefs;
  
  const WebApp({Key? key, required this.prefs}) : super(key: key);
    @override
  Widget build(BuildContext context) {
    final transactionProvider = TransactionProvider();
    
    // プロバイダーのリスト
    final providers = [
      ChangeNotifierProvider(create: (_) => transactionProvider),
      ChangeNotifierProvider(create: (_) => GoalProvider(prefs)),
      ChangeNotifierProvider(create: (_) => BudgetProvider(prefs, transactionProvider)),
      ChangeNotifierProvider(create: (_) => SavingsProvider()),
    ];
    
    // メインアプリ画面
    final mainApp = MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '家計簿アプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansJpTextTheme(),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      home: const WebMainScreen(),
    );
    
    // スプラッシュ画面からメインアプリへ遷移
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          textTheme: GoogleFonts.notoSansJpTextTheme(),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ja', 'JP'),
        ],
        home: SplashScreen(
          nextScreen: MultiProvider(
            providers: providers,
            child: mainApp,
          ),
        ),
      ),
    );
  }
}

// Web用のシンプル化したメイン画面
class WebMainScreen extends StatefulWidget {
  const WebMainScreen({Key? key}) : super(key: key);

  @override
  State<WebMainScreen> createState() => _WebMainScreenState();
}

class _WebMainScreenState extends State<WebMainScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  final List<Widget> _screens = [
    HomeScreen(),
    const DashboardScreen(),
    const TransactionsScreen(),
    const SettingsScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    // Web環境での初期化を少し遅らせる
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('アプリを準備中...', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 20),
              Text(_errorMessage, style: TextStyle(fontSize: 18)),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = '';
                  });
                  
                  // 再初期化を試みる
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  });
                }, 
                child: Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'ダッシュボード',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: '取引',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
