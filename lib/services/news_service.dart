class NewsItem {
  final String title;
  final String source;
  final String timeAgo;
  final String volumeChange; // e.g., "+20%" or "-10%"

  NewsItem({
    required this.title,
    required this.source,
    required this.timeAgo,
    required this.volumeChange,
  });
}

class NewsService {
  // في التطبيق الحقيقي، هنا سنستخدم http.get لجلب الأخبار من API
  // حالياً نستخدم بيانات تجريبية لضمان عمل التطبيق
  static Future<List<NewsItem>> fetchLatestNews() async {
    // محاكاة تأخير الشبكة
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      NewsItem(
        title: 'بيتكوين يكسر حاجز المقاومة ويسجل ارتفاعاً جديداً',
        source: 'Crypto Daily',
        timeAgo: 'منذ 15 دقيقة',
        volumeChange: '+12.5%',
      ),
      NewsItem(
        title: 'الإيثريوم يشهد ضغط بيعي كبير مع اقتراب التحديث الجديد',
        source: 'CoinTelegraph',
        timeAgo: 'منذ ساعة',
        volumeChange: '-5.2%',
      ),
      NewsItem(
        title: 'حجم التداول في العملات البديلة (Altcoins) ي قفز بشكل قياسي',
        source: 'Bloomberg Crypto',
        timeAgo: 'منذ 3 ساعات',
        volumeChange: '+45.0%',
      ),
      NewsItem(
        title: 'تحليل: هل نحن في بداية سوق صاعد جديد؟',
        source: 'MyCoin Analysis',
        timeAgo: 'منذ 5 ساعات',
        volumeChange: '+2.1%',
      ),
    ];
  }
}