import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // سنضيف هذه المكتبة لاحقاً
import '../models/coin.dart';
import '../theme.dart';
import '../utils/constants.dart';

class CoinDetailScreen extends StatelessWidget {
  final Coin coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final isPositive = coin.priceChangePercentage24h >= 0;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        title: Text(coin.symbol.toUpperCase()),
        actions: [
          IconButton(
            icon: Icon(coin.isFavorite ? Icons.star : Icons.star_border, color: AppTheme.accentGold),
            onPressed: () {
              // منطق إضافة/إزالة المفضلة سيضاف لاحقاً
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // السعر الحالي
          Center(
            child: Column(
              children: [
                Text(
                  '\$${coin.currentPrice.toStringAsFixed(coin.currentPrice < 1 ? 6 : 2)}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isPositive ? AppTheme.accentGreen : AppTheme.accentRed).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isPositive ? AppTheme.accentGreen : AppTheme.accentRed,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${coin.priceChangePercentage24h.abs().toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: isPositive ? AppTheme.accentGreen : AppTheme.accentRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // إحصائيات سريعة
          Row(
            children: [
              Expanded(child: _StatCard(label: 'أعلى 24س', value: '\$${coin.high24h.toStringAsFixed(2)}')),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'أدنى 24س', value: '\$${coin.low24h.toStringAsFixed(2)}')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatCard(label: 'القيمة السوقية', value: '\$${(coin.marketCap / 1000000000).toStringAsFixed(2)}B')),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'الحجم', value: '\$${(coin.totalVolume / 1000000000).toStringAsFixed(2)}B')),
            ],
          ),
          const SizedBox(height: 32),

          // أزرار الإجراءات
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                // فتح TradingView
                // سنستخدم url_launcher لاحقاً
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('فتح في TradingView'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // إضافة للمحفظة
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentGreen,
                side: const BorderSide(color: AppTheme.accentGreen),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('إضافة إلى محفظتي'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.bgTertiary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}