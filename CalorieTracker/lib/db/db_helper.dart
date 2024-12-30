import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import '../models/yiyecek.dart';
import '../models/kullanici.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  static Database? _database;

  DBHelper._();

  factory DBHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }
//gerekli tabloların oluşturulması
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'kalori_takip.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE yiyecekler(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            isim TEXT,
            resim TEXT,
            kalori INTEGER,
            karbonhidrat INTEGER,
            protein INTEGER,
            yag INTEGER,
            birim TEXT,
            tarih TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE kullanicilar(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            isim TEXT,
            email TEXT,
            sifre TEXT,
            rol TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE gunluk_kalori(
            tarih TEXT PRIMARY KEY,
            kalori INTEGER
          )
        ''');
      },
    );
  }

  Future<void> gunlukYiyecekleriKaydet(DateTime date, List<Yiyecek> yiyecekler) async {
    final db = await database;

    await db.delete(
      'yiyecekler',
      where: 'tarih = ?',
      whereArgs: [DateFormat('yyyy-MM-dd').format(date)],
    );

    for (var yiyecek in yiyecekler) {
      await db.insert(
        'yiyecekler',
        {
          'isim': yiyecek.isim,
          'resim': yiyecek.resim,
          'kalori': yiyecek.kalori,
          'karbonhidrat': yiyecek.karbonhidrat,
          'protein': yiyecek.protein,
          'yag': yiyecek.yag,
          'birim': yiyecek.birim,
          'tarih': DateFormat('yyyy-MM-dd').format(date),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Yiyecek>> gunlukYiyecekleriGetir(DateTime date) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'yiyecekler',
      where: 'tarih = ?',
      whereArgs: [DateFormat('yyyy-MM-dd').format(date)],
    );

    return List.generate(maps.length, (i) {
      return Yiyecek(
        id: maps[i]['id'],
        isim: maps[i]['isim'],
        resim: maps[i]['resim'],
        kalori: maps[i]['kalori'],
        karbonhidrat: maps[i]['karbonhidrat'],
        protein: maps[i]['protein'],
        yag: maps[i]['yag'],
        birim: maps[i]['birim'],
        tarih: maps[i]['tarih'],
      );
    });
  }

  Future<void> kaydetGunlukKalori(DateTime date, int kalori) async {
    final db = await database;
    await db.insert(
      'gunluk_kalori',
      {
        'tarih': DateFormat('yyyy-MM-dd').format(date),
        'kalori': kalori,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> getirGunlukKalori(DateTime date) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'gunluk_kalori',
      where: 'tarih = ?',
      whereArgs: [DateFormat('yyyy-MM-dd').format(date)],
    );

    if (maps.isNotEmpty) {
      return maps.first['kalori'];
    } else {
      return null;
    }
  }

  Future<List<Yiyecek>> yiyecekleriGetir() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('yiyecekler');
    return List.generate(maps.length, (i) {
      return Yiyecek(
        id: maps[i]['id'],
        isim: maps[i]['isim'],
        resim: maps[i]['resim'],
        kalori: maps[i]['kalori'],
        karbonhidrat: maps[i]['karbonhidrat'],
        protein: maps[i]['protein'],
        yag: maps[i]['yag'],
        birim: maps[i]['birim'],
        tarih: maps[i]['tarih'],
      );
    });
  }

  Future<void> insertYiyecek(Yiyecek yiyecek) async {
    final db = await database;
    await db.insert('yiyecekler', yiyecek.toMap());
  }

  Future<void> yiyecekSil(int id) async {
    final db = await database;
    await db.delete(
      'yiyecekler',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertKullanici(Kullanici kullanici) async {
    final db = await database;
    await db.insert(
      'kullanicilar',
      kullanici.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Kullanici?> kullaniciGetir(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'kullanicilar',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return Kullanici.fromMap(maps.first);
    }
    return null;
  }
}
