class TransactionModel {
  int? id;
  String category;
  double amount;
  DateTime date;
  String type; // 'income' or 'expense'
  String genre; 

  TransactionModel({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.genre, 
  });

  // データベースに保存するためのマップ形式に変換
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

  // データベースから取得したマップを `TransactionModel` に変換
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
