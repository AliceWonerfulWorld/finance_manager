import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../config/export_helper.dart';
import 'backup_restore_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '設定',
          style: GoogleFonts.notoSansJp(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSection(
            'アプリ設定',
            [              _buildSwitchTile(
                '通知',
                Icons.notifications,
                true,
                (value) {
                  // 通知設定の切り替え（将来実装予定）
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('通知設定は近日実装予定です')),
                  );
                },
              ),              _buildSwitchTile(
                '予算超過時のアラート',
                Icons.warning,
                true,
                (value) {
                  // 予算アラート設定の切り替え（将来実装予定）
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('予算アラート機能は近日実装予定です')),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            'データ管理',
            [              _buildListTile(
                'カテゴリー管理',
                Icons.category,
                () {
                  // カテゴリー管理画面への遷移（将来実装予定）
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('カテゴリー管理機能は近日実装予定です')),
                  );
                },
              ),              _buildListTile(
                'データのバックアップ',
                Icons.backup,
                () {
                  // バックアップ画面への遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BackupRestoreScreen(),
                    ),
                  );
                },
              ),              _buildListTile(
                'データの復元',
                Icons.restore,
                () {
                  // バックアップ画面への遷移（復元タブ）
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BackupRestoreScreen(),
                    ),
                  );
                },
              ),
              _buildListTile(
                'データのエクスポート',
                Icons.file_download,
                () => _showExportOptionsDialog(context),
              ),
            ],
          ),
          _buildSection(
            'レポート',
            [              _buildListTile(
                '月次レポート',
                Icons.bar_chart,
                () {
                  // 月次レポート機能（将来実装予定）
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('月次レポート機能は近日実装予定です')),
                  );
                },
              ),              _buildListTile(
                'カテゴリー別分析',
                Icons.pie_chart,
                () {
                  // カテゴリー分析機能（将来実装予定）
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('カテゴリー分析機能は近日実装予定です')),
                  );
                },
              ),              _buildListTile(
                '支出傾向分析',
                Icons.trending_up,
                () {
                  // 支出傾向分析機能（将来実装予定）
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('支出傾向分析機能は近日実装予定です')),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            'その他',
            [              _buildListTile(
                'ヘルプ',
                Icons.help,
                () {
                  // ヘルプ画面の表示（将来実装予定）
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('ヘルプ'),
                      content: const Text('詳細なヘルプドキュメントは近日追加予定です。\n\n現在利用可能な機能：\n• 取引の追加・編集\n• カテゴリー別集計\n• データのエクスポート'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('閉じる'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _buildListTile(
                'フィードバックを送信',
                Icons.feedback,
                () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'support@example.com',
                    queryParameters: {
                      'subject': '家計簿アプリのフィードバック',
                    },
                  );
                  if (await canLaunchUrl(emailLaunchUri)) {
                    await launchUrl(emailLaunchUri);
                  }
                },
              ),              _buildListTile(
                'プライバシーポリシー',
                Icons.privacy_tip,
                () {
                  // プライバシーポリシーの表示（将来実装予定）
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('プライバシーポリシー'),
                      content: const Text('詳細なプライバシーポリシーは近日追加予定です。\n\nこのアプリはユーザーの財務データを安全に管理し、第三者と共有することはありません。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('閉じる'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _buildListTile(
                'アプリについて',
                Icons.info,
                () {
                  showAboutDialog(
                    context: context,
                    applicationName: '家計簿アプリ',
                    applicationVersion: '1.0.0',
                    applicationIcon: const FlutterLogo(size: 64),
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'このアプリは、あなたの家計管理をサポートします。\n'
                        '収入と支出を簡単に記録し、\n'
                        '予算管理や目標設定ができます。',
                        style: GoogleFonts.notoSansJp(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: GoogleFonts.notoSansJp(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildListTile(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.notoSansJp(
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool initialValue,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.notoSansJp(
          fontSize: 16,
        ),
      ),
      value: initialValue,
      onChanged: onChanged,
    );
  }

  // エクスポートオプションのダイアログを表示
  void _showExportOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'データのエクスポート',
          style: GoogleFonts.notoSansJp(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'エクスポート形式を選択してください',
              style: GoogleFonts.notoSansJp(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildExportOption(context, 'CSV形式', Icons.insert_drive_file, () => _exportAsCSV(context)),
            const SizedBox(height: 12),
            _buildExportOption(context, 'JSON形式', Icons.data_object, () => _exportAsJSON(context)),
            const SizedBox(height: 12),
            _buildExportOption(context, 'PDFレポート', Icons.picture_as_pdf, () => _exportAsPDF(context)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('キャンセル', style: GoogleFonts.notoSansJp()),
          ),
        ],
      ),
    );
  }

  // エクスポートオプションのアイテムを作成
  Widget _buildExportOption(
    BuildContext context, 
    String title, 
    IconData icon, 
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.notoSansJp(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CSVファイルとしてエクスポート
  void _exportAsCSV(BuildContext context) async {
    try {
      // ローディングダイアログを表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text('CSVファイルを作成中...', style: GoogleFonts.notoSansJp()),
            ],
          ),
        ),
      );

      // 取引データを取得
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final transactions = transactionProvider.transactions;

      // エクスポート実行
      final success = await ExportHelper.exportAsCSV(transactions);

      // ローディングダイアログを閉じる
      Navigator.of(context).pop();

      // 結果を表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'CSVファイルのエクスポートが完了しました' : 'CSVエクスポートに失敗しました',
            style: GoogleFonts.notoSansJp(),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      // エラーが発生した場合はローディングダイアログを閉じる
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e', style: GoogleFonts.notoSansJp()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // JSONファイルとしてエクスポート
  void _exportAsJSON(BuildContext context) async {
    try {
      // ローディングダイアログを表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text('JSONファイルを作成中...', style: GoogleFonts.notoSansJp()),
            ],
          ),
        ),
      );

      // 取引データを取得
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final transactions = transactionProvider.transactions;

      // エクスポート実行
      final success = await ExportHelper.exportAsJSON(transactions);

      // ローディングダイアログを閉じる
      Navigator.of(context).pop();

      // 結果を表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'JSONファイルのエクスポートが完了しました' : 'JSONエクスポートに失敗しました',
            style: GoogleFonts.notoSansJp(),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      // エラーが発生した場合はローディングダイアログを閉じる
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e', style: GoogleFonts.notoSansJp()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // PDFレポートとしてエクスポート
  void _exportAsPDF(BuildContext context) async {
    try {
      // ローディングダイアログを表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text('PDFレポートを作成中...', style: GoogleFonts.notoSansJp()),
            ],
          ),
        ),
      );

      // 取引データを取得
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final transactions = transactionProvider.transactions;

      // エクスポート実行
      final success = await ExportHelper.exportAsPDF(transactions);

      // ローディングダイアログを閉じる
      Navigator.of(context).pop();

      // 結果を表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'PDFレポートのエクスポートが完了しました' : 'PDFエクスポートに失敗しました',
            style: GoogleFonts.notoSansJp(),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      // エラーが発生した場合はローディングダイアログを閉じる
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e', style: GoogleFonts.notoSansJp()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}