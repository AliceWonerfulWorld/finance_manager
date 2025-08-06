import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:finance_manager/ui/home/home_screen.dart';
import 'package:finance_manager/ui/dashboard/dashboard_screen.dart';
import 'package:finance_manager/config/database_helper.dart';
import 'package:finance_manager/config/web_error_handler.dart';
import 'package:finance_manager/providers/transaction_provider.dart';
import 'package:finance_manager/ui/transactions/transactions_screen.dart';
import 'package:finance_manager/ui/settings/settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finance_manager/providers/goal_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_manager/providers/budget_provider.dart';
import 'package:finance_manager/providers/savings_provider.dart';
import 'package:finance_manager/ui/splash/splash_screen.dart';

// Web専用のエントリーポイント
import 'web_main_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("💾 アプリの初期化開始...");
  
  final prefs = await SharedPreferences.getInstance();

  // Webプラットフォームと通常プラットフォームでアプリを分離
  if (kIsWeb) {
    debugPrint("🌐 Web環境専用モードで実行します");
    runApp(WebApp(prefs: prefs));
  } else {
    debugPrint("📱 通常環境で実行します");
    
    // データベース初期化
    try {
      await DatabaseHelper.instance.database;
      debugPrint("✅ データベースの準備完了");
    } catch (e) {
      debugPrint("❌ データベース初期化中にエラーが発生しました: $e");
    }

    final transactionProvider = TransactionProvider();
    
    // プロバイダー設定
    final providers = [
      ChangeNotifierProvider(create: (_) => transactionProvider),
      ChangeNotifierProvider(create: (_) => GoalProvider(prefs)),
      ChangeNotifierProvider(create: (_) => BudgetProvider(prefs, transactionProvider)),
      ChangeNotifierProvider(create: (_) => SavingsProvider()),
    ];
    
    runApp(
      MultiProvider(
        providers: providers,
        child: WebErrorHandler(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
              textTheme: GoogleFonts.notoSansJpTextTheme(),
            ),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ja', 'JP'),
            ],
            home: SplashScreen(
              nextScreen: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: '家計簿アプリ',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                  useMaterial3: true,
                  textTheme: GoogleFonts.notoSansJpTextTheme(),
                ),
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: [
                  Locale('ja', 'JP'),
                ],
                home: const MainScreen(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    const DashboardScreen(),
    const TransactionsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
