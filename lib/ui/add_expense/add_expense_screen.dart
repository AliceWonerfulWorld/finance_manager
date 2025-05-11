import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:finance_manager/providers/transaction_provider.dart';
import 'package:finance_manager/models/transaction_model.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _memoController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = '食費';

  final List<String> _categories = [
    '食費',
    '交通費',
    '住居費',
    '光熱費',
    '通信費',
    '医療費',
    '教育費',
    '娯楽費',
    'その他支出',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ja', 'JP'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      try {
        final provider = Provider.of<TransactionProvider>(context, listen: false);
        await provider.addTransaction(
          TransactionModel(
            id: provider.generateId(),
            amount: -double.parse(_amountController.text),
            category: _selectedCategory,
            date: _selectedDate,
            type: 'expense',
            memo: _memoController.text,
          ),
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('支出の保存に失敗しました: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '支出を追加',
          style: GoogleFonts.notoSansJp(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '金額',
                  prefixText: '¥',
                  border: const OutlineInputBorder(),
                  labelStyle: GoogleFonts.notoSansJp(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'カテゴリー',
                  border: const OutlineInputBorder(),
                  labelStyle: GoogleFonts.notoSansJp(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _memoController,
                decoration: InputDecoration(
                  labelText: 'メモ',
                  border: const OutlineInputBorder(),
                  labelStyle: GoogleFonts.notoSansJp(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('日付'),
                subtitle: Text(
                  DateFormat('yyyy年MM月dd日').format(_selectedDate),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: GoogleFonts.notoSansJp(fontSize: 18),
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  '保存',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 