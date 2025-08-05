/// 取引データを表すモデルクラス
/// 
/// このクラスは個々の取引記録を表し、以下の情報を保持します：
/// - 取引ID（データベース用）
/// - カテゴリ（食費、交通費等）
/// - 金額
/// - 取引日時
/// - 取引種別（収入/支出）
/// - ジャンル（詳細分類）
class TransactionModel {
  /// データベースの主キー（null可能）
  int? id;
  
  /// 取引のカテゴリ（例：食費、交通費、給与等）
  String category;
  
  /// 取引金額（正の値）
  double amount;
  
  /// 取引が発生した日時
  DateTime date;
  
  /// 取引の種別（'income' または 'expense'）
  String type;
  
  /// 取引のジャンル（カテゴリの詳細分類）
  String genre;
  /// 新しい取引モデルを作成します
  /// 
  /// [category] 取引のカテゴリ
  /// [amount] 取引金額（正の値）
  /// [date] 取引日時
  /// [type] 取引種別（'income' または 'expense'）
  /// [genre] 取引のジャンル
  /// [id] データベースID（通常は自動生成）
  TransactionModel({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.genre, 
  });

  /// データベースに保存するためのマップ形式に変換します
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category, // ✅ category を追加
      'amount': amount,
      'date': date.toIso8601String(), // ✅ DateTime → String に変換
      'type': type,
      'genre': genre, 
    };
  }
  /// データベースから取得したマップから TransactionModel を作成します
  /// 
  /// [map] データベースから取得したマップデータ
  /// 戻り値: 新しいTransactionModelインスタンス
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      category: map['category'] as String, // ✅ category を追加
      amount: (map['amount'] as num).toDouble(), // ✅ double に変換
      date: DateTime.parse(map['date'] as String), // ✅ String → DateTime に変換
      type: map['type'] as String,
      genre: map['genre'] as String, 
    );
  }
}
