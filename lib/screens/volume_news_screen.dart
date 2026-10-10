import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/app_translations.dart';

class VolumeNewsScreen extends StatelessWidget {
  const VolumeNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> mockNews = [
      {'title': 'ارتفاع حجم التداول على بيتكوين بنسبة 20%', 'source': 'CryptoDaily', 'volume': '+20%'},
      {'title': 'انخفاض مفاجئ في حجم تداول الإيثريوم', 'source': 'CoinTelegraph', 'volume': '-15%'},
      {'title': 'حجم تداول قياسي لعملة سولانا هذا الأسبوع', 'source': 'Bloomberg', 'volume': '+45%'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        title: const T('news'), // التصحيح هنا
        backgroundColor: AppTheme.bgPrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockNews.length,
        itemBuilder: (context, index) {
          final news = mockNews[index];
          final isPositive = news['volume']!.startsWith('+');
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.bgTertiary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(news['title']!, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(news['source']!, style: TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isPositive ? AppTheme.accentGreen : AppTheme.accentRed).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Vol: ${news['volume']}',
                        style: TextStyle(
                          color: isPositive ? AppTheme.accentGreen : AppTheme.accentRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}