class SavingsModel {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String category;
  final String memo;

  SavingsModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.category,
    this.memo = '',
  });

  double get progress => currentAmount / targetAmount;
  double get remainingAmount => targetAmount - currentAmount;

  SavingsModel copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? category,
    String? memo,
  }) {
    return SavingsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      memo: memo ?? this.memo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'category': category,
      'memo': memo,
    };
  }

  factory SavingsModel.fromJson(Map<String, dynamic> json) {
    return SavingsModel(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: json['targetAmount'] as double,
      currentAmount: json['currentAmount'] as double,
      targetDate: DateTime.parse(json['targetDate'] as String),
      category: json['category'] as String,
      memo: json['memo'] as String,
    );
  }
} 