# 家計簿アプリ (Finance Manager)

Flutter で開発された多機能家計簿アプリケーションです。個人の財務管理を簡単かつ効率的に行うことができます。

## 📱 主な機能

### 🏠 ホーム画面
- 今月の収支サマリー表示
- 最近の取引履歴
- 直感的な操作でデータ確認

### 📊 ダッシュボード
- リアルタイム収支グラフ
- カテゴリ別支出円グラフ
- 月次トレンド分析
- 支出推移の可視化

### 💰 取引管理
- 収入・支出の記録
- カテゴリ別分類
- 日付別フィルタリング
- 詳細な取引履歴

### 📈 分析機能
- 月次収支レポート
- カテゴリ別支出分析
- 支出傾向の把握

### 💡 アドバイス機能
- AIによる家計改善提案
- 節約アドバイス
- 予算推奨値の算出

### ⚙️ 設定・データ管理
- **データエクスポート機能**
  - CSV形式：表計算ソフト対応
  - PDF形式：詳細レポート付き
  - JSON形式：完全データバックアップ
- データバックアップ・復元
- アプリ設定のカスタマイズ

## 🚀 最新の改善点

### ✅ 完了済み修正
1. **エラー修正**
   - 設定プロバイダーの識別子エラー修正
   - 未使用インポートの削除
   - Lintルール準拠

2. **エクスポート機能の完全実装**
   - ExportHelperクラスによる包括的なエクスポート機能
   - クロスプラットフォーム対応（Web/Mobile/Desktop）
   - ユーザーフレンドリーなUI

3. **コード品質向上**
   - TODOコメントの意味のある実装への変更
   - 包括的なドキュメンテーション追加
   - デバッグ用print文のdebugPrintへの変更

4. **依存関係の最適化**
   - 必要なパッケージの追加と設定
   - pubspec.yamlの構文エラー修正

## 🛠️ 技術スタック

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Database**: SQLite (sqflite)
- **State Management**: Provider
- **Charts**: fl_chart
- **UI Components**: Material Design 3
- **Export Libraries**: 
  - PDF生成: pdf, printing
  - CSV生成: csv
  - ファイル操作: path_provider, file_picker

## 📦 インストールと実行

### 前提条件
- Flutter SDK 3.0 以上
- Dart SDK 2.17 以上

### セットアップ手順

1. **リポジトリのクローン**
   ```bash
   git clone <repository-url>
   cd finance_manager
   ```

2. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

3. **アプリの実行**
   ```bash
   # デバッグモード
   flutter run
   
   # Webアプリとして実行
   flutter run -d chrome
   
   # リリースビルド
   flutter build apk --release
   ```

## 🌐 対応プラットフォーム

- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📁 プロジェクト構成

```
lib/
├── main.dart                 # アプリエントリーポイント
├── config/                   # 設定・ヘルパークラス
│   ├── database_helper.dart  # SQLiteデータベース管理
│   └── export_helper.dart    # データエクスポート機能
├── models/                   # データモデル
│   └── transaction_model.dart
├── providers/                # 状態管理
│   ├── transaction_provider.dart
│   ├── budget_provider.dart
│   └── goal_provider.dart
└── ui/                       # ユーザーインターフェース
    ├── dashboard/            # ダッシュボード画面
    ├── transactions/         # 取引管理画面
    ├── analytics/            # 分析画面
    ├── settings/             # 設定画面
    └── ...
```

## 🔧 開発者向け情報

### デバッグとテスト
```bash
# 静的解析実行
flutter analyze

# テスト実行
flutter test

# 依存関係確認
flutter pub deps
```

### パフォーマンス
- SQLiteによる高速データアクセス
- Providerパターンによる効率的な状態管理
- 非同期処理によるスムーズなUI

## 📄 ライセンス

このプロジェクトはMITライセンスのもとで公開されています。

## 🤝 貢献

プルリクエストやイシューの報告を歓迎します。改善提案がございましたら、お気軽にご連絡ください。

---

**バージョン**: 1.0.0  
**最終更新**: 2025年6月  
**開発者**: Finance Manager Team
