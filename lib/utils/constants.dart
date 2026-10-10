class AppConstants {
  // روابط الـ API الافتراضية (يمكن للمستخدم تغييرها لاحقاً)
  static const String defaultApiBaseUrl = 'https://api.coingecko.com/api/v3';
  static const String defaultNewsApiUrl = 'https://cryptonews-api.com/api/v1';

  // إعدادات التحديث الافتراضية (بالدقائق)
  static const int defaultFavoriteUpdateInterval = 5; // كل 5 دقائق للمفضلة
  static const int defaultMarketUpdateInterval = 120; // كل ساعتين للسوق العام

  // حدود العملات
  static const int maxFavoriteCoins = 150;
  static const int maxTotalCoins = 1000;

  // روابط خارجية
  static const String tradingViewBaseUrl = 'https://www.tradingview.com/chart/?symbol=';
}