import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_manager/main.dart';

void main() {
  testWidgets('アプリのタイトルが表示される', (WidgetTester tester) async {
    // アプリを構築
    await tester.pumpWidget(MyApp());
    await tester.pump(); // ✅ `pumpAndSettle()` ではなく `pump()`

    // "収支管理アプリ" というタイトルがあるか確認
    expect(find.text('収支管理アプリ'), findsOneWidget);
  });

  testWidgets('収入追加ボタンが存在する', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pump(); // ✅ `pumpAndSettle()` ではなく `pump()`

    // "＋" アイコンのボタンが存在することを確認
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
