import 'package:flutter/material.dart';
import '../models/coin.dart';
import '../services/database_service.dart';
import '../widgets/coin_list_item.dart';
import '../theme.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List<Coin> _portfolioCoins = [];
  bool _isLoading = true;
  double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    setState(() => _isLoading = true);
    List<Coin> coins = await DatabaseService.getAllCoins();
    _portfolioCoins = coins.where((c) => (c.portfolioAmount ?? 0) > 0).toList();
    
    _totalValue = _portfolioCoins.fold(0, (sum, coin) => sum + (coin.currentPrice * (coin.portfolioAmount ?? 0)));
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        title: const Text('محفظتي'),
        backgroundColor: AppTheme.bgPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGreen))
          : Column(
              children: [
                // ملخص المحفظة
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text('القيمة الإجمالية', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(
                        '\$${_totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_portfolioCoins.length} عملة',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // قائمة العملات
                Expanded(
                  child: _portfolioCoins.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppTheme.textTertiary),
                              const SizedBox(height: 16),
                              Text('محفظتك فارغة', style: TextStyle(color: AppTheme.textTertiary, fontSize: 16)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _portfolioCoins.length,
                          itemBuilder: (context, index) {
                            return CoinListItem(
                              coin: _portfolioCoins[index],
                              onTap: () {
                                // الانتقال لتفاصيل العملة
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}