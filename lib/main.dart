import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStore.init();
  runApp(const CryptoTrackApp());
}

class Coin {
  const Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.marketCap,
    required this.volume24h,
    required this.category,
    required this.icon,
  });

  final int id;
  final String name;
  final String symbol;
  final double price;
  final double change24h;
  final double marketCap;
  final double volume24h;
  final String category;
  final IconData icon;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbol': symbol,
        'price': price,
        'change24h': change24h,
        'marketCap': marketCap,
        'volume24h': volume24h,
        'category': category,
      };

  factory Coin.fromJson(Map<String, dynamic> j) => Coin(
        id: j['id'] as int,
        name: j['name'] as String,
        symbol: j['symbol'] as String,
        price: (j['price'] as num).toDouble(),
        change24h: (j['change24h'] as num).toDouble(),
        marketCap: (j['marketCap'] as num).toDouble(),
        volume24h: (j['volume24h'] as num).toDouble(),
        category: j['category'] as String,
        icon: Icons.currency_bitcoin,
      );
}

const coins = <Coin>[
  Coin(
    id: 1,
    name: 'Bitcoin',
    symbol: 'BTC',
    price: 67432.50,
    change24h: 2.34,
    marketCap: 1320000000000,
    volume24h: 28500000000,
    category: 'Layer 1',
    icon: Icons.currency_bitcoin,
  ),
  Coin(
    id: 2,
    name: 'Ethereum',
    symbol: 'ETH',
    price: 3521.80,
    change24h: -1.25,
    marketCap: 423000000000,
    volume24h: 15200000000,
    category: 'Layer 1',
    icon: Icons.currency_exchange,
  ),
  Coin(
    id: 3,
    name: 'Binance Coin',
    symbol: 'BNB',
    price: 598.40,
    change24h: 0.87,
    marketCap: 89000000000,
    volume24h: 1800000000,
    category: 'Exchange',
    icon: Icons.account_balance_wallet,
  ),
  Coin(
    id: 4,
    name: 'Solana',
    symbol: 'SOL',
    price: 142.65,
    change24h: 5.12,
    marketCap: 63000000000,
    volume24h: 3200000000,
    category: 'Layer 1',
    icon: Icons.bolt,
  ),
  Coin(
    id: 5,
    name: 'Cardano',
    symbol: 'ADA',
    price: 0.4523,
    change24h: -2.18,
    marketCap: 16000000000,
    volume24h: 420000000,
    category: 'Layer 1',
    icon: Icons.hexagon,
  ),
  Coin(
    id: 6,
    name: 'Ripple',
    symbol: 'XRP',
    price: 0.5234,
    change24h: 1.45,
    marketCap: 28000000000,
    volume24h: 1100000000,
    category: 'Payment',
    icon: Icons.send,
  ),
  Coin(
    id: 7,
    name: 'Polkadot',
    symbol: 'DOT',
    price: 7.23,
    change24h: -0.56,
    marketCap: 9500000000,
    volume24h: 280000000,
    category: 'Layer 0',
    icon: Icons.circle,
  ),
  Coin(
    id: 8,
    name: 'Dogecoin',
    symbol: 'DOGE',
    price: 0.0892,
    change24h: 3.67,
    marketCap: 12700000000,
    volume24h: 650000000,
    category: 'Meme',
    icon: Icons.pets,
  ),
];

class AppStore {
  static late SharedPreferences prefs;

  static const _kName = 'crypto_username';
  static const _kDark = 'crypto_dark';
  static const _kWatchlist = 'crypto_watchlist';
  static const _kPortfolio = 'crypto_portfolio';

  static String username = '';
  static bool isDark = false;
  static Set<int> watchlist = {};
  static Map<int, double> portfolio = {};

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    username = prefs.getString(_kName) ?? '';
    isDark = prefs.getBool(_kDark) ?? false;

    final watchlistRaw = prefs.getString(_kWatchlist);
    if (watchlistRaw != null) {
      watchlist = (jsonDecode(watchlistRaw) as List).cast<int>().toSet();
    }

