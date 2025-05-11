import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:finance_manager/providers/transaction_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
    initializeDateFormatting('ja_JP', null);
  }

  void _loadEvents() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final transactions = provider.getTransactions();
    
    // 取引を日付ごとにグループ化
    final events = <DateTime, List<dynamic>>{};
    for (var transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      if (events[date] == null) events[date] = [];
      events[date]!.add(transaction);
    }
    
    setState(() {
      _events = events;
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '家計簿カレンダー',
          style: GoogleFonts.notoSansJp(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: CalendarStyle(
        markersMaxCount: 1,
        markerDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
      eventLoader: _getEventsForDay,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;
          return Positioned(
            bottom: 1,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: GoogleFonts.notoSansJp(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      locale: 'ja_JP',
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay!);
    
    if (events.isEmpty) {
      return Center(
        child: Text(
          'この日の取引はありません',
          style: GoogleFonts.notoSansJp(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final transaction = events[index];
        final isIncome = transaction.amount > 0;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
              child: Icon(
                isIncome ? Icons.account_balance_wallet : Icons.shopping_cart,
                color: isIncome ? Colors.green[800] : Colors.red[800]
              ),
            ),
            title: Text(
              transaction.memo ?? transaction.category,
              style: GoogleFonts.notoSansJp(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              transaction.category,
              style: GoogleFonts.notoSansJp(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            trailing: Text(
              '¥${transaction.amount.abs().toStringAsFixed(0)}',
              style: GoogleFonts.notoSansJp(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }
} 