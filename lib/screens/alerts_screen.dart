import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../services/database_service.dart';
import '../theme.dart';
import '../utils/app_translations.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<Alert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    _alerts = await DatabaseService.getAllAlerts();
    setState(() => _isLoading = false);
  }

  Future<void> _deleteAlert(String id) async {
    await DatabaseService.deleteAlert(id);
    _loadAlerts();
  }

  void _showAddAlertDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        title: const T('alerts', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('سيتم إضافة نموذج كامل لاحقاً لاختيار العملة ونوع التنبيه.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        title: const T('alerts'), // التصحيح هنا
        backgroundColor: AppTheme.bgPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAlertDialog,
        backgroundColor: AppTheme.accentGreen,
        child: const Icon(Icons.add, color: AppTheme.bgPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGreen))
          : _alerts.isEmpty
              ? Center(child: Text('لا توجد تنبيهات', style: TextStyle(color: AppTheme.textTertiary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _alerts.length,
                  itemBuilder: (context, index) {
                    final alert = _alerts[index];
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
                          Icon(
                            alert.type == AlertType.price ? Icons.attach_money : Icons.analytics,
                            color: AppTheme.accentGold,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${alert.coinSymbol} - ${alert.conditionText}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('الهدف: ${alert.targetValue}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed),
                            onPressed: () => _deleteAlert(alert.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}