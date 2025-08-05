import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:finance_manager/providers/transaction_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'お気に入り',
          style: GoogleFonts.notoSansJp(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final transactions = provider.transactions;
          final favoriteTransactions = transactions.where((t) => t.isFavorite).toList();

          if (favoriteTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'お気に入りの取引がありません',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: favoriteTransactions.length,
            itemBuilder: (context, index) {
              final transaction = favoriteTransactions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.type == 'income'
                        ? Colors.green[100]
                        : Colors.red[100],
                    child: Icon(
                      transaction.type == 'income'
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: transaction.type == 'income'
                          ? Colors.green[800]
                          : Colors.red[800],
                    ),
                  ),
                  title: Text(
                    transaction.category,
                    style: GoogleFonts.notoSansJp(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    transaction.memo ?? '',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transaction.formattedAmount,
                        style: GoogleFonts.notoSansJp(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: transaction.amountColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.star, color: Colors.amber),
                        onPressed: () {
                          provider.toggleFavorite(transaction.id);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // 取引詳細画面への遷移（将来実装予定）
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 