import '../models/coin.dart';

// تعريف أنواع المؤشرات
enum IndicatorType { momentum, trend, volatility, volume }

// نموذج المؤشر الفني
class TechnicalIndicator {
  final String name;
  final String nameAr;
  final IndicatorType type;
  final double value;
  final String signal; // buy, sell, neutral
  final Map<String, double> parameters; // معاملات المؤشر

  TechnicalIndicator({
    required this.name,
    required this.nameAr,
    required this.type,
    required this.value,
    required this.signal,
    this.parameters = const {},
  });
}

// نموذج بطاقة التوصية
class RecommendationCard {
  final String coinSymbol;
  final String overallSignal; // strong_buy, buy, neutral, sell, strong_sell
  final String overallSignalAr;
  final int buyCount;
  final int sellCount;
  final int neutralCount;
  final List<TechnicalIndicator> indicators;

  RecommendationCard({
    required this.coinSymbol,
    required this.overallSignal,
    required this.overallSignalAr,
    required this.buyCount,
    required this.sellCount,
    required this.neutralCount,
    required this.indicators,
  });
}

class TechnicalAnalysisService {
  // حساب المؤشرات الفنية لعملة معينة
  // ملاحظة: في التطبيق الحقيقي، نحتاج لبيانات تاريخية (OHLCV) لحساب المؤشرات بدقة
  // هنا نستخدم محاكاة ذكية بناءً على بيانات العملة الحالية
  static List<TechnicalIndicator> calculateIndicators(Coin coin) {
    List<TechnicalIndicator> indicators = [];

    // 1. RSI (مؤشر القوة النسبية) - Momentum
    double rsiValue = _simulateRSI(coin.priceChangePercentage24h);
    String rsiSignal = rsiValue > 70 ? 'sell' : rsiValue < 30 ? 'buy' : 'neutral';
    indicators.add(TechnicalIndicator(
      name: 'RSI',
      nameAr: 'مؤشر القوة النسبية',
      type: IndicatorType.momentum,
      value: rsiValue,
      signal: rsiSignal,
      parameters: {'period': 14},
    ));

    // 2. MACD - Momentum
    double macdValue = _simulateMACD(coin.priceChangePercentage24h);
    String macdSignal = macdValue > 0 ? 'buy' : macdValue < 0 ? 'sell' : 'neutral';
    indicators.add(TechnicalIndicator(
      name: 'MACD',
      nameAr: 'الماكد',
      type: IndicatorType.momentum,
      value: macdValue,
      signal: macdSignal,
      parameters: {'fast': 12, 'slow': 26, 'signal': 9},
    ));

    // 3. Stochastic - Momentum
    double stochValue = _simulateStochastic(coin.priceChangePercentage24h);
    String stochSignal = stochValue > 80 ? 'sell' : stochValue < 20 ? 'buy' : 'neutral';
    indicators.add(TechnicalIndicator(
      name: 'Stochastic',
      nameAr: 'الستوكاستك',
      type: IndicatorType.momentum,
      value: stochValue,
      signal: stochSignal,
      parameters: {'k': 14, 'd': 3},
    ));

    // 4. SMA (Moving Average) - Trend
    double smaValue = _simulateSMA(coin.currentPrice, coin.priceChangePercentage24h);
    String smaSignal = coin.currentPrice > smaValue ? 'buy' : 'sell';
    indicators.add(TechnicalIndicator(
      name: 'SMA',
      nameAr: 'المتوسط المتحرك البسيط',
      type: IndicatorType.trend,
      value: smaValue,
      signal: smaSignal,
      parameters: {'period': 50},
    ));

    // 5. EMA - Trend
    double emaValue = _simulateEMA(coin.currentPrice, coin.priceChangePercentage24h);
    String emaSignal = coin.currentPrice > emaValue ? 'buy' : 'sell';
    indicators.add(TechnicalIndicator(
      name: 'EMA',
      nameAr: 'المتوسط المتحرك الأسي',
      type: IndicatorType.trend,
      value: emaValue,
      signal: emaSignal,
      parameters: {'period': 20},
    ));

    // 6. Bollinger Bands - Volatility
    double bbValue = _simulateBollingerBands(coin.currentPrice, coin.priceChangePercentage24h);
    String bbSignal = bbValue > 1 ? 'sell' : bbValue < -1 ? 'buy' : 'neutral';
    indicators.add(TechnicalIndicator(
      name: 'Bollinger Bands',
      nameAr: 'بولنجر باند',
      type: IndicatorType.volatility,
      value: bbValue,
      signal: bbSignal,
      parameters: {'period': 20, 'stdDev': 2},
    ));

    // 7. ATR - Volatility
    double atrValue = _simulateATR(coin.high24h, coin.low24h);
    indicators.add(TechnicalIndicator(
      name: 'ATR',
      nameAr: 'متوسط المدى الحقيقي',
      type: IndicatorType.volatility,
      value: atrValue,
      signal: 'neutral',
      parameters: {'period': 14},
    ));

    // 8. OBV - Volume
    double obvValue = _simulateOBV(coin.totalVolume, coin.priceChangePercentage24h);
    String obvSignal = obvValue > 0 ? 'buy' : obvValue < 0 ? 'sell' : 'neutral';
    indicators.add(TechnicalIndicator(
      name: 'OBV',
      nameAr: 'حجم التداول التراكمي',
      type: IndicatorType.volume,
      value: obvValue,
      signal: obvSignal,
    ));

    return indicators;
  }

