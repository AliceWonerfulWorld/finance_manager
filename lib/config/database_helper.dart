import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:finance_manager/models/transaction_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

//test
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const int _databaseVersion = 3;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance_manager.db');
    return _database!;
  }  Future<Database> _initDB(String filePath) async {
    try {
      if (kIsWeb) {
        // Webプラットフォームの場合
        debugPrint('Web環境でのデータベース初期化を試みます（シンプルモード）...');
        
        // WebプラットフォームにはIndexedDBを直接使用
        databaseFactory = databaseFactoryFfiWeb;
        
        // 単純化したデータベースオプション
        return await databaseFactory.openDatabase(
          filePath,
          options: OpenDatabaseOptions(
            version: _databaseVersion,
            onCreate: _createDB,
            onUpgrade: _onUpgrade,
          ),
        );
      } else {
        // ネイティブプラットフォームの場合
        debugPrint('ネイティブ環境でのデータベース初期化を試みます...');
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
        }
        
        final dbPath = await getDatabasesPath();
        final path = join(dbPath, filePath);

        return await openDatabase(
          path,
          version: _databaseVersion,
          onCreate: _createDB,
          onUpgrade: _onUpgrade,
        );
      }
    } catch (e) {
      debugPrint('データベースの初期化に失敗しました: $e');
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE transactions(
          id TEXT PRIMARY KEY,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          memo TEXT,
          date TEXT NOT NULL,
          type TEXT NOT NULL,
          isFavorite INTEGER NOT NULL DEFAULT 0
        )
      ''');
      debugPrint('データベーステーブルを作成しました');
    } catch (e) {
      debugPrint('テーブルの作成に失敗しました: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 3) {
        // バージョン2以下から3へのアップグレード
        await db.execute('DROP TABLE IF EXISTS transactions');
        await _createDB(db, newVersion);
        debugPrint('データベースをバージョン3にアップグレードしました');
      }
    } catch (e) {
      debugPrint('データベースのアップグレードに失敗しました: $e');
      rethrow;
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final db = await instance.database;
      final data = {
        'id': transaction.id,
        'amount': transaction.amount,
        'category': transaction.category,
        'memo': transaction.memo,
        'date': transaction.date.toIso8601String(),
        'type': transaction.type,
        'isFavorite': transaction.isFavorite ? 1 : 0,
      };
      await db.insert(
        'transactions',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('取引を追加しました: ${transaction.category} - ${transaction.amount}円');
    } catch (e) {
      debugPrint('取引の追加に失敗しました: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final db = await instance.database;
      await db.update(
        'transactions',
        {
          'amount': transaction.amount,
          'category': transaction.category,
          'memo': transaction.memo,
          'date': transaction.date.toIso8601String(),
          'type': transaction.type,
          'isFavorite': transaction.isFavorite ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      debugPrint('取引を更新しました: ${transaction.category} - ${transaction.amount}円');
    } catch (e) {
      debugPrint('取引の更新に失敗しました: $e');
      rethrow;
    }
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query('transactions');
      debugPrint('取引を${maps.length}件取得しました');

      return List.generate(maps.length, (i) {
        final transaction = TransactionModel(
          id: maps[i]['id'] as String,
          amount: maps[i]['amount'] as double,
          category: maps[i]['category'] as String,
          memo: maps[i]['memo'] as String?,
          date: DateTime.parse(maps[i]['date'] as String),
          type: maps[i]['type'] as String,
          isFavorite: (maps[i]['isFavorite'] as int) == 1,
        );
        debugPrint('取引を読み込みました: ${transaction.category} - ${transaction.amount}円');
        return transaction;
      });
    } catch (e) {
      debugPrint('取引の取得に失敗しました: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final db = await instance.database;
      await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('取引を削除しました: $id');
    } catch (e) {
      debugPrint('取引の削除に失敗しました: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    try {
      final db = await instance.database;
      await db.close();
      debugPrint('データベースをクローズしました');
    } catch (e) {
      debugPrint('データベースのクローズに失敗しました: $e');
      rethrow;
    }
  }
}
