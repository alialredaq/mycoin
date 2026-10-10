import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/import_screen.dart';
import 'screens/api_manager_screen.dart';
import 'screens/volume_news_screen.dart';
import 'services/price_updater.dart';
import 'services/notification_service.dart';
import 'utils/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة الخدمات
  await NotificationService.init();
  
  // بدء تحديث الأسعار
  PriceUpdater().startUpdating();
  
  runApp(const MyCoinApp());
}

class MyCoinApp extends StatelessWidget {
  const MyCoinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyCoin',
      theme: AppTheme.dark,
      locale: AppTranslations.currentLocale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PortfolioScreen(),
    const Scaffold(body: Center(child: Text('Analysis - Select a coin first', style: TextStyle(color: Colors.white)))),
    const AlertsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppTheme.bgSecondary,
        indicatorColor: AppTheme.accentGreen.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'المحفظة'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'التحليل'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'التنبيهات'),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppTheme.bgSecondary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppTheme.bgPrimary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.currency_bitcoin, color: AppTheme.accentGold, size: 48),
                  SizedBox(height: 12),
                  Text('MyCoin', style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('متتبع العملات الرقمية', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.download, color: AppTheme.textPrimary),
              title: const Text('استيراد عملات', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.api, color: AppTheme.textPrimary),
              title: const Text('إدارة API', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ApiManagerScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper, color: AppTheme.textPrimary),
              title: const Text('الأخبار وحجم التداول', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const VolumeNewsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.textPrimary),
              title: const Text('تغيير اللغة', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _changeLanguage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _changeLanguage() {
    setState(() {
      if (AppTranslations.currentLocale.languageCode == 'ar') {
        AppTranslations.setLocale(const Locale('en'));
      } else {
        AppTranslations.setLocale(const Locale('ar'));
      }
    });
  }
}