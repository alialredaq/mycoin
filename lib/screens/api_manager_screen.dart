import 'package:flutter/material.dart';
import '../models/api_source.dart';
import '../theme.dart';

class ApiManagerScreen extends StatefulWidget {
  const ApiManagerScreen({super.key});

  @override
  State<ApiManagerScreen> createState() => _ApiManagerScreenState();
}

class _ApiManagerScreenState extends State<ApiManagerScreen> {
  List<ApiSource> _sources = [
    ApiSource(id: '1', name: 'CoinGecko (Default)', provider: ApiProvider.coingecko, baseUrl: 'https://api.coingecko.com/api/v3'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        title: const Text('إدارة API'),
        backgroundColor: AppTheme.bgPrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sources.length,
        itemBuilder: (context, index) {
          final source = _sources[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
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
                      Text(source.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(source.baseUrl, style: TextStyle(color: AppTheme.textTertiary, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Switch(
                  value: source.isActive,
                  onChanged: (val) {
                    setState(() {
                      _sources[index] = ApiSource(
                        id: source.id, name: source.name, provider: source.provider,
                        baseUrl: source.baseUrl, apiKey: source.apiKey, isActive: val,
                      );
                    });
                  },
                  activeColor: AppTheme.accentGreen,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // نموذج إضافة مصدر جديد
        },
        backgroundColor: AppTheme.accentGreen,
        child: const Icon(Icons.add, color: AppTheme.bgPrimary),
      ),
    );
  }
}