    final portfolioRaw = prefs.getString(_kPortfolio);
    if (portfolioRaw != null) {
      final map = jsonDecode(portfolioRaw) as Map<String, dynamic>;
      portfolio = map.map(
        (k, v) => MapEntry(
          int.parse(k),
          (v as num).toDouble(),
        ),
      );
    }
  }

  static Future<void> saveUsername(String name) async {
    username = name;
    await prefs.setString(_kName, name);
  }

  static Future<void> saveDark(bool value) async {
    isDark = value;
    await prefs.setBool(_kDark, value);
  }

  static Future<void> saveWatchlist() async {
    await prefs.setString(_kWatchlist, jsonEncode(watchlist.toList()));
  }

  static Future<void> savePortfolio() async {
    await prefs.setString(_kPortfolio, jsonEncode(portfolio));
  }

  static void toggleWatchlist(int coinId) {
    if (watchlist.contains(coinId)) {
      watchlist.remove(coinId);
    } else {
      watchlist.add(coinId);
    }
    saveWatchlist();
  }

  static void addToPortfolio(int coinId, double amount) {
    portfolio[coinId] = (portfolio[coinId] ?? 0) + amount;
    savePortfolio();
  }

  static double portfolioValue() {
    double total = 0;
    portfolio.forEach((coinId, amount) {
      final coin = coins.firstWhere((c) => c.id == coinId);
      total += coin.price * amount;
    });
    return total;
  }

  static double portfolioChange() {
    double totalChange = 0;
    int count = 0;
    portfolio.forEach((coinId, amount) {
      final coin = coins.firstWhere((c) => c.id == coinId);
      totalChange += coin.change24h;
      count++;
    });
    return count > 0 ? totalChange / count : 0;
  }
}

class CryptoTrackApp extends StatefulWidget {
  const CryptoTrackApp({super.key});

  @override
  State<CryptoTrackApp> createState() => _CryptoTrackAppState();
}

class _CryptoTrackAppState extends State<CryptoTrackApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CryptoTrack',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: AppStore.isDark ? ThemeMode.dark : ThemeMode.light,
      home: AppStore.username.isEmpty
          ? WelcomeScreen(
              onDone: (name) {
                AppStore.saveUsername(name);
                setState(() {});
              },
            )
          : CryptoHome(
              onThemeChanged: () => setState(() {}),
              onReset: () => setState(() {}),
            ),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.onDone});

  final ValueChanged<String> onDone;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.currency_bitcoin,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'أهلاً بك في CryptoTrack',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'تتبع أسعار العملات الرقمية وإدارة محفظتك بسهولة',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      hintText: 'اكتب اسمك للبدء',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('ابدأ الآن'),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onDone(name);
  }
}

class CryptoHome extends StatefulWidget {
  const CryptoHome({
    super.key,
    required this.onThemeChanged,
    required this.onReset,
  });

  final VoidCallback onThemeChanged;
  final VoidCallback onReset;

  @override
  State<CryptoHome> createState() => _CryptoHomeState();
}

class _CryptoHomeState extends State<CryptoHome> {
  int _tab = 0;
  String _query = '';
  String _category = 'الكل';

  final _categories = const [
    'الكل',
    'Layer 1',
    'DeFi',
    'NFT',
    'Meme',
    'Payment',
  ];

  List<Coin> get _filtered => coins.where((c) {
        final matchCat = _category == 'الكل' || c.category == _category;
        final matchQuery = _query.isEmpty ||
            c.name.toLowerCase().contains(_query.toLowerCase()) ||
            c.symbol.toLowerCase().contains(_query.toLowerCase());
        return matchCat && matchQuery;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CryptoTrack'),
        actions: [
          IconButton(
            tooltip: 'الوضع الليلي',
            onPressed: () {
              AppStore.saveDark(!AppStore.isDark);
              widget.onThemeChanged();
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  RotationTransition(turns: anim, child: child),
              child: Icon(
                AppStore.isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                key: ValueKey(AppStore.isDark),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _homeTab(),
          _marketTab(),
          _portfolioTab(),
          _profileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (v) => setState(() => _tab = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up),
            label: 'السوق',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'محفظتي',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  Widget _homeTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        _heroBanner(),
        const SizedBox(height: 24),
        _sectionTitle('التصنيفات', null),
        const SizedBox(height: 12),
        _categoryStrip(),
        const SizedBox(height: 24),
        _sectionTitle(
          'العملات الرائجة',
          '${_filtered.length} عملة',
        ),
        const SizedBox(height: 12),
        ..._filtered.asMap().entries.map(
              (entry) => _CoinListTile(
                coin: entry.value,
                index: entry.key,
                onTap: () => _openCoin(entry.value),
              ),
            ),
      ],
    );
  }

  Widget _heroBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStore.username.isEmpty
                      ? 'ابدأ التداول'
                      : 'مرحباً ${AppStore.username}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'تابع أسعار العملات اليوم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => setState(() => _tab = 1),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('استكشف السوق'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.currency_bitcoin,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String? trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _categoryStrip() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = _category == cat;
          return ChoiceChip(
            label: Text(cat),
            selected: selected,
            onSelected: (_) => setState(() => _category = cat),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          );
        },
      ),
    );
  }

