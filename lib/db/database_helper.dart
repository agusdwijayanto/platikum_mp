import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('praktikum.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        // skema berubah -> bikin ulang tabel (data lama kehapus)
        await db.execute('DROP TABLE IF EXISTS users');
        await _createDB(db, newVersion);
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nim TEXT NOT NULL UNIQUE,
        nama TEXT NOT NULL,
        email TEXT NOT NULL,
        no_hp TEXT NOT NULL,
        jenis_kelamin TEXT,
        hobi TEXT,
        password TEXT NOT NULL
      )
    ''');
    // user bawaan: NIM 241011750001 / pass 241011750001
    await db.insert('users', {
      'nim': '241011750001',
      'nama': 'Agus Dwijayanto',
      'email': 'agus@example.com',
      'no_hp': '-',
      'jenis_kelamin': 'Laki-laki',
      'hobi': '-',
      'password': '241011750001',
    });
  }

  Future<Map<String, dynamic>?> login(String nim, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'nim = ? AND password = ?',
      whereArgs: [nim, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> register(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }
}
