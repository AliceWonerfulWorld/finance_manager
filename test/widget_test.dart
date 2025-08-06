import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_manager/main.dart';
import 'package:provider/provider.dart';
import 'package:finance_manager/providers/transaction_provider.dart';
import 'package:finance_manager/providers/goal_provider.dart';
import 'package:finance_manager/providers/budget_provider.dart';
import 'package:finance_manager/providers/savings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('アプリが正常に起動する', (WidgetTester tester) async {
    // SharedPreferencesのモックを作成
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    // プロバイダー設定
    final transactionProvider = TransactionProvider();
    final providers = [
      ChangeNotifierProvider(create: (_) => transactionProvider),
      ChangeNotifierProvider(create: (_) => GoalProvider(prefs)),
      ChangeNotifierProvider(create: (_) => BudgetProvider(prefs, transactionProvider)),
      ChangeNotifierProvider(create: (_) => SavingsProvider()),
    ];
    
    // アプリを構築
    await tester.pumpWidget(
      MultiProvider(
        providers: providers,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '家計簿アプリ',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const MainScreen(),
        ),
      ),
    );
    await tester.pump();

    // アプリが正常に表示されることを確認
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('ナビゲーションバーが表示される', (WidgetTester tester) async {
    // SharedPreferencesのモックを作成
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    
    // プロバイダー設定
    final transactionProvider = TransactionProvider();
    final providers = [
      ChangeNotifierProvider(create: (_) => transactionProvider),
      ChangeNotifierProvider(create: (_) => GoalProvider(prefs)),
      ChangeNotifierProvider(create: (_) => BudgetProvider(prefs, transactionProvider)),
      ChangeNotifierProvider(create: (_) => SavingsProvider()),
    ];
    
    await tester.pumpWidget(
      MultiProvider(
        providers: providers,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '家計簿アプリ',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const MainScreen(),
        ),
      ),
    );
    await tester.pump();

    // ナビゲーションバーが存在することを確認
    expect(find.byType(NavigationBar), findsOneWidget);
    
    // ナビゲーション項目が存在することを確認（複数存在する可能性があるため、atLeastOneWidgetを使用）
    expect(find.text('ホーム'), findsAtLeastNWidgets(1));
    expect(find.text('ダッシュボード'), findsAtLeastNWidgets(1));
    expect(find.text('取引'), findsAtLeastNWidgets(1));
    expect(find.text('設定'), findsAtLeastNWidgets(1));
  });
}
