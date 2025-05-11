import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finance_manager/providers/savings_provider.dart';
import 'package:finance_manager/models/savings_model.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '貯金目標',
          style: GoogleFonts.notoSansJp(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<SavingsProvider>(
        builder: (context, provider, child) {
          final savings = provider.savings;
          
          if (savings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.savings,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '貯金目標を追加しましょう',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddSavingDialog(context),
                    icon: const Icon(Icons.add),
                    label: Text(
                      '新しい貯金目標を追加',
                      style: GoogleFonts.notoSansJp(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: savings.length,
            itemBuilder: (context, index) {
              final saving = savings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              saving.name,
                              style: GoogleFonts.notoSansJp(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: saving.progress >= 1
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${(saving.progress * 100).toStringAsFixed(1)}%',
                                  style: GoogleFonts.notoSansJp(
                                    fontSize: 12,
                                    color: saving.progress >= 1
                                        ? Colors.green
                                        : Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditSavingDialog(context, saving);
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmationDialog(context, saving);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.edit, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          '編集',
                                          style: GoogleFonts.notoSansJp(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.delete, size: 20, color: Colors.red),
                                        const SizedBox(width: 8),
                                        Text(
                                          '削除',
                                          style: GoogleFonts.notoSansJp(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: saving.progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          saving.progress >= 1
                              ? Colors.green
                              : Theme.of(context).primaryColor,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '現在の金額',
                                style: GoogleFonts.notoSansJp(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                NumberFormat.currency(
                                  locale: 'ja_JP',
                                  symbol: '¥',
                                  decimalDigits: 0,
                                ).format(saving.currentAmount),
                                style: GoogleFonts.notoSansJp(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '目標金額',
                                style: GoogleFonts.notoSansJp(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                NumberFormat.currency(
                                  locale: 'ja_JP',
                                  symbol: '¥',
                                  decimalDigits: 0,
                                ).format(saving.targetAmount),
                                style: GoogleFonts.notoSansJp(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '目標日: ${DateFormat('yyyy年MM月dd日').format(saving.targetDate)}',
                            style: GoogleFonts.notoSansJp(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddAmountDialog(context, saving),
                            icon: const Icon(Icons.add_circle_outline),
                            label: Text(
                              '貯金を追加',
                              style: GoogleFonts.notoSansJp(),
                            ),
                          ),
                        ],
                      ),
                      if (saving.memo.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'メモ: ${saving.memo}',
                          style: GoogleFonts.notoSansJp(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSavingDialog(context),
        icon: const Icon(Icons.add),
        label: Text(
          '新しい貯金目標',
          style: GoogleFonts.notoSansJp(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _showAddSavingDialog(BuildContext context) {
    final nameController = TextEditingController();
    final targetAmountController = TextEditingController();
    final memoController = TextEditingController();
    DateTime targetDate = DateTime.now().add(const Duration(days: 30));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '新しい貯金目標',
          style: GoogleFonts.notoSansJp(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '目標名',
                    labelStyle: GoogleFonts.notoSansJp(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '目標名を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: targetAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '目標金額',
                    labelStyle: GoogleFonts.notoSansJp(),
                    prefixText: '¥',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '目標金額を入力してください';
                    }
                    if (double.tryParse(value) == null) {
                      return '有効な金額を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      '目標日',
                      style: GoogleFonts.notoSansJp(
                        color: Colors.grey[700],
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('yyyy年MM月dd日').format(targetDate),
                      style: GoogleFonts.notoSansJp(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: targetDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) {
                        targetDate = date;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: memoController,
                  decoration: InputDecoration(
                    labelText: 'メモ',
                    labelStyle: GoogleFonts.notoSansJp(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: GoogleFonts.notoSansJp(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final saving = SavingsModel(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  targetAmount: double.parse(targetAmountController.text),
                  currentAmount: 0,
                  targetDate: targetDate,
                  category: '一般',
                  memo: memoController.text,
                );
                Provider.of<SavingsProvider>(context, listen: false)
                    .addSaving(saving);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '追加',
              style: GoogleFonts.notoSansJp(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAmountDialog(BuildContext context, SavingsModel saving) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '貯金額を追加',
          style: GoogleFonts.notoSansJp(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '目標: ${saving.name}',
                style: GoogleFonts.notoSansJp(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '現在の金額: ${NumberFormat.currency(locale: 'ja_JP', symbol: '¥', decimalDigits: 0).format(saving.currentAmount)}',
                style: GoogleFonts.notoSansJp(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '追加する金額',
                  labelStyle: GoogleFonts.notoSansJp(),
                  prefixText: '¥',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '金額を入力してください';
                  }
                  if (double.tryParse(value) == null) {
                    return '有効な金額を入力してください';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: GoogleFonts.notoSansJp(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Provider.of<SavingsProvider>(context, listen: false)
                    .addAmount(saving.id, double.parse(amountController.text));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '追加',
              style: GoogleFonts.notoSansJp(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSavingDialog(BuildContext context, SavingsModel saving) {
    final nameController = TextEditingController(text: saving.name);
    final targetAmountController = TextEditingController(text: saving.targetAmount.toInt().toString());
    final memoController = TextEditingController(text: saving.memo);
    DateTime targetDate = saving.targetDate;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '貯金目標を編集',
          style: GoogleFonts.notoSansJp(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: '目標名',
                    labelStyle: GoogleFonts.notoSansJp(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '目標名を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: targetAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '目標金額',
                    labelStyle: GoogleFonts.notoSansJp(),
                    prefixText: '¥',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '目標金額を入力してください';
                    }
                    if (double.tryParse(value) == null) {
                      return '有効な金額を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      '目標日',
                      style: GoogleFonts.notoSansJp(
                        color: Colors.grey[700],
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('yyyy年MM月dd日').format(targetDate),
                      style: GoogleFonts.notoSansJp(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: targetDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) {
                        targetDate = date;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: memoController,
                  decoration: InputDecoration(
                    labelText: 'メモ',
                    labelStyle: GoogleFonts.notoSansJp(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: GoogleFonts.notoSansJp(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final updatedSaving = saving.copyWith(
                  name: nameController.text,
                  targetAmount: double.parse(targetAmountController.text),
                  targetDate: targetDate,
                  memo: memoController.text,
                );
                Provider.of<SavingsProvider>(context, listen: false)
                    .updateSaving(updatedSaving);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '保存',
              style: GoogleFonts.notoSansJp(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, SavingsModel saving) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '貯金目標を削除',
          style: GoogleFonts.notoSansJp(),
        ),
        content: Text(
          '「${saving.name}」を削除してもよろしいですか？\nこの操作は元に戻せません。',
          style: GoogleFonts.notoSansJp(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: GoogleFonts.notoSansJp(),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<SavingsProvider>(context, listen: false)
                  .deleteSaving(saving.id);
              Navigator.pop(context);
            },
            child: Text(
              '削除',
              style: GoogleFonts.notoSansJp(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 