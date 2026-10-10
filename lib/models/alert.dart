enum AlertType {
  price, // تنبيه سعري
  indicator, // تنبيه مؤشر فني
}

enum AlertCondition {
  crossesAbove, // يعبر فوق
  crossesBelow, // يعبر تحت
  equals, // يساوي
}

class Alert {
  final String id;
  final String coinId; // معرف العملة
  final String coinSymbol; // رمز العملة للعرض
  final AlertType type;
  final String indicatorName; // اسم المؤشر (إذا كان تنبيه مؤشر)
  final double targetValue; // القيمة المستهدفة
  final AlertCondition condition;
  final bool isActive;
  final DateTime createdAt;

  Alert({
    required this.id,
    required this.coinId,
    required this.coinSymbol,
    required this.type,
    this.indicatorName = '',
    required this.targetValue,
    required this.condition,
    this.isActive = true,
    required this.createdAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] ?? '',
      coinId: json['coin_id'] ?? '',
      coinSymbol: json['coin_symbol'] ?? '',
      type: AlertType.values.firstWhere((e) => e.name == json['type'], orElse: () => AlertType.price),
      indicatorName: json['indicator_name'] ?? '',
      targetValue: (json['target_value'] ?? 0).toDouble(),
      condition: AlertCondition.values.firstWhere((e) => e.name == json['condition'], orElse: () => AlertCondition.crossesAbove),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coin_id': coinId,
      'coin_symbol': coinSymbol,
      'type': type.name,
      'indicator_name': indicatorName,
      'target_value': targetValue,
      'condition': condition.name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get conditionText {
    switch (condition) {
      case AlertCondition.crossesAbove:
        return 'يعبر فوق';
      case AlertCondition.crossesBelow:
        return 'يعبر تحت';
      case AlertCondition.equals:
        return 'يساوي';
    }
  }
}