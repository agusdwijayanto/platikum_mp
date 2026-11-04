import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';



class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = p.join(await getDatabasesPath(), 'akademik.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE mahasiswa (
            nim TEXT PRIMARY KEY,
            nama TEXT NOT NULL,
            email TEXT NOT NULL,
            jurusan TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');
      },
    );
  }
  Future<bool> register(Mahasiswa m) async {
    final db = await database;
    try {
      await db.insert('mahasiswa', m.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.abort;
    } on DatabaseException{
      return false;
    }
  }
}

class Mahasiswa {
  final String nim;
  final String nama;
  final String email;
  final String jurusan;
  final String password;

  Mahasiswa({
    required this.nim,
    required this.nama,
    required this.email,
    required this.jurusan,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'nim': nim,
      'nama': nama,
      'email': email,
      'jurusan': jurusan,
      'password': password,
    };
  }
}