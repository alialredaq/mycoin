import 'dart:async';
import '../models/coin.dart';
import '../models/alert.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class PriceUpdater {
  Timer? _favoriteTimer;
  Timer? _marketTimer;

  // بدء التحديث الدوري
  void startUpdating() {
    print('Price Updater Started...');
    
    // تحديث المفضلة (مثلاً كل 5 دقائق - للتجربة سنضعها 60 ثانية)
    // ملاحظة: CoinGecko API المجاني له حدود، لذا لا تكثر من التكرار
    _favoriteTimer = Timer.periodic(
      const Duration(minutes: AppConstants.defaultFavoriteUpdateInterval),
      (_) => _updateFavoriteCoins(),
    );

    // تحديث السوق العام (كل ساعتين)
    _marketTimer = Timer.periodic(
      const Duration(minutes: AppConstants.defaultMarketUpdateInterval),
      (_) => _updateMarketCoins(),
    );
  }

  // إيقاف التحديث
  void stopUpdating() {
    _favoriteTimer?.cancel();
    _marketTimer?.cancel();
    print('Price Updater Stopped.');
  }

  // 1. تحديث عملات المفضلة
  Future<void> _updateFavoriteCoins() async {
    try {
      print('Updating Favorite Coins...');
      List<Coin> favorites = await DatabaseService.getFavoriteCoins();
      
      if (favorites.isEmpty) return;

      List<String> ids = favorites.map((c) => c.id).toList();
      List<Coin> updatedCoins = await ApiService.fetchCoinsByIds(ids);

      for (var updatedCoin in updatedCoins) {
        // حفظ السعر الجديد
        await DatabaseService.updateCoinPrice(
          updatedCoin.id,
          updatedCoin.currentPrice,
          updatedCoin.priceChangePercentage24h,
        );

        // فحص التنبيهات لهذه العملة
        await _checkAlerts(updatedCoin);
      }
    } catch (e) {
      print('Error updating favorites: $e');
    }
  }

  // 2. تحديث عملات السوق العام
  Future<void> _updateMarketCoins() async {
    try {
      print('Updating Market Coins...');
      List<Coin> marketCoins = await ApiService.fetchCoins(perPage: 100);
      await DatabaseService.saveCoins(marketCoins);
    } catch (e) {
      print('Error updating market: $e');
    }
  }

  // 3. فحص التنبيهات
  Future<void> _checkAlerts(Coin currentCoinData) async {
    List<Alert> activeAlerts = await DatabaseService.getAlertsByCoin(currentCoinData.id);

    for (var alert in activeAlerts) {
      if (!alert.isActive) continue;

      bool triggered = false;

      // منطق التنبيه السعري
      if (alert.type == AlertType.price) {
        if (alert.condition == AlertCondition.crossesAbove && currentCoinData.currentPrice >= alert.targetValue) {
          triggered = true;
        } else if (alert.condition == AlertCondition.crossesBelow && currentCoinData.currentPrice <= alert.targetValue) {
          triggered = true;
        }
      }

      // إذا تم تفعيل التنبيه
      if (triggered) {
        await NotificationService.showPriceAlertNotification(
          currentCoinData.symbol.toUpperCase(),
          alert.targetValue,
          currentCoinData.currentPrice,
        );
        
        // إيقاف التنبيه بعد_triggered (اختياري)
        await DatabaseService.toggleAlert(alert.id, false);
      }
    }
  }
}