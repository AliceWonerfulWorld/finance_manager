import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            [
              _buildSwitchTile(
                '通知',
                Icons.notifications,
                true,
                (value) {
                  // TODO: 通知設定の実装
                },
              ),
              _buildSwitchTile(
                '予算超過時のアラート',
                Icons.warning,
                true,
                (value) {
                  // TODO: 予算アラート設定の実装
                },
              ),
            ],
          ),
          _buildSection(
            'データ管理',
            [
              _buildListTile(
                'カテゴリー管理',
                Icons.category,
                () {
                  // TODO: カテゴリー管理画面の実装
                },
              ),
              _buildListTile(
                'データのバックアップ',
                Icons.backup,
                () {
                  // TODO: バックアップ機能の実装
                },
              ),
              _buildListTile(
                'データの復元',
                Icons.restore,
                () {
                  // TODO: 復元機能の実装
                },
              ),
              _buildListTile(
                'データのエクスポート',
                Icons.file_download,
                () {
                  // TODO: エクスポート機能の実装
                },
              ),
            ],
          ),
          _buildSection(
            'レポート',
            [
              _buildListTile(
                '月次レポート',
                Icons.bar_chart,
                () {
                  // TODO: 月次レポート画面の実装
                },
              ),
              _buildListTile(
                'カテゴリー別分析',
                Icons.pie_chart,
                () {
                  // TODO: カテゴリー分析画面の実装
                },
              ),
              _buildListTile(
                '支出傾向分析',
                Icons.trending_up,
                () {
                  // TODO: 支出傾向分析画面の実装
                },
              ),
            ],
          ),
          _buildSection(
            'その他',
            [
              _buildListTile(
                'ヘルプ',
                Icons.help,
                () {
                  // TODO: ヘルプ画面の実装
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
              ),
              _buildListTile(
                'プライバシーポリシー',
                Icons.privacy_tip,
                () {
                  // TODO: プライバシーポリシー画面の実装
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
} 