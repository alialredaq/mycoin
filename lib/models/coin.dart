class Coin {
  final String id; // معرف العملة في الـ API (مثل bitcoin)
  final String symbol; // رمز العملة (مثل BTC)
  final String name; // اسم العملة (مثل Bitcoin)
  final double currentPrice; // السعر الحالي
  final double priceChangePercentage24h; // نسبة التغيير في 24 ساعة
  final double marketCap; // القيمة السوقية
  final double totalVolume; // حجم التداول
  final double high24h; // أعلى سعر في 24 ساعة
  final double low24h; // أدنى سعر في 24 ساعة
  final String? imageUrl; // رابط صورة العملة
  final bool isFavorite; // هل هي في المفضلة؟
  final double? portfolioAmount; // الكمية المملوكة في المحفظة (اختياري)

  Coin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    this.priceChangePercentage24h = 0,
    this.marketCap = 0,
    this.totalVolume = 0,
    this.high24h = 0,
    this.low24h = 0,
    this.imageUrl,
    this.isFavorite = false,
    this.portfolioAmount,
  });

  // إنشاء كائن من JSON (للاستقبال من الـ API)
  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      priceChangePercentage24h: (json['price_change_percentage_24h'] ?? 0).toDouble(),
      marketCap: (json['market_cap'] ?? 0).toDouble(),
      totalVolume: (json['total_volume'] ?? 0).toDouble(),
      high24h: (json['high_24h'] ?? 0).toDouble(),
      low24h: (json['low_24h'] ?? 0).toDouble(),
      imageUrl: json['image'],
    );
  }

  // تحويل الكائن إلى JSON (للحفظ المحلي)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'current_price': currentPrice,
      'price_change_percentage_24h': priceChangePercentage24h,
      'market_cap': marketCap,
      'total_volume': totalVolume,
      'high_24h': high24h,
      'low_24h': low24h,
      'image': imageUrl,
      'is_favorite': isFavorite,
      'portfolio_amount': portfolioAmount,
    };
  }

  // نسخ الكائن مع تعديل بعض الخصائص
  Coin copyWith({
    String? id,
    String? symbol,
    String? name,
    double? currentPrice,
    double? priceChangePercentage24h,
    double? marketCap,
    double? totalVolume,
    double? high24h,
    double? low24h,
    String? imageUrl,
    bool? isFavorite,
    double? portfolioAmount,
  }) {
    return Coin(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChangePercentage24h: priceChangePercentage24h ?? this.priceChangePercentage24h,
      marketCap: marketCap ?? this.marketCap,
      totalVolume: totalVolume ?? this.totalVolume,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      portfolioAmount: portfolioAmount ?? this.portfolioAmount,
    );
  }
}