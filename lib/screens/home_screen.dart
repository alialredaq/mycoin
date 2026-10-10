import 'package:flutter/material.dart';
import '../models/coin.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../widgets/coin_list_item.dart';
import '../widgets/filter_pill.dart';
import '../widgets/news_banner.dart';
import '../theme.dart';
import '../utils/app_translations.dart';
import 'coin_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Coin> _coins = [];
  List<Coin> _filteredCoins = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  final List<String> _filters = ['all', 'favorites', 'gainers', 'losers'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      List<Coin> localCoins = await DatabaseService.getAllCoins();
      if (localCoins.isEmpty) {
        List<Coin> apiCoins = await ApiService.fetchCoins(perPage: 50);
        await DatabaseService.saveCoins(apiCoins);
        _coins = apiCoins;
      } else {
        _coins = localCoins;
      }
      _applyFilters();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<Coin> result = _coins;
    if (_searchQuery.isNotEmpty) {
      result = result.where((coin) => 
        coin.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        coin.symbol.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    switch (_selectedFilter) {
      case 'favorites':
        result = result.where((coin) => coin.isFavorite).toList();
        break;
      case 'gainers':
        result = result.where((coin) => coin.priceChangePercentage24h > 0).toList();
        result.sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
        break;
      case 'losers':
        result = result.where((coin) => coin.priceChangePercentage24h < 0).toList();
        result.sort((a, b) => a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));
        break;
    }
    setState(() => _filteredCoins = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _applyFilters();
                },
                decoration: InputDecoration(
                  hintText: AppTranslations.translate('search'), // التصحيح هنا
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textTertiary),
                  filled: true,
                  fillColor: AppTheme.bgSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  String label = filter == 'all' ? 'الكل' : 
                                 filter == 'favorites' ? 'المفضلة' :
                                 filter == 'gainers' ? 'الأعلى ربحاً' : 'الأعلى خسارة';
                  
                  return FilterPill(
                    label: label,
                    isSelected: _selectedFilter == filter,
                    onTap: () {
                      setState(() => _selectedFilter = filter);
                      _applyFilters();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: NewsBanner(
                title: 'بيتكوين يتجاوز حاجز 70,000 دولار وسط تفاؤل المستثمرين',
                source: 'CryptoNews • منذ ساعة',
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGreen))
                  : _filteredCoins.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد نتائج',
                            style: TextStyle(color: AppTheme.textTertiary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredCoins.length,
                          itemBuilder: (context, index) {
                            return CoinListItem(
                              coin: _filteredCoins[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CoinDetailScreen(coin: _filteredCoins[index]),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}