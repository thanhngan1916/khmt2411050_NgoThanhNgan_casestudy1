import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('expense_manager.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE transactions_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT,
        date TEXT,
        note TEXT
      )
    ''');
  }

  Future<int> insertTransaction(
      Map<String, dynamic> data,
      ) async {
    final db = await instance.database;

    return await db.insert(
      'transactions_table',
      data,
    );
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await instance.database;

    return await db.query(
      'transactions_table',
      orderBy: 'id DESC',
    );
  }

  Future<Map<String, dynamic>?> getTransaction(
      int id,
      ) async {
    final db = await instance.database;

    final result = await db.query(
      'transactions_table',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<int> updateTransaction(
      int id,
      Map<String, dynamic> data,
      ) async {
    final db = await instance.database;

    return await db.update(
      'transactions_table',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(
      int id,
      ) async {
    final db = await instance.database;

    return await db.delete(
      'transactions_table',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<void> close() async {
    final db = await instance.database;

    await db.close();

    _database = null;
  }

// THÊM HÀM THỐNG KÊ Ở ĐÂY
  Future<Map<String, double>> getTransactionSummary() async {
    final db = await instance.database;

    final incomeResult = await db.rawQuery(
      '''
    SELECT COALESCE(SUM(amount), 0) AS total
    FROM transactions_table
    WHERE type = ?
    ''',
      ['income'],
    );

    final expenseResult = await db.rawQuery(
      '''
    SELECT COALESCE(SUM(amount), 0) AS total
    FROM transactions_table
    WHERE type = ?
    ''',
      ['expense'],
    );

    final income =
    (incomeResult.first['total'] as num).toDouble();

    final expense =
    (expenseResult.first['total'] as num).toDouble();

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }
}
