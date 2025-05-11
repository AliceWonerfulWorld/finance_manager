import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:finance_manager/providers/transaction_provider.dart';
import 'package:finance_manager/models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'ja_JP', symbol: '¥');
    final dateFormat = DateFormat('yyyy年MM月dd日');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      transaction.type == 'income'
                          ? Colors.green[400]!
                          : Colors.red[400]!,
                      transaction.type == 'income'
                          ? Colors.green[600]!
                          : Colors.red[600]!,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              transaction.type == 'income'
                                  ? Icons.add_circle
                                  : Icons.remove_circle,
                              size: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              transaction.type == 'income' ? '収入' : '支出',
                              style: GoogleFonts.notoSansJp(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        transaction.formattedAmount,
                        style: GoogleFonts.notoSansJp(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailCard(
                    context,
                    '基本情報',
                    [
                      _buildDetailRow(
                        'カテゴリー',
                        transaction.category,
                        Icons.category,
                        transaction.type == 'income'
                            ? Colors.green
                            : Colors.red,
                      ),
                      Divider(),
                      _buildDetailRow(
                        '日付',
                        dateFormat.format(transaction.date),
                        Icons.calendar_today,
                        Colors.blue,
                      ),
                      if (transaction.memo != null && transaction.memo!.isNotEmpty) ...[
                        Divider(),
                        _buildDetailRow(
                          'メモ',
                          transaction.memo!,
                          Icons.note,
                          Colors.orange,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildDetailCard(
                    context,
                    '統計情報',
                    [
                      _buildDetailRow(
                        '取引タイプ',
                        transaction.type == 'income' ? '収入' : '支出',
                        transaction.type == 'income'
                            ? Icons.add_circle
                            : Icons.remove_circle,
                        transaction.type == 'income'
                            ? Colors.green
                            : Colors.red,
                      ),
                      Divider(),
                      _buildDetailRow(
                        '月間の同カテゴリー合計',
                        currencyFormat.format(
                          Provider.of<TransactionProvider>(context)
                              .transactions
                              .where((t) =>
                                  t.category == transaction.category &&
                                  t.type == transaction.type &&
                                  t.date.year == transaction.date.year &&
                                  t.date.month == transaction.date.month)
                              .fold(0.0, (sum, t) => sum + (t.type == 'expense' ? t.amount.abs() : t.amount)),
                        ),
                        Icons.analytics,
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDeleteConfirmationDialog(context),
        backgroundColor: Colors.red,
        child: Icon(Icons.delete),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[700],
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              '取引を削除',
              style: GoogleFonts.notoSansJp(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'この取引を削除してもよろしいですか？',
              style: GoogleFonts.notoSansJp(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: transaction.type == 'income'
                            ? Colors.green[100]
                            : Colors.red[100],
                        radius: 16,
                        child: Icon(
                          transaction.type == 'income'
                              ? Icons.account_balance_wallet
                              : Icons.shopping_cart,
                          size: 16,
                          color: transaction.type == 'income'
                              ? Colors.green[800]
                              : Colors.red[800],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        transaction.category,
                        style: GoogleFonts.notoSansJp(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('yyyy年MM月dd日').format(transaction.date),
                        style: GoogleFonts.notoSansJp(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        transaction.formattedAmount,
                        style: GoogleFonts.notoSansJp(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: transaction.amountColor,
                        ),
                      ),
                    ],
                  ),
                  if (transaction.memo != null && transaction.memo!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction.memo!,
                        style: GoogleFonts.notoSansJp(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'キャンセル',
              style: GoogleFonts.notoSansJp(
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Provider.of<TransactionProvider>(dialogContext, listen: false)
                  .deleteTransaction(transaction.id!);
              Navigator.pop(context); // 詳細画面を閉じる
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '削除',
              style: GoogleFonts.notoSansJp(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSansJp(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.notoSansJp(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 