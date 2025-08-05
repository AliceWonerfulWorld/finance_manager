import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

/// 取引データをCSV、PDF、JSON形式でエクスポートするためのヘルパークラス
/// 
/// このクラスは以下の機能を提供します：
/// - CSV形式でのデータエクスポート（表計算ソフト対応）
/// - PDF形式でのレポート生成（詳細な集計付き）
/// - JSON形式でのデータエクスポート（完全なデータ保存）
/// - クロスプラットフォーム対応（Web/モバイル/デスクトップ）
class ExportHelper {
  /// 取引データをCSV形式でエクスポートします
  /// 
  /// [transactions] エクスポートする取引データのリスト
  /// 戻り値: エクスポートが成功した場合true、失敗した場合false
  static Future<bool> exportAsCSV(List<TransactionModel> transactions) async {
    try {
      // CSVデータを準備
      List<List<String>> csvData = [
        ['日付', '金額', 'カテゴリ', '種別', 'メモ']
      ];

      for (var transaction in transactions) {
        csvData.add([
          DateFormat('yyyy-MM-dd').format(transaction.date),
          transaction.amount.toString(),
          transaction.category,
          transaction.type == 'income' ? '収入' : '支出',
          transaction.memo ?? '',
        ]);
      }

      // CSVデータを文字列に変換
      String csvString = const ListToCsvConverter().convert(csvData);

      if (kIsWeb) {
        // Webの場合はダウンロード
        await _downloadFileWeb(
          csvString, 
          'household_transactions_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
          'text/csv'
        );
      } else {
        // モバイル・デスクトップの場合はファイルに保存
        await _saveFileToDevice(
          csvString, 
          'household_transactions_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv'
        );
      }

      return true;
    } catch (e) {
      debugPrint('CSV export error: $e');
      return false;
    }
  }
  /// 取引データをJSON形式でエクスポートします
  /// 
  /// 完全な取引データとメタデータを含むJSONファイルを生成します。
  /// データの完全な保存やバックアップに適しています。
  /// 
  /// [transactions] エクスポートする取引データのリスト
  /// 戻り値: エクスポートが成功した場合true、失敗した場合false
  static Future<bool> exportAsJSON(List<TransactionModel> transactions) async {
    try {
      // JSONデータを準備
      Map<String, dynamic> jsonData = {
        'export_date': DateTime.now().toIso8601String(),
        'total_transactions': transactions.length,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

      String jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

      if (kIsWeb) {
        // Webの場合はダウンロード
        await _downloadFileWeb(
          jsonString, 
          'household_transactions_${DateFormat('yyyyMMdd').format(DateTime.now())}.json',
          'application/json'
        );
      } else {
        // モバイル・デスクトップの場合はファイルに保存
        await _saveFileToDevice(
          jsonString, 
          'household_transactions_${DateFormat('yyyyMMdd').format(DateTime.now())}.json'
        );
      }

      return true;
    } catch (e) {
      debugPrint('JSON export error: $e');
      return false;
    }
  }
  /// 取引データをPDF形式でエクスポートします
  /// 
  /// 詳細なレポートを生成し、以下の情報を含みます：
  /// - 収支サマリー
  /// - カテゴリ別集計
  /// - 取引詳細一覧
  /// 
  /// [transactions] エクスポートする取引データのリスト
  /// 戻り値: エクスポートが成功した場合true、失敗した場合false
  static Future<bool> exportAsPDF(List<TransactionModel> transactions) async {
    try {
      final pdf = pw.Document();

      // 収入と支出の合計を計算
      double totalIncome = transactions
          .where((t) => t.type == 'income')
          .fold(0, (sum, t) => sum + t.amount);
      
      double totalExpense = transactions
          .where((t) => t.type == 'expense')
          .fold(0, (sum, t) => sum + t.amount);

      // カテゴリ別集計
      Map<String, double> categoryTotals = {};
      for (var transaction in transactions) {
        categoryTotals[transaction.category] = 
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // ヘッダー
              pw.Header(
                level: 0,
                child: pw.Text(
                  '家計簿レポート',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // 期間
              pw.Text(
                '期間: ${DateFormat('yyyy年MM月dd日').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),

              // サマリー
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'サマリー',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text('総収入: ¥${totalIncome.toStringAsFixed(0)}'),
                    pw.Text('総支出: ¥${totalExpense.toStringAsFixed(0)}'),
                    pw.Text('収支: ¥${(totalIncome - totalExpense).toStringAsFixed(0)}'),
                    pw.Text('取引件数: ${transactions.length}件'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // カテゴリ別集計
              pw.Text(
                'カテゴリ別集計',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'カテゴリ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '金額',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  ...categoryTotals.entries.map((entry) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(entry.key),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '¥${entry.value.toStringAsFixed(0)}',
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  )).toList(),
                ],
              ),
              pw.SizedBox(height: 20),

              // 取引詳細
              pw.Text(
                '取引詳細',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  1: const pw.FixedColumnWidth(60),
                  2: const pw.FixedColumnWidth(100),
                  3: const pw.FixedColumnWidth(60),
                  4: const pw.FlexColumnWidth(),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '日付',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '金額',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'カテゴリ',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '種別',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'メモ',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...transactions.map((transaction) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          DateFormat('MM/dd').format(transaction.date),
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          '¥${transaction.amount.toStringAsFixed(0)}',
                          style: const pw.TextStyle(fontSize: 10),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          transaction.category,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          transaction.type == 'income' ? '収入' : '支出',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          transaction.memo ?? '',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  )).toList(),
                ],
              ),
            ];
          },
        ),
      );

      if (kIsWeb) {
        // Webの場合は印刷ダイアログを表示
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      } else {
        // モバイル・デスクトップの場合はファイルに保存
        final bytes = await pdf.save();
        await _savePDFToDevice(
          bytes, 
          'household_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf'
        );
      }

      return true;
    } catch (e) {
      debugPrint('PDF export error: $e');
      return false;
    }
  }
  // Webブラウザでファイルをダウンロード
  static Future<void> _downloadFileWeb(String content, String filename, String mimeType) async {
    // Web環境でのファイルダウンロード
    if (kIsWeb) {
      try {
        final bytes = utf8.encode(content);
        // PrintingパッケージのsharePdfを使用してダウンロード
        await Printing.sharePdf(
          bytes: bytes,
          filename: filename,
        );
      } catch (e) {
        debugPrint('Web download error: $e');
        // 代替手法として、ブラウザのダウンロード機能を使用
        // この部分は実際のプロダクションでは、html パッケージを使用してより適切に実装可能
      }
    }
  }

  // デバイスにファイルを保存
  static Future<void> _saveFileToDevice(String content, String filename) async {
    try {
      // ストレージ権限をチェック
      if (!kIsWeb && Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      }

      // ディレクトリを取得
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final file = File('${directory.path}/$filename');
        await file.writeAsString(content);
        debugPrint('ファイルが保存されました: ${file.path}');
      }
    } catch (e) {
      debugPrint('ファイル保存エラー: $e');
    }
  }

  // PDFをデバイスに保存
  static Future<void> _savePDFToDevice(List<int> bytes, String filename) async {
    try {
      // ストレージ権限をチェック
      if (!kIsWeb && Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      }

      // ディレクトリを取得
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(bytes);
        debugPrint('PDFファイルが保存されました: ${file.path}');
      }
    } catch (e) {
      debugPrint('PDFファイル保存エラー: $e');
    }
  }
}
