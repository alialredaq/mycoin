import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coin.dart';
import '../utils/constants.dart';

class ApiService {
  static String _baseUrl = AppConstants.defaultApiBaseUrl;

  // تغيير رابط الـ API (إذا أراد المستخدم استخدام مصدر آخر)
  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  // جلب قائمة العملات من السوق
  static Future<List<Coin>> fetchCoins({
    int page = 1,
    int perPage = 50,
    String currency = 'usd',
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/coins/markets?vs_currency=$currency&order=market_cap_desc&per_page=$perPage&page=$page&sparkline=false&price_change_percentage=24h',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('انتهت مهلة الاتصال');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Coin.fromJson(json)).toList();
      } else {
        throw Exception('فشل في جلب البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // جلب تفاصيل عملة معينة
  static Future<Map<String, dynamic>?> fetchCoinDetails(String coinId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/coins/$coinId?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // جلب أسعار العملات المحددة (للتحديث السريع)
  static Future<List<Coin>> fetchCoinsByIds(List<String> ids) async {
    try {
      final idsString = ids.join(',');
      final url = Uri.parse(
        '$_baseUrl/coins/markets?vs_currency=usd&ids=$idsString&order=market_cap_desc&sparkline=false&price_change_percentage=24h',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Coin.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // البحث عن العملات
  static Future<List<Map<String, dynamic>>> searchCoins(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/search?query=$query');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['coins'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // جلب البيانات العالمية للسوق
  static Future<Map<String, dynamic>?> fetchGlobalData() async {
    try {
      final url = Uri.parse('$_baseUrl/global');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}