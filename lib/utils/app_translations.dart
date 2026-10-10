import 'package:flutter/material.dart';

class AppTranslations {
  // اللغة الحالية (يمكن تغييرها لاحقاً)
  static Locale currentLocale = const Locale('ar');

  // قاموس الترجمة
  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'app_name': 'MyCoin',
      'home': 'الرئيسية',
      'market': 'السوق',
      'analysis': 'التحليل',
      'profile': 'حسابي',
      'favorites': 'المفضلة',
      'settings': 'الإعدادات',
      'search': 'بحث...',
      'price': 'السعر',
      'change_24h': 'التغيير 24س',
      'volume': 'الحجم',
      'add_to_portfolio': 'إضافة للمحفظة',
      'add_to_favorites': 'إضافة للمفضلة',
      'remove_from_favorites': 'إزالة من المفضلة',
      'alerts': 'التنبيهات',
      'news': 'الأخبار',
      'technical_indicators': 'المؤشرات الفنية',
      'recommendation': 'التوصية',
      'strong_buy': 'شراء قوي',
      'buy': 'شراء',
      'neutral': 'محايد',
      'sell': 'بيع',
      'strong_sell': 'بيع قوي',
      'open_in_tradingview': 'فتح في TradingView',
      'import_coins': 'استيراد عملات',
      'manual_add': 'إضافة يدوية',
      'update_interval': 'فترة التحديث',
      'language': 'اللغة',
      'dark_mode': 'الوضع الليلي',
    },
    'en': {
      'app_name': 'MyCoin',
      'home': 'Home',
      'market': 'Market',
      'analysis': 'Analysis',
      'profile': 'Profile',
      'favorites': 'Favorites',
      'settings': 'Settings',
      'search': 'Search...',
      'price': 'Price',
      'change_24h': '24h Change',
      'volume': 'Volume',
      'add_to_portfolio': 'Add to Portfolio',
      'add_to_favorites': 'Add to Favorites',
      'remove_from_favorites': 'Remove from Favorites',
      'alerts': 'Alerts',
      'news': 'News',
      'technical_indicators': 'Technical Indicators',
      'recommendation': 'Recommendation',
      'strong_buy': 'Strong Buy',
      'buy': 'Buy',
      'neutral': 'Neutral',
      'sell': 'Sell',
      'strong_sell': 'Strong Sell',
      'open_in_tradingview': 'Open in TradingView',
      'import_coins': 'Import Coins',
      'manual_add': 'Manual Add',
      'update_interval': 'Update Interval',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
    },
  };

  // دالة لجلب النص المترجم
  static String translate(String key) {
    final langCode = currentLocale.languageCode;
    return _localizedValues[langCode]?[key] ?? _localizedValues['en']![key] ?? key;
  }

  // دالة لتغيير اللغة
  static void setLocale(Locale locale) {
    currentLocale = locale;
  }
}

// Widget مساعد لاستخدام الترجمة بسهولة
// تم تغيير اسم المتغير من key إلى textKey لتجنب التعارض مع Widget.key
class T extends StatelessWidget {
  final String textKey;
  final TextStyle? style;

  const T(this.textKey, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppTranslations.translate(textKey),
      style: style,
    );
  }
}