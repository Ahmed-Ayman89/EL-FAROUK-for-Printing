import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

import '../models/invoice.dart';
import '../models/item.dart'; // مهم: استيراد موديل Item هنا

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade:
          _onUpgrade, // إضافة دالة الترقية للتعامل مع التغييرات المستقبلية
    );
  }

  // إضافة دالة الترقية (مهمة لو هتغير في جدول مستقبلاً)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // مثال: لو هتضيف عمود جديد في إصدار لاحق
    // if (oldVersion < 2) {
    //   await db.execute("ALTER TABLE invoices ADD COLUMN newColumn TEXT;");
    // }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE invoices(
        id TEXT PRIMARY KEY,
        dateTime TEXT,
        items TEXT, -- سيتم تخزين قائمة الـ Items كـ JSON String
        total REAL
      )
    ''');
  }

  Future<void> insertInvoice(Invoice invoice) async {
    final db = await database;
    await db.insert(
      'invoices',
      {
        'id': invoice.id,
        'dateTime': invoice.dateTime.toIso8601String(),
        'items':
            jsonEncode(invoice.items.map((item) => item.toJson()).toList()),
        'total': invoice.total,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Invoice>> getInvoices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('invoices', orderBy: 'dateTime DESC');

    return List.generate(maps.length, (i) {
      return Invoice(
        id: maps[i]['id'] as String,
        dateTime: DateTime.parse(maps[i]['dateTime'] as String),
        // هنا بيتم تحويل الـ JSON String لقائمة Item objects
        items: (jsonDecode(maps[i]['items'] as String) as List)
            .map((itemMap) => Item.fromJson(itemMap as Map<String, dynamic>))
            .toList(),
        total: maps[i]['total'] as double,
      );
    });
  }

  Future<void> clearAllInvoices() async {
    final db = await database;
    await db.delete('invoices');
  }
}
