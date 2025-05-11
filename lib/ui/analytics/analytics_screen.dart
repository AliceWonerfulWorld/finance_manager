import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:finance_manager/providers/transaction_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' show max;

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = '月間';
  final List<String> _periods = ['週間', '月間', '年間'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'データ分析',
          style: GoogleFonts.notoSansJp(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return _periods.map((String period) {
                return PopupMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 期間選択
                  _buildPeriodSelector(),
                  SizedBox(height: 20),
                  
                  // 収支推移グラフ
                  _buildExpenseTrendChart(provider),
                  SizedBox(height: 20),
                  
                  // カテゴリー別支出割合
                  _buildCategoryPieChart(provider),
                  SizedBox(height: 20),
                  
                  // カテゴリー別詳細
                  _buildCategoryDetails(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '期間: $_selectedPeriod',
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTrendChart(TransactionProvider provider) {
    // 実際のデータを使用
    final transactions = provider.transactions;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: 30)); // 過去30日分のデータ

    // 日付ごとの収支を集計
    Map<DateTime, double> dailyIncome = {};
    Map<DateTime, double> dailyExpense = {};

    for (var transaction in transactions) {
      if (transaction.date.isAfter(startDate)) {
        final date = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
        if (transaction.type == 'income') {
          dailyIncome[date] = (dailyIncome[date] ?? 0) + transaction.amount;
        } else {
          dailyExpense[date] = (dailyExpense[date] ?? 0) + transaction.amount.abs();
        }
      }
    }

    // データポイントの作成
    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];
    double maxY = 0;

    for (var i = 0; i < 30; i++) {
      final date = startDate.add(Duration(days: i));
      final income = dailyIncome[date] ?? 0;
      final expense = dailyExpense[date] ?? 0;
      
      incomeSpots.add(FlSpot(i.toDouble(), income));
      expenseSpots.add(FlSpot(i.toDouble(), expense));
      
      maxY = max(maxY, max(income, expense));
    }

    // データが空の場合
    if (maxY == 0) {
      return Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '収支推移',
                style: GoogleFonts.notoSansJp(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 300,
                child: Center(
                  child: Text(
                    'データがありません',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 16,
                      color: Colors.grey[600] ?? Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '収支推移',
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: maxY > 0 ? maxY / 5 : 1000,
                    verticalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300] ?? Colors.grey,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300] ?? Colors.grey,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          final date = startDate.add(Duration(days: value.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${date.month}/${date.day}',
                              style: GoogleFonts.notoSansJp(
                                fontSize: 12,
                                color: Colors.grey[600] ?? Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxY / 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '¥${value.toInt()}',
                            style: GoogleFonts.notoSansJp(
                              fontSize: 12,
                              color: Colors.grey[600] ?? Colors.grey,
                            ),
                          );
                        },
                        reservedSize: 60,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 29,
                  minY: 0,
                  maxY: maxY * 1.1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: incomeSpots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: expenseSpots,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('収入', Colors.green),
                SizedBox(width: 16),
                _buildLegendItem('支出', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.notoSansJp(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPieChart(TransactionProvider provider) {
    // 実際のデータを使用
    final transactions = provider.transactions;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: 30)); // 過去30日分のデータ

    // カテゴリーごとの支出を集計
    Map<String, double> categoryExpenses = {};
    double totalExpense = 0;

    for (var transaction in transactions) {
      if (transaction.date.isAfter(startDate) && transaction.type == 'expense') {
        final amount = transaction.amount.abs();
        categoryExpenses[transaction.category] = (categoryExpenses[transaction.category] ?? 0) + amount;
        totalExpense += amount;
      }
    }

    // データが空の場合
    if (totalExpense == 0) {
      return Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'カテゴリー別支出',
                style: GoogleFonts.notoSansJp(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 300,
                child: Center(
                  child: Text(
                    'データがありません',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 16,
                      color: Colors.grey[600] ?? Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // パイチャートのセクションを作成
    List<PieChartSectionData> sections = [];
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    int colorIndex = 0;
    categoryExpenses.forEach((category, amount) {
      final percentage = (amount / totalExpense * 100).toStringAsFixed(1);
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: amount,
          title: '$percentage%',
          radius: 100,
          titleStyle: GoogleFonts.notoSansJp(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'カテゴリー別支出',
              style: GoogleFonts.notoSansJp(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: categoryExpenses.entries.map((entry) {
                final percentage = (entry.value / totalExpense * 100).toStringAsFixed(1);
                return _buildCategoryLegendItem(
                  entry.key,
                  colors[categoryExpenses.keys.toList().indexOf(entry.key) % colors.length],
                  '¥${entry.value.toInt()} ($percentage%)',
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLegendItem(String category, Color color, String amount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          '$category: $amount',
          style: GoogleFonts.notoSansJp(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDetails(TransactionProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'カテゴリー別詳細',
              style: GoogleFonts.notoSansJp(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 3, // 仮のデータ数
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index == 0
                        ? Colors.blue
                        : index == 1
                            ? Colors.red
                            : Colors.green,
                    child: Icon(Icons.category, color: Colors.white),
                  ),
                  title: Text(
                    index == 0
                        ? '食費'
                        : index == 1
                            ? '交通費'
                            : 'その他',
                    style: GoogleFonts.notoSansJp(fontSize: 16),
                  ),
                  subtitle: Text(
                    '${index == 0 ? '40' : index == 1 ? '30' : '30'}%',
                    style: GoogleFonts.notoSansJp(fontSize: 14),
                  ),
                  trailing: Text(
                    '¥${index == 0 ? '40,000' : index == 1 ? '30,000' : '30,000'}',
                    style: GoogleFonts.notoSansJp(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 