  Widget _marketTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'ابحث عن عملة',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        _categoryStrip(),
        const SizedBox(height: 24),
        _sectionTitle('النتائج', '${_filtered.length} عملة'),
        const SizedBox(height: 12),
        if (_filtered.isEmpty)
          _emptyState('لا توجد نتائج مطابقة')
        else
          ..._filtered.asMap().entries.map(
                (entry) => _CoinListTile(
                  coin: entry.value,
                  index: entry.key,
                  onTap: () => _openCoin(entry.value),
                ),
              ),
      ],
    );
  }

  Widget _portfolioTab() {
    final myCoins =
        coins.where((c) => AppStore.portfolio.containsKey(c.id)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        _statsRow(),
        const SizedBox(height: 24),
        _sectionTitle('محفظتي', '${myCoins.length} عملة'),
        const SizedBox(height: 12),
        if (myCoins.isEmpty)
          _emptyState('لم تضف أي عملة إلى محفظتك بعد')
        else
          ...myCoins.asMap().entries.map(
                (entry) => _PortfolioTile(
                  coin: entry.value,
                  index: entry.key,
                  onTap: () => _openCoin(entry.value),
                ),
              ),
      ],
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.account_balance_wallet_outlined,
            value: '\$${AppStore.portfolioValue().toStringAsFixed(2)}',
            label: 'قيمة المحفظة',
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: AppStore.portfolioChange() >= 0
                ? Icons.trending_up
                : Icons.trending_down,
            value: '${AppStore.portfolioChange().toStringAsFixed(2)}%',
            label: 'التغيير اليوم',
            color: AppStore.portfolioChange() >= 0
                ? AppTheme.primary
                : AppTheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.star_outline,
            value: '${AppStore.watchlist.length}',
            label: 'مراقبة',
            color: const Color(0xFFFFB300),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    AppStore.username.isNotEmpty
                        ? AppStore.username.characters.first
                        : '؟',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStore.username.isEmpty
                          ? 'مستخدم'
                          : AppStore.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'متداول في CryptoTrack',
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _settingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'الوضع الليلي',
                trailing: Switch.adaptive(
                  value: AppStore.isDark,
                  onChanged: (v) {
                    AppStore.saveDark(v);
                    widget.onThemeChanged();
                  },
                ),
              ),
              const Divider(height: 1),
              _settingsTile(
                icon: Icons.info_outline,
                title: 'عن التطبيق',
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _showAbout(),
              ),
              const Divider(height: 1),
              _settingsTile(
                icon: Icons.delete_outline,
                title: 'حذف كل البيانات',
                titleColor: Colors.red,
                iconColor: Colors.red,
                trailing: const Icon(Icons.chevron_left),
                onTap: _confirmReset,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'CryptoTrack - الإصدار 1.0.0',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
      ),
      trailing: trailing,
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.currency_bitcoin,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: const Text(
          'CryptoTrack',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تطبيق لتتبع أسعار العملات الرقمية وإدارة محفظتك الشخصية. جميع البيانات محفوظة على جهازك فقط.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'الإصدار 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف كل البيانات'),
        content: const Text(
          'سيتم حذف كل بيانات المحفظة والعملات المراقبة واسم المستخدم. لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              await AppStore.prefs.clear();
              AppStore.username = '';
              AppStore.watchlist = {};
              AppStore.portfolio = {};
              AppStore.isDark = false;
              Navigator.pop(dialogContext);
              widget.onReset();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _openCoin(Coin coin) {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, animation, __) => FadeTransition(
              opacity: animation,
              child: CoinDetailScreen(coin: coin),
            ),
            transitionsBuilder: (_, animation, __, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          ),
        )
        .then((_) => setState(() {}));
  }

  Widget _emptyState(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinListTile extends StatelessWidget {
  const _CoinListTile({
    required this.coin,
    required this.index,
    required this.onTap,
  });

  final Coin coin;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isWatched = AppStore.watchlist.contains(coin.id);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(20 * (1 - value), 0),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        coin.change24h >= 0
                            ? AppTheme.primary
                            : AppTheme.secondary,
                        (coin.change24h >= 0
                                ? AppTheme.primary
                                : AppTheme.secondary)
                            .withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    coin.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coin.symbol,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            coin.change24h >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: coin.change24h >= 0
                                ? AppTheme.primary
                                : AppTheme.secondary,
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${coin.change24h.abs().toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: coin.change24h >= 0
                                  ? AppTheme.primary
                                  : AppTheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.category_outlined,
                            size: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            coin.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${coin.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      onPressed: () {
                        AppStore.toggleWatchlist(coin.id);
                      },
                      icon: Icon(
                        isWatched ? Icons.star : Icons.star_border,
                        color: isWatched ? const Color(0xFFFFB300) : null,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PortfolioTile extends StatelessWidget {
  const _PortfolioTile({
    required this.coin,
    required this.index,
    required this.onTap,
  });

  final Coin coin;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amount = AppStore.portfolio[coin.id] ?? 0;
    final value = coin.price * amount;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            coin.change24h >= 0
                                ? AppTheme.primary
                                : AppTheme.secondary,
                            (coin.change24h >= 0
                                    ? AppTheme.primary
                                    : AppTheme.secondary)
                                .withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        coin.icon,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coin.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${amount.toStringAsFixed(4)} ${coin.symbol}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${value.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: coin.change24h >= 0
                                ? AppTheme.primary
                                : AppTheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${coin.change24h >= 0 ? "+" : ""}${coin.change24h.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: coin.change24h >= 0
                                ? AppTheme.primary
                                : AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CoinDetailScreen extends StatefulWidget {
  const CoinDetailScreen({super.key, required this.coin});

  final Coin coin;

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coin = widget.coin;
    final isWatched = AppStore.watchlist.contains(coin.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: coin.change24h >= 0
                ? AppTheme.primary
                : AppTheme.secondary,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      coin.change24h >= 0
                          ? AppTheme.primary
                          : AppTheme.secondary,
                      (coin.change24h >= 0
                              ? AppTheme.primary
                              : AppTheme.secondary)
                          .withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Icon(
                        coin.icon,
                        size: 220,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                coin.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              coin.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              coin.symbol,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _anim,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoGrid(coin),
                      const SizedBox(height: 24),
                      const Text(
                        'أضف إلى محفظتك',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'أدخل الكمية',
                          prefixIcon: Icon(Icons.add_circle_outline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            final amount =
                                double.tryParse(_amountController.text);
                            if (amount != null && amount > 0) {
                              AppStore.addToPortfolio(coin.id, amount);
                              _amountController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم إضافة ${amount.toStringAsFixed(4)} ${coin.symbol} إلى محفظتك',
                                  ),
                                  backgroundColor: AppTheme.primary,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة إلى المحفظة'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _bottomBar(coin, isWatched),
    );
  }

  Widget _infoGrid(Coin coin) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _infoItem(
            icon: Icons.attach_money,
            value: '\$${coin.price.toStringAsFixed(2)}',
            label: 'السعر',
            color: AppTheme.primary,
          ),
          _divider(),
          _infoItem(
            icon: coin.change24h >= 0
                ? Icons.trending_up
                : Icons.trending_down,
            value: '${coin.change24h.abs().toStringAsFixed(2)}%',
            label: '24 ساعة',
            color: coin.change24h >= 0
                ? AppTheme.primary
                : AppTheme.secondary,
          ),
          _divider(),
          _infoItem(
            icon: Icons.show_chart,
            value: '\$${(coin.marketCap / 1000000000).toStringAsFixed(2)}B',
            label: 'القيمة السوقية',
            color: AppTheme.accent,
          ),
        ],
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 34,
      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(
            alpha: 0.15,
          ),
    );
  }

  Widget _bottomBar(Coin coin, bool isWatched) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () {
            AppStore.toggleWatchlist(coin.id);
            setState(() {});
          },
          style: FilledButton.styleFrom(
            backgroundColor:
                isWatched ? Colors.red.withValues(alpha: 0.9) : AppTheme.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            isWatched ? 'إزالة من المراقبة' : 'إضافة إلى المراقبة',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}