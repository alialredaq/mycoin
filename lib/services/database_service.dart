import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/coin.dart';
import '../models/alert.dart';
import '../models/api_source.dart';

class DatabaseService {
  static Database? _database;

  // الحصول على نسخة من قاعدة البيانات
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // تهيئة قاعدة البيانات
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mycoin.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // إنشاء الجداول عند أول تشغيل
  static Future<void> _onCreate(Database db, int version) async {
    // جدول العملات
    await db.execute('''
      CREATE TABLE coins (
        id TEXT PRIMARY KEY,
        symbol TEXT NOT NULL,
        name TEXT NOT NULL,
        current_price REAL DEFAULT 0,
        price_change_percentage_24h REAL DEFAULT 0,
        market_cap REAL DEFAULT 0,
        total_volume REAL DEFAULT 0,
        high_24h REAL DEFAULT 0,
        low_24h REAL DEFAULT 0,
        image TEXT,
        is_favorite INTEGER DEFAULT 0,
        portfolio_amount REAL DEFAULT 0,
        last_updated TEXT
      )
    ''');

    // جدول التنبيهات
    await db.execute('''
      CREATE TABLE alerts (
        id TEXT PRIMARY KEY,
        coin_id TEXT NOT NULL,
        coin_symbol TEXT NOT NULL,
        type TEXT NOT NULL,
        indicator_name TEXT DEFAULT '',
        target_value REAL NOT NULL,
        condition TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (coin_id) REFERENCES coins(id)
      )
    ''');

    // جدول مصادر API
    await db.execute('''
      CREATE TABLE api_sources (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        provider TEXT NOT NULL,
        base_url TEXT NOT NULL,
        api_key TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // جدول الإعدادات
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // ===== عمليات العملات =====

  // إضافة أو تحديث عملة
  static Future<void> saveCoin(Coin coin) async {
    final db = await database;
    await db.insert(
      'coins',
      coin.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // إضافة قائمة عملات دفعة واحدة
  static Future<void> saveCoins(List<Coin> coins) async {
    final db = await database;
    final batch = db.batch();
    for (var coin in coins) {
      batch.insert(
        'coins',
        coin.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // جلب جميع العملات
  static Future<List<Coin>> getAllCoins() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('coins');
    return List.generate(maps.length, (i) {
      return Coin(
        id: maps[i]['id'],
        symbol: maps[i]['symbol'],
        name: maps[i]['name'],
        currentPrice: maps[i]['current_price'] ?? 0,
        priceChangePercentage24h: maps[i]['price_change_percentage_24h'] ?? 0,
        marketCap: maps[i]['market_cap'] ?? 0,
        totalVolume: maps[i]['total_volume'] ?? 0,
        high24h: maps[i]['high_24h'] ?? 0,
        low24h: maps[i]['low_24h'] ?? 0,
        imageUrl: maps[i]['image'],
        isFavorite: maps[i]['is_favorite'] == 1,
        portfolioAmount: maps[i]['portfolio_amount'] ?? 0,
      );
    });
  }

  // جلب العملات المفضلة فقط
  static Future<List<Coin>> getFavoriteCoins() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'coins',
      where: 'is_favorite = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) {
      return Coin(
        id: maps[i]['id'],
        symbol: maps[i]['symbol'],
        name: maps[i]['name'],
        currentPrice: maps[i]['current_price'] ?? 0,
        priceChangePercentage24h: maps[i]['price_change_percentage_24h'] ?? 0,
        marketCap: maps[i]['market_cap'] ?? 0,
        totalVolume: maps[i]['total_volume'] ?? 0,
        high24h: maps[i]['high_24h'] ?? 0,
        low24h: maps[i]['low_24h'] ?? 0,
        imageUrl: maps[i]['image'],
        isFavorite: true,
        portfolioAmount: maps[i]['portfolio_amount'] ?? 0,
      );
    });
  }

  // جلب عملة واحدة بالمعرف
  static Future<Coin?> getCoinById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'coins',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Coin(
      id: maps[0]['id'],
      symbol: maps[0]['symbol'],
      name: maps[0]['name'],
      currentPrice: maps[0]['current_price'] ?? 0,
      priceChangePercentage24h: maps[0]['price_change_percentage_24h'] ?? 0,
      marketCap: maps[0]['market_cap'] ?? 0,
      totalVolume: maps[0]['total_volume'] ?? 0,
      high24h: maps[0]['high_24h'] ?? 0,
      low24h: maps[0]['low_24h'] ?? 0,
      imageUrl: maps[0]['image'],
      isFavorite: maps[0]['is_favorite'] == 1,
      portfolioAmount: maps[0]['portfolio_amount'] ?? 0,
    );
  }

  // تحديث حالة المفضلة
  static Future<void> toggleFavorite(String coinId, bool isFavorite) async {
    final db = await database;
    await db.update(
      'coins',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [coinId],
    );
  }

  // تحديث السعر
  static Future<void> updateCoinPrice(String coinId, double price, double change24h) async {
    final db = await database;
    await db.update(
      'coins',
      {
        'current_price': price,
        'price_change_percentage_24h': change24h,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [coinId],
    );
  }

  // تحديث كمية المحفظة
  static Future<void> updatePortfolioAmount(String coinId, double amount) async {
    final db = await database;
    await db.update(
      'coins',
      {'portfolio_amount': amount},
      where: 'id = ?',
      whereArgs: [coinId],
    );
  }

  // حذف عملة
  static Future<void> deleteCoin(String coinId) async {
    final db = await database;
    await db.delete('coins', where: 'id = ?', whereArgs: [coinId]);
  }

  // ===== عمليات التنبيهات =====

  // إضافة تنبيه
  static Future<void> saveAlert(Alert alert) async {
    final db = await database;
    await db.insert(
      'alerts',
      alert.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // جلب جميع التنبيهات
  static Future<List<Alert>> getAllAlerts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('alerts');
    return List.generate(maps.length, (i) {
      return Alert.fromJson(maps[i]);
    });
  }

  // جلب تنبيهات عملة معينة
  static Future<List<Alert>> getAlertsByCoin(String coinId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'alerts',
      where: 'coin_id = ?',
      whereArgs: [coinId],
    );
    return List.generate(maps.length, (i) {
      return Alert.fromJson(maps[i]);
    });
  }

  // تفعيل/إيقاف تنبيه
  static Future<void> toggleAlert(String alertId, bool isActive) async {
    final db = await database;
    await db.update(
      'alerts',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [alertId],
    );
  }

  // حذف تنبيه
  static Future<void> deleteAlert(String alertId) async {
    final db = await database;
    await db.delete('alerts', where: 'id = ?', whereArgs: [alertId]);
  }

  // ===== عمليات الإعدادات =====

  // حفظ إعداد
  static Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // جلب إعداد
  static Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps[0]['value'];
  }

  // ===== عمليات عامة =====

  // حذف جميع البيانات
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('coins');
    await db.delete('alerts');
    await db.delete('settings');
  }

  // إغلاق قاعدة البيانات
  static Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}