import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({Key? key}) : super(key: key);

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isCreatingBackup = false;
  bool _isRestoringBackup = false;
  String? _statusMessage;
  bool _showSuccess = false;

  Future<void> _createBackup() async {
    setState(() {
      _isCreatingBackup = true;
      _statusMessage = 'バックアップを作成中...';
      _showSuccess = false;
    });

    try {
      // バックアップ機能は今後実装予定です
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _statusMessage = 'バックアップ機能は現在準備中です。しばらくお待ちください。';
        _showSuccess = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'バックアップ作成中にエラーが発生しました: $e';
        _showSuccess = false;
      });
    } finally {
      setState(() {
        _isCreatingBackup = false;
      });
    }
  }

  Future<void> _restoreBackup() async {
    setState(() {
      _isRestoringBackup = true;
      _statusMessage = 'バックアップ復元機能は準備中です...';
      _showSuccess = false;
    });

    try {
      // file_picker パッケージが利用可能になったら本格実装予定
      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        _statusMessage = 'バックアップ復元機能は現在準備中です。しばらくお待ちください。';
        _showSuccess = false;
      });
      
    } catch (e) {
      setState(() {
        _statusMessage = 'バックアップ復元中にエラーが発生しました: $e';
        _showSuccess = false;
      });
    } finally {
      setState(() {
        _isRestoringBackup = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'バックアップと復元',
          style: GoogleFonts.notoSansJp(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildBackupSection(),
          const SizedBox(height: 16),
          _buildRestoreSection(),
          const SizedBox(height: 32),
          if (_statusMessage != null) _buildStatusMessage(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'バックアップについて',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'バックアップには以下のデータが含まれます:',
              style: GoogleFonts.notoSansJp(fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('すべての取引データ'),
            _buildBulletPoint('カスタムカテゴリー'),
            _buildBulletPoint('予算設定'),
            _buildBulletPoint('目標設定'),
            _buildBulletPoint('アプリの設定'),
            const SizedBox(height: 12),
            Text(
              '※ 重要: データの紛失を防ぐため、定期的にバックアップを作成することをお勧めします。',
              style: GoogleFonts.notoSansJp(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.notoSansJp(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'バックアップを作成',
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'データをバックアップファイルに保存します。後でデータを復元するために使用できます。',
              style: GoogleFonts.notoSansJp(fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCreatingBackup ? null : _createBackup,
                icon: _isCreatingBackup
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.backup),
                label: Text(
                  _isCreatingBackup ? 'バックアップ作成中...' : 'バックアップを作成',
                  style: GoogleFonts.notoSansJp(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'バックアップから復元',
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '以前に作成したバックアップからデータを復元します。現在のデータはすべて上書きされます。',
              style: GoogleFonts.notoSansJp(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '現在準備中です。アップデートをお待ちください。',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRestoringBackup ? null : _restoreBackup,
                icon: _isRestoringBackup
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.restore),
                label: Text(
                  _isRestoringBackup ? '復元中...' : 'バックアップから復元',
                  style: GoogleFonts.notoSansJp(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _showSuccess ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _showSuccess ? Colors.green : Colors.red.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _showSuccess ? Icons.check_circle : Icons.error,
            color: _showSuccess ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage!,
              style: GoogleFonts.notoSansJp(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