  // توليد بطاقة التوصية الذكية
  static RecommendationCard generateRecommendation(Coin coin, List<TechnicalIndicator> indicators) {
    int buyCount = indicators.where((i) => i.signal == 'buy').length;
    int sellCount = indicators.where((i) => i.signal == 'sell').length;
    int neutralCount = indicators.where((i) => i.signal == 'neutral').length;
    int total = indicators.length;

    String overallSignal;
    String overallSignalAr;

    double buyRatio = buyCount / total;
    double sellRatio = sellCount / total;

    if (buyRatio >= 0.7) {
      overallSignal = 'strong_buy';
      overallSignalAr = 'شراء قوي';
    } else if (buyRatio >= 0.5) {
      overallSignal = 'buy';
      overallSignalAr = 'شراء';
    } else if (sellRatio >= 0.7) {
      overallSignal = 'strong_sell';
      overallSignalAr = 'بيع قوي';
    } else if (sellRatio >= 0.5) {
      overallSignal = 'sell';
      overallSignalAr = 'بيع';
    } else {
      overallSignal = 'neutral';
      overallSignalAr = 'محايد';
    }

    return RecommendationCard(
      coinSymbol: coin.symbol.toUpperCase(),
      overallSignal: overallSignal,
      overallSignalAr: overallSignalAr,
      buyCount: buyCount,
      sellCount: sellCount,
      neutralCount: neutralCount,
      indicators: indicators,
    );
  }

  // ===== دوال المحاكاة (في التطبيق الحقيقي تستخدم بيانات تاريخية) =====

  static double _simulateRSI(double change24h) {
    // RSI يتراوح بين 0 و 100
    // إذا كان التغيير موجباً كبيراً، RSI مرتفع (ذروة شراء)
    double base = 50 + (change24h * 5);
    return base.clamp(0, 100);
  }

  static double _simulateMACD(double change24h) {
    return change24h * 0.5;
  }

  static double _simulateStochastic(double change24h) {
    double base = 50 + (change24h * 4);
    return base.clamp(0, 100);
  }

  static double _simulateSMA(double price, double change24h) {
    return price * (1 - (change24h / 100));
  }

  static double _simulateEMA(double price, double change24h) {
    return price * (1 - (change24h / 150));
  }

  static double _simulateBollingerBands(double price, double change24h) {
    return change24h / 5;
  }

  static double _simulateATR(double high, double low) {
    return (high - low) / 2;
  }

  static double _simulateOBV(double volume, double change24h) {
    return change24h > 0 ? volume : -volume;
  }
}