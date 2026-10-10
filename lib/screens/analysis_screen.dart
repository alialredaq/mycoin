import 'package:flutter/material.dart';
import '../models/coin.dart';
import '../services/technical_analysis_service.dart';
import '../theme.dart';

class AnalysisScreen extends StatefulWidget {
  final Coin coin;

  const AnalysisScreen({super.key, required this.coin});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late List<TechnicalIndicator> _indicators;
  late RecommendationCard _recommendation;

  @override
  void initState() {
    super.initState();
    _indicators = TechnicalAnalysisService.calculateIndicators(widget.coin);
    _recommendation = TechnicalAnalysisService.generateRecommendation(widget.coin, _indicators);
  }

  Color _getSignalColor(String signal) {
    switch (signal) {
      case 'buy':
      case 'strong_buy':
        return AppTheme.accentGreen;
      case 'sell':
      case 'strong_sell':
        return AppTheme.accentRed;
      default:
        return AppTheme.textTertiary;
    }
  }

  String _getSignalText(String signal) {
    switch (signal) {
      case 'buy': return 'شراء';
      case 'strong_buy': return 'شراء قوي';
      case 'sell': return 'بيع';
      case 'strong_sell': return 'بيع قوي';
      default: return 'محايد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        title: Text('التحليل الفني - ${widget.coin.symbol.toUpperCase()}'),
        backgroundColor: AppTheme.bgPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // بطاقة التوصية الذكية
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getSignalColor(_recommendation.overallSignal).withValues(alpha: 0.2),
                  AppTheme.bgSecondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getSignalColor(_recommendation.overallSignal), width: 2),
            ),
            child: Column(
              children: [
                Text(
                  _recommendation.coinSymbol,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  _recommendation.overallSignalAr,
                  style: TextStyle(
                    color: _getSignalColor(_recommendation.overallSignal),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _signalCount('شراء', _recommendation.buyCount, AppTheme.accentGreen),
                    _signalCount('محايد', _recommendation.neutralCount, AppTheme.textTertiary),
                    _signalCount('بيع', _recommendation.sellCount, AppTheme.accentRed),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // عنوان المؤشرات
          const Text(
            'المؤشرات الفنية',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // قائمة المؤشرات
          ..._indicators.map((indicator) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.bgTertiary),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(indicator.nameAr, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('${indicator.name} (${indicator.value.toStringAsFixed(2)})', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getSignalColor(indicator.signal).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getSignalText(indicator.signal),
                    style: TextStyle(color: _getSignalColor(indicator.signal), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          )),

          const SizedBox(height: 20),

          // زر فتح TradingView
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                // فتح TradingView
                // يمكن استخدام url_launcher لاحقاً
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('فتح الرسم البياني في TradingView'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2962FF), // لون TradingView الأزرق
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signalCount(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      ],
    );
  }
}