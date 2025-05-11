import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:finance_manager/providers/transaction_provider.dart';
import 'package:finance_manager/models/transaction_model.dart';
import 'package:finance_manager/ui/transactions/transaction_detail_screen.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _sortBy = 'date';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '取引履歴',
          style: GoogleFonts.notoSansJp(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: '並び替え',
            onSelected: (value) {
              setState(() {
                if (value == _sortBy) {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortBy = value;
                  _sortAscending = false;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: _sortBy == 'date' ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '日付',
                      style: GoogleFonts.notoSansJp(
                        color: _sortBy == 'date' ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                    if (_sortBy == 'date')
                      Icon(
                        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'amount',
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 20,
                      color: _sortBy == 'amount' ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '金額',
                      style: GoogleFonts.notoSansJp(
                        color: _sortBy == 'amount' ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                    if (_sortBy == 'amount')
                      Icon(
                        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'category',
                child: Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 20,
                      color: _sortBy == 'category' ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'カテゴリー',
                      style: GoogleFonts.notoSansJp(
                        color: _sortBy == 'category' ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                    if (_sortBy == 'category')
                      Icon(
                        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final transactions = provider.transactions;
          
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '取引がありません',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // 取引をソート
          final sortedTransactions = List<TransactionModel>.from(transactions);
          sortedTransactions.sort((a, b) {
            int comparison;
            switch (_sortBy) {
              case 'date':
                comparison = a.date.compareTo(b.date);
                break;
              case 'amount':
                comparison = a.amount.compareTo(b.amount);
                break;
              case 'category':
                comparison = a.category.compareTo(b.category);
                break;
              default:
                comparison = 0;
            }
            return _sortAscending ? comparison : -comparison;
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedTransactions.length,
            itemBuilder: (context, index) {
              final transaction = sortedTransactions[index];
              return Dismissible(
                key: Key(transaction.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
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
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'キャンセル',
                            style: GoogleFonts.notoSansJp(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
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
                },
                onDismissed: (direction) {
                  Provider.of<TransactionProvider>(context, listen: false)
                      .deleteTransaction(transaction.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '取引を削除しました',
                        style: GoogleFonts.notoSansJp(),
                      ),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: '元に戻す',
                        onPressed: () {
                          Provider.of<TransactionProvider>(context, listen: false)
                              .addTransaction(transaction);
                        },
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.type == 'income'
                          ? Colors.green[100]
                          : Colors.red[100],
                      child: Icon(
                        transaction.type == 'income'
                            ? Icons.account_balance_wallet
                            : Icons.shopping_cart,
                        color: transaction.type == 'income'
                            ? Colors.green[800]
                            : Colors.red[800],
                      ),
                    ),
                    title: Text(
                      transaction.category,
                      style: GoogleFonts.notoSansJp(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('yyyy年MM月dd日').format(transaction.date),
                          style: GoogleFonts.notoSansJp(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (transaction.memo != null && transaction.memo!.isNotEmpty)
                          Text(
                            transaction.memo!,
                            style: GoogleFonts.notoSansJp(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    trailing: Text(
                      transaction.formattedAmount,
                      style: GoogleFonts.notoSansJp(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: transaction.amountColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailScreen(
                            transaction: transaction,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 