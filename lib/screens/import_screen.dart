import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/coin.dart';
import '../theme.dart';
import '../utils/app_translations.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final TextEditingController _pasteController = TextEditingController();
  final TextEditingController _manualSymbolController = TextEditingController();
  final TextEditingController _manualNameController = TextEditingController();
  bool _isImporting = false;

  Future<void> _importFromText() async {
    setState(() => _isImporting = true);
    String text = _pasteController.text.trim();
    if (text.isEmpty) {
      _showMessage('الرجاء إدخال رموز العملات');
      setState(() => _isImporting = false);
      return;
    }

    List<String> lines = text.split('\n');
    List<Coin> newCoins = [];
    
    for (String line in lines) {
      String symbol = line.trim().split(' ')[0].toUpperCase();
      if (symbol.isNotEmpty) {
        newCoins.add(Coin(
          id: symbol.toLowerCase(),
          symbol: symbol,
          name: symbol,
          currentPrice: 0,
        ));
      }
    }

    if (newCoins.isNotEmpty) {
      await DatabaseService.saveCoins(newCoins);
      _showMessage('تم استيراد ${newCoins.length} عملة بنجاح');
      _pasteController.clear();
    }
    setState(() => _isImporting = false);
  }

  Future<void> _addManualCoin() async {
    String symbol = _manualSymbolController.text.trim().toUpperCase();
    String name = _manualNameController.text.trim();
    
    if (symbol.isEmpty || name.isEmpty) {
      _showMessage('الرجاء إدخال الرمز والاسم');
      return;
    }

    Coin newCoin = Coin(
      id: symbol.toLowerCase(),
      symbol: symbol,
      name: name,
      currentPrice: 0,
    );

    await DatabaseService.saveCoin(newCoin);
    _showMessage('تمت إضافة $name بنجاح');
    _manualSymbolController.clear();
    _manualNameController.clear();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.accentGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        title: const T('import_coins'), // التصحيح هنا
        backgroundColor: AppTheme.bgPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('استيراد من قائمة (رمز في كل سطر)', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _pasteController,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: 'BTC\nETH\nBNB...',
              filled: true,
              fillColor: AppTheme.bgSecondary,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isImporting ? null : _importFromText,
              child: _isImporting ? const CircularProgressIndicator() : const Text('استيراد القائمة'),
            ),
          ),
          const Divider(height: 32, color: AppTheme.bgTertiary),
          const Text('إضافة يدوية', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _manualSymbolController,
            decoration: InputDecoration(
              hintText: 'الرمز (مثل BTC)',
              filled: true,
              fillColor: AppTheme.bgSecondary,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _manualNameController,
            decoration: InputDecoration(
              hintText: 'الاسم الكامل (مثل Bitcoin)',
              filled: true,
              fillColor: AppTheme.bgSecondary,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _addManualCoin,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentGreen,
                side: const BorderSide(color: AppTheme.accentGreen),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('إضافة العملة'),
            ),
          ),
        ],
      ),
    );
  }
}